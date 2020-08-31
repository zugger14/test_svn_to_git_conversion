IF EXISTS (SELECT * FROM user_defined_fields_template WHERE field_id = -10000320)
BEGIN
	UPDATE user_defined_fields_template SET data_type = 'numeric(38,20)'
	WHERE field_id = -10000320
	PRINT ('Data type updated for UDF -10000320')
END
	