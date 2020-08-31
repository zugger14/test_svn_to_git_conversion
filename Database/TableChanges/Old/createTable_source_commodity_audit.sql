SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[source_commodity_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[source_commodity_audit]
    (
    	[audit_id]             INT IDENTITY(1, 1) NOT NULL,
    	[source_commodity_id]  INT NULL,
    	[source_system_id]     INT NULL,
    	[commodity_id]         VARCHAR(50) NOT NULL,
    	[commodity_name]       VARCHAR(100) NULL,
    	[commodity_desc]       VARCHAR(250) NULL,
    	[create_user]          VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]            DATETIME NULL DEFAULT GETDATE(),
    	[update_user]          VARCHAR(50) NULL,
    	[update_ts]            DATETIME NULL,
    	[user_action]          VARCHAR(50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table source_commodity_audit EXISTS'
END

GO