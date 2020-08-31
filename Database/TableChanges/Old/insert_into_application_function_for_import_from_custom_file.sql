--Function ID For Import From Custom File
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131341)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131341, 'Import From Custom File', 'Import From Custom File', 10131300, NULL)
 	PRINT ' Inserted 10131341 - Import From Custom File.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131341 - Import From Custom File already EXISTS.'
END

--Function ID For Deal Hourly Data (CSV)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131342)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131342, 'Import From Custom File - Deal Hourly Data (CSV)', 'Deal Hourly Data (CSV)', 10131341, NULL)
 	PRINT ' Inserted 10131342 - Import From Custom File - Deal Hourly Data (CSV).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131342 - Import From Custom File - Deal Hourly Data (CSV) already EXISTS.'
END
--Function ID For Expiration Calendar
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131343)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131343, 'Import From Custom File - Expiration Calendar', 'Expiration Calendar', 10131341, NULL)
 	PRINT ' Inserted 10131343 - Import From Custom File - Expiration Calendar.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131343 - Import From Custom File - Expiration Calendar already EXISTS.'
END
--Function ID For Imbalance Volume
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131344)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131344, 'Import From Custom File - Imbalance Volume', 'Imbalance Volume', 10131341, NULL)
 	PRINT ' Inserted 10131344 - Import From Custom File - Imbalance Volume.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131344 - Import From Custom File - Imbalance Volume already EXISTS.'
END
--Function ID For Storage Schedule Import
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131345)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131345, 'Import From Custom File - Storage Schedule Import', 'Storage Schedule Import', 10131341, NULL)
 	PRINT ' Inserted 10131345 - Import From Custom File - Storage Schedule Import.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131345 - Import From Custom File - Storage Schedule Import already EXISTS.'
END
--Function ID For Deal Hourly Data (LRS)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131346)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131346, 'Import From Custom File - Deal Hourly Data (LRS)', 'Deal Hourly Data (LRS)', 10131341, NULL)
 	PRINT ' Inserted 10131346 - Import From Custom File - Deal Hourly Data (LRS).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131346 - Import From Custom File - Deal Hourly Data (LRS) already EXISTS.'
END
--Function ID For Hourly Data
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131347)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131347, 'Import From Custom File - Hourly Data', 'Hourly Data', 10131341, NULL)
 	PRINT ' Inserted 10131347 - Import From Custom File - Hourly Data.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131347 - Import From Custom File - Hourly Data already EXISTS.'
END
--Function ID For Source System File
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131348)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131348, 'Import From Custom File - Source System File', 'Source System File', 10131341, NULL)
 	PRINT ' Inserted 10131348 - Import From Custom File - Source System File.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131348 - Import From Custom File - Source System File already EXISTS.'
END
--Function ID For Shaped Deal Hourly Data
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131349)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131349, 'Import From Custom File - Shaped Deal Hourly Data', 'Shaped Deal Hourly Data', 10131341, NULL)
 	PRINT ' Inserted 10131349 - Import From Custom File - Shaped Deal Hourly Data.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131349 - Import From Custom File - Shaped Deal Hourly Data already EXISTS.'
END
--Function ID For 15 Mins Data
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131350)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131350, 'Import From Custom File - 15 Mins Data', '15 Mins Data', 10131341, NULL)
 	PRINT ' Inserted 10131350 - Import From Custom File - 15 Mins Data.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131350 - Import From Custom File - 15 Mins Data already EXISTS.'
END