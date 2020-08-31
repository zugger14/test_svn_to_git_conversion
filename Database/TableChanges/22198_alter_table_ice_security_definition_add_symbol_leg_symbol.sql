IF COL_LENGTH('ice_security_definition','leg_symbol') IS NULL
	ALTER TABLE ice_security_definition ADD leg_symbol INT
GO

IF COL_LENGTH('ice_security_definition','symbol') IS NULL
	ALTER TABLE ice_security_definition ADD symbol INT
GO

IF COL_LENGTH('ice_security_definition','strip_name') IS NULL
	ALTER TABLE ice_security_definition ADD strip_name NVARCHAR(100)
GO