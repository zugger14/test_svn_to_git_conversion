SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON 
GO

/**
	File Transfer Endpoint CRUD opertaions

	Parameters 
	@flag : Flag Description
	@file_transfer_endpoint_id : File transfer endpoint id
	@auth_certificate_keys_id	:	Auth certificate key id refers to auth_certificate_keys table
	@name : Endpoint host name must be unique
	@file_protocol : File transfer protocol possible values 1,2,3 (FTP, SFTP, FTPS)
	@host_name_url : Host name
	@port_no : Port no
	@description : Endpoint description
	@user_name : user name
	@password : password
	@remote_directory : Default working remote working directory for host
	@is_inbound_default : Inbound default
	@is_outbound_default : Outbound default
	@endpoint_type : Endpoint type either import or export , 1=> Import, 2=> Export
	@xml :  Form value in xml form.

*/


CREATE OR ALTER PROCEDURE [dbo].[spa_file_transfer_endpoint]
    @flag							VARCHAR(50)
	, @file_transfer_endpoint_id	INT = NULL
	, @auth_certificate_keys_id		INT = NULL
	, @name							NVARCHAR(2048) = NULL
	, @file_protocol				INT = NULL
	, @host_name_url				NVARCHAR(2048) = NULL
	, @port_no						INT = NULL
	, @description					NVARCHAR(MAX) = NULL
	, @user_name					NVARCHAR(2048) = NULL
	, @password						NVARCHAR(2048) = NULL
	, @remote_directory				NVARCHAR(2048) = NULL
	, @is_inbound_default			BIT = NULL
	, @is_outbound_default			BIT = NULL
	, @endpoint_type				INT = NULL
	, @xml							NVARCHAR(MAX) = NULL
AS

SET NOCOUNT ON;

/*
--Added for Debugging Purpose
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'

DECLARE
	 @flag							VARCHAR(50)
	, @file_transfer_endpoint_id	INT = NULL
	, @auth_certificate_keys_id		INT = NULL
	, @name							NVARCHAR(2048) = NULL
	, @file_protocol				INT = NULL
	, @host_name_url				NVARCHAR(2048) = NULL
	, @port_no						INT = NULL
	, @description					NVARCHAR(MAX) = NULL
	, @user_name					NVARCHAR(2048) = NULL
	, @password						NVARCHAR(2048) = NULL
	, @remote_directory				NVARCHAR(2048) = NULL
	, @is_inbound_default			BIT = NULL
	, @is_outbound_default			BIT = NULL
	, @endpoint_type				INT = NULL
	, @xml							NVARCHAR(MAX) = NULL

--Drops all temp tables created in this scope.
EXEC spa_drop_all_temp_table

select @flag = 'update', 
@xml = '<Root><FormXML  file_transfer_endpoint_id="1" name="UAT02 SFTP" auth_certificate_keys_id="1" file_protocol="2" host_name_url="uat02.farrms.us" port_no="22" description="Download / Upload from SFTP server with username , password  private key" user_name="Enercity_TEST" password="=v^eCDJ7k2f!c5h" remote_directory="" is_inbound_default="y" is_outbound_default="n"></FormXML></Root>'
--*/

DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's' AND @endpoint_type IS NULL
BEGIN
    SELECT * from file_transfer_endpoint
END

ELSE IF @flag = 's' AND @endpoint_type IS NOT NULL
BEGIN
    SELECT file_transfer_endpoint_id [Id], [name] [Value] from file_transfer_endpoint WHERE (endpoint_type = ISNULL(@endpoint_type, endpoint_type) OR endpoint_type IS NULL)
END

ELSE IF @flag = 'a'
BEGIN
    SELECT fte.file_transfer_endpoint_id, fte.name, ack.name certificate_key_name, fte.description, fte.remote_directory FROM file_transfer_endpoint fte
	LEFT JOIN auth_certificate_keys ack ON ack.auth_certificate_keys_id = fte.auth_certificate_keys_id
END

ELSE IF @flag = 'c'
BEGIN
  SELECT auth_certificate_keys_id [id], [name] [value] FROM auth_certificate_keys
END

ELSE IF @flag = 'p'
BEGIN 
	SELECT dbo.FNADecrypt(password) [password]
	FROM file_transfer_endpoint WHERE file_transfer_endpoint_id = @file_transfer_endpoint_id
END

