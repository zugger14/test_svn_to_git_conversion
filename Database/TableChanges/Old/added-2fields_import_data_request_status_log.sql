IF COL_LENGTH('import_data_request_status_log', 'create_user') IS NULL
BEGIN
    ALTER TABLE import_data_request_status_log ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('import_data_request_status_log', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE import_data_request_status_log ADD [create_ts] DATETIME DEFAULT GETDATE()
END