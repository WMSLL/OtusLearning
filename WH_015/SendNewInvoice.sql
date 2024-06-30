-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--  Sales.SendNewInvoice '2016-05-31','2016-05-31'
-- =============================================

Alter PROCEDURE Sales.SendNewInvoice
	@strDate datetime='2016-05-31' , @endDate datetime='2016-05-31'
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(max);
	--declare @strDate datetime='2016-05-31' , @endDate datetime='2016-05-31'
	BEGIN TRAN --на всякий случай в транзакции, т.к. это еще не относится к транзакции ПЕРЕДАЧИ сообщения

	--Формируем XML с корнем RequestMessage где передадим номер инвойса(в принципе сообщение может быть любым)
	SELECT @RequestMessage = (
                              sELECT count(distinct InvoiceID) countid, CustomerName
                              fROM Sales.Invoices s join Sales.Customers cc on cc.CustomerID=s.CustomerID
                              WHERE InvoiceDate between @strDate and  @endDate --and cc.CustomerName=N'Tailspin Toys (Jessie, ND)'
                              Group by  cc.CustomerName
                              FOR XML AUTO, root('RequestMessage')); 
	
	
	--Создаем диалог
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService] --от этого сервиса(это сервис текущей БД, поэтому он НЕ строка)
	TO SERVICE
	'//WWI/SB/TargetService'    --к этому сервису(это сервис который может быть где-то, поэтому строка)
	ON CONTRACT
	[//WWI/SB/Contract]         --в рамках этого контракта
	WITH ENCRYPTION=OFF;        --не шифрованный

	--отправляем одно наше подготовленное сообщение, но можно отправить и много сообщений, которые будут обрабатываться строго последовательно)
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	
	--Это для визуализации - на проде это не нужно
	SELECT @RequestMessage AS SentRequestMessage;
	
	COMMIT TRAN 
END
GO
