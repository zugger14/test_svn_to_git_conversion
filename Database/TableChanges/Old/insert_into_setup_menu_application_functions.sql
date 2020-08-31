IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 13230000)
BEGIN
	INSERT INTO setup_menu (function_id, display_name, hide_show,parent_menu_id, product_category, menu_type, menu_order)
	SELECT 13230000, 'Run Process', 1, 13000000, 13000000, 1, 70
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13231000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (13231000, 'Run FX Ineffectiveness', 'Run FX Ineffectiveness', 13230000, 'windowRunFxIneffectiveness', '_run_process/run_fx_ineffectiveness/run.fx.ineffectiveness.php')
 	PRINT ' Inserted 13231000 - Run FX Ineffectiveness.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13231000 - Run FX Ineffectiveness already EXISTS.'
END

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 13231000)
BEGIN
	INSERT INTO setup_menu (function_id, display_name, hide_show,parent_menu_id, product_category, menu_type, menu_order, window_name)
	SELECT 13231000, 'Run FX Ineffectiveness', 1, 13230000, 13000000, 0, 1, 'windowRunFxIneffectiveness'
END
