IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183014)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183014, 'Curve Mapping', 'Curve Mapping', 10183000, '')
 	PRINT ' Inserted 10183014 - Curve Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183014 - Curve Mapping already EXISTS.'
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10183012)
BEGIN	
	UPDATE application_functions
	SET	function_name = 'Add/Save', func_ref_id = 10183014 WHERE function_id = 10183012
END 
IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10183013)
BEGIN
	UPDATE application_functions
	SET	function_name = 'Delete' , func_ref_id = 10183014 WHERE function_id = 10183013
END 
