
--Application function
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211213)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211213, 'Setup Custom Report Template', 'Setup Custom Report Template', 10100000, 'windowReportTemplateSetup')
 	PRINT ' Inserted 10211213 - Custom Report Template.'
END
ELSE
BEGIN
	UPDATE application_functions 
	 SET function_name = 'Setup Custom Report Template',
		function_desc = 'Setup Custom Report Template',
		func_ref_id = 10100000,
		function_call = 'windowReportTemplateSetup'
		 WHERE [function_id] = 10211213
	PRINT 'Updated Application Function '

END
GO

UPDATE application_functions
SET file_path = '_setup/custom_report_template/custom.report.template.php'
WHERE function_id = 10211213

GO


--setup_menu
DELETE FROM setup_menu WHERE parent_menu_id = 10211220
DELETE FROM setup_menu WHERE function_id = 10211220

GO
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10211213 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10211213, NULL , 'Setup Custom Report Template', '', 1, 10100000, 10000000, '', 1)
    PRINT 'Setup Custom Report Template - 10211213 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10211213 already exists.'
END

GO