SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[cash_apply_cng]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[cash_apply_cng]
    (
    	[cash_apply_id]         INT IDENTITY(1, 1) NOT NULL,
    	[received_date]         DATETIME,
    	[cash_apply_amount]     FLOAT,
    	[excess_amount]         FLOAT,
    	[outstanding_amount]    FLOAT,
    	[counterparty_id]       INT,
    	[create_user]			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]				DATETIME NULL DEFAULT GETDATE(),
    	[update_user]			VARCHAR(50) NULL,
    	[update_ts]				DATETIME NULL
    )
END
ELSE
BEGIN
    EXEC spa_print 'Table ''cash_apply_cng'' already EXISTS'
END 
GO