Alter PROCEDURE Sales.GetNewInvoice --будет получать сообщение на таргете
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(max),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(max),
			@ReplyMessageName Sysname,			
			@xml XML,
			@countid int,
			@CustomerName nvarchar(200)
	
	BEGIN TRAN; 
	Declare @date datetime =getdate();
	--ѕолучаем сообщение от инициатора которое находитс¤ у таргета
	RECEIVE TOP(1) --обычно одно сообщение, но можно пачкой
		@TargetDlgHandle = Conversation_Handle, --»ƒ диалога
		@Message = Message_Body, --само сообщение
		@MessageType = Message_Type_Name --тип сообщени¤( в зависимости от типа можно по разному обрабатывать) обычно два - запрос и ответ
	FROM dbo.TargetQueueWWI; --им¤ очереди которую мы ранее создавали

	SELECT @Message; --не дл¤ прода
	

	SET @xml = CAST(@Message AS XML);

	-- Курсор для записи 
	Declare SB_getinfo cursor for 
	SELECT  R.Iv.value('@countid','INT'), --тут используетс¤ ¤зык XPath и он регистрозависимый в отличии от TSQL
	R.Iv.value('@CustomerName','nvarchar(200)')
	FROM @xml.nodes('/RequestMessage/cc') as R(Iv);

	open SB_getinfo 
	while 1=1 
	begin
	 fetch next from SB_getinfo into  @countid,@CustomerName;
	     if @@FETCH_STATUS!=0
		 begin
		 Break
		 end
		
	               	insert into Report.CountOrderForCustomer(CountOrder  ,CustomerName ,DateTimeStamp )
	               	values(@countid,@CustomerName,@date)
	             
	end
	close SB_getinfo
	Deallocate SB_getinfo

	
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --не дл¤ прода
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage' --если наш тип сообщени¤
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; --ответ
	    --отправл¤ем сообщение нами придуманное, что все прошло хорошо
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle; --ј вот и завершение диалога!!! - оно двухстороннее(пока-пока) Ё“ќ первый ѕќ ј
		                                   --Ќ≈Ћ№«я «ј¬≈–Ўј“№ ƒ»јЋќ√ ƒќ ќ“ѕ–ј¬ » ѕ≈–¬ќ√ќ —ќќЅў≈Ќ»я
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; --не дл¤ прода - это дл¤ теста

	COMMIT TRAN;
END