IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'user_defined_deal_fields_template' AND COLUMN_NAME = 'udf_user_field_id')
BEGIN
	ALTER TABLE user_defined_deal_fields_template ADD udf_user_field_id varchar(50) NULL
END
