-- Для получения не занятой ячейки выдачи
Select top 1 l.Location
		  From Warehouse.Location l left join  [Sales].[ShippingContainer] sc on sc.Location=l.Location
		  where l.Location like 'DockDoor%'
		  and sc.Location is null

CREATE NONCLUSTERED INDEX [IX_LocationSc_20240602] ON [Sales].[ShippingContainer]
(
	[Location] ASC
)



-- запрос отображает Какой менеджер сколько сделал заказов на какое количество штук и количество SKU ,в разрезе определенного периода времени.
-- для данного запроса мождно сделать такой индекс, но так как сейчас табицы с небольшим количество данных от такого инждекса толку мало,
CREATE NONCLUSTERED INDEX [IX_SHD_DateCreate_20240603] ON [Sales].ShipmentHeader
(
	DateTimeCreate ASC
)

CREATE NONCLUSTERED INDEX [IX_SD_ISN_20240603] ON [Sales].ShipmentDetail
(
	InternalShipmentNum ASC
)


Select up.Description,count(distinct sd.InternalShipmentLineNum) [Количество строк] ,sum(cast(sd.TotalQty as int)) [Количество шт всего] ,sum(cast(sd.QuantityOriginal as int)) [Изначальное количество шт]
                     ,sum(cast(sd.TotalQty*Price as int))  [Стоимсоть]
From Sales.ShipmentHeader sh join Application.UserProfile up on up.ObjectId=sh.UserId
                             join Sales.ShipmentDetail sd on sd.InternalShipmentNum=sh.InternalShipmentNum
where sh.DateTimeCreate between '2024-06-02' and '2024-06-03'

Group by up.Description