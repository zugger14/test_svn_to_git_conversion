--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10167500)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10167500, 'View Available Pipeline Capacity', 'View Available Pipeline Capacity', NULL, '_scheduling_delivery/view_available_pipeline_capacity/view.available.pipeline.capacity.php', NULL, NULL, 0)
	PRINT ' Inserted 10167500 - View Available Pipeline Capacity.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10167500 - View Available Pipeline Capacity already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10167500 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10167500, 'View Available Pipeline Capacity', 10161499, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 10167500 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10167500 already EXISTS.'
END



