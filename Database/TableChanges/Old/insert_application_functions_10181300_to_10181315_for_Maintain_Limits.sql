IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10181300, 'Maintain Limits', 'Maintain Limits', 10180000, 'LimitTrackingScreen', '_valuation_risk_analysis/run_limits/maintain.limits.php')
 	PRINT ' Inserted 10181300 - Maintain Limits.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181300 - Maintain Limits already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181310)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10181310, 'Maintain Limits IU', 'Maintain Limits IU', 10181300, 'LimitTrackingScreenIU')
 	PRINT ' Inserted 10181310 - Maintain Limits IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181310 - Maintain Limits IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181311)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10181311, 'Maintain Limits Book IU', 'Maintain Limits Book IU', 10181310, 'LimitTrackingBookIU')
 	PRINT ' Inserted 10181311 - Maintain Limits Book IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181311 - Maintain Limits Book IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181312)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10181312, 'Delete Maintain Limits Book', 'Delete Maintain Limits Book', 10181310, NULL)
 	PRINT ' Inserted 10181312 - Delete Maintain Limits Book.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181312 - Delete Maintain Limits Book already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181313)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10181313, 'Maintain Limits Pos Tenor IU', 'Maintain Limits Pos Tenor IU', 10181310, 'LimitTrackingCurveIU')
 	PRINT ' Inserted 10181313 - Maintain Limits Pos Tenor IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181313 - Maintain Limits Pos Tenor IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181314)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10181314, 'Delete Maintain Limits Pos Tenor', 'Delete Maintain Limits Pos Tenor', 10181310, NULL)
 	PRINT ' Inserted 10181314 - Delete Maintain Limits Pos Tenor.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181314 - Delete Maintain Limits Pos Tenor already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181315)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10181315, 'Delete Maintain Limits', 'Delete Maintain Limits', 10181300, NULL)
 	PRINT ' Inserted 10181315 - Delete Maintain Limits.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181315 - Delete Maintain Limits already EXISTS.'
END
