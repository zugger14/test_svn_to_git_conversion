--ADD COLUMN FOR IMAP EMAIL ADDRESS
IF COL_LENGTH('connection_string', 'imap_email_address') IS NULL
BEGIN
    ALTER TABLE connection_string ADD imap_email_address VARCHAR(100) NULL
END
ELSE
BEGIN
    PRINT 'imap_email_address Already Exists.'
END 
GO
--ADD COLUMN FOR IMAP EMAIL PASSWORD
IF COL_LENGTH('connection_string', 'imap_email_password') IS NULL
BEGIN
    ALTER TABLE connection_string ADD imap_email_password VARBINARY(1000) NULL
END
ELSE
BEGIN
    PRINT 'imap_email_password Already Exists.'
END 
GO
--ADD COLUMN FOR IMAP SERVER HOST
IF COL_LENGTH('connection_string', 'imap_server_host') IS NULL
BEGIN
    ALTER TABLE connection_string ADD imap_server_host VARCHAR(100) NULL
END
ELSE
BEGIN
    PRINT 'imap_server_host Already Exists.'
END 
GO
--ADD COLUMN FOR IMAP SERVER PORT
IF COL_LENGTH('connection_string', 'imap_server_port') IS NULL
BEGIN
    ALTER TABLE connection_string ADD imap_server_port INT NULL
END
ELSE
BEGIN
    PRINT 'imap_server_port Already Exists.'
END 
GO
--ADD COLUMN FOR IMAP SSL REQUIRE
IF COL_LENGTH('connection_string', 'imap_require_ssl') IS NULL
BEGIN
    ALTER TABLE connection_string ADD imap_require_ssl BIT NULL DEFAULT 1
END
ELSE
BEGIN
    PRINT 'imap_require_ssl Already Exists.'
END 
GO
