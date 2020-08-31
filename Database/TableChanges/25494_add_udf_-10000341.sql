IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Broker Relevant')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000341, 'Broker Relevant', 'd', 'VARCHAR(250)', 'n', 'SELECT ''n'' [value], ''No'' [code] UNION ALL SELECT ''y'' , ''Yes''', 'h', NULL, 400, -10000341
	PRINT 'UDF Created.'
END
ELSE
BEGIN
	PRINT 'UDF aleady exists.'
END
	




	