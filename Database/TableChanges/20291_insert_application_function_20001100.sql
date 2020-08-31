--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20001100)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20001100, 'ICE Interface', 'ICE Interface', NULL, '_setup/ice_interface/ice.interface.php', NULL, NULL, 0)
	PRINT ' Inserted 20001100 - ICE Interface.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20001100 - ICE Interface already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20001100 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20001100, 'ICE Interface', 10106399, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20001100 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20001100 already EXISTS.'
END



--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20001101)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20001101, 'ICE Interface Config', 'ICE Interface Config', 20001100, '', NULL, NULL, 0)
	PRINT ' Inserted 20001101 - ICE Interface Config.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20001101 - ICE Interface Config already EXISTS.'
END




IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20001100)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20001100, 'FIX API Interface', 'FIX API Interface', NULL, '_setup/ice_interface/ice.interface.php', NULL, NULL, 0)
	PRINT ' Inserted 20001100 - FIX API Interface.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20001100 - FIX API Interface already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20001100 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20001100, 'FIX API Interface', 10106399, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20001100 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20001100 already EXISTS.'
END

UPDATE application_functions
	SET function_name = 'FIX API Interface',
		function_desc = 'FIX API Interface',
		func_ref_id = NULL,
		file_path = '_setup/ice_interface/ice.interface.php',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 20001100
PRINT 'Updated Application Function.'
UPDATE setup_menu 
SET display_name = 'FIX API Interface' 
WHERE function_id = 20001100