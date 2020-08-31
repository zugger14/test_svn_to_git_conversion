IF OBJECT_ID(N'[dbo].[spa_application_ui_template_fieldset]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_application_ui_template_fieldset]
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 -- ===========================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2014-01-29
-- Description: CRUD operations for table application_ui_fieldset
-- EXEC spa_application_ui_template_fieldset @flag = 'd',@application_function_id = '10211200',@application_group_name = 'contract'
 

-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_application_ui_template_fieldset]
	@flag CHAR(1),
	@application_function_id INT,
	@application_group_id INT  = NULL,
	@application_group_name VARCHAR(50) =NULL,
	@fieldset_name VARCHAR(50) = NULL,
	@className VARCHAR(100) = NULL,
	@is_disable CHAR(1) = NULL,
	@is_hidden CHAR(1) = NULL,
	@inputLeft INT= NULL,
	@inputTop INT = NULL,
	@label VARCHAR(100) = NULL,
	@offsetLeft INT = NULL,
	@offsetTop INT  = NULL,
	@position VARCHAR(100)  = NULL,
	@width INT = NULL,
	@sequence INT  = NULL,
	@num_column INT = NULL
AS 
IF @flag = 's'
BEGIN
	SELECT 
		afs.application_fieldset_id,
		afs.application_group_id,
		afs.className,
		afs.is_disable,
		afs.is_hidden,
		afs.inputLeft,
		afs.inputTop,
		afs.label,
		afs.offsetLeft,
		afs.offsetTop,
		afs.position,
		afs.width,
		afs.sequence
	FROM application_ui_template_fieldsets afs INNER JOIN  application_ui_template_group ag 
	ON ag.application_group_id = afs.application_group_id 
	INNER JOIN application_ui_template at ON at.application_ui_template_id = ag.application_ui_template_id
	WHERE at.application_function_id = @application_function_id
END
ELSE IF @flag = 'i'
BEGIN 
	IF NOT EXISTS (Select 1 
			FROM application_ui_template_fieldsets afs INNER JOIN  application_ui_template_group ag 
		ON ag.application_group_id = afs.application_group_id 
		INNER JOIN application_ui_template at ON at.application_ui_template_id = ag.application_ui_template_id
		WHERE at.application_function_id = @application_function_id AND ag.group_name= @application_group_name AND afs.fieldset_name = @fieldset_name) 
			BEGIN
					INSERT INTO application_ui_template_fieldsets(
					application_group_id,
					fieldset_name,
					className,
					is_disable,
					is_hidden,
					inputLeft,
					inputTop,
					label,
					offsetLeft,
					offsetTop,
					position,
					width,
					sequence,
					num_column
				)
				SELECT
						application_group_id,
						@fieldset_name,
						@className,
						@is_disable,
						@is_hidden,
						@inputLeft,
						@inputTop,
						@label,
						@offsetLeft,
						@offsetTop,
						@position,
						@width,
						@sequence,
						@num_column
					FROM application_ui_template at INNER JOIN  application_ui_template_group ag on at.application_ui_template_id = ag.application_ui_template_id
						WHERE at.application_function_id = @application_function_id AND ag.group_name = @application_group_name
			END
			ELSE 
				EXEC spa_print 'Fieldset already exists'
END
ELSE IF @flag ='d'
BEGIN
	DELETE afs  FROM application_ui_template_fieldsets afs INNER JOIN  application_ui_template_group ag on afs.application_group_id = ag.application_group_id
			INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
						WHERE at.application_function_id = @application_function_id AND ag.group_name = @application_group_name
END
