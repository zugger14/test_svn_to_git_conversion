IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202200)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10202200, 'View Report', 'View Report', 10200000, 'windowViewReport', '_reporting/view_report/view.report.php')
 	PRINT ' Inserted 10202200 - View Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202200 - View Report already EXISTS.'
END