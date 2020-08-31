-- ICE
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'ResetOnLogon')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'ResetOnLogon', 'Y')
END 
-- CME
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'ResetOnLogon')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'ResetOnLogon', 'Y')
END 
-- NODAL
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'ResetOnLogon')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'ResetOnLogon', 'Y')
END 
-- NASDAQ
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'ResetOnLogon')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'ResetOnLogon', 'Y')
END 
-- EEX
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'ResetOnLogon')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'ResetOnLogon', 'Y')
END 