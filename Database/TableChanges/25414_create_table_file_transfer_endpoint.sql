-- Check if the table is already created
IF OBJECT_ID(N'dbo.file_transfer_endpoint', N'U') IS NULL 
BEGIN
    CREATE TABLE dbo.file_transfer_endpoint (
	/**
		Save the certificate / key information details..

		Columns
		file_transfer_endpoint_id : Id
		auth_certificate_keys_id : FK field refers to auth_certificates, if connection requires certificate key
		name : Endpoint friendly name that will be displayed UI Forms, MUST BE UNIQUE NAME
		description : Endpoint description
		file_protocol : File protocol, 1=> FTP, 2=> FTPS, 3=> SFTP 
		host_name_url : Host name address url
		port_no : Host name port no.
		user_name : User name to connect the host
		password : Host name Encrypted Password
		remote_directory : remote directory append after hostname address url
		is_inbound_default : Is default inboud endpoint
		is_outbound_default : Is default outboud endpoint
		create_user : specifies the username who creates the column.
		create_ts : specifies the date when column was created.
		update_user : specifies the username who updated the column.
		update_ts : specifies the date when column was updated.
	*/
		file_transfer_endpoint_id	INT IDENTITY(1, 1) PRIMARY KEY
		, auth_certificate_keys_id	INT
		, [name]					NVARCHAR(1024) NOT NULL
		, [file_protocol]			INT NOT NULL
		, [host_name_url]			NVARCHAR(1024) NOT NULL
		, [port_no]					INT
		, [description]				NVARCHAR(MAX) NOT NULL
		, [user_name]				NVARCHAR(1024)
		, [password]				VARBINARY(MAX)
		, [remote_directory]		NVARCHAR(1024)
		, [is_inbound_default]		BIT
		, [is_outbound_default]		BIT
		, create_user				NVARCHAR(255)  DEFAULT dbo.FNADBUser()
		, create_ts					DATETIME  DEFAULT GETDATE()
		, update_user				NVARCHAR(255)
		, update_ts					DATETIME
		, CONSTRAINT fk_file_transfer_endpoint_auth_certificate_keys_id FOREIGN KEY (auth_certificate_keys_id) REFERENCES auth_certificate_keys(auth_certificate_keys_id)
		, CONSTRAINT UC_file_transfer_endpoint_id_name UNIQUE([name])
    )
END
ELSE
BEGIN
    PRINT 'Table file_transfer_endpoint EXISTS'
END
 
GO
-- check if the trigger exists
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'dbo.TRGUPD_file_transfer_endpoint'))
    DROP TRIGGER dbo.TRGUPD_file_transfer_endpoint
GO
/*
	Update trigger for updating audit columns
*/
CREATE TRIGGER dbo.TRGUPD_file_transfer_endpoint
ON dbo.file_transfer_endpoint
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE file_transfer_endpoint
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM file_transfer_endpoint  fte
        INNER JOIN DELETED d ON d.file_transfer_endpoint_id =  fte.file_transfer_endpoint_id
    END
END
GO