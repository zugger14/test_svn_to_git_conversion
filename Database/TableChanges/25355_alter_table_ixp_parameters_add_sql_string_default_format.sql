IF COL_LENGTH('ixp_parameters', 'sql_string') IS NULL 
BEGIN
	ALTER TABLE ixp_parameters ADD sql_string NVARCHAR(100)
END

IF COL_LENGTH('ixp_parameters', 'default_format') IS NULL 
BEGIN
	ALTER TABLE ixp_parameters ADD default_format NVARCHAR(100)
END