IF COL_LENGTH('connection_string','service_connection_host') IS NULL
	ALTER TABLE connection_string ADD service_connection_host VARCHAR(50)
GO

IF COL_LENGTH('connection_string','service_connection_port') IS NULL
	ALTER TABLE connection_string ADD service_connection_port INT
GO
