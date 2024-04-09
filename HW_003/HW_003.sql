




--Опционально:
--Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
--то этот месяц также отображался бы в результатах, но там были нули.

--Посчитать среднюю цену товара, общую сумму продажи по месяцам.

Select  ol.StockItemID,avg(UnitPrice) AVG_UnitPrice,sum(UnitPrice*Quantity) sum_sale,format(o.OrderDate,'MMMM','rU-rU') [Месяц]
From Sales.OrderLines ol join Sales.Orders o on o.OrderID=ol.OrderID
Group by ol.StockItemID,format(o.OrderDate,'MMMM','rU-rU'), month(o.OrderDate)
order by month(o.OrderDate),ol.StockItemID
--Отобразить все месяцы, где общая сумма продаж превысила 4 600 000.

if OBJECT_ID('tempdb..#Month')!=0 drop table #Month

SELECT Value  [Месяц]
into #Month
FROM STRING_SPLIT(N'Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь',',')

Select m.Месяц,isnull([Сумма Продаж],0)[Сумма Продаж]
From #Month m left join (Select format(o.OrderDate,'MMMM','rU-rU') [Месяц], sum(ol.Quantity*UnitPrice)[Сумма Продаж]
                                From Sales.Orders o   join Sales.OrderLines ol on ol.OrderID=o.OrderID
                                Group by  format(o.OrderDate,'MMMM','rU-rU'),month(o.OrderDate)
                                having sum(ol.Quantity*UnitPrice)>4600000
                                
                         ) SaleSum on SaleSum.Месяц=m.Месяц



--Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц. Группировка должна быть по году, месяцу, товару.

if OBJECT_ID('tempdb..#Month2')!=0 drop table #Month2
if OBJECT_ID('tempdb..#Sale')!=0 drop table #Sale
SELECT Value  [Месяц]
into #Month2
FROM STRING_SPLIT(N'Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь',',')


Select  ol.StockItemID,sum(ol.Quantity*UnitPrice)[Сумма Продаж],min(o.OrderDate) [дата первой Продажи],format(o.OrderDate,'MMMM','rU-rU') [Месяц],year(o.OrderDate) [Год]
into #Sale
From Sales.Orders o join Sales.OrderLines ol on ol.OrderID=o.OrderID
Group by format(o.OrderDate,'MMMM','rU-rU'),year(o.OrderDate),ol.StockItemID
having sum(ol.Quantity)<50

Select m.Месяц,StockItemID StockItemID,isnull([Сумма Продаж],0)[Сумма Продаж],isnull([дата первой Продажи],'')[дата первой Продажи],isnull([Год],'')[Год]
From #Month2 m left join #Sale s on s.[Месяц]=m.Месяц

