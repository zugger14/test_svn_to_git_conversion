IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10121015)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10121015, 'Maintain Compliance Activity IU_Copy', 'Maintain Compliance Activity IU_Copy', 10121014, 'windowCompActivityIU')
 	PRINT ' Inserted 10121015 - Maintain Compliance Activity IU_Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121015 - Maintain Compliance Activity IU_Copy already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10121016)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10121016, 'Delete Compliance Activity', 'Delete Compliance Activity', 10121014, NULL)
	PRINT ' Inserted 10121016 -Delete Compliance Activity.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121016 -Delete Compliance Activity already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10121017)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10121017, 'Maintain Compliance Activities Dependency', 'Maintain Compliance Activities Dependency', 10121014, 'windowCompActivityDependent')

 	PRINT ' Inserted 10121017 - Maintain Compliance Activities Dependency.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121017 -Maintain Compliance Activities Dependency already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10121018)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10121018, 'Perform Compliance Steps IU', 'Perform Compliance Steps IU', 10121014, 'reportDummyStepsIU')
 	PRINT ' Inserted 10121018 - Perform Compliance Steps IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121018 - Perform Compliance Steps IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10121019)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10121019, 'Delete Compliance Steps', 'Delete Compliance Steps', 10121014, NULL)
	PRINT ' Inserted 10121019 - Delete Compliance Steps.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121019 - Delete Compliance Steps already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10121024)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10121024	,'Create Compliance Activity Instance'	,'Create Compliance Activity Instance', 10121014, NULL)
	PRINT ' Inserted 10121024 - Create Compliance Activity Instance.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121024 - Create Compliance Activity Instance already EXISTS.'
END
