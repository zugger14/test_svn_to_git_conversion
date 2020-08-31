IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233600)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path) 
	VALUES (10233600, 'Close Accounting Period', 'Close Accounting Period', 10230000, 'windowCloseMeasurement', '_accounting/derivative/ongoing_assessment/close_msmt_books/close.msmt.books.php')
 	PRINT ' Inserted 10233600 - Close Accounting Period.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233600 - Close Accounting Period already EXISTS.'
END
