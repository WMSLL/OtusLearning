USE [ProjectShop]
GO
/****** Object:  StoredProcedure [dbo].[PS_RPT_401_001_GoodsSoldSuppliersForSelectedPeriod]    Script Date: 07.07.2024 13:43:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Procedure [dbo].[PS_RPT_401_001_GoodsSoldSuppliersForSelectedPeriod] @DT_str datetime ='20240602',@DT_end datetime='20240602'

as

Select c.FullName [Заказчик],format(sh.DateTimeCreate, 'dd MMMM yyyy', 'ru-RU') [дата],count(distinct sh.InternalShipmentNum) [Кол-во заказов],count(distinct sd.InternalShipmentLineNum) [Кол-во Строк]
                         ,sum(cast(sd.QuantityOriginal as int)) [Кол-во заказано],sum(cast(sd.TotalQty as int))[Кол-во собрано]
From Sales.ShipmentHeader sh join Sales.Customers c on c.ObjectId=sh.CustomerId 
                             left join Sales.ShipmentDetail sd on sd.InternalShipmentNum=sh.InternalShipmentNum
where sh.DateTimeCreate between @DT_str and dateadd(dd,+1,@DT_end)
Group by  c.FullName,datename(M ,sh.DateTimeCreate),format(sh.DateTimeCreate, 'dd MMMM yyyy', 'ru-RU')