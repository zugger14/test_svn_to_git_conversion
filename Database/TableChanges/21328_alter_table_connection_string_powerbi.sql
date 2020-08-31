IF COL_LENGTH('dbo.connection_string', 'power_bi_username') IS NULL
BEGIN
	ALTER TABLE connection_string
	ADD power_bi_username VARCHAR(100)
END

GO

IF COL_LENGTH('dbo.connection_string', 'power_bi_password') IS NULL
BEGIN
	ALTER TABLE connection_string
	ADD power_bi_password varbinary(1000)
END
GO

IF COL_LENGTH('dbo.connection_string', 'power_bi_client_id') IS NULL
BEGIN
	ALTER TABLE connection_string
	ADD power_bi_client_id VARCHAR(100)
END

GO

IF COL_LENGTH('dbo.connection_string', 'power_bi_group_id') IS NULL
BEGIN
	ALTER TABLE connection_string
	ADD power_bi_group_id VARCHAR(100)
END
GO

IF COL_LENGTH('dbo.connection_string', 'power_bi_gateway_id') IS NULL
BEGIN
	ALTER TABLE connection_string
	ADD power_bi_gateway_id VARCHAR(100)
END
GO