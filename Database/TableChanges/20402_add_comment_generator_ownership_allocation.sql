
IF COL_LENGTH('generator_ownership_allocation', 'comments') IS NULL
BEGIN
    ALTER TABLE dbo.generator_ownership_allocation ADD comments VARCHAR(1000)
END
ELSE
BEGIN
    PRINT 'Column:comments Already Exists.'
END

