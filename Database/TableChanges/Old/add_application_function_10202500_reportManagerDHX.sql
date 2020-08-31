IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202500)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10202500, 'Report Manager DHX', 'Report Manager DHX', 10200000, 'windowReportManagerDHX', '_reporting/report_manager_dhx/report.manager.dhx.php')
 	PRINT ' Inserted 10202500 - Report Manager DHX.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202500 - Report Manager DHX already EXISTS.'
END
--delete from application_functions where function_id = 10202500
