IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166910)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10166910, 'Add/Save', 'Add/Save', 10166900, NULL)
 	PRINT ' Inserted 10166910 - TRMTracker.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166910 - TRMTracker already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166911)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10166911, 'Update', 'Update', 10166900, NULL)
 	PRINT ' Inserted 10166911 - TRMTracker.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166911 - TRMTracker already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166912)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10166912, 'Delete', 'Delete', 10166900, NULL)
 	PRINT ' Inserted 10166911 - TRMTracker.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166911 - TRMTracker already EXISTS.'
END

UPDATE setup_menu SET menu_type = 0 WHERE function_id = 10166900


