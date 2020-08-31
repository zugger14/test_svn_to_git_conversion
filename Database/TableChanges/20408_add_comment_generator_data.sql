IF COL_LENGTH('generator_data', 'comments') IS NULL
BEGIN
    ALTER TABLE dbo.generator_data ADD comments VARCHAR(1000)
END
ELSE
BEGIN
    PRINT 'Column:comments Already Exists.'
END


