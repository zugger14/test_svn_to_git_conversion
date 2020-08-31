IF COL_LENGTH('excel_sheet_parameter', 'override_type') IS NOT NULL
BEGIN
	ALTER TABLE excel_sheet_parameter ALTER COLUMN override_type INT
END
GO