IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_name = '-5716' AND Field_label = 'Internal Desk')
BEGIN
	INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT '-5716', 'Internal Desk', 'd', 'INT', 'n', 'SELECT source_internal_desk_id, internal_desk_name FROM source_internal_desk', 'h', 120, '-5716' 
END 
ELSE PRINT 'user_defined_fields_template exists'

DECLARE @field_template_id INT, @field_group_id INT , @field_id INT, @deal_template_id INT

SELECT @field_template_id = field_template_id FROM maintain_field_template WHERE template_name = 'Hedge Accounting'
SELECT @field_id = udf_template_id FROM user_defined_fields_template WHERE field_name = '-5716'
SELECT @field_group_id = field_group_id FROM maintain_field_template_group WHERE field_template_id = @field_template_id AND group_name = 'Other Attribute'
--select @field_template_id,  @field_id, @field_group_id
IF NOT EXISTS (SELECT 1 FROM maintain_field_template_detail WHERE field_id = @field_id AND field_template_id = @field_template_id)
BEGIN
	INSERT INTO maintain_field_template_detail (field_template_id, field_group_id, field_id, seq_no, is_disable, insert_required, field_caption, udf_or_system, update_required, hide_control)
	SELECT @field_template_id, @field_group_id, @field_id, 13, 'n', 'n', 'Internal Desk', 'u', 'n','n'
END 
ELSE PRINT 'maintain_field_template_detail data exists'

SELECT @deal_template_id = template_id FROM dbo.source_deal_header_template WHERE template_name = 'Hedge Accounting'

IF NOT EXISTS(SELECT 1 FROM user_defined_deal_fields_template WHERE field_name = '-5716' AND template_id = @deal_template_id)
BEGIN
	INSERT INTO user_defined_deal_fields_template (template_id, field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id, udf_user_field_id)
	SELECT @deal_template_id, '-5716', 'Internal Desk', 'd', 'INT', 'n', 'SELECT source_internal_desk_id, internal_desk_name FROM source_internal_desk', 'h', 30, '-5716', @field_id
END 
ELSE PRINT 'user_defined_deal_fields_template data exists'