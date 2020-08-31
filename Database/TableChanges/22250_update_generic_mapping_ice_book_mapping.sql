IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Template')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Template', 'Template'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Template'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Type')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Deal Type', 'Deal Type'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Deal Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Product')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Product', 'Product'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Product'
END

--step 2
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Template'
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
    SELECT iose.value_id,
           'Template',
           'd',
           'nvarchar(250)',
           'n',
           'SELECT DISTINCT template_id, template_name FROM source_deal_header_template sdht LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id WHERE sdht.is_active = ''y'' ORDER BY template_name',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT DISTINCT template_id, template_name FROM source_deal_header_template sdht LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id WHERE sdht.is_active = ''y'' ORDER BY template_name'
    WHERE  Field_label = 'Template'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Deal Type'
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
    SELECT iose.value_id,
           'Deal Type',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''n''',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''n'''
    WHERE  Field_label = 'Deal Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Product'
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
    SELECT iose.value_id,
           'Product',
           'd',
           'nvarchar(MAX)',
           'n',
           'SELECT value_id, code FROM static_data_value where type_id = 39800',
           'o',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Product'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value where type_id = 39800'
    WHERE  Field_label = 'Product'
END

DECLARE @template_id INT
		,@deal_type_id INT
		,@product_id INT
SELECT @template_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Template'
SELECT @deal_type_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Type'
SELECT @product_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Product'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'ICE Book Mapping')

BEGIN
	UPDATE gmd
	SET 
		clm4_label = 'Template',
		clm4_udf_id = @template_id,

		clm5_label = 'Deal Type',
		clm5_udf_id = @deal_type_id,

		clm6_label = 'Product',
		clm6_udf_id = @product_id
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'ICE Book Mapping'
END


UPDATE gmh SET gmh.total_columns_used = 6
-- SELECT gmh.*
FROM generic_mapping_header gmh
WHERE gmh.mapping_name = 'ICE Book Mapping'