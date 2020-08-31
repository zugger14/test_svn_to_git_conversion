IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234100)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10234100, 'Amortize Deferred AOCI', 'Amortize Deferred AOCI', 10230000, 'windowAmortizeLockedAOCI', '_accounting/derivative/transaction_processing/amortize_locked_aoci/amortize.locked.aoci.php')
 	PRINT ' Inserted 10234100 - Amortize Deferred AOCI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234100 - Amortize Deferred AOCI already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234110)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234110, 'Delete Amortize Deferred AOCI', 'Delete Amortize Deferred AOCI', 10234100, NULL)
 	PRINT ' Inserted 10234110 - Delete Amortize Deferred AOCI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234110 - Delete Amortize Deferred AOCI already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234111)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234111, 'Amortize Amortize Deferred AOCI', 'Amortize Amortize Deferred AOCI', 10234100, NULL)
 	PRINT ' Inserted 10234111 - Amortize Amortize Deferred AOCI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234111 - Amortize Amortize Deferred AOCI already EXISTS.'
END
