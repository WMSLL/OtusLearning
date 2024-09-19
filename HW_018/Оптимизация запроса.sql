

if  OBJECT_ID('tempdb..#sum')!=0 drop table #sum

SELECT ordTotal.CustomerID
into #sum
FROM Sales.OrderLines AS Total
Join Sales.Orders AS ordTotal
On ordTotal.OrderID = Total.OrderID
Group by ordTotal.CustomerID
having SUM(Total.UnitPrice*Total.Quantity)>250000


Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
          JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
          JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
       --   JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID -- из данной таблицы не тянем ни какие данные и по ней нет фильтров, зачем она в джойне ?!
         -- JOIN Warehouse.StockItemTransactions AS ItemTrans   ON ItemTrans.StockItemID = det.StockItemID  -- из данной таблицы не тянем ни какие данные и по ней нет фильтров, зачем она в джойне ?!

   join Warehouse.StockItems AS It on It.StockItemID=det.StockItemID and it.SupplierID=12
    
	join #sum s on s.CustomerID=Inv.CustomerID 
WHERE Inv.BillToCustomerID != ord.CustomerID
-- избавляемся от подзапросов
--AND (Select SupplierId
--FROM Warehouse.StockItems AS It
--Where It.StockItemID = det.StockItemID) = 12

-- Вынес данный подзапрос в отдельную таблдицу
--AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
--FROM Sales.OrderLines AS Total
--Join Sales.Orders AS ordTotal
--On ordTotal.OrderID = Total.OrderID
--WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000


AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID;