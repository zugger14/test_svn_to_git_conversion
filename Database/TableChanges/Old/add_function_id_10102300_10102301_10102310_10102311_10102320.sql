IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142300)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10142300, 'Run Order Report', 'Run Order report', 10140000, 'windowRunOrderReport')
 	PRINT ' Inserted 10142300 - Run Order Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142300 - Run Order Report already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142301)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10142301, 'Run Order Calc', 'Run Order Calc', 10142300, 'windowRunOrderReport')
 	PRINT ' Inserted 10142301 - Run Order Calc.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142301 - Run Order Calc already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142310)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10142310, 'Run Order Copy', 'Run Order Copy', 10142300, 'windowRunOrderReport')
 	PRINT ' Inserted 10142310 - Run Order Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142310 - Run Order Copy already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142311)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10142311, 'Run Order Order', 'Run Order Order', 10142300, 'windowRunOrderReport')
 	PRINT ' Inserted 10142311 - Run Order Order.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142311 - Run Order Order already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142320)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10142320, 'Run Order Exclude ST dates', 'Run Order Exclude ST dates', 10142300, 'windowExcludeSTDates')
 	PRINT ' Inserted 10142320 - Run Order Exclude ST dates.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142320 - Run Order Exclude ST dates already EXISTS.'
END
