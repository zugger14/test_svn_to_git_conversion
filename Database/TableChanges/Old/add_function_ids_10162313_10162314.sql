IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162313)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162313, 'General Asset Information Constraints', 'General Asset Information Constraints', 10162310, 'windowVirtualConstraints')
 	PRINT ' Inserted 10162313 - General Asset Information Constraints.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162313 - General Asset Information Constraints already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162314)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162314, 'General Asset Information View Hourly', 'General Asset Information View Hourly', 10162310, 'windowSelectDealType')
 	PRINT ' Inserted 10162314 - General Asset Information View Hourly.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162314 - General Asset Information View Hourly already EXISTS.'
END
