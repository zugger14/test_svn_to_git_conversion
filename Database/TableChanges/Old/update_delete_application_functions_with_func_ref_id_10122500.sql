IF EXISTS(SELECT 1 FROM application_functions where function_id = 10122510 AND func_ref_id = 10122500)
BEGIN
	UPDATE application_functions SET function_name = 'Add/Save' WHERE function_id = 10122510 AND func_ref_id = 10122500
	PRINT 'Function ID 10102510 updated successfully.'
END

IF EXISTS(SELECT 1 FROM application_functions where function_id = 10122511 AND func_ref_id = 10122500)
BEGIN
	UPDATE application_functions SET function_name = 'Delete' WHERE function_id = 10122511 AND func_ref_id = 10122500
	PRINT 'Function ID 10122511 updated successfully.'
END

IF EXISTS(SELECT 1 FROM application_functions where function_id IN(10122512,10122513,10122514,10122515,10122516,10122517,10122518,10122519) AND func_ref_id = 10122500)
BEGIN
	DELETE FROM application_functional_users where function_id IN (10122512,10122513,10122514,10122515,10122516,10122517,10122518,10122519)
	DELETE FROM application_functions WHERE function_id IN(10122512,10122513,10122514,10122515,10122516,10122517,10122518,10122519)
	PRINT 'Function ID 10122512,10122513,10122514,10122515,10122516,10122517,10122518,10122519 deleted successfully.'
END