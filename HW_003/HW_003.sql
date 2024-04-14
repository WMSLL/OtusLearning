




/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
Select YEAR(InvoiceDate) [Год продажи],month(InvoiceDate) [Месяц продажи],avg(ol.UnitPrice) avg_Price,sum(Quantity*UnitPrice) sum_sales
From Sales.Invoices i  join Sales.OrderLines ol on ol.OrderID=i.OrderID
Group by YEAR(InvoiceDate) ,month(InvoiceDate) 
Order by YEAR(InvoiceDate) ,month(InvoiceDate) 

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

Select YEAR(InvoiceDate) [Год продажи],month(InvoiceDate) [Месяц продажи],sum(Quantity*UnitPrice) sum_sales
From Sales.Invoices i  join Sales.OrderLines ol on ol.OrderID=i.OrderID
Group by YEAR(InvoiceDate) ,month(InvoiceDate) 
having sum(Quantity*UnitPrice)>4600000
Order by YEAR(InvoiceDate) ,month(InvoiceDate) 

--if OBJECT_ID('tempdb..#Month')!=0 drop table #Month

--SELECT Value  [Месяц]
--into #Month
--FROM STRING_SPLIT(N'Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь',',')

--Select m.Месяц,isnull([Сумма Продаж],0)[Сумма Продаж]
--From #Month m left join (Select format(o.OrderDate,'MMMM','rU-rU') [Месяц], sum(ol.Quantity*UnitPrice)[Сумма Продаж]
--                                From Sales.Orders o   join Sales.OrderLines ol on ol.OrderID=o.OrderID
--                                Group by  format(o.OrderDate,'MMMM','rU-rU'),month(o.OrderDate)
--                                having sum(ol.Quantity*UnitPrice)>4600000
                                
--                         ) SaleSum on SaleSum.Месяц=m.Месяц



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

