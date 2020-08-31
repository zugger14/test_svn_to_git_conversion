IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201000, 'Report Writer', 'Report Writer', 10200000, 'windowreportwriter')
 	PRINT ' Inserted 10201000 - Report Writer.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201000 - Report Writer already EXISTS.'
END

UPDATE application_functions set file_path = '_reporting/report_writer/report_writer.php' where application_functions.function_id = 10201000

