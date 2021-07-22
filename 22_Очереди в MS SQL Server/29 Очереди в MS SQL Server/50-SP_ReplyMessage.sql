drop procedure if exists Sales.GetNewInvoice;
GO
CREATE OR ALTER PROCEDURE Sales.GetNewInvoice
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER, --������������� �������
			@Message NVARCHAR(4000),--���������� ���������
			@MessageType Sysname,--��� ����������� ���������
			@ReplyMessage NVARCHAR(4000),--�������� ���������
			@InvoiceID INT,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	--����� �������� � �� �� 1 ���������
	--1 ������������ �� MS
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueWWI; 

	SELECT @Message; --������� � ������� ���������� �������

	SET @xml = CAST(@Message AS XML); -- �������� xml �� ��������

	--�������� InvoiceID �� xml
	SELECT @InvoiceID = R.Iv.value('@InvoiceID','INT')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	--��������� ���� � ������ ���� ��� InvoiceID
	IF EXISTS (SELECT * FROM Sales.Invoices WHERE InvoiceID = @InvoiceID)
	BEGIN
		UPDATE Sales.Invoices
		SET InvoiceConfirmedForProcessing = GETUTCDATE()
		WHERE InvoiceId = @InvoiceID;
	END;
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --� ���. ��������� ������
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received </ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;--������� ������ �� ������� �������
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; --� ���

	COMMIT TRAN;
END