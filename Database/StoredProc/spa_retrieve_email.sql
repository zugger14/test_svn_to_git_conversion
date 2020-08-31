/**
Purpose: Used by job 'TRMTracker - Notification - Retrieve Email' for email related functionalities taking imap mail settings from connection string. This sp uses CLR assembly to extract email from inbox.
Tasks: 
1. Get incoming email and dump on physical file,table
2. Get attachment and save all.
3. Parse email body with pattern and do triggering actions like trigger workflow,map email/documents to object.
Date: 2017-05-04
By: sligal@pioneersolutionsglobal.com 
**/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_retrieve_email]') AND TYPE in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_retrieve_email]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_retrieve_email]
	@flag CHAR(1) = NULL
	
AS
SET NOCOUNT ON

/*
DECLARE @flag CHAR(1) = NULL
	

select @flag='r'

--*/
SET NOCOUNT ON
BEGIN TRY
	declare @process_id varchar(100) = dbo.FNAGetNewID()
	--BEGIN TRAN
	IF @flag = 'r'
	BEGIN
	
		DECLARE @shared_document_path VARCHAR(1000) = NULL
		DECLARE @imap_email_address VARCHAR(100) = NULL
		DECLARE @imap_email_password VARCHAR(500) = NULL
		DECLARE @imap_server_host VARCHAR(100) = NULL
		DECLARE @imap_server_port INT = NULL
		DECLARE @imap_require_ssl BIT = 1

		DECLARE @result NVARCHAR(MAX) = NULL

		SELECT @imap_email_address = cs.imap_email_address
			, @imap_email_password = dbo.FNADecrypt(cs.imap_email_password)
			, @imap_server_host = cs.imap_server_host
			, @imap_server_port = cs.imap_server_port
			, @imap_require_ssl = cs.imap_require_ssl
			, @shared_document_path = cs.document_path

		FROM connection_string cs
		--select '@email_id'=@imap_email_address
		--	, '@email_pwd'=@imap_email_password
		--	, '@email_host'=@imap_server_host
		--	, '@email_port'=@imap_server_port
		--	, '@document_path'=@shared_document_path
		--	, '@email_require_ssl'=@imap_require_ssl
		--	, '@flag'='i'
		--	return
		EXEC spa_dump_incoming_email_clr 
			@email_id=@imap_email_address
			, @email_pwd=@imap_email_password
			, @email_host=@imap_server_host
			, @email_port=@imap_server_port
			, @document_path=@shared_document_path
			, @email_require_ssl=@imap_require_ssl
			, @flag='i'
			, @process_id=@process_id
			, @output_result = @result OUTPUT
	END
	--COMMIT
END TRY
BEGIN CATCH
	--ROLLBACK
	DECLARE @catch_err VARCHAR(MAX) = ERROR_MESSAGE()
	--PRINT ERROR_MESSAGE()
END CATCH
GO
