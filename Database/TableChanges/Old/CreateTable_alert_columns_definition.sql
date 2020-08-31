SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[alert_columns_definition]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[alert_columns_definition] (
    	[alert_columns_definition_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[alert_table_id]               INT REFERENCES alert_table_definition(alert_table_definition_id) NOT NULL,
    	[column_name]                  VARCHAR(600) NULL,
    	[is_primary]                   CHAR(1) NULL,
    	[static_data_type_id]          INT NULL,
    	[create_user]                  VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                    DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                  VARCHAR(50) NULL,
    	[update_ts]                    DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table alert_columns_definition EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_alert_columns_definition]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_alert_columns_definition]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_alert_columns_definition]
ON [dbo].[alert_columns_definition]
FOR UPDATE
AS
    UPDATE alert_columns_definition
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM alert_columns_definition t
      INNER JOIN DELETED u ON t.[alert_columns_definition_id] = u.[alert_columns_definition_id]
GO
