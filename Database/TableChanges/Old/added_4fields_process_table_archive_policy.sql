IF COL_LENGTH('process_table_archive_policy', 'create_user') IS NULL
BEGIN
    ALTER TABLE process_table_archive_policy ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('process_table_archive_policy', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE process_table_archive_policy ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('process_table_archive_policy', '[update_user]') IS NULL
BEGIN
    ALTER TABLE process_table_archive_policy ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('process_table_archive_policy', 'update_ts') IS NULL
BEGIN
    ALTER TABLE process_table_archive_policy ADD [update_ts] DATETIME NULL
END