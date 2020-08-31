IF OBJECT_ID(N'[dbo].[alert_report_params]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[alert_report_params]
    (
        [alert_report_params_id]	INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
        [alert_sql_id]				INT REFERENCES alert_sql(alert_sql_id) NOT NULL,
		[alert_report_id]			INT REFERENCES alert_reports(alert_reports_id) NOT NULL,
		[main_table_id]				INT REFERENCES alert_rule_table(alert_rule_table_id) NOT NULL,
		[parameter_name]			NVARCHAR(100) NOT NULL,
		[parameter_value]			NVARCHAR(1000) NULL,
		[create_user]               VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                 DATETIME NULL DEFAULT GETDATE(),
    	[update_user]               VARCHAR(50) NULL,
    	[update_ts]                 DATETIME NULL
    )
END
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_alert_report_params]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_alert_report_params]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_alert_report_params]
ON [dbo].[alert_report_params]
FOR UPDATE
AS
    UPDATE alert_report_params
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM alert_report_params t
      INNER JOIN DELETED u ON t.[alert_report_params_id] = u.[alert_report_params_id]
GO