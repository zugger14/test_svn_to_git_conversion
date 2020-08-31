IF COL_LENGTH('dbo.report', 'is_custom_report') IS NULL
BEGIN
    ALTER TABLE dbo.report ADD is_custom_report INT 
END