IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161200)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10161200, 'Run Daily Gas Position Report', 'Run Daily Gas Position Report', 10160000, 'windowPositionGas', '_scheduling_delivery/run.gas.position.report.php')
 	PRINT ' Inserted 10161200 - Run Daily Gas Position Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161200 - Run Daily Gas Position Report already EXISTS.'
END
