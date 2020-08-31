IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'static_data_type' AND  COLUMN_NAME = 'is_active')
BEGIN
	ALTER TABLE static_data_type ADD is_active BIT
END
ELSE 
	PRINT 'Column already exists.'
