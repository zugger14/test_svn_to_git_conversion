--ADD COLUMN FOR MOBILE INTEGRATED
IF COL_LENGTH('connection_string', 'enable_otp') IS NULL
BEGIN
    ALTER TABLE connection_string ADD enable_otp BIT NULL DEFAULT 0
END
ELSE
BEGIN
    PRINT 'enable_otp Already Exists.'
END 
GO
