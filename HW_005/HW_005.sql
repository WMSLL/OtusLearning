/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
-- set statistics time, io OFF
set statistics time, io on
if object_id('tempdb..#SumSum')!=0 drop table #SumSum

Select sum(summ) summ ,Year_InvoiceDate,MONTH_InvoiceDate,InvoiceDate,InvoiceLineID
into #SumSum
From 
                     (Select sum(UnitPrice*Quantity) summ ,YEAR(i2.InvoiceDate) Year_InvoiceDate,MONTH(i2.InvoiceDate) MONTH_InvoiceDate ,InvoiceDate,il2.InvoiceLineID
					          From Sales.Invoices i2 join  Sales.InvoiceLines il2 on il2.InvoiceID=i2.InvoiceID 
                                   Group by YEAR(i2.InvoiceDate) ,MONTH(i2.InvoiceDate),InvoiceDate,il2.InvoiceLineID )s
								   Group by  Year_InvoiceDate,MONTH_InvoiceDate,InvoiceDate,InvoiceLineID

Select i.InvoiceID [id продажи],c.CustomerName [название клиента],InvoiceDate [дата продажи],

(Select sum(summ) From #SumSum s where s.MONTH_InvoiceDate=MONTH(i.InvoiceDate) and YEAR(i.InvoiceDate)=Year_InvoiceDate  ) [сумму продажи]
 ,

(Select sum(summ) From #SumSum s where MONTH(i.InvoiceDate)=s.MONTH_InvoiceDate and Year_InvoiceDate=YEAR(i.InvoiceDate)  and s.InvoiceLineID<=il.InvoiceLineID   )  [сумму нарастающим итогом]

From Sales.Invoices i join Sales.InvoiceLines il on il.InvoiceID=i.InvoiceID
join Sales.Customers c on c.CustomerID=i.CustomerID
where i.InvoiceDate>='2015-01-01' 

order by InvoiceDate,i.InvoiceID


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
--39071
Select i.InvoiceID [id продажи],c.CustomerName [название клиента],InvoiceDate [дата продажи],
sum(UnitPrice*Quantity) over(partition by YEAR(InvoiceDate),MONTH(InvoiceDate) ) [сумму продажи],
sum(UnitPrice*Quantity) over (partition by YEAR(InvoiceDate),MONTH(InvoiceDate)  order by InvoiceDate,i.InvoiceID  rows between unbounded preceding and current row ) [сумму нарастающим итогом]
From Sales.Invoices i join Sales.InvoiceLines il on il.InvoiceID=i.InvoiceID
                      join Sales.Customers c on c.CustomerID=i.CustomerID
where i.InvoiceDate>='2015-01-01' 
order by InvoiceDate,i.InvoiceID
set statistics time, io  off

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/


SELECT StockItemID,Description,InvoiceDate,qty
FROM (
SELECT StockItemID,il.Description, SUM(Quantity) qty, datename(MONTH,InvoiceDate) InvoiceDate, 
       ROW_NUMBER() OVER (partition by datename(MONTH,InvoiceDate) ORDER BY SUM(Quantity) DESC) rowNum
FROM Sales.Invoices i join Sales.InvoiceLines il on il.InvoiceID=i.InvoiceID
WHERE i.InvoiceDate>='2016-01-01' and i.InvoiceDate<'2017-01-01'
GROUP BY StockItemID,il.Description,datename(MONTH,InvoiceDate) 
)  s
WHERE s.rowNum <=2
order by InvoiceDate,qty desc,StockItemID



/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):

* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"

* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

Select i.StockItemID [ид товара],i.StockItemName [название], N'Не пойму откуда взять' as [брэнд], i.UnitPrice [цена],
ROW_NUMBER () over (Partition by left(i.StockItemName,1) order by StockItemID) as [Номер записи по названию товара], -- [* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново]
count(*)  over (Partition by 1) [общее количество товаров], --[* посчитайте общее количество товаров и выведете полем в этом же запросе]
count(*)  over (Partition by left(i.StockItemName,1)) as [общее количество товаров по первой букве], --[* посчитайте общее количество товаров в зависимости от первой буквы названия товара]
lead(StockItemID) over (Order by StockItemID) [отобразиnm следующий id товара] , --[* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени ]
lag(StockItemID) over (Order by StockItemID) [отобразиnm предыдущий id товара],  --[* предыдущий ид товара с тем же порядком отображения (по имени)]
isnull(lag(StockItemName,2) over (Order by StockItemID),N'No items') [названия товара 2 строки наза "No items"],  --[* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"]
ntile(30) over (partition by TypicalWeightPerUnit order by StockItemID) [30 групп товаров]--[* сформируйте 30 групп товаров по полю вес товара на 1 шт]
From Warehouse.StockItems i
order by left(i.StockItemName,1),[Номер записи по названию товара],[отобразиnm следующий id товара]

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
; with employees as (
Select i.SalespersonPersonID,p.FullName,c.CustomerID,CustomerName,
ROW_NUMBER() OVER (partition by SalespersonPersonID  ORDER BY InvoiceDate DESC) row_num,InvoiceDate
From Sales.Invoices i join Sales.Customers c on c.CustomerID=i.CustomerID
                      join  Application.People p on p.PersonID=i.SalespersonPersonID)

Select*
From employees e 
where row_num in (Select max(row_num)
From employees ee 
where e.SalespersonPersonID=ee.SalespersonPersonID
Group by SalespersonPersonID)

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/


--top 2 WITH TIES 

Select s.*
From (
Select  i.CustomerID,c.CustomerName,il.StockItemID,il.UnitPrice,STRING_AGG(i.InvoiceDate, '; ') InvoiceDate,ROW_NUMBER() OVER (partition by i.CustomerID ORDER BY UnitPrice DESC) rowNum
From  Sales.Invoices i join Sales.InvoiceLines il on il.InvoiceID=i.InvoiceID
                       join Sales.Customers c on c.CustomerID=i.CustomerID
group by i.CustomerID,c.CustomerName,il.StockItemID,il.UnitPrice
--Order by i.CustomerID,il.UnitPrice desc
) s
where rowNum<=2



--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 