IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103200)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103200, 'Pratos Mapping', 'Pratos Mapping', 10100000, 'windowPratosMapping')
 	PRINT ' Inserted 10103200 - Pratos Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103200 - Pratos Mapping already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103210)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103210, 'Pratos Mapping index IU', 'Pratos Mapping index IU', 10103200, 'windowPratosMappingIndexIU')
 	PRINT ' Inserted 10103210 - Pratos Mapping index IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103210 - Pratos Mapping index IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103211)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103211, 'Delete Pratos Mapping index', 'Delete Pratos Mapping index', 10103200, NULL)
 	PRINT ' Inserted 10103211 - Delete Pratos Mapping index.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103211 - Delete Pratos Mapping index already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103220)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103220, 'Pratos Mapping Book IU', 'Pratos Mapping Book IU', 10103200, 'windowPratosMappingBookIU')
 	PRINT ' Inserted 10103220 - Pratos Mapping Book IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103220 - Pratos Mapping Book IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103221)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103221, 'Delete Pratos Mapping Book', 'Delete Pratos Mapping Book', 10103200, NULL)
 	PRINT ' Inserted 10103221 - Delete Pratos Mapping Book.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103221 - Delete Pratos Mapping Book already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103230)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103230, 'Pratos Mapping Formula IU', 'Pratos Mapping Formula IU', 10103200, 'windowPratosMappingFormulaIU')
 	PRINT ' Inserted 10103230 - Pratos Mapping Formula IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103230 - Pratos Mapping Formula IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103231)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103231, 'Delete Pratos Mapping Formula', 'Delete Pratos Mapping Formula', 10103200, NULL)
 	PRINT ' Inserted 10103231 - Delete Pratos Mapping Formula.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103231 - Delete Pratos Mapping Formula already EXISTS.'
END
