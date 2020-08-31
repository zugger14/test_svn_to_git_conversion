SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[counterparty_bank_info_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[counterparty_bank_info_audit]
    (
    	[audit_id]           INT IDENTITY(1, 1) NOT NULL,
    	[bank_id]            INT NOT NULL,
    	[counterparty_id]    INT NULL,
    	[bank_name]          VARCHAR(100) NULL,
    	[wire_ABA]           VARCHAR(50) NULL,
    	[ACH_ABA]            VARCHAR(50) NULL,
    	[Account_no]         CHAR(50) NULL,
    	[Address1]           VARCHAR(50) NULL,
    	[Address2]           VARCHAR(50) NULL,
    	[account_name]       VARCHAR(50) NULL,
    	[reference]          VARCHAR(50) NULL,
    	[currency]           VARCHAR(50) NULL,
    	[create_user]        VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]          DATETIME NULL DEFAULT GETDATE(),
    	[update_user]        VARCHAR(50) NULL,
    	[update_ts]          DATETIME NULL,
    	[user_action]        VARCHAR(50),
    	[counterparty_name]  VARCHAR(1000),
    	[source_system]      INT
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table counterparty_bank_info_audit EXISTS'
END

GO

