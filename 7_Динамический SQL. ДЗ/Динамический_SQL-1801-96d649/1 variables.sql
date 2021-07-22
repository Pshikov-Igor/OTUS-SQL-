USE [WideWorldImporters]

---- ���������� ����������
--������� 1
DECLARE @CustomerId INT,
		@CustId INT = 0,
		@InvoiceDate DATE;

--- �������������
set @CustId = 10;
set @CustomerId = (select max(CustomerID) from Sales.Customers);
--select @CustId, @CustomerId;


--������� 2
Declare @InvoiceId INT;
DECLARE @TransactionDate DATE;
DECLARE @CustomerName NVARCHAR(100);

SELECT 
	@InvoiceId = InvoiceID,
	@TransactionDate = TransactionDate
FROM Sales.CustomerTransactions
ORDER BY TransactionDate DESC;

--select @InvoiceId, @TransactionDate;

--���������� �� ����� ��������?
SELECT TOP 1
	@InvoiceId = InvoiceID,
	@TransactionDate = TransactionDate
FROM Sales.CustomerTransactions
ORDER BY TransactionDate DESC;

--select @InvoiceId, @TransactionDate;


SELECT 
	@InvoiceDate = InvoiceDate,
	@CustomerId = CustomerId
FROM Sales.Invoices
WHERE InvoiceId = @InvoiceId

SELECT 
	@CustomerName = CustomerName
FROM Sales.Customers
WHERE CustomerID = @CustomerId;

SELECT	@InvoiceId AS InvoiceId, @InvoiceDate AS InvoiceDate, 
		@CustomerId AS CustomerId, @CustomerName AS CustomerName,
		@TransactionDate AS TD

SELECT DATEDIFF(dd, @TransactionDate, @InvoiceDate) AS paymentLag;

--������� 1
IF @TransactionDate = @InvoiceDate
	SELECT 'Great customer';

--������� 2
IF (@TransactionDate = @InvoiceDate)
	SELECT 'Great customer';
ELSE 
	SELECT 'So so';


IF DATEDIFF(dd, @TransactionDate, @InvoiceDate) < 2
BEGIN
	SELECT 'Great customer';
END
ELSE 
BEGIN
	SELECT 'So so';
END


--� ���� ��������� ELSE? 
IF DATEDIFF(dd, @TransactionDate, @InvoiceDate) < 2
BEGIN
	IF @CustomerId = 1
		SELECT 'Great customer';

ELSE 
	SELECT 'So so';
END

DECLARE @error INT = 0,
		@vip   INT = -1;

--antipattern
IF DATEDIFF(dd, @TransactionDate, @InvoiceDate) < 2
	IF @CustomerId != 1 
		IF @TransactionDate > '20150101'
			IF @CustomerName IS NOT NULL 
			BEGIN
				IF @CustomerName like '%toys%'
					SET @vip = 1
				ELSE
					SET @vip = 0
			END --END IF @CustomerName IS NOT NULL 
			ELSE --IF @CustomerName IS NOT NULL 
				SET @error = 100 --������ ���
		ELSE
		BEGIN
			IF @TransactionDate > '20140101'
				SET @error = 300; --������
			ELSE
				SET @error = 320; --����� ������
		END
	ELSE
		SET @error = 200; --�������� ������
ELSE
	SET @error = 530; --�������� ������

select @error as error, @vip AS vip;

SET @error = -1;
SET @vip = -1;

IF DATEDIFF(dd, @TransactionDate, @InvoiceDate) < 2
	SET @error = 0;
ELSE 
	SET @error = 530;

IF @error = 0 
BEGIN
	IF @CustomerId != 1
		--������ ��� �� ��������
		SET @error = 0;
	ELSE 
		SET @error = 200;
END;

IF @error = 0 
BEGIN
	IF @TransactionDate > '20150101'
		SET @error = 0; --������
	ELSE
		SET @error = 300; --������ ���������� �� ��������� ��������
END;

IF @error = 300 
BEGIN
	IF @TransactionDate > '20140101' AND @TransactionDate < '20150101'
		SET @error = 300; --������
	ELSE
		SET @error = 320; --����� ������
END;

IF @error = 0 
BEGIN
	IF @CustomerName IS NOT NULL 
		SET @error = 0; 
		--���-�� �������
	ELSE
		SET @error = 100; --������ ���
END;
				

IF @error = 0 
BEGIN
	IF @CustomerName like '%toys%'
		SET @vip = 1;
	ELSE
		SET @vip = 0;
END;



select @error as error, @vip AS vip;
	
--�������� ����� ���������� � ���� https://www.sqlteam.com/forums/topic.asp?TOPIC_ID=53185

