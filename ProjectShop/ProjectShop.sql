
begin tran

Declare @CountOrders int=5,@valuesIterationHeader int =0, @OrderState int =600

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