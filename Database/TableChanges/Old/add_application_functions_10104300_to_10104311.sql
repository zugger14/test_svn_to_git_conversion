IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104300)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104300, 'Setup Contract Component Mapping', 'Setup Contract Component mapping', 10100000, 'windowSetupContractComponentMapping')
 	PRINT ' Inserted 10104300 - Setup Contract Component Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104300 - Setup Contract Component Mapping already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104310)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104310, 'Setup Contract Component Mapping IU', 'Setup Contract Component mapping IU', 10104300, 'windowSetupContractComponentMappingIU')
 	PRINT ' Inserted 10104310 - Setup Contract Component Mapping IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104310 - Setup Contract Component Mapping IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104311)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104311, 'Setup Contract Component Mapping Delete', 'Setup Contract Component Mapping Delete', 10104300, NULL)
 	PRINT ' Inserted 10104311 - Setup Contract Component Mapping Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104311 - Setup Contract Component Mapping Delete already EXISTS.'
END