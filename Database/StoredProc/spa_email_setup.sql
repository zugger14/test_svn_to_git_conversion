IF OBJECT_ID(N'[dbo].[spa_email_setup]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_email_setup]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rgiri@pioneersolutionsglobal.com
-- Create date: 2013-09-27
-- Description: CRUD operations for table admin_email_configuration
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_email_setup]
    @flag CHAR(1),
    @email_subject VARCHAR(5000) = NULL,
    @email_body VARCHAR(8000) = NULL,
    @module_type INT = NULL,
	@template_id INT = NULL,
	@template_name VARCHAR(100) = NULL,
    @default_email CHAR(1) = NULL,
	@xml XML = NULL,
	@module_name varchar(100) = NULL
AS

SET NOCOUNT ON

DECLARE @DESC VARCHAR(5000)
DECLARE @err_no INT
DECLARE @default_email_template_id INT
DECLARE @XML2 VARCHAR(MAX)
DECLARE @SQL VARCHAR(MAX)
DECLARE @set_default CHAR(1)
DECLARE @return_ids VARCHAR(25) -- return combination to 2 ids when template is set to default first id current default, second id previous defult as Varchar 

IF @flag = 's'
BEGIN
	SELECT email_subject, email_body FROM admin_email_configuration WHERE module_type = 17804
END

ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
	DELETE FROM admin_email_configuration WHERE module_type= 17804
	INSERT INTO admin_email_configuration (email_subject, email_body ,module_type) 
	SELECT @email_subject, @email_body, @module_type  FROM admin_email_configuration 
	
	EXEC spa_ErrorHandler 0
			, 'email_setup'
			, 'spa_email_setup'
			, 'Success'
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK

		SET @DESC = 'Fail to save Email setup (Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler -1
			, 'email_setup'
			, 'spa_email_setup'
			, 'Error'
			, 'Fail to save Email setup.'
			, ''
	END CATCH
END

ELSE IF @flag = 'g'
BEGIN
	SELECT aec.admin_email_configuration_id, aec.template_name, sdv.code as template_type FROM admin_email_configuration aec
	RIGHT JOIN static_data_value sdv ON sdv.value_id = aec.module_type
	WHERE sdv.type_id= 17800 AND sdv.value_id IN (17804,17808,17809,17821,17811,17823, 17824)
END

IF @flag = 'o'
BEGIN
	SELECT aec.admin_email_configuration_id, aec.template_name FROM admin_email_configuration aec
	RIGHT JOIN static_data_value sdv ON sdv.value_id = aec.module_type
	WHERE sdv.type_id= 17800 AND sdv.code = @module_name
END

ELSE IF @flag = 'p'
BEGIN
	SELECT aec.admin_email_configuration_id, aec.template_name, sdv.code as template_type FROM admin_email_configuration aec
	JOIN static_data_value sdv ON sdv.value_id = aec.module_type
	WHERE sdv.type_id= 17800
END

ELSE IF @flag = 'm'
BEGIN
	SELECT aec.admin_email_configuration_id, aec.template_name, sdv.code as template_type FROM admin_email_configuration aec
	JOIN static_data_value sdv ON sdv.value_id = aec.module_type
	WHERE module_type = 17810
END

ELSE IF @flag = 'a'
BEGIN
	IF(@template_id IS NOT NULL)
	BEGIN
		SELECT admin_email_configuration_id, module_type, template_name, default_email, email_subject, email_body FROM admin_email_configuration WHERE admin_email_configuration_id = @template_id
	END
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		IF @xml IS NOT NULL
		BEGIN
			DECLARE @template_ids VARCHAR(MAX) = NULL

			SELECT @template_ids = xmlData.col.value('@template_id','VARCHAR(100)')
			FROM @xml.nodes('/Root/GridDelete') AS xmlData(Col)

			IF(@template_ids IS NOT NULL)
			BEGIN
				IF EXISTS (
					SELECT 1
					FROM dbo.FNASplit(@template_ids,',') tid
					INNER JOIN admin_email_configuration aec ON tid.item = aec.admin_email_configuration_id
					WHERE aec.default_email = 'n'
				)
				BEGIN
					DELETE aec
					FROM dbo.FNASplit(@template_ids, ',') del_ids
					INNER JOIN admin_email_configuration aec ON del_ids.item = aec.admin_email_configuration_id
					WHERE aec.default_email = 'n'
					
					EXEC spa_ErrorHandler 0
						, 'email delete'
						, 'spa_email_setup'
						, 'Success'
						, 'Email template deleted successfully.'
						,  @template_ids
		END
				ELSE
				BEGIN
				EXEC spa_ErrorHandler -1
					, 'email delete'
					, 'spa_email_setup'
					, 'Error'
					, 'Fail to delete Email template. Change default template first.'
					, ''
				END
			END
		END
	END TRY
	BEGIN CATCH	 
		SET @DESC = 'Fail to delete Email template (Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler -1
			, 'email delete'
			, 'spa_email_setup'
			, 'Error'
			, 'Fail to delete Email template.'
			, ''
	END CATCH
