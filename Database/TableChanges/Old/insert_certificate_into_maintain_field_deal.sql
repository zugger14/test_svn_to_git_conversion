
DECLARE @field_deal_id INT
SELECT @field_deal_id = MAX(field_deal_id) + 1
FROM   maintain_field_deal

IF NOT EXISTS (
       SELECT 1
       FROM   maintain_field_deal
       WHERE  farrms_field_id = 'certificate'
   )
BEGIN
    INSERT INTO maintain_field_deal
      (
        -- field_deal_id -- this column value is auto-generated
        field_id,
        farrms_field_id,
        default_label,
        field_type,
        data_type,
        default_validation,
        header_detail,
        system_required,
        sql_string,
        field_size,
        is_disable,
        window_function_id,
        is_hidden,
        default_value,
        insert_required,
        data_flag,
        update_required
      )
    VALUES
      (
        @field_deal_id,
        'certificate',
        'Certificate',
        'c',
        'char',
        NULL,
        'h',
        'y',
        'SELECT ''y'' code, ''Yes'' value UNION select ''n'',''No''',
        180,
        NULL,
        NULL,
        'y',
        'n',
        'n',
        'i',
        'n'
      )
END
   --SELECT * FROM maintain_field_deal