--Insert script for Density start--
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Density')
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
    SELECT -5619,
           'Density',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'd',
           NULL,
           30,
           -5619
END
ELSE
BEGIN
   PRINT 'UDF Density already exists.' 
END
--Insert script for Density end--

--Insert script for Density To start--
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Density To')
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
    SELECT -5625,
           'Density To',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'd',
           NULL,
           30,
           -5625
END
ELSE
BEGIN
   PRINT 'UDF Density To already exists.' 
END
--Insert script for Density To end--

--Insert script for Density From start--
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Density From')
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
    SELECT -5624,
           'Density From',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'd',
           NULL,
           30,
           -5624
END
ELSE
BEGIN
   PRINT 'UDF Density From already exists.' 
END
--Insert script for Density From end--

--Insert script for UOM To start--
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'UOM To')
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
    SELECT -5623,
           'UOM To',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_uom_id, uom_name FROM source_uom',
           'd',
           NULL,
           30,
           -5623
END
ELSE
BEGIN
   PRINT 'UDF UOM To already exists.' 
END
--Insert script for UOM To end--

--Insert script for UOM From start--
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'UOM From')
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
    SELECT -5622,
           'UOM From',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_uom_id, uom_name FROM source_uom',
           'd',
           NULL,
           30,
           -5622
END
ELSE
BEGIN
   PRINT 'UDF UOM From already exists.' 
END
--Insert script for UOM From end--

--Insert script for UOM Conversion start--
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'UOM Conversion')
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
    SELECT -5620,
           'UOM Conversion',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'd',
           NULL,
           30,
           -5620
END
ELSE
BEGIN
   PRINT 'UDF Density already exists.' 
END
--Insert script for UOM Conversion end--

--Insert script for Price Multiplier start--
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Price Multiplier')
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
    SELECT -5621,
           'Price Multiplier',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'd',
           NULL,
           30,
           -5621
END
ELSE
BEGIN
   PRINT 'UDF Price Multiplier already exists.' 
END
--Insert script for Price Multiplier end--