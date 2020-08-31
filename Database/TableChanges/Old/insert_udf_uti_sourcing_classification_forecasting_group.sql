
DELETE uddft
FROM   user_defined_fields_template udft
       INNER JOIN user_defined_deal_fields_template uddft
            ON  udft.field_name = uddft.field_name
WHERE  udft.Field_label = 'uti' 

DELETE 
FROM   user_defined_fields_template
WHERE  Field_label = 'uti'

DELETE ad  FROM maintain_field_template_detail ad LEFT JOIN  user_defined_Fields_template ut 
ON ad.field_id = ut.udf_template_id WHERE field_caption = 'Reporting Entity ID' 
AND ut.udf_template_id IS NULL 

DELETE ad FROM maintain_field_template_detail ad LEFT JOIN  user_defined_Fields_template ut 
ON ad.field_id = ut.udf_template_id WHERE field_caption = 'Reporting Entity ID Source'
AND ut.udf_template_id IS NULL

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5617)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5617', 5500, 'UTI', 'UTI'
	SET IDENTITY_INSERT static_data_value OFF
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5618)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5618', 5500, 'Sourcing Classification', 'Sourcing Classification'
	SET IDENTITY_INSERT static_data_value OFF
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5619)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5619', 5500, 'Forecasting Group', 'Forecasting Group'
	SET IDENTITY_INSERT static_data_value OFF
END


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_name = -5617)
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -5617, 'uti', 't', 'text','n',null,'h',120,-5617
END

DECLARE @udf_template_id_uti INT
SELECT @udf_template_id_uti = udf_template_id FROM user_defined_fields_template WHERE field_name = -5617

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_name = -5618)
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -5618, 'Sourcing Classification', 't', 'varchar(150)','n',null,'h',120,-5618
END

DECLARE @udf_template_id_Sourcing INT
SELECT @udf_template_id_Sourcing = udf_template_id FROM user_defined_fields_template WHERE field_name = -5618


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_name = -5619)
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -5619, 'Forecasting Group', 't', 'varchar(150)','n',null,'h',120,-5619
END

DECLARE @udf_template_id_Forecast INT
SELECT @udf_template_id_Forecast = udf_template_id FROM user_defined_fields_template WHERE field_name = -5619

DECLARE @template_id_phy INT
SELECT @template_id_phy = template_id from source_deal_header_template where template_name = 'Physical PWR'

DECLARE @template_id_forecasted_15 INT
SELECT @template_id_forecasted_15 = template_id from source_deal_header_template where template_name = 'Forecasted Physical PWR - 15 Mins'


DECLARE @template_id_forecasted INT
SELECT @template_id_forecasted = template_id from source_deal_header_template where template_name = 'Forecasted Physical PWR'


IF @template_id_phy IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM user_defined_deal_fields_template WHERE template_id = @template_id_phy and field_name = -5617)
	BEGIN
		INSERT INTO user_defined_deal_fields_template(template_id,	field_name,	Field_label,	Field_type,	data_type,	is_required,	sql_string,	udf_type,	sequence,	field_size,	field_id,	default_value,	book_id,	udf_group,	udf_tabgroup,	formula_id,	internal_field_type,	currency_field_id,	udf_user_field_id,	leg,	calc_granularity)
		SELECT @template_id_phy,	-5617,	'UTI',	't',	'ntext',	'n', '', 'h',	NULL,	30,	-5617,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	1410,	NULL,	NULL
	END
END

IF @template_id_phy IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM user_defined_deal_fields_template WHERE template_id = @template_id_phy and field_name = -5618)
	BEGIN
		INSERT INTO user_defined_deal_fields_template(template_id,	field_name,	Field_label,	Field_type,	data_type,	is_required,	sql_string,	udf_type,	sequence,	field_size,	field_id,	default_value,	book_id,	udf_group,	udf_tabgroup,	formula_id,	internal_field_type,	currency_field_id,	udf_user_field_id,	leg,	calc_granularity)
		SELECT @template_id_phy,	-5618,	'Sourcing Classification',	't',	'varchar(150)',	'n', '', 'h',	NULL,	20,	-5618,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	1411,	NULL,	NULL
	END
END

IF @template_id_phy IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM user_defined_deal_fields_template WHERE template_id = @template_id_phy and field_name = -5619)
	BEGIN
		INSERT INTO user_defined_deal_fields_template(template_id,	field_name,	Field_label,	Field_type,	data_type,	is_required,	sql_string,	udf_type,	sequence,	field_size,	field_id,	default_value,	book_id,	udf_group,	udf_tabgroup,	formula_id,	internal_field_type,	currency_field_id,	udf_user_field_id,	leg,	calc_granularity)
		SELECT @template_id_phy,	-5619,	'Forecasting Group',	't',	'varchar(150)',	'n','',  'h', NULL,	20,	-5619,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	1412,	NULL,	NULL
	END
END

IF @template_id_forecasted_15 IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM user_defined_deal_fields_template WHERE template_id = @template_id_forecasted_15 and field_name = -5619)
	BEGIN
		INSERT INTO user_defined_deal_fields_template(template_id,	field_name,	Field_label,	Field_type,	data_type,	is_required,	sql_string,	udf_type,	sequence,	field_size,	field_id,	default_value,	book_id,	udf_group,	udf_tabgroup,	formula_id,	internal_field_type,	currency_field_id,	udf_user_field_id,	leg,	calc_granularity)
		SELECT @template_id_forecasted_15,	-5619,	'Forecasting Group',	't',	'varchar(150)',	'n', '',  'h',	NULL,	20,	-5619,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	1412,	NULL,	NULL
	END
END

