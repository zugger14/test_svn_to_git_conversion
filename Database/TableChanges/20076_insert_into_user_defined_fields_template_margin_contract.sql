IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Margin Contract')
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT -5657,
           'Margin Contract',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT cg.contract_id, cg.contract_name FROM contract_group cg',
           'h',
           NULL,
           30,
           -5657
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT cg.contract_id, cg.contract_name FROM contract_group cg'
    WHERE  Field_label = 'Margin Contract'
END