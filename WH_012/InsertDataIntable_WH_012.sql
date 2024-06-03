

-- добавляем пользователей
  insert into [Application].[UserProfile] ([UserName],[Description])
  values(N'Ivanov.ii',N'Иванов Иван Иванович'),
  (N'Sidorob.SS',N'Сидоров Сидор Сидорович'),
  (N'Petrov.PP',N'Путров Петр Петрович')

  -- добавляем поставщиков
  INSERT INTO [Sales].[Customers]
           ([FullName]
           ,[Category])
     VALUES
           (N'ООО "Рога и Копыта"',N'Импортер'),
		   (N'ООО "Максимус',N'Дистрибьютор'),
		   (N'ООО "Трубный завод им.Тарасенко',N'Производитель')



		-- добавляем товар    
INSERT INTO [Warehouse].[Items]
           ([item]
           ,[Description])
     VALUES
           (N'TZ0000001',N'Труба 100х6000 мм'),
		   (N'TZ0000002',N'Труба 50х6000 мм'),
		   (N'TZ0000003',N'Труба 200х6000 мм'),
		   (N'TZ0000004',N'Труба 15000х6000 мм'),
		   (N'TZ0000005',N'Труба профильная 40х40х3000 мм'),
		   (N'TZ0000006',N'Труба профильная 20х40х3000 мм'),
		   (N'TZ0000007',N'Труба профильная 20х20х3000 мм'),
		   (N'TZ0000008',N'Труба профильная 60х60х3000 мм')

-- добавляем ячейки

INSERT INTO [Warehouse].[Location]
           ([Location])
     VALUES
           (N'001-01'),
		   (N'001-02'),
		   (N'001-03'),
		   (N'001-04'),
		   (N'001-05'),
		   (N'001-06'),
		   (N'001-07'),
		   (N'001-08'),
		   ('DockDoor-1'),
		   ('DockDoor-2'),
		   ('DockDoor-3')

-- добавдяем товар на ячейки 
INSERT INTO [Warehouse].[LocationInventory]
           ([LocationID]
           ,[ItemId]
		   ,[quantity])
     VALUES
           (1,8,8),
		   (2,7,40),
		   (3,6,23),
		   (4,5,12),
		   (5,4,6),
		   (6,3,6),
		   (7,2,12),
		   (8,1,6)		   

-- добавляем заказы


begin tran

Declare @CountOrders int=2,@valuesIterationHeader int =0, @OrderState int =100

while  @valuesIterationHeader<@CountOrders

begin

     Declare @CustomerId int= ABS(CHECKSUM(NEWID()) % 3) + (Select min(ObjectId) From  [Sales].[Customers])
     Declare @UserId int = ABS(CHECKSUM(NEWID()) % 3) + (Select min(ObjectId) From Application.UserProfile)
     
     Declare @countDetailInOrders int = ABS(CHECKSUM(NEWID()) % 8)+1
     Declare @NewInternalShipmentNum int,@valuesIterationDetail int=0

	

    INSERT INTO [Sales].[ShipmentHeader]
               ([CustomerId]
               ,[DateTimeCreate]
               ,[OrderState]
               ,[UserId])
         VALUES
               (@CustomerId
               ,Getdate()
               ,@OrderState
               ,@UserId)
    
set @NewInternalShipmentNum = SCOPE_IDENTITY()

while  @valuesIterationDetail<@countDetailInOrders
    begin
        Declare @ItemId int = ABS(CHECKSUM(NEWID()) % 8) + (Select min(ItemId) From Warehouse.Items)
        Declare @quantity int =ABS(CHECKSUM(NEWID()) % 50) +1
        Declare @price int =ABS(CHECKSUM(NEWID()) % 50) +100
        
        while exists(Select*From [Sales].[ShipmentDetail] where InternalShipmentNum=@NewInternalShipmentNum and ItemId=@ItemId ) and @valuesIterationDetail<@countDetailInOrders
        begin
              set @ItemId  = ABS(CHECKSUM(NEWID()) % 8) + (Select min(ItemId) From Warehouse.Items)
        end
        INSERT INTO [Sales].[ShipmentDetail]
           ([InternalShipmentNum]
           ,[ItemId]
           ,[TotalQty]
           ,[QuantityOriginal]
           ,[Price])
         VALUES
           (@NewInternalShipmentNum
           ,@ItemId
           ,@quantity
           ,@quantity
           ,@price)

Declare  @NewInternalShipmentLineNum int = SCOPE_IDENTITY()

 if @OrderState>=300

 begin
 Declare @NewInternalContainerNum int
 -- Записываем заголовок контейнера
 if not exists(Select 1 From  [Sales].[ShippingContainer] where InternalShipmentNum=@NewInternalShipmentNum)
           begin
          
          INSERT INTO [Sales].[ShippingContainer]
                     ([InternalShipmentLineNum]
                     ,[InternalShipmentNum]
                     ,[container_id]
                     ,[parent]
                     ,[ItemId]
                     ,[Quantity]
                     ,[Location])
               VALUES
                     (NULL
                     ,@NewInternalShipmentNum
                     ,NULL
                     ,NULL
                     ,NULL
                     ,0
                     ,NULL)
 set @NewInternalContainerNum =SCOPE_IDENTITY()
                            update sc set container_id='SHIP00'+cast(@NewInternalContainerNum as nvarchar)
                                      From [Sales].[ShippingContainer] sc where InternalContainerNum=@NewInternalContainerNum

Declare @dockDoor nvarchar(25)
                                Select top 1 @dockDoor=l.Location
                                		  From Warehouse.Location l left join  [Sales].[ShippingContainer] sc on sc.Location=l.Location
                                		  where l.Location like 'DockDoor%'
                                		  and sc.Location is null
                                         end

		  
  INSERT INTO [Sales].[ShippingContainer]
                     ([InternalShipmentLineNum]
                     ,[InternalShipmentNum]
                     ,[container_id]
                     ,[parent]
                     ,[ItemId]
                     ,[Quantity]
                     ,[Location])
               VALUES
                     (@NewInternalShipmentLineNum
                     ,@NewInternalShipmentNum
                     ,NULL
                     ,@NewInternalContainerNum
                     ,@ItemId
                     ,@quantity
                     ,@dockDoor)


end


    set @valuesIterationDetail+=1
end

		   set @valuesIterationHeader+=1
		   

end

Select*
From Sales.ShipmentHeader


Select*
From Sales.ShipmentDetail

Select*
From [Sales].[ShippingContainer]

Commit tran


  