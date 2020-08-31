SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[alert_table_definition]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[alert_table_definition] (
    	[alert_table_definition_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[logical_table_name]         VARCHAR(1000) NULL,
    	[physical_table_name]        VARCHAR(1000) NULL,
    	[create_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                VARCHAR(50) NULL,
    	[update_ts]                  DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table alert_table_definition EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_alert_table_definition]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_alert_table_definition]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_alert_table_definition]
ON [dbo].[alert_table_definition]
FOR UPDATE
AS
    UPDATE alert_table_definition
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM alert_table_definition t
      INNER JOIN DELETED u ON t.[alert_table_definition_id] = u.[alert_table_definition_id]
GO