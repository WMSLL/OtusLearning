ALTER DATABASE ProjectShop ADD FILEGROUP DateTimes
GO
ALTER DATABASE ProjectShop 
	ADD FILE (NAME = N'FileGroup', FILENAME = N'E:\Otus\Reposetory\OtusLearning\HW_019\DateTimes.ndf') 
	TO FILEGROUP DateTimes
go
-- обычно при секционировании таблиц все индексы стараются выровнять по схеме (добавить поле по которому секционировали + разместить с привязкой к функции/схеме секционирования). сможете доработать?
CREATE PARTITION FUNCTION [FN_partition](datetime) AS RANGE RIGHT FOR VALUES ('2020-01-01','2021-01-01','2022-01-01')


CREATE PARTITION SCHEME [S_partition] AS PARTITION [FN_partition]  ALL TO ([DateTimes])


ALTER TABLE [Sales].[ShipmentDetail] DROP CONSTRAINT [FK__ShipmentD__Inter__5165187F]


ALTER TABLE [Sales].[ShippingContainer] DROP CONSTRAINT [FK__ShippingC__Inter__52593CB8]






ALTER TABLE [Sales].[ShipmentHeader] DROP CONSTRAINT [PK__Shipment__BC035B666D3EDF29] WITH ( ONLINE = OFF )


ALTER TABLE [Sales].[ShipmentHeader] ADD PRIMARY KEY NONCLUSTERED 
(
	[InternalShipmentNum] ASC
) ON [PRIMARY]


CREATE CLUSTERED INDEX [ClusteredIndex_on_S_partition_638633716818646737] ON [Sales].[ShipmentHeader]
(
	[DateTimeCreate],[InternalShipmentNum]
) ON [S_partition]([DateTimeCreate])


DROP INDEX [ClusteredIndex_on_S_partition_638633716818646737] ON [Sales].[ShipmentHeader]




ALTER TABLE [Sales].[ShipmentDetail]  WITH CHECK ADD FOREIGN KEY([InternalShipmentNum])
REFERENCES [Sales].[ShipmentHeader] ([InternalShipmentNum])


ALTER TABLE [Sales].[ShippingContainer]  WITH CHECK ADD FOREIGN KEY([InternalShipmentNum])
REFERENCES [Sales].[ShipmentHeader] ([InternalShipmentNum])








