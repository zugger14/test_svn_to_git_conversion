IF COL_LENGTH('dbo.formula_breakdown','data_source_id') IS NULL
BEGIN
	ALTER TABLE formula_breakdown
	ADD data_source_id INT NULL
END