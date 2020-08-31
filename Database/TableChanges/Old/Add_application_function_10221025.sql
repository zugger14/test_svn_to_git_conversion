IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221025)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10221025, 'RFP Report', 'RFP Report', 10221010, 'windowrfpinput')
 	PRINT ' Inserted 10221025 - RFP Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10221025 - RFP Report already EXISTS.'
END
