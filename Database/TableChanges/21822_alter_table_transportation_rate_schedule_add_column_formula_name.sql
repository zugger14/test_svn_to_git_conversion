IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'transportation_rate_schedule' AND COLUMN_NAME = 'formula_name')
BEGIN
	ALTER TABLE transportation_rate_schedule ADD formula_name VARCHAR(5000)
END
GO