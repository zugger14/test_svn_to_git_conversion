IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202300)
BEGIN
  INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
 VALUES (10202300, 'Run Process', 'Run Process', 10200000, 'windowRunProcess', '_reporting/view_report/run.process.php')
  PRINT ' Inserted 10202300 - Run Process.'
END
ELSE
BEGIN
 PRINT 'Application FunctionID 10202300 - Run Process already EXISTS.'
END