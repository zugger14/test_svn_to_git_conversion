IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10141310)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10141310, 'Deal Search', 'Deal Search', 10141300, 'windowSearchDeal')
 	PRINT ' Inserted 10141310 - Deal Search.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10141310 - Deal Search already EXISTS.'
END
