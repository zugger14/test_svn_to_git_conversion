--ADD COLUMN FOR MOBILE INTEGRATED
IF COL_LENGTH('connection_string', 'mobile_integrated') IS NULL
BEGIN
    ALTER TABLE connection_string ADD mobile_integrated BIT NULL DEFAULT 0
END
ELSE
BEGIN
    PRINT 'mobile_integrated Already Exists.'
END 
GO
