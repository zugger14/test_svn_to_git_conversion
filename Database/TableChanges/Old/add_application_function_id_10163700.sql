IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163700)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10163700, 'Scheduling Workbench', 'Scheduling Workbench', 10160000, 'windowSchedulingWorkbench', '_scheduling_delivery/scheduling_workbench/scheduling.workbench.php')
 	PRINT ' Inserted 10163700 - Scheduling Workbench.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163700 - Scheduling Workbench already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10163700 AND product_category = 10000000)
BEGIN 
	INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	SELECT 10163700, 'windowSchedulingWorkbench', 'Scheduling Workbench', '', 1, 10160000, 10000000, 100, 0
END 
ELSE 
BEGIN 
	PRINT '10163700 already exists.'
END 

GO
