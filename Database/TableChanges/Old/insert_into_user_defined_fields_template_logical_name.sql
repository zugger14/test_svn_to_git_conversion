IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Logical Name')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    VALUES(-5690, 'Logical Name', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 30, -5690)
END