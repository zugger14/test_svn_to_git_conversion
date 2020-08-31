IF OBJECT_ID(N'[dbo].[spa_application_ui_template_group]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_application_ui_template_group
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2014-01-29
-- Description: CRUD operations for table application_ui_template_group
-- spa_application_ui_template_group 'i','10211200',1,'glcode','glcode','y','y',1
-- Params:
--field_layout 1C default, other 2E,2U,3E

-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_application_ui_template_group]
    @flag							CHAR(1),
	@application_function_id		INT = NULL,
	@application_ui_template_id		INT = NULL,
	@template_name					VARCHAR(100) = NULL,
	@group_name						VARCHAR(100) = NULL,
	@group_desc						VARCHAR(200) = NULL,
	@active_flag					CHAR(1) = 'y',
	@default_flag					CHAR(1) = 'y',
	@sequence						INT  = NULL,
	@field_layout					VARCHAR(100) = NULL
AS
IF @flag = 's'
	BEGIN
		 SELECT 
			application_group_id,
			at.application_ui_template_id,
			group_name,
			group_description,
			ag.active_flag,
			ag.default_flag,
			sequence,
			template_name,
			template_description,
			at.default_flag as template_default,
			at.active_flag as template_active
		FROM application_ui_template_group ag INNER JOIN 
		application_ui_template at on ag.application_ui_template_id = at.application_ui_template_id
		 WHERE at.application_ui_template_id  = @application_ui_template_id
	END
--ELSE IF @flag = 'a'
--	BEGIN
--		 SELECT 
--			application_ui_template_id,
--			application_function_id,
--			template_name,
--			template_description,
--			active_flag,
--			default_flag 
--		FROM v
--	END
ELSE IF @flag = 'i'
	BEGIN 
	IF NOT EXISTS(Select 1 FROM application_ui_template_group ag
		INNER JOIN  application_ui_template at ON at.application_ui_template_id = ag.application_ui_template_id
		WHERE ag.group_name =@group_name and at.template_name= @template_name)
		BEGIN
			INSERT INTO application_ui_template_group (
			application_ui_template_id,
			group_name,
			group_description,
			active_flag,
			default_flag,
			sequence,
			field_layout)
			Select application_ui_template_id,
				@group_name,
				@group_desc,
				@active_flag,
				@default_flag,
				@sequence,
				@field_layout
		FROM application_ui_template at WHERE template_name  = @template_name
		END
		ELSE 
			EXEC spa_print 'GROUP already exists'
		
	END
ELSE IF @flag = 'u'
	BEGIN 
		UPDATE application_ui_template_group SET
			group_name = @group_name,
			group_description=@group_desc,
			active_flag= @active_flag,
			default_flag=@default_flag,
			sequence = @sequence
		WHERE 
			application_ui_template_id=@application_ui_template_id 
	END
ELSE IF @flag = 'd'
	BEGIN TRY
		BEGIN TRAN
			--DELETE FROM application_ui_template_group WHERE application_ui_template_id=@application_ui_template_id 
			DELETE autf2 FROM application_ui_template_fieldsets AS autf2
			INNER JOIN application_ui_template_group AS autg ON autf2.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_ui_template_id = @application_ui_template_id

			DELETE autf FROM application_ui_template_fields AS autf
			INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_ui_template_id = @application_ui_template_id

			DELETE aulg FROM application_ui_layout_grid AS aulg
			INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_ui_template_id = @application_ui_template_id

			DELETE autg FROM application_ui_template_group AS autg 
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_ui_template_id = @application_ui_template_id
			
			COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
	      IF @@TRANCOUNT > 0 ROLLBACK
	      EXEC spa_print 'Delete Failed'
	END CATCH