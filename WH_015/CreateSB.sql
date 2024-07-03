USE [WideWorldImporters];



--Service Broker включен ли?
select name, is_broker_enabled
from sys.databases;

--Включить брокер
USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE; --NO WAIT --prod (в однопользовательском режиме!!! На проде так не нужно)

--БД должна функционировать от имени технической учетки!!!
ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];

--Включите это чтобы доверять сервисам без использования сертификатов когда работаем между различными 
--БД и инстансами(фактически говорим серверу, что этой БД можно доверять)
--Если мы открепим БД и вновь ее прикрепим, то это свойство сбросится в OFF
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

--Создаем типы сообщений
USE WideWorldImporters
-- For Request
CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML; --служит исключительно для проверки, что данные соответствуют типу XML(но можно любой тип)
-- For Reply
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; --служит исключительно для проверки, что данные соответствуют типу XML(но можно любой тип) 

--Создаем контракт(определяем какие сообщения в рамках этого контракта допустимы)
CREATE CONTRACT [//WWI/SB/Contract]
      ([//WWI/SB/RequestMessage]
         SENT BY INITIATOR,
       [//WWI/SB/ReplyMessage]
         SENT BY TARGET
      );

--Создаем ОЧЕРЕДЬ таргета(настрим позже т.к. через ALTER можно ею рулить еще
CREATE QUEUE TargetQueueWWI;
--и сервис таргета
CREATE SERVICE [//WWI/SB/TargetService]
       ON QUEUE TargetQueueWWI
       ([//WWI/SB/Contract]);

--то же для ИНИЦИАТОРА
CREATE QUEUE InitiatorQueueWWI;

CREATE SERVICE [//WWI/SB/InitiatorService]
       ON QUEUE InitiatorQueueWWI
       ([//WWI/SB/Contract]);

--Создаем процедуры в скрипте CreateProcedure
--1. SendNewInvoice.sql - процедура которая вызывается в процессе какого-то техпроцесса - НЕ АКТИВАЦИОННАЯ для очередей
--2. GetNewInvoice.sql - АКТИВАЦИОННАЯ процедура(всегда без параметров)
--3. ConfirmInvoice.sql - АКТИВАЦИОННАЯ процедура - обработка сообщения что все прошло хорошо

--тепер настроим ОЧЕРЕДЬ или так можем рулить прецессами связанными с очередями
USE [WideWorldImporters]
GO
--пока с MAX_QUEUE_READERS = 0 чтобы вручную вызвать процедуры и увидеть все своими глазами 
ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON --OFF=очередь НЕ доступна(ставим если глобальные проблемы)
                                          ,RETENTION = OFF --ON=все завершенные сообщения хранятся в очереди до окончания диалога
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=после 5 ошибок очередь будет отключена
	                                      ,ACTIVATION (STATUS = ON --OFF=очередь не активирует ХП(в PROCEDURE_NAME)(ставим на время исправления ХП, но с потерей сообщений)  
										              ,PROCEDURE_NAME = Sales.ConfirmInvoice
													  ,MAX_QUEUE_READERS = 1 --количество потоков(ХП одновременно вызванных) при обработке сообщений(0-32767)
													                         --(0=тоже не позовется процедура)(ставим на время исправления ХП, без потери сообщений) 
													  ,EXECUTE AS OWNER --учетка от имени которой запустится ХП
													  ) 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = ON 
									               ,PROCEDURE_NAME = Sales.GetNewInvoice
												   ,MAX_QUEUE_READERS = 1
												   ,EXECUTE AS OWNER 
												   ) 

GO


