IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Clearing Counterparty')
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
    SELECT -5658,
           'Clearing Counterparty',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc',
           'h',
           NULL,
           30,
           -5658
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc'
    WHERE  Field_label = 'Clearing Counterparty'
END