IF COL_LENGTH('dashboard_report_template', 'create_user') IS NULL
BEGIN
    ALTER TABLE dashboard_report_template ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('dashboard_report_template', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE dashboard_report_template ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('dashboard_report_template', '[update_user]') IS NULL
BEGIN
    ALTER TABLE dashboard_report_template ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('dashboard_report_template', 'update_ts') IS NULL
BEGIN
    ALTER TABLE dashboard_report_template ADD [update_ts] DATETIME NULL
END