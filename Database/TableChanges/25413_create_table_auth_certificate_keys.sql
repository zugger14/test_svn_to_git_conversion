-- Check if the table is already created
IF OBJECT_ID(N'dbo.auth_certificate_keys', N'U') IS NULL 
BEGIN
	CREATE TABLE dbo.auth_certificate_keys (
	/**
		Saves the certificate / key information details

		Columns
		auth_certificate_keys_id : Id
		name : Certficate friendly name that will be displayed UI Forms, MUST BE UNIQUE NAME
		description : Certificate description , Provide valid description about certificate and its corresponding connection that will be used.
		file_name : Upload certificate file name, these file will be stored in shared_docs\\certificate_keys folder. MUST BE UNIQUE NAME
		passphrase : passphrase key use for certificate if applicable
		certificate_key : In case of user wants to input key manually without certificate upload.
		create_user : specifies the username who creates the column.
		create_ts : specifies the date when column was created.
		update_user : specifies the username who updated the column.
		update_ts : specifies the date when column was updated.
	*/
		auth_certificate_keys_id	INT IDENTITY(1, 1) PRIMARY KEY
		, [name]					NVARCHAR(100) NOT NULL
		, [description]				NVARCHAR(MAX) NOT NULL
		, [file_name]				NVARCHAR(1024)
		, passphrase				NVARCHAR(1024)
		, [certificate_key]			NVARCHAR(MAX)
		, create_user				NVARCHAR(255)  DEFAULT dbo.FNADBUser()
		, create_ts					DATETIME  DEFAULT GETDATE()
		, update_user				NVARCHAR(255)
		, update_ts					DATETIME
		, CONSTRAINT UC_auth_certificate_keys_id_name UNIQUE([name])
    )
END
ELSE
BEGIN
    PRINT 'Table auth_certificate_keys EXISTS'
END
 
GO

-- check if the trigger exists
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'dbo.TRGUPD_auth_certificate_keys'))
    DROP TRIGGER dbo.TRGUPD_auth_certificate_keys
GO
/*
	Update trigger for updating audit columns
*/
CREATE TRIGGER dbo.TRGUPD_auth_certificate_keys
ON dbo.auth_certificate_keys
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE auth_certificate_keys
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM auth_certificate_keys  ack
        INNER JOIN DELETED d ON d.auth_certificate_keys_id =  ack.auth_certificate_keys_id
    END
END
GO