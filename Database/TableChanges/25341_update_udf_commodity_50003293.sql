IF EXISTS (SELECT * FROM user_defined_fields_template WHERE field_id = 50003293)
BEGIN
	UPDATE user_defined_fields_template SET Field_type = 'd', sql_string = 'EXEC spa_source_commodity_maintain ''a'''
	WHERE field_id = 50003293
END