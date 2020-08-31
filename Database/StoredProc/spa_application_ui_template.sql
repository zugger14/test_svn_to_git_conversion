IF OBJECT_ID(N'[dbo].[spa_application_ui_template]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_application_ui_template]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2014-01-29
-- Description: CRUD operations for table application_ui_template
 
-- Params:
--EXEC spa_application_ui_template 'i',10211200,'glcode','glcode','y','n','table_name'

-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_application_ui_template]
    @flag							CHAR(1),
	@application_function_id        INT,
	@template_name					VARCHAR(100) =	NULL,
	@template_desc					VARCHAR(500) =	NULL,
	@active_flag					CHAR(1) =	NULL,
	@default_flag					CHAR(1) =	NULL,
	@is_report						CHAR(1) = NULL,
	@table_name						VARCHAR(100) =	NULL,
	@edit_permission				VARCHAR(100) =	NULL,
	@delete_permission				VARCHAR(100) =	NULL
AS
/*
DECLARE
@flag							CHAR(1),
@application_function_id        INT,
	@template_name					VARCHAR(100) =	NULL,
	@template_desc					VARCHAR(500) =	NULL,
	@active_flag					CHAR(1) =	NULL,
	@default_flag					CHAR(1) =	NULL,
	@is_report						CHAR(1) = NULL,
	@table_name						VARCHAR(100) =	NULL,
	@edit_permission				VARCHAR(100) =	NULL,
	@delete_permission				VARCHAR(100) =	NULL

select @flag = 'd', @application_function_id = 10105900
--*/
DECLARE @application_ui_template_id INT 
SELECT @application_ui_template_id =application_ui_template_id FROM  application_ui_template 
			WHERE application_function_id = @application_function_id AND template_name = @template_name
IF @flag = 's'
	BEGIN
		  SELECT application_ui_template_id,
			application_function_id,
			template_name,
			template_description,
			active_flag,
			default_flag 
		FROM application_ui_template WHERE application_function_id  = @application_function_id
	END
ELSE IF @flag = 'a'
	BEGIN
		 SELECT 
			application_ui_template_id,
			application_function_id,
			template_name,
			template_description,
			active_flag,
			default_flag 
		FROM application_ui_template
	END
ELSE IF @flag = 'i'
	BEGIN 
		IF NOT EXISTS(Select 1 FROM  application_ui_template 
			WHERE application_function_id = @application_function_id AND template_name = @template_name)
		BEGIN
			INSERT INTO application_ui_template (
				application_function_id,
				template_name,
				template_description,
				active_flag,
				default_flag,
				is_report,
				table_name,
				edit_permission,
                delete_permission)
				VALUES
				(@application_function_id,
				@template_name,
				@template_desc,
				@active_flag,
				@default_flag,
				@is_report,
				@table_name,
				@edit_permission,
				@delete_permission)
		END
		ELSE 
			EXEC spa_print 'Template name already exist'	
	END
ELSE IF @flag = 'u'
	BEGIN 
		UPDATE application_ui_template SET
			template_name = @template_name,
			template_description = @template_desc,
			active_flag = @active_flag,
			default_flag = @default_flag,
			is_report = @is_report,
			table_name=@table_name
		WHERE 
			application_ui_template_id = @application_ui_template_id
	END
ELSE IF @flag = 'd'
	BEGIN TRY
		BEGIN TRAN		
			/*Delete junk data from filter Starts*/
			DELETE 
			FROM application_ui_filter_details
			WHERE application_field_id IS NULL
				AND report_column_id IS NULL
				AND layout_grid_id IS NULL
				AND book_level IS NULL
			
			-- For Special case as found in some version.
			DELETE aufd
			FROM application_ui_filter auf
			INNER JOIN application_ui_filter_details aufd
				ON aufd.application_ui_filter_id = auf.application_ui_filter_id
			WHERE auf.report_id IS NULL AND auf.application_function_id IS NULL

			DELETE
			FROM application_ui_filter 
			WHERE application_function_id IS NULL 
			AND report_id IS NULL
			/*Junk data delete ends*/
			
			/*Delete from application filter*/
			DELETE aufd  FROM application_ui_filter_details aufd
			INNER JOIN application_ui_filter auf ON  auf.application_ui_filter_id = aufd.application_ui_filter_id
			WHERE auf.application_function_id = @application_function_id

			DELETE FROM application_ui_filter WHERE application_function_id = @application_function_id
			/**End of filter delete**/
			
			--DELETE FROM application_ui_template_group WHERE application_ui_template_id=@application_ui_template_id 
			DELETE autf2 FROM application_ui_template_fieldsets AS autf2
			INNER JOIN application_ui_template_group AS autg ON autf2.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = @application_function_id

			DELETE autf FROM application_ui_template_fields AS autf
			INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = @application_function_id

			DELETE aulg FROM application_ui_layout_grid AS aulg
			INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = @application_function_id

			DELETE autg FROM application_ui_template_group AS autg 
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = @application_function_id
			
			DELETE autd FROM application_ui_template_definition AS autd
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = autd.application_function_id
			WHERE aut.application_function_id = @application_function_id
			
			DELETE FROM application_ui_template
			WHERE application_function_id = @application_function_id
			
		COMMIT		
	END TRY
	BEGIN CATCH
		DECLARE @msg varchar(100)= ERROR_MESSAGE()

		ROLLBACK TRAN
		IF @@TRANCOUNT > 0 ROLLBACK

		RAISERROR (@msg, 16, 1)
	END CATCH