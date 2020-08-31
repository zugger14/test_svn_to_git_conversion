IF NOT EXISTS(SELECT 1 FROM admin_email_configuration WHERE template_name = 'Login Credentials' AND module_type = 17808)
BEGIN 
	INSERT INTO admin_email_configuration(email_subject,	
										email_body,	
										mail_server_name,	
										module_type,	
										email_footer,	
										template_name,	
										default_email)
	SELECT 'Login Credentials',	'%3Cp%3E%26nbsp%3BDear%20User%2C%3Cbr%3E%3C%2Fp%3E%3Cp%3EYour%20account%20has%20been%20created.%20Please%20find%20your%20one-time-password%20below.%3C%2Fp%3E%3Cp%3EUsername%3A%20%26lt%3B%3Cstrong%3ETRM_USER_NAME%3C%2Fstrong%3E%26gt%3B%3C%2Fp%3E%3Cp%3EPassword%3A%20%26lt%3B%3Cstrong%3ETRM_PASSWORD%3C%2Fstrong%3E%26gt%3B%3C%2Fp%3E%3Cp%3EClick%20Here%20to%20return%20tologin%20page.%3C%2Fp%3E%3Cp%3EThank%20you%2C%26nbsp%3B%3C%2Fp%3E%3Cp%3EAutomatically%20generated%20by%20FARRMS.%20Please%20do%20nto%20reply.%3C%2Fp%3E%3Cp%3EThanks%3C%2Fp%3E%3Cp%3E%26nbsp%3B%3Cbr%3E%3C%2Fp%3E'
			,NULL, 17808, NULL,	'Login Credentials', 'y'
END 

IF NOT EXISTS(SELECT 1 FROM admin_email_configuration WHERE template_name = 'Login Credentials Update' AND module_type = 17809)
BEGIN 
	INSERT INTO admin_email_configuration(email_subject,	
										email_body,	
										mail_server_name,	
										module_type,	
										email_footer,	
										template_name,	
										default_email)
	SELECT 'Login Credentials Update', '%3Cp%3E%26nbsp%3BDear%20User%2C%3Cbr%3E%3C%2Fp%3E%3Cp%3EYour%20password%20has%20been%20changed.%20Please%20find%20your%20one-time-password%20below.%3C%2Fp%3E%3Cp%3EUsername%3A%20%26lt%3B%3Cstrong%3ETRM_USER_NAME%3C%2Fstrong%3E%26gt%3B%3C%2Fp%3E%3Cp%3EPassword%3A%20%26lt%3B%3Cstrong%3ETRM_PASSWORD%3C%2Fstrong%3E%26gt%3B%3C%2Fp%3E%3Cp%3EClick%20Here%20to%20return%20tologin%20page.%3C%2Fp%3E%3Cp%3EThank%20you%2C%26nbsp%3B%3C%2Fp%3E%3Cp%3EAutomatically%20generated%20by%20FARRMS.%20Please%20do%20nto%20reply.%3C%2Fp%3E%3Cp%3EThanks%3C%2Fp%3E%3Cp%3E%26nbsp%3B%3Cbr%3E%3C%2Fp%3E'
			,NULL, 17809, NULL,	'Login Credentials Update', 'y'
END 

GO

UPDATE agcfd
SET agcfd.column_name = 'admin_email_configuration_id' 
--SELECT * 
FROM adiha_grid_definition agd
INNER JOIN adiha_grid_columns_definition agcfd ON agcfd.grid_id = agd.grid_id
WHERE grid_name = 'email_configuration'
	AND column_name = 'cust_id'

GO