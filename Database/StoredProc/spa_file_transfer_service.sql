SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON 
GO

/**
	File transfer endpoint operations

	Parameters 
	@flag : 'config' => Get end point configuration settings, 'certificates' => Get endpoint certificate
	file_transfer_endpoint_id : File transfer endpoint id
	@p2 : Parameter2 Description
	@p3 : Parameter3 Description

*/

CREATE OR ALTER PROCEDURE [dbo].[spa_file_transfer_service]
    @flag CHAR(50),
	@file_transfer_endpoint_id INT = NULL
AS

SET NOCOUNT ON;

/*
--Added for Debugging Purpose
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'

DECLARE
	@flag CHAR(50),
	file_transfer_endpoint_id INT = NULL
	
--Drops all temp tables created in this scope.
EXEC spa_drop_all_temp_table
--*/

DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 'config'
BEGIN
    -- Get configuration detail of endpoint
	SELECT fte.file_transfer_endpoint_id [FileTransferEndpointId] ,
		   fte.[name] [Name] ,
		   fte.[file_protocol] [FileProtocol] ,
		   fte.host_name_url [HostNameUrl] ,
		   ISNULL(fte.port_no, 21) [PortNo] ,
		   fte.[user_name] [UserName] ,
		   dbo.FNADecrypt(fte.[password]) [Password] ,
		   ISNULL(fte.remote_directory, '') [RemoteDirectory] ,
		   ack.passphrase [PassPhraseKey] ,
		   CASE
			   WHEN ack.file_name IS NOT NULL THEN dbo.FNAReadFileContents(rs_key.cert_folder + ack.file_name)
			   ELSE ack.certificate_key
		   END[PrivateKey]
	FROM file_transfer_endpoint fte
	LEFT JOIN auth_certificate_keys ack ON fte.auth_certificate_keys_id = ack.auth_certificate_keys_id OUTER APPLY
	  (SELECT document_path + '\certificate_keys\' AS cert_folder
	   FROM connection_string) rs_key
	WHERE file_transfer_endpoint_id = @file_transfer_endpoint_id
END
	
GO	




