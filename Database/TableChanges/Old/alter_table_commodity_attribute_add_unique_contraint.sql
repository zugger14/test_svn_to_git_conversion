IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='commodity_attribute_contraints' AND table_name = 'commodity_attribute' )
BEGIN
	ALTER TABLE commodity_attribute ADD CONSTRAINT commodity_attribute_contraints UNIQUE (data_type,commodity_name)
END