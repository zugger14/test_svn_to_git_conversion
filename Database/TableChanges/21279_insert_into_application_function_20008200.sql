--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008200)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20008200, 'Setup Storage Contract', 'Setup Storage Contract', NULL, '_contract_administration/maintain_contract_group/maintain.contract.storage.php', NULL, NULL, 0)
	PRINT ' Inserted 20008200 - Setup Storage Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20008200 - Setup Storage Contract already EXISTS.'
END