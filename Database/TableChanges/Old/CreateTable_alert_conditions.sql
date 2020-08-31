SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[alert_conditions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[alert_conditions] (
    	[alert_conditions_id]           INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[rules_id]						INT REFERENCES alert_sql(alert_sql_id) NOT NULL,
    	[alert_conditions_name]         VARCHAR(100) NULL,
    	[alert_conditions_description]  VARCHAR(500) NULL,
    	[create_user]                   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                   VARCHAR(50) NULL,
    	[update_ts]                     DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table alert_conditions EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_alert_conditions]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_alert_conditions]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_alert_conditions]
ON [dbo].[alert_conditions]
FOR UPDATE
AS
    UPDATE alert_conditions
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM alert_conditions t
      INNER JOIN DELETED u ON t.[alert_conditions_id] = u.[alert_conditions_id]
GO