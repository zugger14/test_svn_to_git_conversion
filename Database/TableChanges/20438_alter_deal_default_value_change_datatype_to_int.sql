IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'deal_default_value' AND COLUMN_NAME = 'volume_frequency')
BEGIN
	ALTER TABLE deal_default_value ALTER COLUMN volume_frequency INT
END