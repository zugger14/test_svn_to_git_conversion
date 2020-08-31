IF COL_LENGTH('mv90_data_mins', 'Hr25_15') IS NULL
BEGIN
    ALTER TABLE [mv90_data_mins] ADD [Hr25_15] FLOAT
END
GO

IF COL_LENGTH('mv90_data_mins', 'Hr25_30') IS NULL
BEGIN
    ALTER TABLE [mv90_data_mins] ADD [Hr25_30] FLOAT
END
GO

IF COL_LENGTH('mv90_data_mins', 'Hr25_45') IS NULL
BEGIN
    ALTER TABLE [mv90_data_mins] ADD [Hr25_45] FLOAT
END
GO

IF COL_LENGTH('mv90_data_mins', 'Hr25_60') IS NULL
BEGIN
    ALTER TABLE [mv90_data_mins] ADD [Hr25_60] FLOAT
END
GO