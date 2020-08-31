
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'transportation_rate_schedule' AND COLUMN_NAME = 'effective_date')
BEGIN
	ALTER TABLE transportation_rate_schedule ADD effective_date datetime NULL
END
GO
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'transportation_rate_schedule' AND COLUMN_NAME = 'uom_id')
BEGIN
	ALTER TABLE transportation_rate_schedule ADD uom_id int NULL
END
