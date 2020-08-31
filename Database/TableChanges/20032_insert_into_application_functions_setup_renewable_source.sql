--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101700)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (12101700, 'Setup Renewable Sources', 'Setup Renewable Sources', NULL, '', NULL, NULL, 1)
	PRINT ' Inserted 12101700 - Setup Renewable Sources.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101700 - Setup Renewable Sources already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 12101700 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (12101700, 'Setup Renewable Source', 10101099, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 12101700 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 12101700 already EXISTS.'
END
                    
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101710)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (12101710, 'Add/Save/Copy', 'Setup Renewable Generators Edit', 12101700, '', NULL, NULL, 1)
	PRINT ' Inserted 12101710 - Add/Save/Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101710 - Add/Save/Copy already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101711)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (12101711, 'Delete', 'Renewable Generators Delete', 12101700, '', NULL, NULL, 1)
	PRINT ' Inserted 12101711 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101711 - Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101712)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (12101712, 'Setup Source Group', 'Setup Source Group', 12101700, '', NULL, NULL, 0)
	PRINT ' Inserted 12101712 - Setup Source Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101712 - Setup Source Group already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101713)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (12101713, 'Add/Save/Delete', 'Setup Source Group IU', 12101712, '', NULL, NULL, 0)
	PRINT ' Inserted 12101713 - Add/Save/Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101713 - Add/Save/Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101720)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (12101720, 'Assignment', 'Assignment Form', 12101700, '', NULL, NULL, 0)
	PRINT ' Inserted 12101720 - Assignment.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101720 - Assignment already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101721)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (12101721, 'Add/Save', 'Assignment Form Details', 12101720, '', NULL, NULL, 0)
	PRINT ' Inserted 12101721 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101721 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101722)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (12101722, 'Delete', 'Assignment Form Delete', 12101720, '', NULL, NULL, 0)
	PRINT ' Inserted 12101722 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101722 - Delete already EXISTS.'
END

DELETE
FROM application_functions
WHERE function_id = 12101724

GO