IF COL_LENGTH('dashboard_report_template_header', 'create_user') IS NULL
BEGIN
    ALTER TABLE dashboard_report_template_header ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('dashboard_report_template_header', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE dashboard_report_template_header ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('dashboard_report_template_header', '[update_user]') IS NULL
BEGIN
    ALTER TABLE dashboard_report_template_header ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('dashboard_report_template_header', 'update_ts') IS NULL
BEGIN
    ALTER TABLE dashboard_report_template_header ADD [update_ts] DATETIME NULL
END