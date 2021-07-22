use WideWorldImporters;
GO
CREATE PROCEDURE Sales.ConfirmInvoice
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER, --����� �������
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

	--������� ��������� �� ������� ����������
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --������� ������ �� ������� ����������
		--��� ��������� ������� ������ ��������� ���
		--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/end-conversation-transact-sql?view=sql-server-ver15
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; --� �������

	COMMIT TRAN; 
END


