IF OBJECT_ID(N'[dbo].[spa_application_ui_template_definition]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_application_ui_template_definition]
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
-- spa_application_ui_template_definition 'i','10211200','Name','Name','textbox',varchar,'h','y',NULL,50,'n','y','y','n','n'
-- EXEC spa_application_ui_template_definition 'u','10211200','Name','NULL','NULL','NULL','null','NULL','Query',50,'n','y','y','n','n'
-- spa_application_ui_template_definition 'd','10211200','Name',null,'input',varchar,'h','y',NULL,50,'n','y','y','n','n'
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_application_ui_template_definition]
    @flag							CHAR(1),
	@application_function_id		VARCHAR(100) = NULL,
	@column_name						VARCHAR(100) = NULL,
	@default_label						VARCHAR(100)=NULL,
	@field_type						VARCHAR(100)=NULL,
	@data_type						VARCHAR(100)=NULL,
	@header_detail					CHAR(1) = NULL,
	@system_required					CHAR(1) = NULL,
	@sql_string						VARCHAR(5000)=NULL,
	@field_size						INT = NULL,
	@is_disable						CHAR(1) = NULL,
	@is_hidden						CHAR(1) = NULL, 
	@default_value					VARCHAR(200) = NULL,
	@insert_required				CHAR(1) = NULL,
	@data_flag						CHAR(1) = NULL,
	@update_required				CHAR(1) = NULL,
	@has_round_option				CHAR(1) = NULL,
	@has_blank_option				CHAR(1) = 'y',
	@is_primary						CHAR(1) = 'n',
	@is_udf							CHAR(1) = 'n',
	@is_identity					CHAR(1) = 'n',
	@text_row_num					INT = NULL,
    @hyperlink_function				VARCHAR(200) = NULL,
    @char_length					INT = NULL
AS	
 
IF @flag = 'i'
BEGIN
	IF NOT EXISTS(Select 1 FROM application_ui_template_definition WHERE application_function_id = @application_function_id AND field_id = @column_name AND field_type = @field_type) 
	BEGIN
		INSERT INTO  application_ui_template_definition(
		application_function_id,
		field_id,
		farrms_field_id,
		default_label,
		field_type,
		data_type,
		header_detail,
		system_required,
		sql_string,
		field_size,
		is_disable,
		is_hidden,
		default_value,
		insert_required,
		data_flag,
		update_required,
		has_round_option,blank_option,is_primary,is_udf,is_identity, text_row_num, hyperlink_function, char_length)
	  VALUES (@application_function_id,ISNULL(@column_name, ''),ISNULL(@column_name, ''),@default_label,@field_type,@data_type,@header_detail,@system_required,@sql_string,
		@field_size,@is_disable,@is_hidden,@default_value,@insert_required,@data_flag,@update_required,@has_round_option,@has_blank_option,@is_primary,@is_udf,@is_identity,@text_row_num,@hyperlink_function,@char_length)
	END																																											
	ELSE																																											
		EXEC spa_print 'Function ID :', @application_function_id , ' WITH same field_name ', @column_name,' AND same fieldtype:', @field_type,' already Exists'


  
END
IF @flag = 's' 
BEGIN
	SELECT 
		application_ui_field_id,
		application_function_id,
		field_id,
		farrms_field_id,
		default_label,
		field_type,
		data_type,
		header_detail,
		system_required,
		sql_string,
		field_size,
		is_disable,
		is_hidden,
		default_value,
		insert_required,
		data_flag,
		update_required,
		has_round_option
	FROM application_ui_template_definition 
	WHERE application_function_id = @application_function_id
END
ELSE IF @flag = 'u'
BEGIN
	UPDATE application_ui_template_definition SET 
	sql_string = @sql_string 
	WHERE application_function_id = @application_function_id AND field_id = @column_name
END
ELSE IF @flag='d'
BEGIN TRY
	BEGIN TRAN
	--DELETE FROM application_ui_template_definition 
	--	WHERE application_function_id = @application_function_id AND field_id = @column_name AND field_type = @field_type
	
	DELETE autf FROM application_ui_template_fields AS autf
	INNER JOIN application_ui_template_definition AS autd ON autf.application_ui_field_id = autd.application_ui_field_id
	WHERE autd.application_function_id = @application_function_id AND autd.field_id = @column_name

	DELETE FROM application_ui_template_definition 
	WHERE application_function_id = @application_function_id AND field_id = @column_name
	
	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	      IF @@TRANCOUNT > 0 ROLLBACK
	      EXEC spa_print 'Delete Failed'
END CATCH


