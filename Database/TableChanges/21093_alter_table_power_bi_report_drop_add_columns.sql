IF COL_LENGTH('power_bi_report', 'ext_int') IS NOT NULL
BEGIN
    ALTER TABLE power_bi_report DROP COLUMN  ext_int
END
GO

IF COL_LENGTH('power_bi_report', 'report_url') IS NOT NULL
BEGIN
    ALTER TABLE power_bi_report DROP COLUMN  report_url
END
GO

IF COL_LENGTH('power_bi_report', 'report_url') IS NOT NULL
BEGIN
    ALTER TABLE power_bi_report DROP COLUMN  report_url
END
GO

IF COL_LENGTH('power_bi_report', 'powerbi_report_id') IS NULL
BEGIN
	ALTER TABLE power_bi_report ADD powerbi_report_id VARCHAR(50)
END
GO

IF COL_LENGTH('power_bi_report', 'powerbi_dataset_id') IS NULL
BEGIN
	ALTER TABLE power_bi_report ADD powerbi_dataset_id VARCHAR(50)
END
GO