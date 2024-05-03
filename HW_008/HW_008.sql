/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/


INSERT INTO [Purchasing].[Suppliers] ( [SupplierName] , [SupplierCategoryID] , [PrimaryContactPersonID] , [AlternateContactPersonID] , [DeliveryCityID] , [PostalCityID] , [SupplierReference] , [BankAccountName] , [BankAccountBranch] , [BankAccountCode] , [BankAccountNumber] , [BankInternationalCode] , [PaymentDays] , [InternalComments] , [PhoneNumber] , [FaxNumber] , [WebsiteURL] , [DeliveryAddressLine1] , [DeliveryAddressLine2] , [DeliveryPostalCode] , [DeliveryLocation] , [PostalAddressLine1] , [PostalAddressLine2] , [PostalPostalCode] , [LastEditedBy]
                                     )
VALUES ( N'Рога и копыта' , 9 , 45 , 46 , 30378 , 30378 , 028034202 , N'Woodgrove Bank' , N'Woodgrove Bank San Francisco' , 325698 , 2147825698 , 65893 , 7 , N'Only speak to Donald if Hubert really is not available' , N'(415) 555-0103' , N'(415) 555-0107' , N'http://www.woodgrovebank.com' , 'Level 3' , '8488 Vienna Boulevard' , '94101' , 'POINT(-95.46684547613926 30.152422380193446)' , N'PO Box 2390' , N'Canterbury' , '94101' , 1
       ) , ( N'ИП Иванов И.И' , 9 , 45 , 46 , 30378 , 30378 , 028034202 , N'Woodgrove Bank' , N'Woodgrove Bank San Francisco' , 325698 , 2147825698 , 65893 , 7 , N'Only speak to Donald if Hubert really is not available' , N'(415) 555-0103' , N'(415) 555-0107' , N'http://www.woodgrovebank.com' , 'Level 3' , '8488 Vienna Boulevard' , '94101' , 'POINT(-95.46684547613926 30.152422380193446)' , N'PO Box 2390' , N'Canterbury' , '94101' , 1
           ) , ( N'ИП Карасев К.К' , 9 , 45 , 46 , 30378 , 30378 , 028034202 , N'Woodgrove Bank' , N'Woodgrove Bank San Francisco' , 325698 , 2147825698 , 65893 , 7 , N'Only speak to Donald if Hubert really is not available' , N'(415) 555-0103' , N'(415) 555-0107' , N'http://www.woodgrovebank.com' , 'Level 3' , '8488 Vienna Boulevard' , '94101' , 'POINT(-95.46684547613926 30.152422380193446)' , N'PO Box 2390' , N'Canterbury' , '94101' , 1
               ) , ( N'ИП Петров П.П' , 9 , 45 , 46 , 30378 , 30378 , 028034202 , N'Woodgrove Bank' , N'Woodgrove Bank San Francisco' , 325698 , 2147825698 , 65893 , 7 , N'Only speak to Donald if Hubert really is not available' , N'(415) 555-0103' , N'(415) 555-0107' , N'http://www.woodgrovebank.com' , 'Level 3' , '8488 Vienna Boulevard' , '94101' , 'POINT(-95.46684547613926 30.152422380193446)' , N'PO Box 2390' , N'Canterbury' , '94101' , 1
                   ) , ( N'ИП Шерстобитов Ш.Ш' , 9 , 45 , 46 , 30378 , 30378 , 028034202 , N'Woodgrove Bank' , N'Woodgrove Bank San Francisco' , 325698 , 2147825698 , 65893 , 7 , N'Only speak to Donald if Hubert really is not available' , N'(415) 555-0103' , N'(415) 555-0107' , N'http://www.woodgrovebank.com' , 'Level 3' , '8488 Vienna Boulevard' , '94101' , 'POINT(-95.46684547613926 30.152422380193446)' , N'PO Box 2390' , N'Canterbury' , '94101' , 1
                        )

						


/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/
with table2 as (
Select  top 5 *
From [Purchasing].[Suppliers]
order by SupplierID desc
)
delete top (1)
From table2

/*
3. Изменить одну запись, из добавленных через UPDATE
*/


