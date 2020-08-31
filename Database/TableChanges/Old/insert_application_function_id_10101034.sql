IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101034)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10101034, 'Block Type Group', 'Block Type Group', 10101000, 'windowBlockTypeGroup', '_setup/maintain_static_data/block.type.php')
 	PRINT ' Inserted 10101034 - Block Type Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101034 - Block Type Group already EXISTS.'
END
