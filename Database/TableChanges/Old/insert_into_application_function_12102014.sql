IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12102018)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (12102018, 'Maintain Emission Inventory', 'Maintain Emission Inventory', 12102000, 'windowEmsInventory')
 	PRINT ' Inserted 12102018 - Maintain Emission Inventory.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12102018 - Maintain Emission Inventory already EXISTS.'
END