update s set PhoneNumber='+7(499) 777-7777',FaxNumber='+7(499) 333-7474'
From [Purchasing].[Suppliers] s
where SupplierID=28

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/
DROP TABLE IF EXISTS [Purchasing].[Suppliers_copy];
Select*
into [Purchasing].[Suppliers_copy]
From [Purchasing].[Suppliers]
 delete top (2)
From [Purchasing].[Suppliers_copy]
where SupplierID>=28
MERGE [Purchasing].[Suppliers_copy] AS T_Base --Целевая таблица
        USING [Purchasing].[Suppliers] AS T_Source --Таблица источник
        ON (T_Base.SupplierID = T_Source.SupplierID) --Условие объединения
        WHEN MATCHED THEN --Если истина (UPDATE)
                 UPDATE SET BankAccountName = T_Source.BankAccountName, BankAccountcode = T_Source.BankAccountcode
        WHEN NOT MATCHED THEN --Если НЕ истина (INSERT)
                 INSERT (SupplierID,[SupplierName] , [SupplierCategoryID] , [PrimaryContactPersonID] , [AlternateContactPersonID] , [DeliveryCityID] , [PostalCityID] , [SupplierReference] , [BankAccountName] , [BankAccountBranch] , [BankAccountCode] , [BankAccountNumber] , [BankInternationalCode] , [PaymentDays] , [InternalComments] , [PhoneNumber] , [FaxNumber] , [WebsiteURL] , [DeliveryAddressLine1] , [DeliveryAddressLine2] , [DeliveryPostalCode] , [DeliveryLocation] , [PostalAddressLine1] , [PostalAddressLine2] , [PostalPostalCode] , [LastEditedBy]
                                     ,ValidFrom,ValidTo) 
                 VALUES (
		    T_Source.SupplierID
		   ,T_Source.[SupplierName]
           ,T_Source.[SupplierCategoryID]
           ,T_Source.[PrimaryContactPersonID]
           ,T_Source.[AlternateContactPersonID]           
           ,T_Source.[DeliveryCityID]
           ,T_Source.[PostalCityID]
           ,T_Source.[SupplierReference]
           ,T_Source.[BankAccountName]
           ,T_Source.[BankAccountBranch]
           ,T_Source.[BankAccountCode]
           ,T_Source.[BankAccountNumber]
           ,T_Source.[BankInternationalCode]
           ,T_Source.[PaymentDays]
           ,T_Source.[InternalComments]
           ,T_Source.[PhoneNumber]
           ,T_Source.[FaxNumber]
           ,T_Source.[WebsiteURL]
           ,T_Source.[DeliveryAddressLine1]
           ,T_Source.[DeliveryAddressLine2]
           ,T_Source.[DeliveryPostalCode]
           ,T_Source.[DeliveryLocation]
           ,T_Source.[PostalAddressLine1]
           ,T_Source.[PostalAddressLine2]
           ,T_Source.[PostalPostalCode]
           ,T_Source.[LastEditedBy]
		   ,T_Source.ValidFrom
		   ,T_Source.ValidTo)
