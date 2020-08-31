--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20013700)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20013700, 'Workflow Module - Event mapping', 'Workflow Module - Event mapping', NULL, NULL, '_compliance_management/setup_rule_workflow/workflow.module.event.mapping.php', 0)
    PRINT ' Inserted 20013700 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20013700 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20013700 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20013700, 'Workflow Module - Event mapping', 10106699, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20013700 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20013700 already EXISTS.'
END            