IF EXISTS (SELECT * FROM user_defined_fields_template WHERE field_id = 112000)
BEGIN
	UPDATE user_defined_fields_template SET sql_string = 'SELECT ''p'' AS code, ''PJM Inventory'' AS value
		    UNION ALL
			SELECT ''t'' AS code, ''Trayport'' AS value
			UNION ALL
			SELECT ''i'' AS code, ''ICE'' AS value 
			UNION ALL
			SELECT ''m'' AS code, ''MIRECS'' AS value '
	WHERE field_id = 112000
END
	