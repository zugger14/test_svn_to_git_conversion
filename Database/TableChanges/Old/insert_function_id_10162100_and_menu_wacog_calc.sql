--select * from application_functions where function_id = 10162100
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162100)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10162100, 'Run Storage WACOG Calc', 'Run Storage WACOG Calc', 10160000, 'windowWACOG')
 	PRINT ' Inserted 10162100 - Run Storage WACOG Calc.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162100 - Run Storage WACOG Calc already EXISTS.'
END


-- update file path for wacog calculation
update application_functions set file_path ='_scheduling_delivery/run_storage_wacog_calc/run.storage.wacog.calc.php' where function_id = 10162100


-- insert menu
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10162100 AND product_category = 10000000) 
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order)
	VALUES (10162100, 'windowWACOG', 'Run Storage WACOG Calc', 1, 10160000, 10000000, 137)	
END
ELSE
BEGIN
	PRINT 'Menu 10162100 -  Run Storage WACOG Calc already exists.'
END

update setup_menu set display_name = 'Run Storage WACOG Calc' WHERE function_id = 10162100



