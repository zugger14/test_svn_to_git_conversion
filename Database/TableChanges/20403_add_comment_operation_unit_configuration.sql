
IF COL_LENGTH('operation_unit_configuration', 'comments') IS NULL
BEGIN
    ALTER TABLE dbo.operation_unit_configuration ADD comments VARCHAR(1000)
END
ELSE
BEGIN
    PRINT 'Column:comments Already Exists.'
END