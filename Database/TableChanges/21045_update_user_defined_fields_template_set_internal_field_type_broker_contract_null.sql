IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'user_defined_fields_template' AND COLUMN_NAME = 'internal_field_type')
BEGIN
	UPDATE user_defined_fields_template
	SET internal_field_type = NULL
	WHERE field_id = -5604
END