IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101701)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10101701, 'SSIS Configurations', 'SSIS Configurations', 10101700, NULL)
 	PRINT ' Inserted 10101701 - SSIS Configurations.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101701 - SSIS Configurations already EXISTS.'
END

GO
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101702)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10101702, 'SSIS Configurations IU', 'SSIS Configurations IU', 10101700, NULL)
 	PRINT ' Inserted 10101702 - SSIS Configurations IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101702 - SSIS Configurations IU already EXISTS.'
END

GO
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101703)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10101703, 'SSIS Configurations Delete', 'SSIS Configurations Delete', 10101700, NULL)
 	PRINT ' Inserted 10101703 - SSIS Configurations Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101703 - SSIS Configurations Delete already EXISTS.'
END
GO

UPDATE application_functions
SET
	func_ref_id = 10101701
WHERE function_id = 10101702
PRINT '10101702 updated.'
GO

UPDATE application_functions
SET
	func_ref_id = 10101701
WHERE function_id = 10101703
PRINT '10101703 updated.'
GO
