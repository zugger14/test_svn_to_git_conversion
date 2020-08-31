

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = '10141300' AND product_category = '10000000')
BEGIN
	UPDATE setup_menu 
	SET display_name = 'Run Position Report'
	WHERE function_id = '10141300' AND product_category = '10000000'
END
ELSE
	PRINT 'Data can not be updated.'
	

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = '10141300' AND product_category = '12000000')
BEGIN
	UPDATE setup_menu 
	SET display_name = 'Run Position Report'
	WHERE function_id = '10141300' AND product_category = '12000000'
END
ELSE
	PRINT 'Data can not be updated.'
	

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = '10141300' AND product_category = '14000000')
BEGIN
	UPDATE setup_menu 
	SET display_name = 'Run Position Report'
	WHERE function_id = '10141300' AND product_category = '14000000'
END
ELSE
	PRINT 'Data can not be updated.'
