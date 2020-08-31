IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131026)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call,file_path)
	VALUES (10131026, 'Certificate Info', 'Certificate Info',10130000,'windowCertificate','deal_capture/maintain_deals/certificate.php')
 	PRINT ' Inserted 10131026 - Certificate Info.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131026 - Certificate Info already EXISTS.'
END
