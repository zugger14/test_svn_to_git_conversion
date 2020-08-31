--Update field value to 'Rate Schedule' from 'Rounding Method' and also sql_string to get Rate Schedule (static data type id 1800)
IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5678)
BEGIN
	UPDATE user_defined_fields_template 
	SET Field_label = 'Rate Schedule'  
		,sql_string = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 1800'
	WHERE field_name = -5678
	print 'Updated value for field_name -5678.'
END
else print 'Data with field_name -5678 does not exist.'

--Update code,description for static data with value_id -5678 used for UDF
IF EXISTS (SELECT 1 FROM static_data_value WHERE value_id = -5678)
BEGIN
	UPDATE static_data_value 
	SET code = 'Rate Schedule'  
		,description = 'Rate Schedule'
	WHERE value_id = -5678
	print 'Updated code,description for value_id -5678.'
END
else print 'Data with value_id -5678 does not exist.'