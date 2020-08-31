SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].spa_application_ui_template_audit', N'P ') IS NOT NULL 
	DROP PROCEDURE [dbo].spa_application_ui_template_audit
GO

/**
	

	Parameters
	@flag	:	Operation flag (i = insert, d = delete)
	@application_function_id	:	Application Function ID
	@application_ui_template_audit_id	:	Template Audit id
*/

CREATE PROCEDURE [dbo].spa_application_ui_template_audit
	@flag CHAR(1),
	@application_function_id VARCHAR(100) = NULL,
	@application_ui_template_audit_id INT = NULL
AS
SET NOCOUNT ON
/*
DECLARE @flag CHAR(1) = 'i',
		@application_function_id VARCHAR(100) = 10102500,
		@application_ui_template_audit_id INT = 8
--*/
IF @flag = 'i'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		
		INSERT INTO application_ui_template_audit(application_ui_template_id, application_function_id, template_name, template_description, active_flag, default_flag, table_name, is_report, edit_permission, delete_permission, remarks)
		SELECT application_ui_template_id, application_function_id, template_name, template_description, active_flag, default_flag, table_name, is_report, edit_permission, delete_permission, remarks
		FROM application_ui_template 
		WHERE application_function_id = @application_function_id

		SET @application_ui_template_audit_id = SCOPE_IDENTITY()
		
		INSERT INTO application_ui_template_definition_audit(application_ui_template_audit_id, application_ui_field_id, application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length)
		SELECT @application_ui_template_audit_id, application_ui_field_id, application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length
		FROM application_ui_template_definition 
		WHERE application_function_id = @application_function_id
		
		INSERT INTO application_ui_template_group_audit(application_ui_template_audit_id , application_group_id, application_ui_template_id, group_name, group_description, active_flag, default_flag, sequence, inputWidth, field_layout, application_grid_id)
		SELECT @application_ui_template_audit_id, application_group_id, autg.application_ui_template_id, group_name, group_description, autg.active_flag, autg.default_flag, sequence, inputWidth, field_layout, application_grid_id
		FROM application_ui_template_group  autg
		INNER JOIN application_ui_template aut ON aut.application_ui_template_id = autg.application_ui_template_id
		WHERE aut.application_function_id = @application_function_id

		INSERT INTO application_ui_template_fields_audit(application_ui_template_audit_id, application_field_id, application_group_id, application_ui_field_id, application_fieldset_id, field_alias, Default_value, default_format, validation_flag, hidden, field_size, field_type, field_id, sequence, inputHeight, udf_template_id, position, dependent_field, dependent_query, grid_id, validation_message)
		SELECT @application_ui_template_audit_id, application_field_id, autf.application_group_id, application_ui_field_id, application_fieldset_id, field_alias, Default_value, default_format, validation_flag, hidden, field_size, field_type, field_id, autf.sequence, inputHeight, udf_template_id, position, dependent_field, dependent_query, grid_id, validation_message
		FROM application_ui_template_fields autf
		INNER JOIN application_ui_template_group autg ON autg.application_group_id = autf.application_group_id
		INNER JOIN application_ui_template aut ON aut.application_ui_template_id = autg.application_ui_template_id
		WHERE aut.application_function_id = @application_function_id

		INSERT INTO application_ui_template_fieldsets_audit(application_ui_template_audit_id, application_fieldset_id, application_group_id, fieldset_name, className, is_disable, is_hidden, inputLeft, inputTop, label, offsetLeft, offsetTop, position, width, sequence, num_column)
		SELECT @application_ui_template_audit_id, application_fieldset_id, autfs.application_group_id, fieldset_name, className, is_disable, is_hidden, inputLeft, inputTop, label, offsetLeft, offsetTop, position, width, autfs.sequence, num_column
		FROM application_ui_template_fieldsets autfs
		INNER JOIN application_ui_template_group autg ON autg.application_group_id = autfs.application_group_id
		INNER JOIN application_ui_template aut ON aut.application_ui_template_id = autg.application_ui_template_id
		WHERE aut.application_function_id = @application_function_id

		INSERT INTO application_ui_layout_grid_audit(application_ui_template_audit_id, application_ui_layout_grid_id, group_id, layout_cell, grid_id, sequence, num_column, cell_height, grid_object_name, grid_object_unique_column)
		SELECT @application_ui_template_audit_id, application_ui_layout_grid_id, group_id, layout_cell, grid_id, aulg.sequence, num_column, cell_height, grid_object_name, grid_object_unique_column
		FROM application_ui_layout_grid aulg
		INNER JOIN application_ui_template_group autg ON autg.application_group_id = aulg.group_id
		INNER JOIN application_ui_template aut ON aut.application_ui_template_id = autg.application_ui_template_id
		WHERE aut.application_function_id = @application_function_id

		INSERT INTO adiha_grid_definition_audit(application_ui_template_audit_id, grid_id, grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at)
		SELECT @application_ui_template_audit_id, agd.grid_id, grid_name, fk_table, fk_column, load_sql, agd.grid_label, grid_type, grouping_column, agd.edit_permission, agd.delete_permission, split_at
		FROM adiha_grid_definition agd
		INNER JOIN application_ui_layout_grid aulg ON aulg.grid_id = CAST(agd.grid_id AS VARCHAR(20))
		INNER JOIN application_ui_template_group autg ON autg.application_group_id = aulg.group_id
		INNER JOIN application_ui_template aut ON aut.application_ui_template_id = autg.application_ui_template_id
		WHERE aut.application_function_id = @application_function_id

		INSERT INTO adiha_grid_columns_definition_audit(application_ui_template_audit_id, column_id, grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, fk_table, fk_column, is_unique, column_order, is_hidden, column_width, sorting_preference, validation_rule, column_alignment)
		SELECT @application_ui_template_audit_id, column_id, agcd.grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, agcd.fk_table, agcd.fk_column, is_unique, column_order, is_hidden, column_width, sorting_preference, validation_rule, column_alignment
		FROM adiha_grid_columns_definition agcd
		INNER JOIN  adiha_grid_definition_audit agda ON agda.grid_id = agcd.grid_id
		WHERE agda.application_ui_template_audit_id = @application_ui_template_audit_id

		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	IF OBJECT_ID('tempdb..#temp_application_ui_template_delete') IS NOT NULL
		DROP TABLE #temp_application_ui_template_delete
	
	CREATE TABLE #temp_application_ui_template_delete(application_ui_template_audit_id INT)

	IF @application_function_id IS NOT NULL
	BEGIN
		INSERT INTO #temp_application_ui_template_delete
		SELECT auta.application_ui_template_audit_id
		FROM application_ui_template_audit auta
		WHERE auta.application_function_id = @application_function_id
	END
	ELSE IF @application_ui_template_audit_id IS NOT NULL
	BEGIN
		INSERT INTO #temp_application_ui_template_delete
		SELECT @application_ui_template_audit_id [application_ui_template_audit_id]
	END
	
	DELETE autda FROM application_ui_template_definition_audit autda
	INNER JOIN #temp_application_ui_template_delete tautd ON tautd.application_ui_template_audit_id = autda.application_ui_template_audit_id
	
	DELETE autga FROM application_ui_template_group_audit autga
	INNER JOIN #temp_application_ui_template_delete tautd ON tautd.application_ui_template_audit_id = autga.application_ui_template_audit_id
	
	DELETE autfa FROM application_ui_template_fields_audit autfa
	INNER JOIN #temp_application_ui_template_delete tautd ON tautd.application_ui_template_audit_id = autfa.application_ui_template_audit_id
	
	DELETE autfsa FROM application_ui_template_fieldsets_audit autfsa
	INNER JOIN #temp_application_ui_template_delete tautd ON tautd.application_ui_template_audit_id = autfsa.application_ui_template_audit_id
	
	DELETE aulga FROM application_ui_layout_grid_audit aulga
	INNER JOIN #temp_application_ui_template_delete tautd ON tautd.application_ui_template_audit_id = aulga.application_ui_template_audit_id
	
	DELETE agda FROM adiha_grid_definition_audit agda
	INNER JOIN #temp_application_ui_template_delete tautd ON tautd.application_ui_template_audit_id = agda.application_ui_template_audit_id
	
	DELETE agcda FROM adiha_grid_columns_definition_audit agcda
	INNER JOIN #temp_application_ui_template_delete tautd ON tautd.application_ui_template_audit_id = agcda.application_ui_template_audit_id
	
	DELETE auta FROM application_ui_template_audit auta
	INNER JOIN #temp_application_ui_template_delete tautd ON tautd.application_ui_template_audit_id = auta.application_ui_template_audit_id
END

GO
