IF COL_LENGTH('system_access_log', 'cookie_hash') IS NULL
BEGIN
    ALTER TABLE system_access_log ADD cookie_hash VARCHAR(100)
END
ELSE
BEGIN
    PRINT 'Column ''system_access_log'' Already Exists.'
END 
GO