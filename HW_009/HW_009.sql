/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

-- OPENXML
DECLARE @xmlDocument xml,@handle INT ,@PrepareXmlStatus INT ,@StockItemName NVARCHAR(150),@StockItemID int,@UnitPackageID int,@OuterPackageID int,@QuantityPerOuter int,@TypicalWeightPerUnit numeric(19,3)
,@LeadTimeDays int,@IsChillerStock int,@TaxRate numeric(19,3),@UnitPrice numeric(19,6),@SupplierID int
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET(BULK 'E:\Otus\Reposetory\OtusLearning\HW_009\StockItems.xml', SINGLE_CLOB) as data
Drop table if exists  #items

EXEC @PrepareXmlStatus= sp_xml_preparedocument @handle OUTPUT, @xmlDocument  

SELECT  *
into #items
FROM    OPENXML(@handle, '/StockItems/Item/Package', 2)  
    WITH (
	StockItemName NVARCHAR(150) '../@Name',
	StockItemID int '../StockItemID',
	SupplierID int '../SupplierID',
	UnitPackageID int '../Package/UnitPackageID',
    OuterPackageID int '../Package/OuterPackageID' ,
	QuantityPerOuter int '../Package/QuantityPerOuter',
	TypicalWeightPerUnit numeric(19,3) '../Package/TypicalWeightPerUnit',
    LeadTimeDays int '../LeadTimeDays',
	IsChillerStock int '../IsChillerStock',
	TaxRate numeric(19,3) '../TaxRate',
	UnitPrice numeric(19,6) '../UnitPrice'
    )  
EXEC sp_xml_removedocument @handle 


Declare updatestockItems cursor for
Select  SupplierID,StockItemName		,UnitPackageID	,OuterPackageID	,QuantityPerOuter	,TypicalWeightPerUnit	,LeadTimeDays	,IsChillerStock	,TaxRate	,UnitPrice
From #items
open updatestockItems
     while 1=1 
	   Begin   
	       fetch next FROM  updatestockItems into  @SupplierID,@StockItemName		,@UnitPackageID	,@OuterPackageID	,@QuantityPerOuter	,@TypicalWeightPerUnit	,@LeadTimeDays	,@IsChillerStock	,@TaxRate	,@UnitPrice
		       if @@FETCH_STATUS!=0
		          begin 
		               break;
		          end

				  update Warehouse.StockItems set StockItemName=@StockItemName,	UnitPackageID=@UnitPackageID,	OuterPackageID=@OuterPackageID,	QuantityPerOuter=@QuantityPerOuter,	TypicalWeightPerUnit=@TypicalWeightPerUnit
				  ,	LeadTimeDays=@LeadTimeDays,	IsChillerStock=@IsChillerStock,	TaxRate=@TaxRate,	UnitPrice=@UnitPrice
				     where StockItemName=@StockItemName
					 if @@ROWCOUNT=0
					 begin
					  insert into Warehouse.StockItems ( LastEditedBy,
					                                                 SupplierID,StockItemName		,UnitPackageID	,OuterPackageID	,QuantityPerOuter	,TypicalWeightPerUnit	,LeadTimeDays	,IsChillerStock	,TaxRate	,UnitPrice)
					   Select 1,
					            @SupplierID,@StockItemName		,@UnitPackageID	,@OuterPackageID	,@QuantityPerOuter	,@TypicalWeightPerUnit	,@LeadTimeDays	,@IsChillerStock	,@TaxRate	,@UnitPrice

					   Select @StockItemName
					 end
       end
close updatestockItems
deallocate updatestockItems



-- XQuery 

Drop table if exists  #items2

  DECLARE @xmlDocument2 xml,@handle2 INT ,@PrepareXmlStatus2 INT ,@StockItemName2 NVARCHAR(150),@StockItemID2 int,@UnitPackageID2 int,@OuterPackageID2 int,@QuantityPerOuter2 int,@TypicalWeightPerUnit2 numeric(19,3)
