SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[alert_actions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[alert_actions] (
    	[alert_actions_id]  INT IDENTITY(1, 1) NOT NULL,
    	[alert_id]          INT NOT NULL,
    	[table_id]          INT REFERENCES alert_rule_table(alert_rule_table_id) NOT NULL,
    	[column_id]         INT REFERENCES alert_columns_definition(alert_columns_definition_id) NOT NULL,
    	[column_value]      VARCHAR(500),
    	[create_user]       VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]         DATETIME NULL DEFAULT GETDATE(),
    	[update_user]       VARCHAR(50) NULL,
    	[update_ts]         DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table alert_actions EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_table_name]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_table_name]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_table_name]
ON [dbo].[alert_actions]
FOR UPDATE
AS
    UPDATE alert_actions
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM alert_actions t
      INNER JOIN DELETED u ON t.[alert_actions_id] = u.[alert_actions_id]
GO