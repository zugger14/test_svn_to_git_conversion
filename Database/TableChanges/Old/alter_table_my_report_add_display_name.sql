IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'my_report' AND COLUMN_NAME = 'display_name')
BEGIN
	ALTER TABLE my_report ADD display_name VARCHAR(100)
END

