--Added standard reports in view report

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10221200 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10221200,
		NULL,
		'Contract Settlement Report',
		0,
		10202200,
		10000000,
		6
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'
	
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10222400 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10222400,
		NULL,
		'Meter Data Report',
		0,
		10202200,
		10000000,
		7
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'
	
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10111300 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10111300,
		NULL,
		'Privilege Report',
		0,
		10202200,
		10000000,
		8
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10111400 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10111400,
		NULL,
		'System Access Log Report',
		0,
		10202200,
		10000000,
		9
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'				


	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10171100 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10171100,
		NULL,
		'Transaction Audit Log Report',
		0,
		10202200,
		10000000,
		10
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'				

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201500 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10201500,
		NULL,
		'Static Data Audit Report',
		0,
		10202200,
		10000000,
		11
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201900 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10201900,
		NULL,
		'Data Import/Export Audit Report',
		0,
		10202200,
		10000000,
		12
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10221900 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10221900,
		NULL,
		'Deal Settlement Report',
		0,
		10202200,
		10000000,
		13
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	

UPDATE application_functions SET function_name = 'Add/Save' WHERE function_id = 10106110	--Time Series IU
UPDATE application_functions SET function_name = 'Delete' WHERE function_id = 10106111	--Time Series Delete


UPDATE application_functions SET func_ref_id = NULL WHERE function_id = 10106112	--Series Values IU
UPDATE application_functions SET func_ref_id = NULL WHERE function_id = 10106113	--Series Values Delete