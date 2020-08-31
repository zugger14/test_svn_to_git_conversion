--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20009000)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20009000, 'Setup Rate Schedule', 'Setup Rate Schedule', NULL, '_scheduling_delivery/gas/maintain_rate_schedule/maintain.rate.schedule.php', NULL, NULL, 0)
	PRINT ' Inserted 20009000 - Setup Rate Schedule.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20009000 - Setup Rate Schedule already EXISTS.'
END