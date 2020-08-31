IF COL_LENGTH('interface_configuration_detail', 'user_role_id') IS NULL
	ALTER TABLE interface_configuration_detail ADD user_role_ids VARCHAR(1024)
GO