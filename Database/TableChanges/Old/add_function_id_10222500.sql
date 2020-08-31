IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10222500)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10222500, 'Print Invoices', 'Print Invoices', 10220000, 'windowPrintInvoices')
 	PRINT ' Inserted 10222500 - Print Invoices.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10222500 - Print Invoices already  EXISTS.'
END
