IF OBJECT_ID(N'[dbo].[spa_template_definition_udf_remap]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].spa_template_definition_udf_remap

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Displays preserve and restore/remap udf values. 

	Parameters
	@flag :
			't' : Temporary preserve udf data to be restored after patch.  
			'r'	: Remap/save data after patch apply. 
*/

CREATE PROCEDURE [dbo].spa_template_definition_udf_remap
	@flag varchar(2)
AS

SET NOCOUNT ON

--This script create physical tables application_ui_template_definition_udf_remapping 
--and application_ui_template_fields_udf_remapping if doesnot exists. 
--It truncates all the existing data in above two tables and preserves data from application_ui_template_definition with where is_udf = 'y' 
--and data from application_ui_template_fields with udf_template_id IS NOT NULL before applying patch.
--These data will be used in second script if any udf data in application UI are deleted using patch(mainly client specific). 

IF @flag = 't'
BEGIN
	IF OBJECT_ID(N'[dbo].[application_ui_template_definition_udf_remapping]', N'U') IS NULL
		BEGIN
		CREATE TABLE [dbo].[application_ui_template_definition_udf_remapping](
			[application_ui_field_id] [int] NOT NULL,
			[application_function_id] [int] NOT NULL,
			[field_id] [varchar](100) NULL,
			[farrms_field_id] [varchar](100) NULL,
			[default_label] [varchar](100) NULL,
			[field_type] [varchar](100) NULL,
			[data_type] [varchar](100) NULL,
			[header_detail] [char](1) NULL,
			[system_required] [char](1) NULL,
			[sql_string] [varchar](5000) NULL,
			[field_size] [int] NULL,
			[is_disable] [char](1) NULL,
			[is_hidden] [char](1) NULL,
			[default_value] [varchar](200) NULL,
			[insert_required] [char](1) NULL,
			[data_flag] [char](1) NULL,
			[update_required] [char](1) NULL,
			[has_round_option] [char](1) NULL,
			[create_user] [varchar](50) NULL,
			[create_ts] [datetime] NULL,
			[update_user] [varchar](50) NULL,
			[update_ts] [datetime] NULL,
			[blank_option] [char](1) NULL,
			[is_primary] [char](1) NULL,
			[is_udf] [char](1) NULL,
			[is_identity] [char](1) NULL,
			[text_row_num] [int] NULL,
			[hyperlink_function] [varchar](200) NULL,
			[char_length] [int] NULL,
		PRIMARY KEY CLUSTERED 
		(
			[application_ui_field_id] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]
	END
	IF OBJECT_ID(N'[dbo].[application_ui_template_fields_udf_remapping]', N'U') IS  NULL
	BEGIN
	CREATE TABLE [dbo].[application_ui_template_fields_udf_remapping](
		[application_field_id] [int] NOT NULL,
		[application_ui_field_id] [int] NULL,
		--[application_fieldset_id] [int] NULL,fieldset_name
		[field_alias] [varchar](100) NULL,
		[Default_value] [varchar](200) NULL,
		[default_format] [varchar](200) NULL,
		[validation_flag] [char](1) NULL,
		[hidden] [char](1) NULL,
		[field_size] [int] NULL,
		[field_type] [varchar](200) NULL,
		[field_id] [varchar](200) NULL,
		[sequence] [int] NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL,
		[inputHeight] [int] NULL,
		[udf_template_id] [int] NULL,
		[position] [varchar](200) NULL,
		[dependent_field] [varchar](200) NULL,
		[dependent_query] [varchar](200) NULL,
		[grid_id] [varchar](100) NULL,
		[validation_message] [varchar](200) NULL,
		[load_child_without_parent] [bit] NULL,
		[application_group_name] [varchar](200) NULL,
		[fieldset_name]  [varchar](200) NULL)
	END

	------- Data Insert in remapping start

	Truncate table application_ui_template_definition_udf_remapping
	Truncate table application_ui_template_fields_udf_remapping

	INSERT INTO application_ui_template_definition_udf_remapping
				(application_ui_field_id
				,application_function_id
				,field_id
				,farrms_field_id
				,default_label
				,field_type
				,data_type
				,header_detail
				,system_required
				,sql_string
				,field_size
				,is_disable
				,is_hidden
				,default_value
				,insert_required
				,data_flag
				,update_required
				,has_round_option
				,blank_option
				,is_primary
				,is_udf
				,is_identity
				,text_row_num
				,hyperlink_function
				,char_length)
			
		SELECT  application_ui_field_id
				,application_function_id
				,field_id
				,farrms_field_id
				,default_label
				,field_type
				,data_type
				,header_detail
				,system_required
				,sql_string
				,field_size
				,is_disable
				,is_hidden
				,default_value
				,insert_required
				,data_flag
				,update_required
				,has_round_option
				,blank_option
				,is_primary
				,is_udf
				,is_identity
				,text_row_num
				,hyperlink_function
				,char_length
			FROM application_ui_template_definition where is_udf = 'y'
	
	INSERT INTO application_ui_template_fields_udf_remapping
				(application_field_id
				,application_ui_field_id
				,field_alias
				,Default_value
				,default_format
				,validation_flag
				,hidden
				,field_size
				,field_type
				,field_id
				,sequence
				,inputHeight
				,udf_template_id
				,position
				,dependent_field
				,dependent_query
				,grid_id
				,validation_message
				,load_child_without_parent
				,application_group_name
				,fieldset_name)
		SELECT  autf.application_field_id
				,autf.application_ui_field_id
				,autf.field_alias
				,autf.Default_value
				,autf.default_format
				,autf.validation_flag
				,autf.hidden
				,autf.field_size
				,autf.field_type
				,autf.field_id
				,autf.sequence
				,autf.inputHeight
				,autf.udf_template_id
				,autf.position
				,autf.dependent_field
				,autf.dependent_query
				,autf.grid_id
				,autf.validation_message
				,autf.load_child_without_parent
				,autg.group_name
				,auft.fieldset_name
				 FROM application_ui_template_fields autf
				 INNER JOIN application_ui_template_group autg ON autf.application_group_id = autg.application_group_id
				 LEFT JOIN application_ui_template_fieldsets auft ON auft.application_group_id = autg.application_group_id AND auft.application_fieldset_id = autf.application_fieldset_id
				 WHERE autf.udf_template_id IS NOT NULL
	-------------Data insert in remapping end-----
	END
	
IF @flag = 'r'
BEGIN
	CREATE TABLE #temp_application_ui_group
	(application_function_id INT,udf_template_id int,  group_name VARCHAR(1000) COLLATE DATABASE_DEFAULT, fieldset_name VARCHAR(1000) COLLATE DATABASE_DEFAULT,application_group_id INT, application_ui_field_id int)

	INSERT INTO #temp_application_ui_group
	SELECT autdr.application_function_id,autfur.udf_template_id, autg.group_name, autfur.fieldset_name, autg.application_group_id,autfur.application_ui_field_id
		From application_ui_template_fields_udf_remapping autfur
		INNER JOIN application_ui_template_definition_udf_remapping autdr ON autdr.application_ui_field_id = autfur.application_ui_field_id			
		INNER JOIN application_ui_template aut ON aut.application_function_id = autdr.application_function_id
		INNER JOIN application_ui_template_group autg on autg.application_ui_template_id = aut.application_ui_template_id AND autg.group_name = autfur.application_group_name
		LEFT JOIN application_ui_template_definition autd ON autdr.application_function_id = autd.application_function_id
			AND autdr.field_id = autd.field_id
			AND autdr.farrms_field_id = autd.farrms_field_id
		WHERE autd.application_ui_field_id IS NULL

	-------------Data Compare start and insert--------
	IF EXISTS
	(SELECT 1 FROM application_ui_template_definition_udf_remapping autdr
	LEFT JOIN  application_ui_template_definition autd 
	ON autdr.application_function_id = autd.application_function_id
	AND autdr.field_id = autd.field_id
	AND autdr.farrms_field_id = autd.farrms_field_id 
	WHERE autd.application_ui_field_id IS NULL)
		BEGIN
			SET IDENTITY_INSERT application_ui_template_definition ON
			INSERT INTO application_ui_template_definition
				(application_ui_field_id
				,application_function_id
				,field_id
				,farrms_field_id
				,default_label
				,field_type
				,data_type
				,header_detail
				,system_required
				,sql_string
				,field_size
				,is_disable
				,is_hidden
				,default_value
				,insert_required
				,data_flag
				,update_required
				,has_round_option
				,blank_option
				,is_primary
				,is_udf
				,is_identity
				,text_row_num
				,hyperlink_function
				,char_length)
			SELECT 
				autdr.application_ui_field_id
				,autdr.application_function_id
				,autdr.field_id
				,autdr.farrms_field_id
				,autdr.default_label
				,autdr.field_type
				,autdr.data_type
				,autdr.header_detail
				,autdr.system_required
				,autdr.sql_string
				,autdr.field_size
				,autdr.is_disable
				,autdr.is_hidden
				,autdr.default_value
				,autdr.insert_required
				,autdr.data_flag
				,autdr.update_required
				,autdr.has_round_option
				,autdr.blank_option
				,autdr.is_primary
				,autdr.is_udf
				,autdr.is_identity
				,autdr.text_row_num
				,autdr.hyperlink_function
				,autdr.char_length
			FROM application_ui_template_definition_udf_remapping autdr
			LEFT JOIN application_ui_template_definition autd ON autdr.application_function_id = autd.application_function_id
				AND autdr.field_id = autd.field_id
				AND autdr.farrms_field_id = autd.farrms_field_id 
			WHERE autd.application_ui_field_id is null
			SET IDENTITY_INSERT application_ui_template_definition  OFF
		END

	IF EXISTS (Select 1 from application_ui_template_fields_udf_remapping re
		INNER JOIN application_ui_template_definition_udf_remapping  autd 
		ON autd.application_ui_field_id = re.application_ui_field_id
		LEFT JOIN application_ui_template_fields autf on autf.application_ui_field_id = re.application_ui_field_id
	WHERE autf.application_ui_field_id IS NULL)
	BEGIN
			SET IDENTITY_INSERT application_ui_template_fields ON
			INSERT INTO application_ui_template_fields
				(application_field_id
				,application_group_id
				,application_ui_field_id
				,application_fieldset_id
				,field_alias
				,Default_value
				,default_format
				,validation_flag
				,hidden
				,field_size
				,field_type
				,field_id
				,sequence
				,create_user
				,create_ts
				,update_user
				,update_ts
				,inputHeight
				,udf_template_id
				,position
				,dependent_field
				,dependent_query
				,grid_id
				,validation_message
				,load_child_without_parent)
			Select
				 autfur.application_field_id
				,taug.application_group_id
				,autfur.application_ui_field_id
				,taug.fieldset_name
				,autfur.field_alias
				,autfur.Default_value
				,autfur.default_format
				,autfur.validation_flag
				,autfur.hidden
				,autfur.field_size
				,autfur.field_type
				,autfur.field_id
				,autfur.sequence
				,autfur.create_user
				,autfur.create_ts
				,autfur.update_user
				,autfur.update_ts
				,autfur.inputHeight
				,autfur.udf_template_id
				,autfur.position
				,autfur.dependent_field
				,autfur.dependent_query
				,autfur.grid_id
				,autfur.validation_message
				,autfur.load_child_without_parent
				From application_ui_template_fields_udf_remapping autfur
				INNER JOIN application_ui_template_definition_udf_remapping autd ON autd.application_ui_field_id = autfur.application_ui_field_id			
				INNER JOIN #temp_application_ui_group taug on taug.application_function_id = autd.application_function_id 
					and taug.group_name = autfur.application_group_name and taug.application_ui_field_id = autfur.application_ui_field_id
				LEFT JOIN application_ui_template_fieldsets autff ON autff.application_group_id = taug.application_group_id 
					and autff.fieldset_name = autfur.fieldset_name
				LEFT JOIN application_ui_template_fields autf on autf.application_ui_field_id = autfur.application_ui_field_id and autf.application_field_id = autfur.application_field_id
				WHERE autf.application_ui_field_id IS NULL
			SET IDENTITY_INSERT application_ui_template_fields OFF
	END
END
