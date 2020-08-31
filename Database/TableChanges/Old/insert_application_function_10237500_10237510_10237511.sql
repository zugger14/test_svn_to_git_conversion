IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237500)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10237500, 'Close Accounting Period', 'Close Accounting Period', 10230000, 'windowClosingAccountingPeriod', '_accounting/derivative/ongoing_assessment/close_msmt_books/close.accounting.period.php')
 	PRINT ' Inserted 10237500 - Close Accounting Period.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237500 - Close Accounting Period already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237510)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237510, 'Close Accounting Period- Run', 'Close Accounting Period- Run', 10237500, NULL)
 	PRINT ' Inserted 10237510 - Close Accounting Period- Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237510 - Close Accounting Period- Run already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237511)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237511, 'Close Accounting Period- Delete', 'Close Accounting Period- Delete', 10237500, NULL)
 	PRINT ' Inserted 10237511 - Close Accounting Period- Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237511 - Close Accounting Period- Delete already EXISTS.'
END

UPDATE application_functions SET function_name = 'Run' WHERE function_id = 10237510
UPDATE application_functions SET function_name = 'Delete' WHERE function_id = 10237511