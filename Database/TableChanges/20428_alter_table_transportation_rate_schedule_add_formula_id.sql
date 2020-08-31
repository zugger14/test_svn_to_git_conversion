IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'transportation_rate_schedule' AND COLUMN_NAME = 'formula_id')
BEGIN
	ALTER TABLE transportation_rate_schedule ADD formula_id INT
END
GO