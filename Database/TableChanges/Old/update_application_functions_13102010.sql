IF EXISTS(SELECT 1 FROM application_functions WHERE function_id IN (13102010, 13102011))
BEGIN
	UPDATE application_functions SET function_name = 'Add/Save/Delete', function_desc = 'Add/Save/Delete', book_required = 0, func_ref_id = 13102000 WHERE function_id = 13102010
	DELETE FROM dbo.application_functional_users WHERE function_id = 13102011
	DELETE FROM application_functions WHERE function_id = 13102011
	PRINT 'Updated table successfully.'
END
ELSE
BEGIN
	PRINT 'Function Id does not Exist.'
END