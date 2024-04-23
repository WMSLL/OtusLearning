/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

--[Tailspin Toys (Sylvanite, MT)],
--[Tailspin Toys (Peeples Valley, AZ)],
--[Tailspin Toys (Medicine Lodge, KS)],
--[Tailspin Toys (Gasport, NY)],
--[Tailspin Toys (Jessie, ND)]

Select InvoiceDate,
[Tailspin Toys (Sylvanite, MT)],
[Tailspin Toys (Peeples Valley, AZ)],
[Tailspin Toys (Medicine Lodge, KS)],
[Tailspin Toys (Gasport, NY)],
[Tailspin Toys (Jessie, ND)]
From (
Select   c.CustomerName,i.InvoiceID,i.InvoiceDate
From Sales.Invoices i join Sales.Customers c on c.CustomerID=i.CustomerID  and i.CustomerID between 2 and 6) customs
pivot
(count(InvoiceID)
for CustomerName in (
[Tailspin Toys (Sylvanite, MT)],
[Tailspin Toys (Peeples Valley, AZ)],
[Tailspin Toys (Medicine Lodge, KS)],
[Tailspin Toys (Gasport, NY)],
[Tailspin Toys (Jessie, ND)])
) pivotTable

order by InvoiceDate

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

Select CustomerName,AddressLine
From (Select CustomerName,DeliveryAddressLine1,DeliveryAddressLine2,PostalAddressLine1,PostalAddressLine2
From Sales.Customers
where CustomerName like N'%Tailspin Toys%'
) Adress
unpivot
(
  AddressLine  For  Adress in (DeliveryAddressLine1,DeliveryAddressLine2,PostalAddressLine1,PostalAddressLine2)
) tt
order by CustomerName,AddressLine

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

Select CountryID,CountryName, Code.Code
from Application.Countries c cross apply (Select IsoAlpha3Code Code From Application.Countries c1 where c1.CountryID=c.CountryID 
 union all 
 Select cast(IsoNumericCode as nvarchar) From Application.Countries c1 where c1.CountryID=c.CountryID) Code
 order by CountryID,Code.Code
                              

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

Select c.CustomerID,c.CustomerName,o2.StockItemID,o2.UnitPrice,o2.InvoiceDate
From Sales.Customers c cross apply (
Select top 2 StockItemID,UnitPrice,InvoiceDate
From Sales.Invoices o join Sales.InvoiceLines ol on ol.InvoiceID=o.OrderID 
where o.CustomerID=c.CustomerID
order by ol.UnitPrice) o2
