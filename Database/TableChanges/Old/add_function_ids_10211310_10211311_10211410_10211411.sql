-- Standard

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211216)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211216, 'Maintain Standard Contract Document', 'Maintain Standard Contract Document', 10211300, NULL)
 	PRINT ' Inserted 10211216 - Maintain Standard Contract Document.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211216 - Maintain Standard Contract Document exists.'
END

-- Non Standard Contract

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211310)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211310, 'Maintain Non Standard Contract IU', 'Maintain Non Standard Contract IU', 10211300, NULL)
 	PRINT ' Inserted 10211310 - Maintain Non Standard Contract IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211310 - Maintain Non Standard Contract IU exists.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211311)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211311, 'Maintain Non Standard Contract Delete', 'Maintain Non Standard Contract Delete', 10211300, NULL)
 	PRINT ' Inserted 10211311 - Maintain Non Standard Contract Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211311 - Maintain Non Standard Contract Delete exists.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211312)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211312, 'Maintain Non Standard Contract Copy', 'Maintain Non Standard Contract Copy', 10211300, NULL)
 	PRINT ' Inserted 10211312 - Maintain Non Standard Contract Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211312 - Maintain Non Standard Contract Copy exists.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211313)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211313, 'Maintain Non Standard Contract Document', 'Maintain Non Standard Contract Document', 10211300, NULL)
 	PRINT ' Inserted 10211313 - Maintain Non Standard Contract Document.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211313 - Maintain Non Standard Contract Document exists.'
END

-- Transportation Contract

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211410)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211410, 'Maintain Transportation Contract IU', 'Maintain Transportation Contract IU', 10211400, NULL)
 	PRINT ' Inserted 10211410 - Maintain Transportation Contract IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211410 - Maintain Transportation Contract IU exists.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211411)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211411, 'Maintain Transportation Contract Delete', 'Maintain Transportation Contract Delete', 10211400, NULL)
 	PRINT ' Inserted 10211411 - Maintain Transportation Contract Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211411 - Maintain Transportation Contract Delete exists.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211412)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211412, 'Maintain Transportation Contract Copy', 'Maintain Transportation Contract Copy', 10211400, NULL)
 	PRINT ' Inserted 10211412 - Maintain Transportation Contract Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211412 - Maintain Transportation Contract Copy exists.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211413)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211413, 'Maintain Transportation Contract Document', 'Maintain Transportation Contract Document', 10211400, NULL)
 	PRINT ' Inserted 10211413 - Maintain Transportation Contract Document.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211413 - Maintain Transportation Contract Document exists.'
END