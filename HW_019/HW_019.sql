ALTER DATABASE ProjectShop ADD FILEGROUP DateTimes
GO
ALTER DATABASE ProjectShop 
	ADD FILE (NAME = N'FileGroup', FILENAME = N'E:\Otus\Reposetory\OtusLearning\HW_019\DateTimes.ndf') 
	TO FILEGROUP DateTimes
go

CREATE PARTITION FUNCTION [FN_partition](datetime) AS RANGE LEFT FOR VALUES ('2020-01-01', '2020-01-02', '2020-01-03')


CREATE PARTITION SCHEME [S_partition] AS PARTITION [FN_partition] TO ([DateTimes])


ALTER TABLE [Sales].[ShipmentDetail] DROP CONSTRAINT [FK__ShipmentD__Inter__5165187F]


ALTER TABLE [Sales].[ShippingContainer] DROP CONSTRAINT [FK__ShippingC__Inter__52593CB8]






ALTER TABLE [Sales].[ShipmentHeader] DROP CONSTRAINT [PK__Shipment__BC035B666D3EDF29] WITH ( ONLINE = OFF )


ALTER TABLE [Sales].[ShipmentHeader] ADD PRIMARY KEY NONCLUSTERED 
(
	[InternalShipmentNum] ASC
) ON [PRIMARY]


CREATE CLUSTERED INDEX [ClusteredIndex_on_S_partition_638633716818646737] ON [Sales].[ShipmentHeader]
(
	[DateTimeCreate]
) ON [S_partition]([DateTimeCreate])


DROP INDEX [ClusteredIndex_on_S_partition_638633716818646737] ON [Sales].[ShipmentHeader]




ALTER TABLE [Sales].[ShipmentDetail]  WITH CHECK ADD FOREIGN KEY([InternalShipmentNum])
REFERENCES [Sales].[ShipmentHeader] ([InternalShipmentNum])


ALTER TABLE [Sales].[ShippingContainer]  WITH CHECK ADD FOREIGN KEY([InternalShipmentNum])
REFERENCES [Sales].[ShipmentHeader] ([InternalShipmentNum])








