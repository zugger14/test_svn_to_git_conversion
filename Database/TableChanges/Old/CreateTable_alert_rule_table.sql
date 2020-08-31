SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[alert_rule_table]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[alert_rule_table] (
    	[alert_rule_table_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[alert_id]			   INT NULL,
    	[table_id]			   INT REFERENCES alert_table_definition(alert_table_definition_id) NULL,
    	[root_table_id]		   INT NULL,
    	[table_alias]          VARCHAR(50) NULL,
    	[create_user]          VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]            DATETIME NULL DEFAULT GETDATE(),
    	[update_user]          VARCHAR(50) NULL,
    	[update_ts]            DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table alert_rule_table EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_alert_rule_table]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_alert_rule_table]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_alert_rule_table]
ON [dbo].[alert_rule_table]
FOR UPDATE
AS
    UPDATE alert_rule_table
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM alert_rule_table t
      INNER JOIN DELETED u ON t.[alert_rule_table_id] = u.[alert_rule_table_id]
GO