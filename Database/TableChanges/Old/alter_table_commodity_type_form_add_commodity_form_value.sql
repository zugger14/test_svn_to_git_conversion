IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'commodity_type_form' AND  COLUMN_NAME = 'commodity_form_value')
BEGIN
	ALTER TABLE commodity_type_form ADD commodity_form_value INT
END
ELSE 
	PRINT 'Column already exists.'


IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'commodity_type_form' AND  COLUMN_NAME = 'commodity_form_name')
BEGIN
	ALTER TABLE commodity_type_form ALTER COLUMN commodity_form_name VARCHAR(50) NULL
END

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'commodity_type_form' AND  COLUMN_NAME = 'commodity_form_description')
BEGIN
	ALTER TABLE commodity_type_form ALTER COLUMN commodity_form_description VARCHAR(100) NULL
END