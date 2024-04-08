

--Все товары, в названии которых есть "urgent" или название начинается с "Animal".

Select*
From Warehouse.StockItems
where StockItemName like '%urgent%' or  stockItemName like 'Animal%'

--Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).

Select s.*
From Purchasing.Suppliers s left join Purchasing.PurchaseOrders po on po.SupplierID=s.SupplierID
where po.PurchaseOrderID is null

--Заказы (Orders) с ценой товара (UnitPrice) более 100$ либо количеством единиц (Quantity) товара более 20 штуки присутствующей датой комплектации всего заказа (PickingCompletedWhen).

Select *
From Sales.Orders o join [Sales].[OrderLines] ol on ol.OrderID=o.OrderID
where (ol.UnitPrice >100 or ol.Quantity>20) and ol.PickingCompletedWhen is not null


--Заказы поставщикам (Purchasing.Suppliers), которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName) и которые исполнены (IsOrderFinalized).

Select *
From [Purchasing].[PurchaseOrders] po join  Purchasing.Suppliers s on s.SupplierID=po.SupplierID
                                      join [Application].[DeliveryMethods] dm on dm.DeliveryMethodID=po.DeliveryMethodID
where ExpectedDeliveryDate between '20130101' and '20230131'
and DeliveryMethodName in ('Air Freight','Refrigerated Air Freight')
and IsOrderFinalized=1


--Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника, который оформил заказ (SalespersonPerson). Сделать без подзапросов.

Select top 10  OrderID,pcont.[CustomerName] [Client],pSale.FullName [Salesperson]


From Sales.Orders o left join [Application].[People] pSale on pSale.PersonID=o.SalespersonPersonID
                    left join [Sales].[Customers] pcont on pcont.CustomerID=o.CustomerID
order by ExpectedDeliveryDate desc
 

 --Все ид и имена клиентов и их контактные телефоны, которые покупали товар "Chocolate frogs 250g".

 Select o.OrderID,pcont.CustomerID,pcont.[CustomerName]  ,pcont.PhoneNumber
 From Sales.Orders o join Sales.OrderLines ol on ol.OrderID=o.OrderID
                      join [Sales].[Customers] pcont on pcont.CustomerID=o.CustomerID
 where Description=N'Chocolate frogs 250g'