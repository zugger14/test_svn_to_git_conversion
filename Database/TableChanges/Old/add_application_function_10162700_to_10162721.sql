IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162700)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162700, 'Transportation Contract', 'Transportation Contract', 10160000, 'windowTransportationContract')
 	PRINT ' Inserted 10162700 - Transportation Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162700 - Transportation Contract already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162710)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162710, 'Transportation Contract IU', 'Transportation Contract IU', 10162700, 'windowTransportationContractIU')
 	PRINT 'Inserted 10162710 - Transportation Contract IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162710 - Transportation Contract IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162711)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162711, 'Transportation Contract Del', 'Transportation Contract Del', 10162700, NULL)
 	PRINT 'Inserted 10162711 - Transportation Contract Del.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162711 - Transportation Contract Del already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162712)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162712, 'Transportation Contract Copy', 'Transportation Contract Copy', 10162700, NULL)
 	PRINT 'Inserted 10162712 - Transportation Contract Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162712 - Transportation Contract Copy already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162720)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162720, 'Transportation Contract Capacity IU', 'Transportation Contract Capacity IU', 10162710, 'windowTransportationContractCapacityIU')
 	PRINT 'Inserted 10162720 - Transportation Contract Capacity IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162720 - Transportation Contract Detail IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162721)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162721, 'Transportation Contract Capacity Delete', 'Transportation Contract Capacity Delete', 10162710, NULL)
 	PRINT 'Inserted 10162721 - Transportation Contract Capacity Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162721 - Transportation Contract Capacity Delete already EXISTS.'
END