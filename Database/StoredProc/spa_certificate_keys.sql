IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_setup_certificate]') AND [type] IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_setup_certificate]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	CRUD Operations for auth_certificate_keys 

	Parameters : 
	@flag : i - insert, u - update
	@xml_value : 
	

**/
CREATE PROCEDURE [dbo].[spa_setup_certificate]
		@flag CHAR(1),
		@xml_value NVARCHAR(MAX) = NULL,
		@ids INT = NULL
AS

/*
Declare
	@flag CHAR(1) = NULL,	
	@xml_value NVARCHAR(max) = NULL
	
	select @flag ='u',
	@xml_value ='<Root><FormXML  auth_certificate_keys_id="12" name="test1" file_name="" passphrase="" description="test" certificate_key=""></FormXML></Root>'
--*/ 

SET NOCOUNT ON

IF @flag = 'i' OR @flag = 'u'
BEGIN
BEGIN TRY
	DECLARE @auth_certificate_keys_id INT

	IF OBJECT_ID(N'tempdb..#auth_certificate_keys', N'U') IS NOT NULL
	DROP TABLE #auth_certificate_keys
	
	
	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_value
		SELECT 
			auth_certificate_keys_id AS auth_certificate_keys_id,
			[name] AS name, 
			[description] AS description,
			NULLIF(file_name,'') AS file_name, 
			NULLIF(passphrase,'') AS passphrase,
			NULLIF(certificate_key,'') AS certificate_key
		INTO #auth_certificate_keys
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			auth_certificate_keys_id INT '@auth_certificate_keys_id',
			name NVARCHAR(200) '@name',
			description NVARCHAR(200) '@description',
			file_name NVARCHAR(200) '@file_name',
			passphrase NVARCHAR(200) '@passphrase',
			certificate_key NVARCHAR(MAX) '@certificate_key'
			)
		
		EXEC sp_xml_removedocument @idoc

		BEGIN TRAN
		IF @flag = 'i'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM auth_certificate_keys auc INNER JOIN #auth_certificate_keys temp ON auc.name = temp.name)
			BEGIN
			INSERT INTO auth_certificate_keys (
										name
										, description
										, file_name
										, passphrase
										, certificate_key
										)
				SELECT name, description,file_name,passphrase,certificate_key FROM #auth_certificate_keys

				SET @auth_certificate_keys_id = SCOPE_IDENTITY()

				EXEC spa_ErrorHandler 0, 
					'Setup Certification',   
					'spa_setup_certificate', 'Success',   
					'Data added successfully.', @auth_certificate_keys_id
				END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 1, 
				'Setup Certification', 
				'spa_setup_certificate', 
				'DB Error', 
				'Duplicate data in <b>Name</b>.',
				''
			END
		END

		ELSE
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM auth_certificate_keys auc INNER JOIN #auth_certificate_keys temp ON auc.name = temp.name 
			AND auc.auth_certificate_keys_id <> temp.auth_certificate_keys_id)
			BEGIN
				
				SELECT @auth_certificate_keys_id = auth_certificate_keys_id FROM #auth_certificate_keys

				DECLARE @old_file nvarchar(512), @new_file nvarchar(512)
				SELECT @old_file = file_name FROM auth_certificate_keys  WHERE  auth_certificate_keys_id = @auth_certificate_keys_id
				SELECT @new_file = file_name FROM #auth_certificate_keys 

				IF (ISNULL(@old_file,'') <> ISNULL(@new_file,'') AND @old_file IS NOT NULL)
				BEGIN
					SELECT @old_file = document_path + '\certificate_keys\' + @old_file FROM connection_string
					EXEC spa_delete_file @filename = @old_file, @result = NULL
				END

				UPDATE acu 
				SET
					acu.name = ac.name,
					acu.description = ac.description,
					acu.file_name = ac.file_name,
					acu.passphrase = ac.passphrase,
					acu.certificate_key = ac.certificate_key
				FROM auth_certificate_keys as acu
				inner join #auth_certificate_keys ac
				on acu.auth_certificate_keys_id = ac.auth_certificate_keys_id

				EXEC spa_ErrorHandler 0, 
						'Setup Certification',   
						'spa_setup_certificate', 'Success',   
						'Data updated successfully.', @auth_certificate_keys_id

			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 1, 
				'Setup Certification', 
				'spa_setup_certificate', 
				'DB Error', 
				'Duplicate data in <b>Name</b>.',
				''
			END
		END	 
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		EXEC spa_ErrorHandler 1, 
			'Setup Certification', 
			'spa_setup_certificate', 
			'DB Error', 
			'Failed to save data.',
			''
	END CATCH
END

ELSE IF @flag = 'd'
BEGIN
	DECLARE @file_name VARCHAR(512)

	SELECT @file_name = file_name FROM auth_certificate_keys  WHERE  auth_certificate_keys_id = @ids
	SELECT @file_name = document_path + '\certificate_keys\' + @file_name FROM connection_string
	EXEC spa_delete_file @filename = @file_name, @result = NULL

	DELETE ack
			FROM auth_certificate_keys ack
			INNER JOIN dbo.FNASplit(@ids, ',') di ON di.item = ack.auth_certificate_keys_id

	EXEC spa_ErrorHandler 0,
			'Setup Certification',
			'spa_setup_certificate',
			'Success',
			'Data deleted successfully.',
			@ids
END 
