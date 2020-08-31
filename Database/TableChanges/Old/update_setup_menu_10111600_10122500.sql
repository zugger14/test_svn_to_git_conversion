IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = '10111600')
BEGIN
	UPDATE setup_menu 
	SET display_name = 'Maintain Events Rules'
	WHERE function_id = '10111600' AND product_category = '13000000'
END
ELSE
	PRINT 'Data can not be updated.'
	
	
	IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = '10122500')
BEGIN
	UPDATE setup_menu 
	SET display_name = 'Maintain Events Rules'
	WHERE function_id = '10122500' AND product_category = '10000000'
END
ELSE
	PRINT 'Data can not be updated.'
	

