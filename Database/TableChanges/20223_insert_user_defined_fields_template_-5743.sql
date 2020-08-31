
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'CSA Reportable Trade'
   )
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
    SELECT -5743,
           'CSA Reportable Trade',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT ''Y'' id, ''Y'' value UNION ALL SELECT ''N'' id, ''N'' value ORDER BY value',
           'h',
           NULL,
           180,
           -5743
    
    PRINT 'Inserted user defined fields(CSA Reportable Trade)'
END
ELSE
    PRINT 'User defined fields(CSA Reportable Trade) already exists'        
          
         