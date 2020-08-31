IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182800)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182800, 'Run MTM Explain Report', 'Run MTM Explain Report', 10180000, 'windowRunMTMExplainReport')
 	PRINT ' Inserted 10182800 - Run MTM Explain Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182800 - Run MTM Explain Report already EXISTS.'
END	