IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101050)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path)
	VALUES (10101050, 'Account', 'Account', 10101000, 'windowMaintainHourgroup', 'Administration/Setup/maintain static data.htm')
 	PRINT ' Inserted 10101050 -Account.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101050 - already EXISTS.'
END

--10101050


