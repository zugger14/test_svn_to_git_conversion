IF OBJECT_ID(N'[dbo].[spa_application_ui_template_field]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_application_ui_template_field
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2014-01-29
-- Description: CRUD operations for table application_ui_template_field
 --Exec spa_application_ui_template_field 'j',10211200,'charge' --2,1074,NULL,NULL,NULL,'y','n',50,null,Null
--Exec spa_application_ui_template_field 'd',10211200,'contract_group','settlement_date',NULL,'Contract Price'
--Select  * from application_ui_template
-- Params:
--@flag = New flag used on this spa  'j' which returns json formatted output of the field. @application_function should be provided. 
--,@application_function_id,@
--SQL_query- for combo its sql query , for calendar - it acts as position. 
-- FOR calendar - defaultFormat works as EnableTime option

-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_application_ui_template_field]
    @flag							CHAR(1),
	@application_function_id INT = NULL,
	@template_name VARCHAR(100) = NULL,
	@column_name VARCHAR(100) = NULL,
	@field_type VARCHAR(100)= NULL,
	@group_name VARCHAR(100) = NULL,
	@application_group_id    INT = NULL,
	@application_ui_field_id		INT = NULL,
	@return_type				VARCHAR  = NULL,
	@application_ui_template_id INT = NULL,
	@field_alias VARCHAR(100) = NULL,
	@Default_value VARCHAR(100) = NULL, 
	@default_format VARCHAR(100) = NULL, 
	@validation_flag CHAR(1)= NULL,
	@hidden CHAR(1)= NULL,
	@field_size INT= NULL,
	@field_id VARCHAR(100)= NULL,
	@inputheight INT = NULL,
	@fieldset_id INT = NULL,
	@udf_template_id INT = NULL,
	@sequence INT = NULL,
	@position VARCHAR(100) =NULL,
	@grid_id  VARCHAR(100) =NULL,
	@validation_message VARCHAR(500) = NULL
AS
IF @flag = 's'
	BEGIN
		Select 
			application_field_id,
			ag.application_group_id,
			af.application_ui_field_id,
			coalesce(af.field_alias,ad.default_label,udft.field_label) field_name,
			coalesce(af.Default_value,ad.default_value) default_value,
			default_format,
			COALESCE(validation_flag,insert_required) validation_flag,
			COALESCE(hidden,ad.is_hidden) is_hidden
			,COALESCE(af.field_size,ad.field_size) field_size
			,COALESCE(af.field_type,ad.field_type) field_type
			,COALESCE(af.field_id,ad.field_id) field_id,
			ad.header_detail,
			ad.system_required,
			ad.is_disable,
			ad.has_round_option,
			ad.update_required,
			ad.data_flag,
			COALESCE(ad.insert_required,udft.is_required),
			ag.group_name tab_name,
			ag.group_description tab_description,
			ag.active_flag tab_active_flag,
			ag.sequence tab_sequence,
			COALESCE(ad.sql_string,ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string)) sql_string,
			af.inputheight,
			af.udf_template_id
		 FROM application_ui_template_fields  af INNER JOIN application_ui_template_group ag
			ON ag.application_group_id = af.application_group_id
		INNER JOIN application_ui_template_definition ad on ad.application_ui_field_id = af.application_ui_field_id
		INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
		LEFT JOIN user_defined_fields_template udft on udft.udf_template_id = af.udf_template_id
		LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udft.data_source_type_id
		WHERE at.application_ui_template_id = @application_ui_template_id 
		Order by af.sequence

		
	END
ELSE IF @flag = 'a'
	BEGIN
		 Select 
			application_field_id,
			ag.application_group_id,
			af.application_ui_field_id,
			coalesce(af.field_alias,ad.default_label) field_name,
			coalesce(af.Default_value,ad.default_value) default_value,
			default_format,
			COALESCE(validation_flag,insert_required) validation_flag,
			COALESCE(hidden,is_hidden) is_hidden
			,COALESCE(af.field_size,ad.field_size) field_size
			,COALESCE(af.field_type,ad.field_type) field_type
			,COALESCE(af.field_id,ad.field_id) field_id,
			ad.header_detail,
			ad.system_required,
			ad.is_disable,
			ad.has_round_option,
			ad.update_required,
			ad.data_flag,
			ad.insert_required,
			ag.group_name tab_name,
			ag.group_description tab_description,
			active_flag tab_active_flag,
			ag.sequence tab_sequence,
			ad.sql_string,
			af.inputheight
		 FROM application_ui_template_fields  af INNER JOIN application_ui_template_group ag
			ON ag.application_group_id = af.application_group_id
		INNER JOIN application_ui_template_definition ad on ad.application_ui_field_id = af.application_ui_field_id
		
		Order by af.sequence
	END
ELSE IF @flag = 'i'
	BEGIN 
		IF NOT EXISTS(Select 1 FROM application_ui_template_fields af 
			INNER JOIN  application_ui_template_definition ad ON af.application_ui_field_id = ad.application_ui_field_id
			INNER JOIN application_ui_template_group ag on ag.application_group_id = af.application_group_id
			WHERE ad.application_function_id = @application_function_id AND ad.field_id = ISNULL(@column_name,'') AND ad.field_type  = ISNULL(@field_type,'') AND ag.group_name=ISNULL(@group_name,''))
		BEGIN 
			INSERT INTO application_ui_template_fields (
				application_group_id,
				application_ui_field_id,
				application_fieldset_id,
				field_alias,
				Default_value,
				default_format,
				validation_flag,
				hidden,
				field_size,
				field_type,
				field_id,
				inputheight,
				udf_template_id, 
				sequence,
				position,
				grid_id,
				validation_message
			)
			SELECT	ag.application_group_id,
				application_ui_field_id,
				@fieldset_id,
				@field_alias,
				@default_value,
				@default_format,
				@validation_flag,
				@hidden,
				@field_size,
				@field_type,
				@field_id,
				@inputheight,
				@udf_template_id,
				@sequence,
				@position,
				@grid_id,
				@validation_message
			FROM application_ui_template_definition ad INNER JOIN application_ui_template at 
				ON ad.application_function_id = at.application_function_id 
				INNER JOIN application_ui_template_group ag ON ag.application_ui_template_id = at.application_ui_template_id 
			WHERE at.application_function_id = @application_function_id AND ISNULL(field_id,'') = ISNULL(@column_name,'') AND field_type = ISNULL(@field_type,'') AND at.template_name = @template_name
			AND ag.group_name = @group_name 


		END
		ELSE 
			EXEC spa_print 'Column already exists in the Table. '
	END
ELSE IF @flag = 'd'
	BEGIN
		DELETE af FROM application_ui_template_fields af  INNER JOIN application_ui_template_definition ad 
			ON ad.application_ui_field_id = af.application_ui_field_id
		INNER JOIN application_ui_template_group ag on ag.application_group_id = af.application_group_id 
		INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
		WHERE ag.group_name = @group_name AND ad.application_function_id= @application_function_id AND at.template_name = @template_name AND ad.field_id = @column_name
	END
