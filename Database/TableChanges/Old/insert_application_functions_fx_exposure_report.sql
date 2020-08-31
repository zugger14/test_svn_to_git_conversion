IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142100)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10142100, 'Run FX Exposure Report', 'Run FX Exposure Report', 10140000, 'windowRunFXExposureReport')
 	PRINT ' Inserted 10142100 - Run FX Exposure Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142100 - Run FX Exposure Report already EXISTS.'
END
