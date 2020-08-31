IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10106600 AND product_category = 10000000 )
BEGIN
	UPDATE setup_menu
	SET display_name = 'Setup Workflow'
		WHERE [function_id] = 10106600
		AND [product_category]= 10000000
	PRINT 'Updated Setup Menu - Setup Workflow/Alerts.'
END
ELSE
BEGIN 
	PRINT 'Setup Menu - Setup Workflow/Alerts doesnot EXISTS'
END

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10106700 AND product_category = 10000000 )
BEGIN
	UPDATE setup_menu
	SET display_name = 'Manage Workflow Approval'
		WHERE [function_id] = 10106700
		AND [product_category]= 10000000
	PRINT 'Updated Setup Menu - Manage Approval.'
END
ELSE
BEGIN 
	PRINT 'Setup Menu - Manage Approval doesnot EXISTS'
END

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10122600 AND product_category = 10000000 )
BEGIN
	UPDATE setup_menu
	SET display_name = 'Setup Simple Workflow'
		WHERE [function_id] = 10122600
		AND [product_category]= 10000000
	PRINT 'Updated Setup Menu - Setup Simple Alert.'
END
ELSE
BEGIN 
	PRINT 'Setup Menu - Setup Simple Alert doesnot EXISTS'
END

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 20013700 AND product_category = 10000000 )
BEGIN
	UPDATE setup_menu
	SET display_name = 'Setup Workflow Mapping'
		WHERE [function_id] = 20013700
		AND [product_category]= 10000000
	PRINT 'Updated Setup Menu - Workflow Module Mapping.'
END
ELSE
BEGIN 
	PRINT 'Setup Menu - Workflow Module Mapping doesnot EXISTS'
END