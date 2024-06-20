/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

--напишите здесь свое решение


-- select dbo.fGetClientMaxPurchaseAmount ()
Alter Function dbo.fGetClientMaxPurchaseAmount ()

returns   nvarchar(50)

as
begin
Declare  @Client nvarchar(50);

Select top 1 @Client=c.CustomerName
From Sales.Invoices i join Sales.InvoiceLines il on il.InvoiceID=i.InvoiceID
                      join Sales.Customers c on c.CustomerID=i.CustomerID
Group by c.CustomerName,i.InvoiceID
order by sum(il.UnitPrice) desc ,i.InvoiceID

return @Client
end



/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/
-- exec SP_PurchaseAmountForCustomerid 1
Alter Procedure SP_PurchaseAmountForCustomerid @ustomerID int
as

set NoCount on


Select sum(il.UnitPrice) sumPrice
From Sales.Invoices i join Sales.InvoiceLines il on il.InvoiceID=i.InvoiceID
                     
where CustomerID=@ustomerID



/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

Alter Procedure SP_PurchaseAmountForCustomerid @ustomerID int
as




Select sum(il.UnitPrice) sumPrice
From Sales.Invoices i join Sales.InvoiceLines il on il.InvoiceID=i.InvoiceID
                     
where CustomerID=@ustomerID

/*
Select DBO.FN_PurchaseAmountForCustomerid(1)

exec SP_PurchaseAmountForCustomerid 1

*/
Create Function FN_PurchaseAmountForCustomerid ( @ustomerID int)

returns int

begin
Declare @sum int
Select @sum= sum(il.UnitPrice) 
From Sales.Invoices i join Sales.InvoiceLines il on il.InvoiceID=i.InvoiceID
                     
where CustomerID=@ustomerID

return @sum

end

-- разница в планах запроса , думаю потому, что функции используются только для вывода данных, т.е оптимизатор не выполняет дополнительных проверок на запрос в отличии хранимых процедур,

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

CREATE FUNCTION Sales.FN_CustomerTotalQty
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT SUM(il.Quantity) AS Total From Sales.Invoices i join Sales.InvoiceLines il on il.InvoiceID=i.InvoiceID  WHERE CustomerID = @CustomerID
)


SELECT CustomerID, Customertotal.Total

FROM Sales.Customers
CROSS APPLY Sales.FN_CustomerTotalQty(Customers.CustomerID) AS Customertotal



/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
