SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[counterparty_epa_account_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[counterparty_epa_account_audit]
    (
    	audit_id                       INT IDENTITY(1, 1) NOT NULL,
    	[counterparty_epa_account_id]  [int] NULL,
    	[counterparty_id]              [int] NULL,
    	[external_type_id]             [int] NULL,
    	[external_value]               [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    	[create_user]                  VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                    DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                  VARCHAR(50) NULL,
    	[update_ts]                    DATETIME NULL,
    	[user_action]                  VARCHAR(50),
    	[counterparty_name]            VARCHAR(1000),
    	[source_system]                INT
    )
END
ELSE
BEGIN
    PRINT 'Table counterparty_epa_account_audit EXISTS'
END
 
GO

