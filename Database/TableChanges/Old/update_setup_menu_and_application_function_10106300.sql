IF EXISTS (SELECT 1 FROM setup_menu WHERE display_name = 'Data Import/Export New UI' and function_id = 10106300)
BEGIN	
	UPDATE
	setup_menu
	SET
	parent_menu_id = 10100000
	WHERE function_id = 10106300 AND product_category = 10000000
	PRINT 'Data Import/Export New UI Updated.'
END
ELSE
BEGIN
	PRINT 'Data Import/Export New UI Doesnot exists.'
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10106300)
BEGIN
	Update
	application_functions
	SET
	func_ref_id = 10100000
	WHERE
	function_id = 10106300 
	PRINT 'Data Import/Export New UI Updated successfully.'
END
ELSE
BEGIN
	PRINT 'Data Import/Export New UI Doesnot exists.'
END

