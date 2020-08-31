--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008900)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20008900, 'Setup Storage Rate Schedule', 'Setup Storage Rate Schedule', NULL, '_scheduling_delivery/gas/maintain_storage_rate_schedule/maintain.storage.rate.schedule.php', NULL, NULL, 0)
	PRINT ' Inserted 20008900 - Setup Storage Rate Schedule.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20008900 - Setup Storage Rate Schedule already EXISTS.'
END