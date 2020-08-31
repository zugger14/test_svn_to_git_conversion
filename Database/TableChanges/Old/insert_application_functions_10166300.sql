IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10166300, 'Copy Nomination', 'Copy Nomination', 10160000, 'windowCopyNomination', '_scheduling_delivery/copy_autonom_optimizer/copy.autonom.optimizer.php')
 	PRINT ' Inserted 10166300 - Copy Nomination.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166300 - Copy Nomination already EXISTS.'
END