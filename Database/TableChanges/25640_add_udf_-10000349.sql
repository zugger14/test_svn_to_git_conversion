SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000349)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000349, 'Price Formula', 'Price Formula', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000349 - Price Formula.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000349 - Price Formula already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Price Formula'
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
    SELECT -10000349,
           'Price Formula',
           't',
           'NVARCHAR(MAX)',
           'n',
           NULL,
           'h',
           NULL,
           180,
           -10000349
 
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL,
		   field_size = 180,
		   is_required = 'n'
    WHERE  Field_label = 'Price Formula'
END