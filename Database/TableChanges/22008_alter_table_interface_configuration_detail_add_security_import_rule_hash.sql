IF COL_LENGTH('interface_configuration_detail','security_import_rule_hash') IS NULL 
	ALTER TABLE interface_configuration_detail ADD security_import_rule_hash VARCHAR(1000)
GO
	