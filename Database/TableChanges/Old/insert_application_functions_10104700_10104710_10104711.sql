IF NOT EXISTS(SELECT * FROM application_functions WHERE function_id = 10104700)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104700, 'Setup User Defined Fields', 'Setup User Defined Fields', 10100000, 'windowSetupUserDefinedFields')
 	PRINT ' Inserted 10104700 - Setup User Defined Fields.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104700 - Setup User Defined Fields EXISTS.'
END	

IF NOT EXISTS(SELECT * FROM application_functions WHERE function_id = 10104710)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104710, 'Setup User Defined Fields UI', 'Setup User Defined Fields UI ', 10104700, 'windowSetupUserDefinedFieldsUI')
 	PRINT ' Inserted 10104710 - Setup User Defined Fields UI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104710 - Setup User Defined Fields UI EXISTS.'
END	

IF NOT EXISTS(SELECT * FROM application_functions WHERE function_id = 10104711)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104711, 'Setup User Defined Fields Delete', 'Setup User Defined Fields Delete', 10104700, NULL)
 	PRINT ' Inserted 10104711 - Setup User Defined Fields.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104711 - Setup User Defined Fields Delete EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104712)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104712, 'Setup User Defined Fields Header', 'Setup User Defined Fields Header', 10104700, 'windowSetupUserDefinedFieldsDetail')
 	PRINT ' Inserted 10104712 - Setup User Defined Fields Header.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104712 - Setup User Defined Fields Header already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104713)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104713, 'Setup User Defined Fields Header Add', 'Setup User Defined Fields Header Add', 10104700, NULL)
 	PRINT ' Inserted 10104713 - Setup User Defined Fields Header Add.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104713 - Setup User Defined Fields Header Add already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104714)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104714, 'Setup User Defined Fields Header Save', 'Setup User Defined Fields Header Save', 10104700, NULL)
 	PRINT ' Inserted 10104714 - Setup User Defined Fields Header Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104714 - Setup User Defined Fields Header Save already EXISTS.'
END


