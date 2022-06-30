-- alter column length 
IF OBJECT_ID(N'ixp_parameters', N'U') IS NOT NULL AND COL_LENGTH('ixp_parameters', 'sql_string') IS NOT NULL
BEGIN
    ALTER TABLE ixp_parameters ALTER COLUMN sql_string NVARCHAR(1000)
END
GO