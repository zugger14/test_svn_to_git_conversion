IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164100)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10164100, 'Update Demand Volume', 'Update Demand Volume', 10160000, 'windowUpdateDemandVolume')
 	PRINT ' Inserted 10164100 - Update Demand Volume.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164100 - Update Demand Volume already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164110)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10164110, 'Update Demand Volume IU', 'Update Demand Volume IU', 10164100, NULL)
 	PRINT ' Inserted 10164110 - Update Demand Volume IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164110 - Update Demand Volume IU already EXISTS.'
END