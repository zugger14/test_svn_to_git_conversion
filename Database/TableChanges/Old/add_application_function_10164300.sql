IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10164300, 'EDI', 'EDI', 10160000, 'windowEDI', '_scheduling_delivery/EDI/edi.php')
 	PRINT ' Inserted 10164300 - EDI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164300 - EDI already EXISTS.'
END
