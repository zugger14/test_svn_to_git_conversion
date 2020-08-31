IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='commodity_type_contraints' AND table_name = 'commodity_type' )
BEGIN
	ALTER TABLE commodity_type ADD CONSTRAINT commodity_type_contraints UNIQUE (data_type,commodity_name)
END