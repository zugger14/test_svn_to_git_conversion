SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

USE adiha_process

IF OBJECT_ID(N'[dbo].[stage_ice_deal_raw__]', N'U') IS  NULL
BEGIN
CREATE TABLE adiha_process.dbo.stage_ice_deal_raw__
	(
		[deal_date]			DATETIME NULL			
		,[deal_id]			NVARCHAR(255) NULL		
		,[volume]			NVARCHAR(255) NULL		
		,[price]			NVARCHAR(255) NULL		
		,[term]				NVARCHAR(255) NULL		
		,[template]			NVARCHAR(255) NULL		
		,[currency]			NVARCHAR(255) NULL		
		,[buy_sell_flag]	NVARCHAR(255)NULL		
		,[trader]			NVARCHAR(255) NULL
		,[counterparty]		NVARCHAR(255) NULL
		,[broker]			NVARCHAR(255) NULL
	)
END
ELSE 
	BEGIN
		PRINT 'Table stage_ice_deal_raw__ exists.'
	END

GO


--SELECT  * FROM adiha_process.adiha_process.dbo.stage_ice_deal_raw__
--drop table adiha_process.dbo.stage_ice_deal_raw__
