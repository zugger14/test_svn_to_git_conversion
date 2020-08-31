SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[alert_table_relation]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[alert_table_relation] (
    	[alert_table_relation_id]  INT IDENTITY(1, 1) NOT NULL,
    	[alert_id]				   INT NOT NULL,
    	[from_table_id]            INT REFERENCES alert_rule_table(alert_rule_table_id) NOT NULL,
    	[from_column_id]           INT REFERENCES alert_columns_definition(alert_columns_definition_id) NOT NULL,
    	[to_table_id]              INT REFERENCES alert_rule_table(alert_rule_table_id) NOT NULL,
    	[to_column_id]             INT REFERENCES alert_columns_definition(alert_columns_definition_id) NOT NULL,
    	[create_user]              VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                DATETIME NULL DEFAULT GETDATE(),
    	[update_user]              VARCHAR(50) NULL,
    	[update_ts]                DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table alert_table_relation EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_alert_table_relation]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_alert_table_relation]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_alert_table_relation]
ON [dbo].[alert_table_relation]
FOR UPDATE
AS
    UPDATE alert_table_relation
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM alert_table_relation t
      INNER JOIN DELETED u ON t.[alert_table_relation_id] = u.[alert_table_relation_id]
GO