/****** Object:  StoredProcedure [dbo].[spa_trayport_staging]    Script Date: 07/18/2011 23:23:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_trayport_staging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_trayport_staging]
GO

/****** Object:  StoredProcedure [dbo].[spa_trayport_staging]    Script Date: 07/18/2011 23:23:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--spa_TrayPort_Staging 'p','Success','test.xml'
create PROC [dbo].[spa_trayport_staging]
@flag CHAR(1),
@status VARCHAR(50)=NULL,
@file_name VARCHAR(150)=NULL
AS
IF @flag='d'
BEGIN
	TRUNCATE table Trayport_XML_Trade_Raw
	TRUNCATE table TrayPort_XML_INSTSPECIFIER_RAW
	RETURN
	
END 
ELSE IF @flag='p'
BEGIN 
		declare @process_id varchar(150),@desc VARCHAR(500)
		set @process_id=dbo.FNAGetNewID()
		IF @status='Success'
		begin
			INSERT Trayport_Staging([Action]
				  ,[Trade_Id]
				  ,[RelationshipID]
				  ,[Price]
				  ,[Volume]
				  ,[DateTime]
				  ,[LastUpdate]
				  ,[AggressorCompany]
				  ,[AggressorCompanyID]
				  ,[AggressorTrader]
				  ,[AggressorTraderID]
				  ,[AggressorUser]
				  ,[AggressorUserID]
				  ,[AggressorAction]
				  ,[AggressorBroker]
				  ,[AggressorBrokerID]
				  ,[InitiatorCompany]
				  ,[InitiatorCompanyID]
				  ,[InitiatorTrader]
				  ,[InitiatorTraderID]
				  ,[InitiatorUser]
				  ,[InitiatorUserID]
				  ,[InitiatorAction]
				  ,[InitiatorBroker]
				  ,[InitiatorBrokerID]
				  ,[ClearingStatus]
				  ,[ClearingID]
				  ,[ManualDeal]
				  ,[VoiceDeal]
				  ,[InitSleeve]
				  ,[AggSleeve]
				  ,[PNC]
				  ,[PostTradeNegotiating]
				  ,[InitiatorOwnedSpread]
				  ,[AggressorOwnedSpread]
				  ,[UnderInvestigation]
				  ,[EngineID]
				  ,[OrderID]
				  ,[InstID]
				  ,[SeqSpan]
				  ,[FirstSequenceID]
				  ,[FirstSequenceItemID]
				  ,[SecondSequenceItemID]
				  ,[TermFormatID]
				  ,[InstName]
				  ,[FirstSequenceItemName]
				  ,[SecondSequenceItemName]
				  ,[Trade_SNO]
				  ,Create_ts
				  ,XML_FileName
				  ,process_id
				  )
			SELECT [Action]
				  ,'T-'+CAST(t.[Trade_Id] AS VARCHAR) 
				  ,[RelationshipID]
				  ,[Price]
				  ,[Volume]
				  ,[DateTime]
				  ,[LastUpdate]
				  ,[AggressorCompany]
				  ,[AggressorCompanyID]
				  ,[AggressorTrader]
				  ,[AggressorTraderID]
				  ,[AggressorUser]
				  ,[AggressorUserID]
				  ,[AggressorAction]
				  ,[AggressorBroker]
				  ,[AggressorBrokerID]
				  ,[InitiatorCompany]
				  ,[InitiatorCompanyID]
				  ,[InitiatorTrader]
				  ,[InitiatorTraderID]
				  ,[InitiatorUser]
				  ,[InitiatorUserID]
				  ,[InitiatorAction]
				  ,[InitiatorBroker]
				  ,[InitiatorBrokerID]
				  ,[ClearingStatus]
				  ,[ClearingID]
				  ,[ManualDeal]
				  ,[VoiceDeal]
				  ,[InitSleeve]
				  ,[AggSleeve]
				  ,[PNC]
				  ,[PostTradeNegotiating]
				  ,[InitiatorOwnedSpread]
				  ,[AggressorOwnedSpread]
				  ,[UnderInvestigation]
				  ,[EngineID]
				  ,[OrderID]
				  ,[InstID]
				  ,[SeqSpan]
				  ,[FirstSequenceID]
				  ,[FirstSequenceItemID]
				  ,[SecondSequenceItemID]
				  ,[TermFormatID]
				  ,[InstName]
				  ,[FirstSequenceItemName]
				  ,[SecondSequenceItemName]
				  ,t.[Trade_SNO]
				  , GETDATE()
				  ,@file_name
				  ,@process_id
			  FROM [dbo].[Trayport_XML_Trade_Raw] t JOIN TrayPort_XML_INSTSPECIFIER_RAW i
			  ON t.Trade_SNO=i.trade_id
			  WHERE t.ACTION IN ('Insert','Update','Remove')
			  update Trayport_Staging set DATETIME=convert(varchar,DATETIME,111)
			  exec spa_TrayPort_Staging_Process @process_id
		  END
		  ELSE ----------- Error
		  BEGIN
			SET @desc='Technical Error in file: '+ @file_name
		  	EXEC spa_NotificationUserByRole 5,@process_id,'Tray-Port',@desc ,'e','Tray-Port Import'
		  END
END





GO


