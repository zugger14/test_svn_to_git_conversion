IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10142400, 'Derivative Position Report', 'Derivative Position Report', 10140000, 'windowDerivativePositionReport')
 	PRINT ' Inserted 10142400 - Derivative Position Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142400 - Derivative Position Report already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10142400 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10142400, 'windowDerivativePositionReport', 'Derivative Position Report', '', 1, 10140000, 10000000, '', 0)
    PRINT 'Accounting derivative Transaction Processing - 10230095 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10230095 already exists.'
END

--SELECT * FROM setup_menu ORDER BY 1 DESC

--DELETE FROM setup_menu WHERE setup_menu_id = 1087