ELSE IF @flag IN ('insert', 'update')
BEGIN 
	IF @xml IS NOT NULL 
	BEGIN
		DECLARE @idoc_form INT
		
		IF OBJECT_ID(N'tempdb..#temp_general_form') IS NOT NULL 
			DROP TABLE #temp_general_form
	
		EXEC sp_xml_preparedocument @idoc_form OUTPUT, @xml		

		SELECT NULLIF(file_transfer_endpoint_id,'') file_transfer_endpoint_id,
			[name],
			NULLIF(auth_certificate_keys_id, '') auth_certificate_keys_id,
			file_protocol,
			host_name_url,
			port_no,
			[description],
			NULLIF([user_name], '') [user_name],
			NULLIF([password], '') [password],
			NULLIF(remote_directory, '') remote_directory,
			IIF(is_inbound_default = 'y', 1, 0) is_inbound_default,
			IIF(is_outbound_default = 'y', 1, 0) is_outbound_default,
			NULLIF(endpoint_type , '') endpoint_type
		INTO #temp_general_form
		FROM   OPENXML(@idoc_form, 'Root/FormXML', 1)
		WITH (
			file_transfer_endpoint_id INT '@file_transfer_endpoint_id',
			[name] NVARCHAR(1024) '@name',
			auth_certificate_keys_id INT '@auth_certificate_keys_id',
			file_protocol INT '@file_protocol',
			host_name_url NVARCHAR(1024) '@host_name_url',
			port_no INT '@port_no',
			[description] NVARCHAR(MAX) '@description',
			[user_name] NVARCHAR(1024) '@user_name',
			[password] NVARCHAR(MAX) '@password',
			[remote_directory] NVARCHAR(1024) '@remote_directory',
			is_inbound_default NCHAR '@is_inbound_default',
			is_outbound_default NCHAR '@is_outbound_default',
			endpoint_type INT
		)

		SELECT @is_inbound_default = is_inbound_default FROM #temp_general_form
		SELECT @is_outbound_default = is_outbound_default FROM #temp_general_form

		BEGIN TRY
			BEGIN TRAN
				IF @flag = 'insert'
				BEGIN
					INSERT INTO file_transfer_endpoint (name, auth_certificate_keys_id, file_protocol, host_name_url, port_no, description, user_name, password, remote_directory, is_inbound_default, is_outbound_default, endpoint_type)
					SELECT name, auth_certificate_keys_id, file_protocol, host_name_url, port_no, description, user_name, dbo.FNAEncrypt(password), remote_directory, CAST(is_inbound_default AS BIT), CAST(is_outbound_default AS BIT), endpoint_type FROM #temp_general_form
				
					SET @file_transfer_endpoint_id = SCOPE_IDENTITY()

					IF @is_inbound_default = 1 
					BEGIN
						UPDATE file_transfer_endpoint 
						SET is_inbound_default = 0 
						WHERE file_transfer_endpoint_id NOT IN (@file_transfer_endpoint_id)
					END

					IF @is_outbound_default = 1 
					BEGIN
						UPDATE file_transfer_endpoint 
						SET is_outbound_default = 0 
						WHERE file_transfer_endpoint_id NOT IN (@file_transfer_endpoint_id)
					END
				END

				IF @flag = 'update'
				BEGIN
					UPDATE fte
					SET fte.name = tgf.name,
						fte.auth_certificate_keys_id = tgf.auth_certificate_keys_id,
						fte.file_protocol = tgf.file_protocol,
						fte.host_name_url = tgf.host_name_url,
						fte.port_no = tgf.port_no,
						fte.description = tgf.description,
						fte.user_name = tgf.user_name,
						fte.password = dbo.FNAEncrypt(tgf.password),
						fte.remote_directory = tgf.remote_directory,
						fte.is_inbound_default = CAST(tgf.is_inbound_default AS BIT),
						fte.is_outbound_default = CAST(tgf.is_outbound_default AS BIT),
						fte.endpoint_type = tgf.endpoint_type
					FROM file_transfer_endpoint fte
					INNER JOIN #temp_general_form tgf ON fte.file_transfer_endpoint_id = tgf.file_transfer_endpoint_id

					SELECT @file_transfer_endpoint_id = file_transfer_endpoint_id FROM #temp_general_form

					IF @is_inbound_default = 1 
					BEGIN
						UPDATE file_transfer_endpoint 
						SET is_inbound_default = 0 
						WHERE file_transfer_endpoint_id NOT IN (@file_transfer_endpoint_id)
					END

					IF @is_outbound_default = 1 
					BEGIN
						UPDATE file_transfer_endpoint 
						SET is_outbound_default = 0 
						WHERE file_transfer_endpoint_id NOT IN (@file_transfer_endpoint_id)
					END
				END
			COMMIT
			EXEC spa_ErrorHandler 0
				, 'file_transfer_endpoint'
				, 'spa_file_transfer_endpoint'
				, 'Success'
				, 'Changes have been saved successfully.'
				, @file_transfer_endpoint_id
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK

		    DECLARE @error_msg VARCHAR(MAX);
			SET @error_msg = ERROR_MESSAGE();

			EXEC spa_ErrorHandler -1,
				 'compliance_jurisdiction',
				 'spa_save_custom_form_data',
				 'Error',
				 @error_msg,
				 ''
		END CATCH
	END
END

ELSE IF @flag = 'test_connection'
BEGIN 
	-- For testing connection we dont have test connection method in clr, so using ftp list directory method
	DECLARE @status NVARCHAR(MAX)
	IF OBJECT_ID ('tempdb..#ftp_test_status') IS NOT NULL
		DROP TABLE #ftp_test_status

	CREATE TABLE #ftp_test_status(
		ftp_url NVARCHAR(MAX),
		dir_file NVARCHAR(MAX)
	)

	INSERT INTO #ftp_test_status
	EXEC spa_list_ftp_contents @file_transfer_endpoint_id = @file_transfer_endpoint_id, @remote_directory = @remote_directory, @result= @status OUTPUT

	DECLARE @message NVARCHAR(max) = NULL

	IF(@status IN ('Username', 'Password'))
	BEGIN
		SET @message = 'Username/Password required.'
	END
	ELSE 
	BEGIN
		SET @message = @status
	END
	
	IF (@status = 'success')
	BEGIN
		EXEC spa_ErrorHandler 0
				, 'file_transfer_endpoint'
				, 'spa_file_transfer_endpoint'
				, 'Success'
				, 'File transfer endpoint connection settings is valid.'
				, ''
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler -1,
				 'file_transfer_endpoint',
				 'spa_file_transfer_endpoint',
				 'Error',
				 @message,
				 ''
	END
END 
ELSE IF @flag = 'endpoint with url'
BEGIN
    SELECT CAST(file_transfer_endpoint_id AS NVARCHAR(8)) + '|' + CASE WHEN file_protocol = 2 THEN 'sftp://' ELSE 'ftp://'  END + host_name_url url
		, name
	FROM file_transfer_endpoint
	WHERE (endpoint_type = ISNULL(@endpoint_type, endpoint_type) OR endpoint_type IS NULL)
END
GO	




