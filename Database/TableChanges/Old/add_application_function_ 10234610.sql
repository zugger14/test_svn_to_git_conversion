IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234610)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234610, 'Process First Day Gain/Loss Treatment', 'Process First Day Gain/Loss Treatment', 10234600, 'windowFirstDayGainLossIU')
 	PRINT ' Inserted 10234610 - Process First Day Gain/Loss Treatment.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234610 - Process First Day Gain/Loss Treatment already EXISTS.'
END
