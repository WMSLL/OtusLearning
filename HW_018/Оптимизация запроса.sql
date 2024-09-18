

With ttt as (

SELECT ord.CustomerID , det.StockItemID , det.UnitPrice , det.Quantity , ord.OrderID,sum(det.UnitPrice*det.Quantity) over(partition by inv.CustomerID ) sum_customer
FROM Sales.Orders AS ord JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
                         JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
                         JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
                         JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
						 join Warehouse.StockItems it on It.StockItemID = det.StockItemID and it.SupplierId=12
WHERE Inv.BillToCustomerID != ord.CustomerID

-- Если есть возможность убрать подзапросы , делаем это
/*
      AND
      ( SELECT SupplierId
        FROM Warehouse.StockItems AS It
        WHERE It.StockItemID = det.StockItemID
      ) = 12
*/
      AND
      --( SELECT SUM(Total.UnitPrice * Total.Quantity)
      --  FROM Sales.OrderLines AS Total JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
      --  WHERE ordTotal.CustomerID = Inv.CustomerID
      --) > 250000
      --AND
	   
	   
      DATEDIFF(dd , Inv.InvoiceDate , ord.OrderDate) = 0
--GROUP BY ord.CustomerID , det.StockItemID
)


Select CustomerID,StockItemID,sum(UnitPrice),sum(Quantity),count( OrderID)
From ttt
where sum_customer>250000
Group by CustomerID,StockItemID