END

ELSE IF @flag = 't'
BEGIN
	SELECT value_id, code FROM static_data_value where type_id= 17800
END

ELSE IF @flag = 'n'
BEGIN
	SELECT 'New', @template_name
END

ELSE IF @flag = 'k'
BEGIN
	BEGIN TRY
		IF @xml IS NOT NULL
		BEGIN
			SELECT @module_type = xmlData.col.value('@module_type','VARCHAR(100)'),
				@default_email = xmlData.col.value('@default_email','VARCHAR(100)')
			FROM @xml.nodes('/Root/FormXML') AS xmlData(Col)

			IF @default_email = 'y'
			BEGIN
				IF(@module_type IS NOT NULL)
				BEGIN
					IF EXISTS (SELECT 1 FROM admin_email_configuration WHERE module_type = @module_type AND default_email = 'y')
					BEGIN
						EXEC spa_ErrorHandler 0
								, 'email_setup'
								, 'spa_email_setup'
								, 'default_exist'
								, 'Default Template already exist. Are you sure you want to overwrite default template?'
								, ''

						RETURN
					END
				END
			END

			SET @XML2 = REPLACE ( CAST(@XML AS VARCHAR(MAX)) , '/></Root>' , '></FormXML></Root>') 
			SET @SQL = 'EXEC spa_email_setup @flag = ''j'', @xml = ''' + @XML2 +''''
			EXEC(@SQL)
		END
	END TRY
	BEGIN CATCH	 
		SET @DESC = 'Fail to save Email setup (Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler -1
			, 'email_setup'
			, 'spa_email_setup'
			, 'Error'
			, 'Fail to save Email setup.'
			, ''
	END CATCH
END

ELSE IF @flag = 'v'
BEGIN
	BEGIN TRY
		IF @xml IS NOT NULL
		BEGIN
			SELECT @template_id = xmlData.col.value('@template_id','VARCHAR(100)'),
				@module_type = xmlData.col.value('@module_type','VARCHAR(100)'),
				@default_email = xmlData.col.value('@default_email','VARCHAR(100)')
			FROM @xml.nodes('/Root/FormXML') AS xmlData(Col)
			
			IF @default_email = 'y'
			BEGIN
				IF(@module_type IS NOT NULL)
				BEGIN
					IF EXISTS (SELECT 1 FROM admin_email_configuration WHERE module_type = @module_type AND default_email = 'y' AND admin_email_configuration_id != @template_id)
					BEGIN
						EXEC spa_ErrorHandler 0
								, 'email_setup'
								, 'spa_email_setup'
								, 'default_exist'
								, 'Default Template already exist. Are you sure you want to overwrite default template?'
								, ''
				
						RETURN
					END
				END
			END

			SET @XML2 = REPLACE ( CAST(@XML AS VARCHAR(MAX)) , '/></Root>' , '></FormXML></Root>') 
			SET @SQL = 'EXEC spa_email_setup @flag = ''u'', @xml = ''' + @XML2 +''''
			EXEC(@SQL)
		END
	END TRY
	BEGIN CATCH	 
		SET @DESC = 'Fail to save Email setup (Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler -1
			, 'email_setup'
			, 'spa_email_setup'
			, 'Error'
			, 'Fail to save Email setup.'
			, ''
	END CATCH
END

--For New Entry
ELSE IF @flag = 'j'
BEGIN
	BEGIN TRY
		IF @xml IS NOT NULL
		BEGIN
			SELECT @module_type = xmlData.col.value('@module_type','VARCHAR(100)'),
				@template_name = xmlData.col.value('@template_name','VARCHAR(100)'),
				@default_email = xmlData.col.value('@default_email','VARCHAR(100)'),
				@email_subject = xmlData.col.value('@email_subject','VARCHAR(MAX)'),
				@email_body = xmlData.col.value('@email_body','VARCHAR(MAX)')
			FROM
				@xml.nodes('/Root/FormXML') AS xmlData(Col)
			
			--if default_email is set and @default_email = 'n' then @default_email = 'n' else @default_email = 'y' for all other cases.
			IF(@module_type IS NOT NULL)
			BEGIN
				IF EXISTS (SELECT 1 FROM admin_email_configuration WHERE module_type = @module_type AND default_email = 'y')
				BEGIN
					SELECT @default_email_template_id = admin_email_configuration_id FROM admin_email_configuration WHERE module_type = @module_type AND default_email = 'y'

					IF @default_email = 'n'
					BEGIN
						SET @set_default = 'n'
					END
				END
			END

			IF(@set_default = 'n')
			BEGIN
				SET @default_email = 'n'

				SET @default_email_template_id = NULL
			END
			ELSE
			BEGIN
				SET @default_email = 'y'
			END

			INSERT INTO admin_email_configuration (email_subject, email_body, module_type, template_name, default_email) VALUES 
			(@email_subject, @email_body, @module_type, @template_name, @default_email)

			--set current default_email to 'n'
			IF @default_email_template_id IS NOT NULL
			BEGIN
				UPDATE admin_email_configuration SET default_email = 'n' WHERE admin_email_configuration_id = @default_email_template_id
			END



			IF @default_email_template_id IS NOT NULL
				SET @return_ids = CONVERT(VARCHAR(25), SCOPE_IDENTITY()) + ' , ' + CONVERT(VARCHAR(25), @default_email_template_id)
			ELSE
				SET @return_ids = CONVERT(VARCHAR(25), SCOPE_IDENTITY()) 

			EXEC spa_ErrorHandler 0
					, 'email_setup'
					, 'spa_email_setup'
					, 'Success'
					, 'Changes have been saved successfully.'
					, @return_ids
		END
	END TRY
	BEGIN CATCH	 
		SET @DESC = 'Fail to save Email setup (Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		IF @err_no = 2627
		BEGIN
			EXEC spa_ErrorHandler -1
			, 'email_setup'
			, 'spa_email_setup'
			, 'Error'
			, 'Template Name must be unique.'
			, ''
		END
		ELSE
		BEGIN	
			EXEC spa_ErrorHandler -1
			, 'email_setup'
			, 'spa_email_setup'
			, 'Error'
			, @DESC
			, ''
		END

	END CATCH
END

ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		IF @xml IS NOT NULL
		BEGIN
			SELECT @template_id = xmlData.col.value('@template_id','VARCHAR(100)'),
				@module_type = xmlData.col.value('@module_type','VARCHAR(100)'),
				@template_name = xmlData.col.value('@template_name','VARCHAR(100)'),
				@default_email = xmlData.col.value('@default_email','VARCHAR(100)'),
				@email_subject = xmlData.col.value('@email_subject','VARCHAR(MAX)'),
				@email_body = xmlData.col.value('@email_body','VARCHAR(MAX)')
			FROM
				@xml.nodes('/Root/FormXML') AS xmlData(Col)

			--if this template is not currently set default_email and @default_email = 'n' then @default_email = 'n' else @default_email = 'y' for all other cases.
			IF(@module_type IS NOT NULL)
			BEGIN
				IF EXISTS (SELECT 1 FROM admin_email_configuration WHERE module_type = @module_type AND default_email = 'y' and admin_email_configuration_id != @template_id)
				BEGIN
					SELECT @default_email_template_id = admin_email_configuration_id FROM admin_email_configuration WHERE module_type = @module_type AND default_email = 'y'

					IF @default_email = 'n'
					BEGIN
						SET @set_default = 'n'
					END
				END
			END

			IF(@set_default = 'n')
			BEGIN
				SET @default_email = 'n'

				SET @default_email_template_id = NULL
			END
			ELSE
			BEGIN
				SET @default_email = 'y'
			END

			IF(@template_id IS NOT NULL)
			BEGIN
				UPDATE admin_email_configuration SET 
					email_subject = @email_subject, 
					email_body = @email_body, 
					module_type = @module_type, 
					template_name = @template_name, 
					default_email = @default_email 
				WHERE admin_email_configuration_id = @template_id

				IF @default_email_template_id IS NOT NULL
					SET @return_ids = CONVERT(VARCHAR(25), @template_id) + ' , ' + CONVERT(VARCHAR(25), @default_email_template_id) + ' , ' + '0'
				ELSE
					SET @return_ids = CONVERT(VARCHAR(25), @template_id) + ' , ' + '0'
				
				EXEC spa_ErrorHandler 0
						, 'email_setup'
						, 'spa_email_setup'
						, 'Success'
						, 'Changes have been saved successfully.'
						, @return_ids 

				--set current default_email to 'n'
				IF @default_email_template_id IS NOT NULL
				BEGIN
					UPDATE admin_email_configuration SET default_email = 'n' WHERE admin_email_configuration_id = @default_email_template_id
				END
			END
		END
	END TRY
	BEGIN CATCH	 
		SET @DESC = 'Fail to save Email setup (Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		IF @err_no = 2627
		BEGIN
			EXEC spa_ErrorHandler -1
			, 'email_setup'
			, 'spa_email_setup'
			, 'Error'
			, 'Template Name must be unique.'
			, ''
		END
		ELSE
		BEGIN	
			EXEC spa_ErrorHandler -1
			, 'email_setup'
			, 'spa_email_setup'
			, 'Error'
			, 'Fail to save Email setup.'
			, ''
		END
	END CATCH
END