IF COL_LENGTH('interface_configuration_detail', 'socket_connect_host') IS NOT NULL
	ALTER TABLE interface_configuration_detail DROP COLUMN socket_connect_host
GO

IF COL_LENGTH('interface_configuration_detail', 'socket_connect_port') IS NOT NULL
	ALTER TABLE interface_configuration_detail DROP COLUMN socket_connect_port
GO