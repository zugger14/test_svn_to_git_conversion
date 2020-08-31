
 DECLARE @application_field_id_2 INT
 DECLARE @application_field_id_1 INT
 SELECT @application_field_id_1 = application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10103000 and default_label in ('Operator')
 SELECT @application_field_id_2 = application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10103000 and default_label in ('Pigridcode')
 
DECLARE @application_ui_template_fields1 INT
DECLARE @application_ui_template_fields2 INT
SELECT @application_ui_template_fields1 = autf.application_field_id FROM application_ui_template_fields autf INNER JOIN application_ui_template_definition autd on autf.application_ui_field_id = autd.application_ui_field_id where autd.default_label = 'Operator'
SELECT @application_ui_template_fields2 = autf.application_field_id FROM application_ui_template_fields autf INNER JOIN application_ui_template_definition autd on autf.application_ui_field_id = autd.application_ui_field_id where autd.default_label = 'Pigridcode'

DECLARE @udf_template_id_1 INT
DECLARE @udf_template_id_2 INT
SELECT @udf_template_id_1 = udf_template_id from user_defined_fields_template where Field_label = 'Operator'
SELECT @udf_template_id_2 = udf_template_id from user_defined_fields_template where Field_label = 'Pigridcode'


DECLARE @maintain_udf_detail_id1 INT
DECLARE @maintain_udf_detail_id2 INT
SELECT @maintain_udf_detail_id1 = maintain_udf_detail_id FROM maintain_udf_detail WHERE udf_label = 'Operator'
SELECT @maintain_udf_detail_id2 = maintain_udf_detail_id FROM maintain_udf_detail WHERE udf_label = 'Pigridcode'

--Delete from maintain_udf_static_data_detail_values
DELETE FROM maintain_udf_static_data_detail_values WHERE application_field_id in (@application_ui_template_fields1, @application_ui_template_fields2) 

--Delete from application_ui_template_fields 
DELETE FROM application_ui_template_fields WHERE application_ui_field_id in (@application_field_id_1, @application_field_id_2)

--Delete from application_ui_template_definition
DELETE FROM application_ui_template_definition WHERE application_ui_field_id in (@application_field_id_1, @application_field_id_2)

--Delete from maintain_udf_detail_values 
DELETE FROM maintain_udf_detail_values WHERE application_field_id in (@maintain_udf_detail_id1, @maintain_udf_detail_id2)

--Delete from maintain_udf_detail
DELETE FROM maintain_udf_detail WHERE udf_template_id in (@udf_template_id_1, @udf_template_id_2)

--Delete from user_defined_fields_template 
DELETE FROM user_defined_fields_template WHERE Field_label in ('Operator','Pigridcode')

--Delete from static_data_value
DELETE FROM static_data_value WHERE code in ('Pigridcode','Operator') and type_id = 5500


