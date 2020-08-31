DECLARE @value_id INT
SET @value_id = (SELECT value_id FROM dbo.static_data_value WHERE code = 'Accounting Key')
--PRINT @value_id

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  field_name = @value_id)
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
        SEQUENCE,
        field_size,
        field_id
      )
    VALUES 
	(
			@value_id,
           'Accounting Key',
           'd',
           'VARCHAR(MAX)',
           'n',
           'SELECT ''40'' AS id, ''40'' AS value UNION ALL SELECT ''50'', ''50''',
 
-- Query to populate the data in combo.
 
           'h',
           NULL,
           30,
           @value_id
	)
END
ELSE
BEGIN
	UPDATE user_defined_fields_template
    SET 
        Field_label = 'Accounting Key',
        Field_type = 'd',
        data_type = 'VARCHAR(MAX)',
        is_required = 'n',
        sql_string = 'SELECT ''40'' AS id, ''40'' AS value UNION ALL SELECT ''50'', ''50''',
        udf_type = 'h',
        SEQUENCE = NULL,
        field_size = 30
    WHERE field_name = @value_id
END


   