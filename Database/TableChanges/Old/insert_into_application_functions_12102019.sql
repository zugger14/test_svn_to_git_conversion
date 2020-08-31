IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12102019)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (12102019, 'Maintain Emission Inventory IU', 'Maintain Emission Inventory Detail', 12102018, 'windowEmsInventoryIU')
 	PRINT ' Inserted 12102019 - Maintain Emission Inventory IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12102019 - Maintain Emission Inventory IU already EXISTS.'
END