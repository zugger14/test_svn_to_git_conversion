IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12102020)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (12102020, 'Maintain Emission Inventory Delete', 'Maintain Emission Inventory Detail', 12102018, 'windowEmsInventoryIU')
 	PRINT ' Inserted 12102020 - Maintain Emission Inventory Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12102020 - Maintain Emission Inventory Delete already EXISTS.'
END