IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234300, 'Automation of Forecasted Transaction', 'Automation of Forecasted Transaction', 10230000, 'windowAutomationofForecastedTransaction')
 	PRINT ' Inserted 10234300 - Automation of Forecasted Transaction.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234300 - Automation of Forecasted Transaction already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234310)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234310, 'Select Deals Group', 'Select Deals Group', 10234300, 'windowGenDealsGroupIU')
 	PRINT ' Inserted 10234310 - Select Deals Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234310 - Select Deals Group already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234311)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234311, 'Delete Automation of Forecasted Transaction', 'Delete Automation of Forecasted Transaction', 10234300, NULL)
 	PRINT ' Inserted 10234311 - Delete Automation of Forecasted Transaction.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234311 - Delete Automation of Forecasted Transaction already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234312)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234312, 'Update General Deal Groups IU', 'Update General Deal Groups IU', 10234300, 'windowGenDealsGroupDetailIU')
 	PRINT ' Inserted 10234312 - Update General Deal Groups IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234312 - Update General Deal Groups IU already EXISTS.'
END
