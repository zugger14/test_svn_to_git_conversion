IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105200)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105200, 'Lock As of Date', 'Lock As of Date', 10100000, 'windowLockAsOfDate')
 	PRINT ' Inserted 10105200 - Lock As of Date.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105200 - Lock As of Date already EXISTS.'
END 

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105201)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105201, 'Lock As of Date IU', 'Lock As of Date IU', 10105200, 'windowLockAsOfDate')
 	PRINT ' Inserted 10105201 - Lock As of Date IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105201 - Lock As of Date IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105211)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105211, 'Lock As of Date Delete', 'Lock As of Date Delete', 10105200, 'windowLockAsOfDate')
 	PRINT ' Inserted 10105211 - Lock As of Date Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105211 - Lock As of Date Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu sm WHERE sm.function_id = 10105200 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu
	(
		function_id,
		window_name,
		display_name,
		default_parameter,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order,
		menu_type
	)
	SELECT 10105200, 'windowLockAsOfDate', 'Lock As of Date', NULL, 1, 10100000, 10000000, 50, 0	
END