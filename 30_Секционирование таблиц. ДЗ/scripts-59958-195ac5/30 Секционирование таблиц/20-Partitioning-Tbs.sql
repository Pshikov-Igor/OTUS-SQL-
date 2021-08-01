--создадим партиционированную таблицу
CREATE TABLE [Sales].[InvoiceLinesYears](
	[InvoiceLineID] [int] NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[InvoiceDate] [date] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
) ON [schmYearPartition]([InvoiceDate])---в схеме [schmYearPartition] по ключу [InvoiceDate]
GO

--создадим кластерный индекс в той же схеме с тем же ключом
ALTER TABLE [Sales].[InvoiceLinesYears] ADD CONSTRAINT PK_Sales_InvoiceLinesYears 
PRIMARY KEY CLUSTERED  (InvoiceDate, InvoiceId, InvoiceLineId)
 ON [schmYearPartition]([InvoiceDate]);

--то же самое для второй таблицы
CREATE TABLE [Sales].[InvoicesYears](
	[InvoiceID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[OrderID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[ContactPersonID] [int] NOT NULL,
	[AccountsPersonID] [int] NOT NULL,
	[SalespersonPersonID] [int] NOT NULL,
	[PackedByPersonID] [int] NOT NULL,
	[InvoiceDate] [date] NOT NULL,
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsCreditNote] [bit] NOT NULL,
	[CreditNoteReason] [nvarchar](max) NULL,
	[Comments] [nvarchar](max) NULL,
	[DeliveryInstructions] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL
) ON [schmYearPartition]([InvoiceDate])
GO

ALTER TABLE [Sales].[InvoicesYears] ADD CONSTRAINT PK_Sales_InvoicesYears 
PRIMARY KEY CLUSTERED  (InvoiceDate, InvoiceId)
 ON [schmYearPartition]([InvoiceDate]);

 --второй вариант - на существующей таблице удалить кластерный индекс 
 -- и создать новый кластерный индекс с ключом секционирования

 select min(invoiceDate), max(invoiceDate)
 FROM Sales.Invoices