
sp_help 'Sales.Invoices';



sp_help 'Sales.InvoiceLines';

DROP INDEX IX_Invoices_Date ON Sales.Invoices ;

CREATE INDEX IX_Invoices_Date ON Sales.Invoices (InvoiceDate) INCLUDE (CustomerId, BillToCustomerId, SalespersonPersonID, OrderID);

UPDATE STATISTICS Sales.Orders WITH FULLSCAN;


UPDATE STATISTICS Sales.OrderLines WITH FULLSCAN;