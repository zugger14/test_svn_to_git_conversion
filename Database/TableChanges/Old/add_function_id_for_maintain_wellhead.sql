
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102100)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10102100,'Maintain Wellhead', 'Maintain Wellhead', 10100000, 'windowMaintainWellhead')
	PRINT '10102100 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102110)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10102110,'Maintain Wellhead Detail', 'Maintain Wellhead Detail', 10100000, 'windowMaintainWellheadDetail')
	PRINT '10102110 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102111)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10102111,'Delete Maintain Wellhead Detail', 'Delete Maintain Wellhead Detail', 10100000, '')
	PRINT '10102111 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102112)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10102112,'Maintain Ownership Detail', 'Maintain Ownership Detail', 10100000, 'windowMaintainOwnershipDetail')
	PRINT '10102112 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102113)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10102113,'Delete Maintain Ownership Detail', 'Delete Maintain Ownership Detail', 10100000, '')
	PRINT '10102113 INSERTED'
END