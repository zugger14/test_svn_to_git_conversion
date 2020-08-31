IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10236500)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10236500, 'Run Not Mapped Transaction Report', 'Run Not Mapped Transaction Report', 10230000, 'windowRunNotMappedDealReport')
 	PRINT ' Inserted 10236500 - Run Not Mapped Transaction Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10236500 - Run Not Mapped Transaction Report already EXISTS.'
END