IF @template_id_forecasted_15 IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM user_defined_deal_fields_template WHERE template_id = @template_id_forecasted_15 and field_name = -5618)
	BEGIN
		INSERT INTO user_defined_deal_fields_template(template_id,	field_name,	Field_label,	Field_type,	data_type,	is_required,	sql_string,	udf_type,	sequence,	field_size,	field_id,	default_value,	book_id,	udf_group,	udf_tabgroup,	formula_id,	internal_field_type,	currency_field_id,	udf_user_field_id,	leg,	calc_granularity)
		SELECT @template_id_forecasted_15,	-5618,	'Sourcing Classification',	't', 'varchar(150)', 'n', '', 	'h',	NULL,	20,	-5618,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	1411,	NULL,	NULL
	END
END

IF @template_id_forecasted_15 IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM user_defined_deal_fields_template WHERE template_id = @template_id_forecasted_15 and field_name = -5617)
	BEGIN
		INSERT INTO user_defined_deal_fields_template(template_id,	field_name,	Field_label,	Field_type,	data_type,	is_required,	sql_string,	udf_type,	sequence,	field_size,	field_id,	default_value,	book_id,	udf_group,	udf_tabgroup,	formula_id,	internal_field_type,	currency_field_id,	udf_user_field_id,	leg,	calc_granularity)
		SELECT @template_id_forecasted_15,	-5617,	'UTI',	't',	'ntext',	'n', '', 	'h',	NULL,	30,	-5617,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	1410,	NULL,	NULL
	END
END

IF @template_id_forecasted IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM user_defined_deal_fields_template WHERE template_id = @template_id_forecasted and field_name = -5617)
	BEGIN
		INSERT INTO user_defined_deal_fields_template(template_id,	field_name,	Field_label,	Field_type,	data_type,	is_required,	sql_string,	udf_type,	sequence,	field_size,	field_id,	default_value,	book_id,	udf_group,	udf_tabgroup,	formula_id,	internal_field_type,	currency_field_id,	udf_user_field_id,	leg,	calc_granularity)
		SELECT @template_id_forecasted,	-5617,	'UTI',	't',	'ntext',	'n', '', 	'h',	NULL,	30,	-5617,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	1410,	NULL,	NULL
	END
END

IF @template_id_forecasted IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM user_defined_deal_fields_template WHERE template_id = @template_id_forecasted and field_name = -5618)
	BEGIN
		INSERT INTO user_defined_deal_fields_template(template_id,	field_name,	Field_label,	Field_type,	data_type,	is_required,	sql_string,	udf_type,	sequence,	field_size,	field_id,	default_value,	book_id,	udf_group,	udf_tabgroup,	formula_id,	internal_field_type,	currency_field_id,	udf_user_field_id,	leg,	calc_granularity)
		SELECT @template_id_forecasted,	-5618,	'Sourcing Classification',	't',	'varchar(150)',	'n', '', 	'h',	NULL,	20,	-5618,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	1411,	NULL,	NULL
	END
END

IF @template_id_forecasted IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM user_defined_deal_fields_template WHERE template_id = @template_id_forecasted and field_name = -5619)
	BEGIN
		INSERT INTO user_defined_deal_fields_template(template_id,	field_name,	Field_label,	Field_type,	data_type,	is_required,	sql_string,	udf_type,	sequence,	field_size,	field_id,	default_value,	book_id,	udf_group,	udf_tabgroup,	formula_id,	internal_field_type,	currency_field_id,	udf_user_field_id,	leg,	calc_granularity)
		SELECT @template_id_forecasted,	-5619,	'Forecasting Group',	't',	'varchar(150)',	'n', '', 	'h',	NULL,	20,	-5619,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	1412,	NULL,	NULL
	END
END

DECLARE @field_template_id INT
SELECT @field_template_id = field_template_id from maintain_field_template where template_name = 'Physical Power'

DECLARE @field_group_id INT
SELECT @field_group_id = field_group_id FROM maintain_field_template_group WHERE field_template_id = @field_template_id AND group_name = 'Other Attribute'


IF NOT EXISTS(SELECT 1 FROM maintain_field_template_detail WHERE field_id = @udf_template_id_uti AND field_template_id = @field_template_id AND udf_or_system = 'u')
BEGIN
	INSERT INTO maintain_field_template_detail(field_template_id, field_group_id, field_id, seq_no, is_disable, insert_required, field_caption, default_value, udf_or_system,deal_update_seq_no, update_required, hide_control, value_required, show_in_form)
	SELECT @field_template_id,@field_group_id, @udf_template_id_uti, 24, 'n', 'n', 'UTI', NULL, 'u', 1039, 'y', 'n', 'n','y'
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_template_detail WHERE field_id = @udf_template_id_Sourcing AND field_template_id = @field_template_id AND udf_or_system = 'u')
BEGIN
	INSERT INTO maintain_field_template_detail(field_template_id, field_group_id, field_id, seq_no, is_disable, insert_required, field_caption, default_value, udf_or_system,deal_update_seq_no, update_required, hide_control, value_required, show_in_form)
	SELECT @field_template_id,@field_group_id, @udf_template_id_Sourcing, 24, 'n', 'n', 'Sourcing Classification', NULL, 'u', 1040, 'y', 'n', 'n','y'
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_template_detail WHERE field_id = @udf_template_id_Forecast AND field_template_id = @field_template_id AND udf_or_system = 'u')
BEGIN
	INSERT INTO maintain_field_template_detail(field_template_id, field_group_id, field_id, seq_no, is_disable, insert_required, field_caption, default_value, udf_or_system,deal_update_seq_no, update_required, hide_control, value_required, show_in_form)
	SELECT @field_template_id,@field_group_id, @udf_template_id_Forecast, 24, 'n', 'n', 'Forecasting Group', NULL, 'u', 1041, 'y', 'n', 'n','y'
END
