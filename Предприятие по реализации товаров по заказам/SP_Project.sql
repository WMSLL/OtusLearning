


--1. Найти фамилию и телефон клиента, оформившего заказ с заданным номером.Create Procedure SP_SearchCustomerInfoForOrdersNum @InternalShipmentNum int =37asSelect c.FullName,PhoneNumFrom Sales.ShipmentHeader sh join Sales.Customers c on c.ObjectId=sh.CustomerIdwhere InternalShipmentNum=@InternalShipmentNumgo--2. Составить список товаров, количество которых на складе меньше заданной величины.Create Procedure SP_ItemListForQuantityLessSpecifiedValue @QTY numeric(19,5)=55asSelect i.item,i.Description, sum(quantity) quantityFrom Warehouse.LocationInventory li join Warehouse.Items i on i.ItemId=li.ItemIdGroup by i.item,i.Descriptionhaving sum(quantity)<@QTY--3. Найти заказы, оформленные заданным сотрудником.goCreate Procedure SP_SearchCustomerInfoForOrdersNum @Employee int=2asSelect sh.InternalShipmentNum,sh.OrderState,sh.CustomerId,up.UserName,up.DescriptionFrom Sales.ShipmentHeader sh join [ProjectShop].[Application].[UserProfile] up on up.ObjectId=sh.UserIdwhere UserId=@Employeego --4. Найти заказы, стоимость на которые не выше заданной величины.


Create Procedure SP_OrdersForPriceLessSpecifiedValue @CostOrders numeric(19,5)=222.00000

as

Select  sh.InternalShipmentNumFrom Sales.ShipmentHeader sh join Sales.ShipmentDetail sd on sd.InternalShipmentNum=sh.InternalShipmentNumgroup by sh.InternalShipmentNum
having sum(TotalQty*Price)<=@CostOrders

