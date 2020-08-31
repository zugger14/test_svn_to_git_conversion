IF EXISTS(SELECT 1 FROM application_functions where function_id = 10221310)
BEGIN 
	UPDATE application_functions SET function_name = 'Delete', function_desc = 'Delete'  WHERE function_id = 10221310
END
ELSE 
BEGIN
	PRINT 'Application FunctionID 10221310 does not EXIST. '
END

------------------------------------------------------------------------------------------------------

IF EXISTS(SELECT 1 FROM application_functions where function_id = 10221311)
BEGIN 
	UPDATE application_functions SET function_name = 'Void', function_desc = 'Void'  WHERE function_id = 10221311
END
ELSE 
BEGIN
	PRINT 'Application FunctionID 10221311 does not EXIST. '
END

------------------------------------------------------------------------------------------------------

IF EXISTS(SELECT 1 FROM application_functions where function_id = 10221316)
BEGIN 
	UPDATE application_functions SET function_name = 'Finalize And Unfinalize', function_desc = 'Finalize And Unfinalize'  WHERE function_id = 10221316
END
ELSE 
BEGIN
	PRINT 'Application FunctionID 10221316 does not EXIST. '
END

------------------------------------------------------------------------------------------------------

IF EXISTS(SELECT 1 FROM application_functions where function_id = 10221317)
BEGIN 
	UPDATE application_functions SET function_name = 'Lock And Unlock', function_desc = 'Lock And Unlock'  WHERE function_id = 10221317
END
ELSE 
BEGIN
	PRINT 'Application FunctionID 10221317 does not EXIST. '
END