,@LeadTimeDays2 int,@IsChillerStock2 int,@TaxRate2 numeric(19,3),@UnitPrice2 numeric(19,6),@SupplierID2 int

  SELECT @xmlDocument2 = BulkColumn  FROM OPENROWSET(BULK 'E:\Otus\Reposetory\OtusLearning\HW_009\StockItems.xml', SINGLE_CLOB) as data   
  --Select @xmlDocument2
   select distinct tr.value('(@Name)','NVARCHAR(150)') [StockItemName]
        ,tr.value('(SupplierID[1])','int') [SupplierID]
		,tr.value('(Package[1]/UnitPackageID[1])','int') UnitPackageID
		,tr.value('(Package[1]/OuterPackageID[1])','int') OuterPackageID
		,tr.value('(Package[1]/QuantityPerOuter[1])','int') QuantityPerOuter
		,tr.value('(Package[1]/TypicalWeightPerUnit[1])','numeric(19,3)') TypicalWeightPerUnit
		,tr.value('(LeadTimeDays[1])','int') LeadTimeDays
		,tr.value('(IsChillerStock[1])','int') IsChillerStock
		,tr.value('(TaxRate[1])','numeric(19,3)') TaxRate
		,tr.value('(UnitPrice[1])','numeric(19,6)') UnitPrice
		into #items2
  FROM   @xmlDocument2.nodes('/StockItems/Item') A(tr) 
  
  
  
Declare updatestockItems cursor for
Select  SupplierID,StockItemName		,UnitPackageID	,OuterPackageID	,QuantityPerOuter	,TypicalWeightPerUnit	,LeadTimeDays	,IsChillerStock	,TaxRate	,UnitPrice
From #items2
open updatestockItems
     while 1=1 
	   Begin   
	       fetch next FROM  updatestockItems into  @SupplierID2,@StockItemName2		,@UnitPackageID2	,@OuterPackageID2	,@QuantityPerOuter2	,@TypicalWeightPerUnit2	,@LeadTimeDays2	,@IsChillerStock2	,@TaxRate2
		   ,@UnitPrice2
		       if @@FETCH_STATUS!=0
		          begin 
		               break;
		          end

				  update Warehouse.StockItems set StockItemName=@StockItemName2,	UnitPackageID=@UnitPackageID2,	OuterPackageID=@OuterPackageID2,	QuantityPerOuter=@QuantityPerOuter2,
				  TypicalWeightPerUnit=@TypicalWeightPerUnit2
				  ,	LeadTimeDays=@LeadTimeDays2,	IsChillerStock=@IsChillerStock2,	TaxRate=@TaxRate2,	UnitPrice=@UnitPrice2
				     where StockItemName=@StockItemName2
					 if @@ROWCOUNT=0
					 begin
					  insert into Warehouse.StockItems ( LastEditedBy,
					                                                 SupplierID,StockItemName		,UnitPackageID	,OuterPackageID	,QuantityPerOuter	,TypicalWeightPerUnit	,LeadTimeDays	,IsChillerStock	,TaxRate	,UnitPrice)
					   Select 1,
					             @SupplierID2,@StockItemName2		,@UnitPackageID2	,@OuterPackageID2	,@QuantityPerOuter2	,@TypicalWeightPerUnit2	,@LeadTimeDays2	,@IsChillerStock2	,@TaxRate2
		   ,@UnitPrice2

					   Select @StockItemName2
					 end
       end
close updatestockItems
deallocate updatestockItems



/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

Select StockItemName [@Name]
       ,SupplierID           [SupplierID]      		
	   ,UnitPackageID	     [Package/UnitPackageID]
	   ,OuterPackageID	     [Package/OuterPackageID]
	   ,QuantityPerOuter     [Package/QuantityPerOuter]	
	   ,TypicalWeightPerUnit [Package/TypicalWeightPerUnit]	
	   ,LeadTimeDays	     [LeadTimeDays]
	   ,IsChillerStock	     [IsChillerStock]
	   ,TaxRate	             [TaxRate]
	   ,UnitPrice            [UnitPrice]
From Warehouse.StockItems
for XML path('Item'),root('StockItems') ,elements;


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

Select StockItemID,StockItemName,JSON_VALUE(CustomFields ,'$.CountryOfManufacture') CountryOfManufacture
,JSON_VALUE(CustomFields ,'$.Tags[0]') FirstTag
From Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


Select StockItemID,StockItemName,CustomFields,ss.*,JSON_QUERY(CustomFields,'$.Tags')
From Warehouse.StockItems
 Cross apply openJSON(CustomFields,'$.Tags') ss
 where ss.value='Vintage'

