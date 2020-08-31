IF EXISTS (SELECT * FROM user_defined_fields_template WHERE field_id = 112000)
BEGIN
	UPDATE user_defined_fields_template SET sql_string = 'SELECT sdv.value_id, sdv.code 
														  FROM static_data_value sdv
														  INNER JOIN static_data_type sdt
														  	ON sdt.type_id = sdv.type_id
														  WHERE sdt.type_name = ''Certification Systems'''
	WHERE field_id = 112000

	PRINT 'Field ID: 112000 updated successfully.'
END