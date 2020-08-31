IF COL_LENGTH('connection_string', 'api_token_expiry_days') IS NULL
BEGIN
    ALTER TABLE connection_string ADD api_token_expiry_days INT NULL
END
ELSE
BEGIN
    PRINT 'api_token_expiry_days Already Exists.'
END 
GO
