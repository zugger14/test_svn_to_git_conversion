IF COL_LENGTH('Contract_report_template', 'filename') IS NOT NULL
BEGIN
    ALTER TABLE Contract_report_template ALTER COLUMN [filename] VARCHAR(1000)
END
GO



