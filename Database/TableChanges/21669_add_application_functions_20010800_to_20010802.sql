--Insert into application_functions - 20010800
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20010800)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20010800, 'Run Margin Analysis', 'Run Margin Analysis', NULL, NULL, '_valuation_risk_analysis/margin_analysis/margin.analysis.php', 0)
    PRINT ' Inserted 20010800 - Run Margin Analysis.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20010800 - Run Margin Analysis already EXISTS.'
END

--Insert into application_functions - 20010801
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20010801)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20010801, 'Add/Save', 'Add/Save', 20010800, NULL, NULL, 0)
    PRINT ' Inserted 20010801 - Add/Save.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20010801 - Add/Save already EXISTS.'
END

--Insert into application_functions - 20010802
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20010802)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20010802, 'Delete', 'Delete', 20010800, NULL, NULL, 0)
    PRINT ' Inserted 20010802 - Delete.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20010802 - Delete already EXISTS.'
END            