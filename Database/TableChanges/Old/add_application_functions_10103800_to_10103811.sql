IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103800)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103800, 'Maintain Source Generator', 'Maintain Source Generator', 10100000, 'windowMaintainSourceGenerator')
 	PRINT ' Inserted 10103800 - Maintain Source Generator.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103800 - Maintain Source Generator already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103810)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103810, 'Maintain Source Generator IU', 'Maintain Source Generator IU', 10103800, 'windowMaintainSourceGeneratorIU')
 	PRINT ' Inserted 10103810 - Maintain Source Generator IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103810 - Maintain Source Generator IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103811)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103811, 'Maintain Source Generator Delete', 'Maintain Source Generator Delete', 10103800, NULL)
 	PRINT ' Inserted 10103811 - Maintain Source Generator Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103811 - Maintain Source Generator Delete already EXISTS.'
END

UPDATE application_functional_users
SET
	function_id = 10103800
WHERE function_id = 10161500

UPDATE application_functional_users
SET
	function_id = 10103810
WHERE function_id = 10161510

UPDATE application_functional_users
SET
	function_id = 10103811
WHERE function_id = 10161511

DELETE FROM application_functions WHERE function_id IN (10161500, 10161510, 10161511)