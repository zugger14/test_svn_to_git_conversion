IF COL_LENGTH('interface_configuration_detail','session_qualifier') IS NULL
	ALTER TABLE interface_configuration_detail ADD session_qualifier BIT DEFAULT 1
GO