CREATE TABLE [ShipmentHeader] (
  [InternalShipmentNum] int PRIMARY KEY,
  [CustomerId] int,
  [DateTimeCreate] datetime,
  [OrderState] numeric(3),
  [ManagerId] int
)
GO

CREATE TABLE [ShipmentDetail] (
  [InternalShipmentLineNum] int PRIMARY KEY,
  [InternalShipmentNum] int,
  [ItemId] int,
  [TotalQty] numeric(19,5),
  [QuantityOriginal] numeric(19,5),
  [Price] numeric(19,5)
)
GO

CREATE TABLE [ShippingContainer] (
  [InternalContainerNum] pk PRIMARY KEY,
  [InternalShipmentLineNum] int,
  [InternalShipmentNum] int,
  [ItemId] int,
  [Quantity] numeric(19,5)
)
GO

CREATE TABLE [ReceiptHeader] (
  [InternaltReceiptNum] int PRIMARY KEY,
  [SourceId] int,
  [CloseDate] dateTime,
  [DateTimeCreate] datetime
)
GO

CREATE TABLE [ReceiptDetail] (
  [InternalReceiptLineNum] int PRIMARY KEY,
  [InternaltReceiptNum] int,
  [ItemId] int,
  [totalQty] numeric(19,5),
  [OpentQty] numeric(19,5)
)
GO

CREATE TABLE [ReceiptContainer] (
  [InternalReceiptContainer] int PRIMARY KEY,
  [InternalReceiptLineNum] int,
  [InternaltReceiptNum] int,
  [ItemId] int,
  [Quantity] numeric(19,5)
)
GO

CREATE TABLE [Items] (
  [ItemId] int PRIMARY KEY,
  [Description] nvarchar(50)
)
GO

CREATE TABLE [Location] (
  [ObjectId] int PRIMARY KEY,
  [Location] nvarchar(25)
)
GO

CREATE TABLE [LocationInventory] (
  [internalInvNum] int PRIMARY KEY,
  [Location] nvarchar(25),
  [ItemId] int
)
GO

CREATE TABLE [CounterParty] (
  [ObjectId] int PRIMARY KEY,
  [FullName] nvarchar(50),
  [Type] nvarchar(25)
)
GO

CREATE TABLE [UserProfile] (
  [UserId] int PRIMARY KEY,
  [Description] nvarchar(100),
  [GroupId] int
)
GO

CREATE TABLE [SecurityGroup] (
  [GroupId] int PRIMARY KEY,
  [Description] nvarchar(25)
)
GO

ALTER TABLE [ShipmentDetail] ADD FOREIGN KEY ([InternalShipmentNum]) REFERENCES [ShipmentHeader] ([InternalShipmentNum])
GO

ALTER TABLE [ShippingContainer] ADD FOREIGN KEY ([InternalShipmentNum]) REFERENCES [ShipmentHeader] ([InternalShipmentNum])
GO

ALTER TABLE [ShippingContainer] ADD FOREIGN KEY ([InternalShipmentLineNum]) REFERENCES [ShipmentDetail] ([InternalShipmentLineNum])
GO

ALTER TABLE [ShipmentDetail] ADD FOREIGN KEY ([ItemId]) REFERENCES [Items] ([ItemId])
GO

ALTER TABLE [ShippingContainer] ADD FOREIGN KEY ([ItemId]) REFERENCES [Items] ([ItemId])
GO

ALTER TABLE [ReceiptDetail] ADD FOREIGN KEY ([ItemId]) REFERENCES [Items] ([ItemId])
GO

ALTER TABLE [ReceiptContainer] ADD FOREIGN KEY ([ItemId]) REFERENCES [Items] ([ItemId])
GO

ALTER TABLE [ReceiptDetail] ADD FOREIGN KEY ([InternaltReceiptNum]) REFERENCES [ReceiptHeader] ([InternaltReceiptNum])
GO

ALTER TABLE [ReceiptContainer] ADD FOREIGN KEY ([InternaltReceiptNum]) REFERENCES [ReceiptHeader] ([InternaltReceiptNum])
GO

ALTER TABLE [ReceiptContainer] ADD FOREIGN KEY ([InternalReceiptLineNum]) REFERENCES [ReceiptDetail] ([InternalReceiptLineNum])
GO

ALTER TABLE [LocationInventory] ADD FOREIGN KEY ([ItemId]) REFERENCES [Items] ([ItemId])
GO

ALTER TABLE [LocationInventory] ADD FOREIGN KEY ([Location]) REFERENCES [Location] ([Location])
GO

ALTER TABLE [ShipmentHeader] ADD FOREIGN KEY ([CustomerId]) REFERENCES [CounterParty] ([ObjectId])
GO

ALTER TABLE [ReceiptHeader] ADD FOREIGN KEY ([SourceId]) REFERENCES [CounterParty] ([ObjectId])
GO

ALTER TABLE [ShipmentHeader] ADD FOREIGN KEY ([ManagerId]) REFERENCES [UserProfile] ([UserId])
GO

ALTER TABLE [UserProfile] ADD FOREIGN KEY ([GroupId]) REFERENCES [SecurityGroup] ([GroupId])
GO
