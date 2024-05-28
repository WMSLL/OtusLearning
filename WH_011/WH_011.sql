
-- Создаем БД  "Предприятие по реализации товаров по заказам"
/*
Предприятие реализует товары по заказам. Предприятие располагает складом, на котором
хранятся товары. Для получения товара клиент оформляет заказ. Для пополнения товаров
на складе предприятие заключает договоры с поставщиками. Заказы формируются из
товаров, имеющихся на складе. Клиент может оформить заказ на несколько товаров.
Формированием заказа занимается один сотрудник.
*/

Create DataBase ProjectShop

Go
use ProjectShop
go
-- Создаем Схемы
Create Schema [Warehouse]
Go
 Create Schema [Purchase]
 Go
 Create schema [Sales]
 go
 Create Schema [Application]

 Go


 -- создаем  Таблицу заголовков заказов
CREATE TABLE ProjectShop.Sales.[ShipmentHeader] (
  [InternalShipmentNum] int identity PRIMARY KEY,
  [CustomerId] int  not null,
  [DateTimeCreate] datetime   not null,
  [OrderState] numeric(3)  not null,
  [UserName] nvarchar(25) 
)
GO
-- создаем  Таблицу Деталей заказов
CREATE TABLE ProjectShop.Sales.[ShipmentDetail] (
  [InternalShipmentLineNum] int identity PRIMARY KEY,
  [InternalShipmentNum] int not null,
  [item] nvarchar(25) not null,
  [TotalQty] numeric(19,5) ,
  [QuantityOriginal] numeric(19,5) ,
  [Price] numeric(19,5) 
)
GO
-- создаем  Таблицу Контейнеров  заказов
CREATE TABLE ProjectShop.Sales.[ShippingContainer] (
  [InternalContainerNum] int identity PRIMARY KEY,
  [InternalShipmentLineNum] int not null,
  [InternalShipmentNum] int not null,
  [item] nvarchar(25) not null,
  [Quantity] numeric(19,5),
  [Location] nvarchar(25) not null
)
GO


-- создаем  Таблицу Заголовков приемки 
CREATE TABLE ProjectShop.Purchase.[ReceiptHeader] (
  [InternaltReceiptNum] int identity PRIMARY KEY,
  [SourceId] int not null,
  [CloseDate] dateTime,
  [DateTimeCreate] datetime not null
)
GO
-- создаем  Таблицу Деталей приемки 
CREATE TABLE ProjectShop.Purchase.[ReceiptDetail] (
  [InternalReceiptLineNum] int identity PRIMARY KEY,
  [InternaltReceiptNum] int not null,
  [item] nvarchar(25) not null,
  [totalQty] numeric(19,5),
  [OpentQty] numeric(19,5)
)
GO
-- создаем  Таблицу Контейнров приемки 
CREATE TABLE ProjectShop.Purchase.[ReceiptContainer] (
  [InternalReceiptContainer] int identity PRIMARY KEY,
  [InternalReceiptLineNum] int not null,
  [InternaltReceiptNum] int not null,
  [item] nvarchar(25) not null,
  [Quantity] numeric(19,5),
  [TO_Location] nvarchar(25)
)
GO
-- создаем  Таблицу Ячеек 
CREATE TABLE ProjectShop.[Warehouse].[Location] (
  [ObjectId] int identity ,
  [Location] nvarchar(25) PRIMARY KEY
)
GO
-- создаем  Таблицу Ячеек хранения товара
CREATE TABLE ProjectShop.[Warehouse].[LocationInventory] (
  [internalInvNum] int identity PRIMARY KEY,
  [Location] nvarchar(25) not null,
  [item] nvarchar(25) not null,
)
GO
-- создаем  Таблицу  товара
CREATE TABLE ProjectShop.[Warehouse].[Items] (
  [id] int identity  PRIMARY KEY,
  [item] nvarchar(25) UNIQUE  ,
  [Description] nvarchar(50)
)
GO


-- создаем  Таблицу  поставщиков товара
CREATE TABLE ProjectShop.Purchase.SupplierCategories (
  [ObjectId] int PRIMARY KEY,
  [FullName] nvarchar(50) not null,
  Category nvarchar(25)
)
GO

