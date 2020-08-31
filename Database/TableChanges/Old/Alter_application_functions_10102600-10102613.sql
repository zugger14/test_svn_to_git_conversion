IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102600)
BEGIN
 	UPDATE application_functions set function_name = 'View' where function_id = 10102600
 	PRINT ' Function name changed.'
END
ELSE
BEGIN
	PRINT 'Application Function ID 10102600 does not exist.'
END


IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102610)
BEGIN
 	UPDATE application_functions set function_name = 'Add/Save' where function_id = 10102610
 	PRINT ' Function name changed.'
END
ELSE
BEGIN
	PRINT 'Application Function ID 10102610 does not exist.'
END


IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102611)
BEGIN
 	UPDATE application_functions set function_name = 'Delete' where function_id = 10102611
 	PRINT ' Function name changed.'
END
ELSE
BEGIN
	PRINT 'Application Function ID 10102611 does not exist.'
END


IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102612)
BEGIN
 	UPDATE application_functions set function_name = 'Insert/Update Privilege' where function_id = 10102612
 	PRINT ' Function name changed.'
END
ELSE
BEGIN
	PRINT 'Application Function ID 10102612 does not exist.'
END


IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102613)
BEGIN
 	UPDATE application_functions set function_name = 'Delete Privilege' where function_id = 10102613
 	PRINT ' Function name changed.'
END
ELSE
BEGIN
	PRINT 'Application Function ID 10102613 does not exist.'
END
