IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164200)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10164200, 'Run Auto Nom Process', 'Run Auto Nom Process', 10160000, 'windowRunAutoNumProcess', '_scheduling_delivery/run_auto_nom_process/run.auto.nom.process.php')
 	PRINT ' Inserted 10164200 - Run Auto Nom Process.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164200 - Run Auto Nom Process already EXISTS.'
END
