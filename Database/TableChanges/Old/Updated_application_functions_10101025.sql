IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101025)
BEGIN
 	UPDATE application_functions
	SET    func_ref_id = 10101000
	WHERE  [function_id] = 10101025
	
 	PRINT ' Updated 10101025 - Tier Type Properties.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101025 - Tier Type Properties does not exist.'
END