-- создаем  Таблицу  заказчиков
CREATE TABLE ProjectShop.Sales.Customers (
  [ObjectId] int PRIMARY KEY,
  [FullName] nvarchar(50) not null,
  Category nvarchar(25)
)
GO
-- Создаем таблицу пользователей(Сотрудников)
CREATE TABLE ProjectShop.[Application].[UserProfile] (
  [ObjectId] int ,
  [UserName] nvarchar(25) PRIMARY KEY, 
  [Description] nvarchar(100),
  [GroupId] int
)
GO
-- Создаем таблицу Групп безобасности сотруждников
CREATE TABLE ProjectShop.[Application].[SecurityGroup] (
  [GroupId] int PRIMARY KEY,
  [Description] nvarchar(25)
)
GO
 -- создание индексов
Create Index [SC_Internal_shipmentNum] on Sales.[ShippingContainer] ([InternalShipmentNum],[InternalShipmentLineNum])

go

Create Index [UP_UserName] on .[Application].[UserProfile] ([UserName])

go

-- Создаени внешних ключей 
ALTER TABLE [Sales].[ShipmentDetail] ADD FOREIGN KEY ([InternalShipmentNum]) REFERENCES Sales.[ShipmentHeader] ([InternalShipmentNum])
GO

ALTER TABLE [Sales].[ShippingContainer] ADD FOREIGN KEY ([InternalShipmentNum]) REFERENCES [Sales].[ShipmentHeader] ([InternalShipmentNum])
GO

ALTER TABLE [Sales].[ShippingContainer] ADD FOREIGN KEY ([InternalShipmentLineNum]) REFERENCES [Sales].[ShipmentDetail] ([InternalShipmentLineNum])
GO

ALTER TABLE [Sales].[ShipmentDetail] ADD FOREIGN KEY ([item]) REFERENCES [Warehouse].[Items] ([item])
GO

ALTER TABLE [Sales].[ShippingContainer] ADD FOREIGN KEY ([item]) REFERENCES [Warehouse].[Items] ([item])
GO

ALTER TABLE Purchase.[ReceiptDetail] ADD FOREIGN KEY ([item]) REFERENCES [Warehouse].[Items] ([item])
GO

ALTER TABLE Purchase.[ReceiptContainer] ADD FOREIGN KEY ([item]) REFERENCES [Warehouse].[Items] ([item])
GO

ALTER TABLE Purchase.[ReceiptDetail] ADD FOREIGN KEY ([InternaltReceiptNum]) REFERENCES Purchase.[ReceiptHeader] ([InternaltReceiptNum])
GO

ALTER TABLE Purchase.[ReceiptContainer] ADD FOREIGN KEY ([InternaltReceiptNum]) REFERENCES Purchase.[ReceiptHeader] ([InternaltReceiptNum])
GO

ALTER TABLE Purchase.[ReceiptContainer] ADD FOREIGN KEY ([InternalReceiptLineNum]) REFERENCES Purchase.[ReceiptDetail] ([InternalReceiptLineNum])
GO

ALTER TABLE [Warehouse].[LocationInventory] ADD FOREIGN KEY ([item]) REFERENCES [Warehouse].[Items] ([item])
GO

ALTER TABLE [Warehouse].[LocationInventory] ADD FOREIGN KEY ([Location]) REFERENCES [Warehouse].[Location] ([Location])
GO

ALTER TABLE Sales.[ShipmentHeader] ADD FOREIGN KEY ([CustomerId]) REFERENCES [Sales].Customers ([ObjectId])
GO

ALTER TABLE Purchase.[ReceiptHeader] ADD FOREIGN KEY ([SourceId]) REFERENCES Purchase.SupplierCategories ([ObjectId])
GO

ALTER TABLE [Sales].[ShipmentHeader] ADD FOREIGN KEY ([UserName]) REFERENCES [Application].[UserProfile] ([UserName])
GO

ALTER TABLE ProjectShop.[Application].[UserProfile] ADD FOREIGN KEY ([GroupId]) REFERENCES [Application].[SecurityGroup] ([GroupId])
GO


