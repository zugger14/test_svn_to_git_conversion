IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181318)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10181318, 'Limit', 'Limit - Maintain Limits', 10181300, '')
 	PRINT ' Inserted 10181318 - Limit - Maintain Limits.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181318 - Run - Run At Risk Measurement already EXISTS.'
END


UPDATE application_functions SET func_ref_id = NULL WHERE function_id IN (10181311,10181312,10181314)

UPDATE application_functions SET func_ref_id = 10181318 WHERE function_id IN (10181316,10181317)


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166512)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10166512, 'Schedules', 'Schedules - Actualize Schedules', 10166500, '')
 	PRINT ' Inserted 10166512 - Schedules - Actualize Schedules.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166512 - Schedules - Actualize Schedules already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166513)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10166513, 'Save', 'Save - Schedules - Actualize Schedules', 10166512, '')
 	PRINT ' Inserted 10166513 - Save - Schedules - Actualize Schedules.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166513 - Save - Schedules - Actualize Schedules already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166514)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10166514, 'Unmatch', 'Unmatch - Schedules - Actualize Schedules', 10166512, '')
 	PRINT ' Inserted 10166514 - Unmatch - Schedules - Actualize Schedules.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166514 - Unmatch - Schedules - Actualize Schedules already EXISTS.'
END