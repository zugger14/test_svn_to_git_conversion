IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101700)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (12101700, 'Setup Renewable Sources', 'Setup Renewable Sources', 12100000, 'windowSetup RenewableGenerators', '_models_and_activity/setup_renewable_source/setup.renewable.source.php')
 	PRINT ' Inserted 12101700 - Setup Renewable Sources.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101700 - Setup Renewable Sources already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101701)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (12101701, 'Setup Renewable Sources Grid', 'Setup Renewable Sources Grid', 12101700, 'windowSetupRenewableGeneratorsGrid')
 	PRINT ' Inserted 12101701 - Setup Renewable Sources Grid.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101701 - Setup Renewable Sources Grid already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101710)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (12101710, 'Setup Renewable Generators Edit', 'Setup Renewable Generators Edit', 12101700, 'windowSetupRecGeneratorIU')
 	PRINT ' Inserted 12101710 - Setup Renewable Generators Edit.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101710 - Setup Renewable Generators Edit already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101711)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (12101711, 'Renewable Generators Delete', 'Renewable Generators Delete', 12101700, NULL)
 	PRINT ' Inserted 12101711 - Delete Renewable Generators.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101711 - Delete Renewable Generators already EXISTS.'
END