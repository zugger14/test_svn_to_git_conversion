IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142200)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10142200, 'Run Position Explain Report', 'Run Position Explain Report', 10140000, 'windowRunPositionExplainReport')
 	PRINT ' Inserted 10142200 - Run Position Explain Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142200 - Run Position Explain Report already EXISTS.'
END	


