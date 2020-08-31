IF COL_LENGTH('dashboard_template_detail', 'option_formula') IS NOT NULL
BEGIN
	ALTER TABLE dashboard_template_detail ALTER COLUMN option_formula NVARCHAR(100)
END
GO