output $action [Операция]
,
            inserted.SupplierID as SupplierID_new
		   ,inserted.[SupplierName] [SupplierName_new]
           ,inserted.[SupplierCategoryID] [SupplierCategoryID_new]
           ,inserted.[PrimaryContactPersonID] [PrimaryContactPersonID_new]
           ,inserted.[AlternateContactPersonID]    [AlternateContactPersonID_new]        
           ,inserted.[DeliveryCityID] [DeliveryCityID_new]
           ,inserted.[PostalCityID] [PostalCityID_new]
           ,inserted.[SupplierReference] [SupplierReference_new]
           ,inserted.[BankAccountName] [BankAccountName_new]
           ,inserted.[BankAccountBranch] [BankAccountBranch_new]
           ,inserted.[BankAccountCode] [BankAccountCode_new]
           ,inserted.[BankAccountNumber] [BankAccountNumber_new]
           ,inserted.[BankInternationalCode] [BankInternationalCode_new]
           ,inserted.[PaymentDays] [PaymentDays_new]
           ,inserted.[InternalComments] [InternalComments_new]
           ,inserted.[PhoneNumber] [PhoneNumber_new]
           ,inserted.[FaxNumber] [FaxNumber_new]
           ,inserted.[WebsiteURL] [WebsiteURL_new]
           ,inserted.[DeliveryAddressLine1] [DeliveryAddressLine1_new]
           ,inserted.[DeliveryAddressLine2] [DeliveryAddressLine2_new]
           ,inserted.[DeliveryPostalCode] [DeliveryPostalCode_new]
           ,inserted.[DeliveryLocation] [DeliveryLocation_new]
           ,inserted.[PostalAddressLine1] [PostalAddressLine1_new]
           ,inserted.[PostalAddressLine2] [PostalAddressLine2_new]
           ,inserted.[PostalPostalCode] [PostalPostalCode_new]
           ,inserted.[LastEditedBy] [LastEditedBy_new]
		   ,inserted.ValidFrom ValidFrom_new
		   ,inserted.ValidTo  ValidTo_new
		   ,'  '
		   ,Deleted.SupplierID as SupplierID_old
		   ,Deleted.[SupplierName] [SupplierName_old]
           ,Deleted.[SupplierCategoryID] [SupplierCategoryID_old]
           ,Deleted.[PrimaryContactPersonID] [PrimaryContactPersonID_old]
           ,Deleted.[AlternateContactPersonID]    [AlternateContactPersonID_old]        
           ,Deleted.[DeliveryCityID] [DeliveryCityID_old]
           ,Deleted.[PostalCityID] [PostalCityID_old]
           ,Deleted.[SupplierReference] [SupplierReference_old]
           ,Deleted.[BankAccountName] [BankAccountName_old]
           ,Deleted.[BankAccountBranch] [BankAccountBranch_old]
           ,Deleted.[BankAccountCode] [BankAccountCode_old]
           ,Deleted.[BankAccountNumber] [BankAccountNumber_old]
           ,Deleted.[BankInternationalCode] [BankInternationalCode_old]
           ,Deleted.[PaymentDays] [PaymentDays_old]
           ,Deleted.[InternalComments] [InternalComments_old]
           ,Deleted.[PhoneNumber] [PhoneNumber_old]
           ,Deleted.[FaxNumber] [FaxNumber_old]
           ,Deleted.[WebsiteURL] [WebsiteURL_old]
           ,Deleted.[DeliveryAddressLine1] [DeliveryAddressLine1_old]
           ,Deleted.[DeliveryAddressLine2] [DeliveryAddressLine2_old]
           ,Deleted.[DeliveryPostalCode] [DeliveryPostalCode_old]
           ,Deleted.[DeliveryLocation] [DeliveryLocation_old]
           ,Deleted.[PostalAddressLine1] [PostalAddressLine1_old]
           ,Deleted.[PostalAddressLine2] [PostalAddressLine2_old]
           ,Deleted.[PostalPostalCode] [PostalPostalCode_old]
           ,Deleted.[LastEditedBy] [LastEditedBy_old]
		   ,Deleted.ValidFrom ValidFrom_old
		   ,Deleted.ValidTo  ValidTo_old;
		

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bcp in
*/


DECLARE @out varchar(250);
set @out = 'bcp WideWorldImporters.[Purchasing].[Suppliers] OUT "C:\BCP\demo.txt" -T -S ' + @@SERVERNAME + ' -c';
PRINT @out;

EXEC master..xp_cmdshell @out

DROP TABLE IF EXISTS WideWorldImporters.[Purchasing].[Suppliers_copy];
SELECT * INTO WideWorldImporters.[Purchasing].[Suppliers_copy] FROM WideWorldImporters.[Purchasing].[Suppliers]
WHERE 1 = 2; 


DECLARE @in varchar(250);
set @in = 'bcp WideWorldImporters.[Purchasing].[Suppliers_copy] IN "C:\BCP\demo.txt" -T -S ' + @@SERVERNAME + ' -c';

EXEC master..xp_cmdshell @in;

SELECT *
FROM WideWorldImporters.[Purchasing].[Suppliers_copy]