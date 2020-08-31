IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103700)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103700, 'Location Price Index', 'Location Price Index', 10100000, 'windowLocationPriceIndex')
 	PRINT ' Inserted 10103700 - Location Price Index.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103700 - Location Price Index already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103710)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103710, 'Location Price Index IU', 'Location Price Index IU', 10103700, 'windowLocationPriceIndexDetail')
 	PRINT ' Inserted 10103710 - Location Price Index IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103710 - Location Price Index IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103711)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103711, 'Location Price Index Delete', 'Location Price Index Delete', 10103700, NULL)
 	PRINT ' Inserted 10103711 - Location Price Index Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103711 - Location Price Index Delete already EXISTS.'
END

UPDATE application_functional_users
SET
	function_id = 10103700
WHERE function_id = 10161600

UPDATE application_functional_users
SET
	function_id = 10103710
WHERE function_id = 10161610

UPDATE application_functional_users
SET
	function_id = 10103711
WHERE function_id = 10161611

DELETE FROM application_functions WHERE function_id IN (10161600, 10161610, 10161611)