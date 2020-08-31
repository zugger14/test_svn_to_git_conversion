
IF COL_LENGTH('import_filter_deal', '[update_user]') IS NULL
BEGIN
    ALTER TABLE import_filter_deal ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('import_filter_deal', 'update_ts') IS NULL
BEGIN
    ALTER TABLE import_filter_deal ADD [update_ts] DATETIME NULL
END

IF COL_LENGTH('import_filter_deal', 'import_filter_id') IS NULL
BEGIN
    ALTER TABLE import_filter_deal ADD import_filter_id INT IDENTITY(1,1)
END
GO
