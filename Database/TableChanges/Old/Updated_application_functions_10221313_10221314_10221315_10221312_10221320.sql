--IF EXISTS(SELECT 1 FROM application_functions where function_id = 10221313)
--BEGIN 
--	--UPDATE application_functions SET function_name = 'View Audit', function_desc = 'View Audit', func_ref_id = 10221300, book_required = 0 WHERE function_id = 10221313
--	DELETE FROM application_functions WHERE function_id = 10221313
--END
--ELSE 
--BEGIN
--	PRINT 'Application FunctionID 10221313 does not EXIST. '
--END

------------------------------------------------------------------------------------------------------

IF EXISTS(SELECT 1 FROM application_functions where function_id = 10221314)
BEGIN 
	UPDATE application_functions SET function_name = 'Save', function_desc = 'Save', func_ref_id = 10221300, book_required = 1 WHERE function_id = 10221314
END
ELSE 
BEGIN
	PRINT 'Application FunctionID 10221314 does not EXIST. '
END

------------------------------------------------------------------------------------------------------

IF EXISTS(SELECT 1 FROM application_functions where function_id = 10221315)
BEGIN 
	UPDATE application_functions SET function_name = 'Document', function_desc = 'Document', func_ref_id = 10221300, book_required = 0 WHERE function_id = 10221315
END
ELSE 
BEGIN
	PRINT 'Application FunctionID 10221315 does not EXIST. '
END

------------------------------------------------------------------------------------------------------

IF EXISTS(SELECT 1 FROM application_functions where function_id = 10221312)
BEGIN 
	UPDATE application_functions SET function_name = 'Add/Save Counterparty Invoice', function_desc = 'Add/Save Counterparty Invoice'  WHERE function_id = 10221312
END
ELSE 
BEGIN
	PRINT 'Application FunctionID 10221312 does not EXIST. '
END

--------------------------------------------------------------------------------------------------------

--IF EXISTS(SELECT 1 FROM application_functions where function_id = 10221320)
--BEGIN 
--	--UPDATE application_functions SET function_name = 'View Detail', function_desc = 'View Detail'  WHERE function_id = 10221320
--	DELETE FROM application_functions WHERE function_id = 10221320
--END
--ELSE 
--BEGIN
--	PRINT 'Application FunctionID 10221320 does not EXIST. '
--END
