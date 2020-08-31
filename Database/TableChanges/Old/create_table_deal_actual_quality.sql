SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_actual_quality]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].deal_actual_quality (
		deal_actual_id INT IDENTITY(1, 1) NOT NULL,
		[source_deal_detail_id] INT NULL,
		split_deal_actuals_id INT NULL,
		quality INT, 
		value FLOAT, 
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME NULL DEFAULT GETDATE(),
		[update_user] VARCHAR(50) NULL,
		[update_ts] DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_actual_qualtity EXISTS'
END
