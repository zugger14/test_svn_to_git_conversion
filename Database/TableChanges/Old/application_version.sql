IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes WHERE default_code_id = 42)
BEGIN
	INSERT INTO adiha_default_codes VALUES(42, 'application_version', 'Application Version', 'Application Version', 1)
	INSERT INTO adiha_default_codes_params VALUES(1, 42, 'application_version', 3, NULL, 'h')
	INSERT INTO adiha_default_codes_values_possible VALUES(42, '2.4.000', '2.4.000')
	INSERT INTO adiha_default_codes_values VALUES(1, 42, 1, '2.4.000', '2.4.000') 	
END
ELSE
	PRINT 'Default Code Exists' 

