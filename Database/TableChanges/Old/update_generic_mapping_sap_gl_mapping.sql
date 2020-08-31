UPDATE generic_mapping_header
SET    mapping_name = 'Non EFET SAP GL Mapping'
WHERE  mapping_name = 'SAP GL Mapping'
IF NOT EXISTS(SELECT 1  FROM user_defined_fields_template  WHERE  field_label = 'Inbound Outbound' )
BEGIN
	UPDATE user_defined_fields_template
	SET    field_label = 'Sub Process'
	WHERE  field_label = 'Inbound Outbound'
END
UPDATE generic_mapping_definition
SET    clm2_label = 'Sub Process'
WHERE  mapping_table_id = (
           SELECT mapping_table_id
           FROM   generic_mapping_header
           WHERE  mapping_name = 'Non EFET SAP GL Mapping'
       )

UPDATE user_defined_fields_template
SET    sql_string = 
       'Select  value_id,code FROM static_Data_value where type_id = 14000'
WHERE  field_label = 'Country'

IF NOT EXISTS (
       SELECT 1
       FROM   static_data_value
       WHERE  code = 'Entity'
   )
BEGIN
    INSERT INTO static_data_value
      (
        TYPE_ID,
        code,
        DESCRIPTION
      )
    VALUES
      (
        5500,
        'Entity',
        'Entity'
      )
END

DECLARE @value_id INT 
SET @value_id = SCOPE_IDENTITY()
DECLARE @entity_id INT 

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Entity'
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
    SELECT @value_id,
           'Entity',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''e'' value_id, ''EET'' name union all select ''r'' value_id, ''Retail'' name',
           'h',
           NULL,
           30,
           @value_id
SET @entity_id = SCOPE_IDENTITY()
END
ELSE 
BEGIN
	SELECT @entity_id = udf_template_id  FROM user_defined_fields_template udf  WHERE Field_label = 'Entity'
END



UPDATE generic_mapping_definition
SET    clm4_label                  = 'Entity',
       clm4_udf_id                 = @entity_id,
       unique_columns_index        = '1,2,3,4,5,6'
WHERE  mapping_table_id            = (
           SELECT mapping_table_id
           FROM   generic_mapping_header
           WHERE  mapping_name     = 'Non EFET SAP GL Mapping'
       )
