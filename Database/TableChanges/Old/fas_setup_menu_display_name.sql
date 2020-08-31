
--Insert into application_functions
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10201800 AND sm.product_category = 13000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, product_category,menu_order)
	VALUES (10201800, 'Report Group Manager', 13121295, 1, 0, 13000000,'')
	PRINT ' Setup Menu 10201800 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10201800 already EXISTS.'
END
      

--Insert into application_functions
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10106699 AND sm.product_category = 13000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, product_category,menu_order)
	VALUES (10106699, 'Alert and Workflow', 10100000, 1, 1, 13000000,'')
	PRINT ' Setup Menu 10106699 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10106699 already EXISTS.'
END


UPDATE setup_menu
	SET display_name = 'Setup Advanced Workflow Rule',
		parent_menu_id = 10106699,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 10122500
		AND [product_category]= 13000000
PRINT 'Updated Setup Menu.'


--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10106600 AND sm.product_category = 13000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, product_category,menu_order)
	VALUES (10106600, 'Setup Workflow/Alert', 10106699, 1, 0, 13000000,'')
	PRINT ' Setup Menu 10106600 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10106600 already EXISTS.'
END


--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10106700 AND sm.product_category = 13000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, product_category,menu_order)
	VALUES (10106700, 'Manage Approval', 10106699, 1, 0, 13000000,'')
	PRINT ' Setup Menu 10106700 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10106700 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10122600 AND sm.product_category = 13000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, product_category,menu_order)
	VALUES (10122600, 'Setup Simple Alert', 10106699, 1, 0, 13000000,'')
	PRINT ' Setup Menu 10122600 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10122600 already EXISTS.'
END


--Update application_functions
UPDATE setup_menu
	SET display_name = 'Report Writer',
		parent_menu_id = 13121295,
		menu_type = 1,
		hide_show = 0
		WHERE [function_id] = 10201000
		AND [product_category]= 13000000
PRINT 'Updated Setup Menu.'
      