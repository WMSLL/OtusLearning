/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

Select *
From Application.People p 
where IsSalesPerson=1
and not exists(Select*From Sales.Invoices i where i.SalespersonPersonID=p.PersonID and i.InvoiceDate='20150704')



/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/


SELECT *
  FROM [WideWorldImporters].[Warehouse].[StockItems]
  where  UnitPrice = (Select min(UnitPrice) From [WideWorldImporters].[Warehouse].[StockItems])


  ;with MinPrice as(
  Select min(UnitPrice)UnitPrice From [WideWorldImporters].[Warehouse].[StockItems]
                   )
  
  SELECT *
  FROM [WideWorldImporters].[Warehouse].[StockItems] p join MinPrice mp on mp.UnitPrice=p.UnitPrice


/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

;with CustTran_CTE as
(

Select  CustomerID, max(TransactionAmount) TransactionAmount
From Sales.CustomerTransactions st
Group by CustomerID
)

Select top 5   *
From CustTran_CTE
order by TransactionAmount desc


Select top 5  CustomerID, max(TransactionAmount) TransactionAmount
From Sales.CustomerTransactions st
Group by CustomerID
order by max(TransactionAmount) desc


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

; with items as (

SELECT TOP 3 WITH TIES StockItemID, StockItemName, UnitPrice
FROM Warehouse.StockItems
ORDER BY UnitPrice DESC -- сортировка обязательна!!
)


Select ci.CityID,ci.CityName,o.PickedByPersonID
From items i join  Sales.OrderLines ol on i.StockItemID=ol.StockItemID
             join Sales.Orders o on o.OrderID=ol.OrderID
			 join Sales.Customers cust on cust.CustomerID=o.CustomerID
			 join Application.Cities ci on ci.CityID=cust.DeliveryCityID


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	i.InvoiceID, 
	i.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = i.SalespersonPersonID
	) AS SalesPersonName,

	SalesTotals.TotalSumm AS TotalSummByInvoice, 

	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = i.OrderId)	
	) AS TotalSummForPickedItems


FROM Sales.Invoices  i
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON i.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
-- читабельней


;with invLine as (
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000)
, Oline as (SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)TotalSummForPickedItems,OrderId
		FROM Sales.OrderLines 
		Group by OrderId)


Select i.InvoiceID, 
	i.InvoiceDate,p.FullName SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice,
	TotalSummForPickedItems
FROM Sales.Invoices i join Application.People p on p.PersonID = i.SalespersonPersonID
                      JOIN invLine AS SalesTotals ON i.InvoiceID = SalesTotals.InvoiceID
		
		join Oline as	o on  o.OrderId =i.OrderID
ORDER BY TotalSumm DESC
	