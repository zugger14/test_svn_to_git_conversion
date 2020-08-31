SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[alert_actions_events]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[alert_actions_events] (
    	[alert_actions_events_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[alert_id]                 INT REFERENCES alert_sql(alert_sql_id) NOT NULL,
    	[table_id]                 INT REFERENCES alert_rule_table(alert_rule_table_id) NULL,
    	[callback_alert_id]        INT REFERENCES alert_sql(alert_sql_id) NOT NULL,
    	[create_user]              VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                DATETIME NULL DEFAULT GETDATE(),
    	[update_user]              VARCHAR(50) NULL,
    	[update_ts]                DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table alert_actions_events EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_alert_actions_events]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_alert_actions_events]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_alert_actions_events]
ON [dbo].[alert_actions_events]
FOR UPDATE
AS
    UPDATE alert_actions_events
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM alert_actions_events t
      INNER JOIN DELETED u ON t.[alert_actions_events_id] = u.[alert_actions_events_id]
GO