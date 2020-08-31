IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10202400)
BEGIN 
	INSERT INTO application_functions(function_id
									, function_name
									, function_desc
									, func_ref_id
									, book_required
									, file_path
									, function_call)
	SELECT 10202400, 'Run Purge Process', 'Run Purge Process', 10200000, 1, '_reporting/run_purge_process/run_purge_process.php', 'windowRunPurgeProcess'
END 
GO

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10202400 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id
						, window_name
						, display_name
						, hide_show
						, parent_menu_id
						, product_category
						, menu_order
						, menu_type)
	SELECT 10202400, 'windowRunPurgeProcess', 'Run Purge Process', 1, 10200000, 10000000, 135, 0
END
GO

DELETE FROM setup_menu WHERE function_id = 10202400

DELETE FROM  application_functions WHERE function_id = 10202400

GO

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10166000)
BEGIN 
	INSERT INTO application_functions(function_id
									, function_name
									, function_desc
									, func_ref_id
									, book_required
									, file_path
									, function_call)
	SELECT 10166000, 'Run Purge Process', 'Run Purge Process', 10160000, 1, '_scheduling_delivery/run_purge_process/run_purge_process.php', 'windowRunPurgeProcess'
END 
GO

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10166000 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id
						, window_name
						, display_name
						, hide_show
						, parent_menu_id
						, product_category
						, menu_order
						, menu_type)
	SELECT 10166000, 'windowRunPurgeProcess', 'Run Purge Process', 1, 10160000, 10000000, 135, 0
END
GO