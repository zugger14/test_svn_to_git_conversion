IF COL_LENGTH('process_table_location', 'create_user') IS NULL
BEGIN
    ALTER TABLE process_table_location ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('process_table_location', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE process_table_location ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('process_table_location', '[update_user]') IS NULL
BEGIN
    ALTER TABLE process_table_location ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('process_table_location', 'update_ts') IS NULL
BEGIN
    ALTER TABLE process_table_location ADD [update_ts] DATETIME NULL
END