IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Trader')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Trader', 'Trader'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Trader'
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Tenor')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Tenor', 'Tenor'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Tenor'
END


/* Insert into user_defined_fields_template */
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Trader'
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
           'Trader',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_trader_id, trader_id FROM source_traders',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Trader'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT source_trader_id, trader_id FROM source_traders'
    WHERE  Field_label = 'Trader'
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
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''n'''
    WHERE  Field_label = 'Deal Type'
END

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
           'VARCHAR(150)',
           'n',
           'SELECT template_id, template_name FROM source_deal_header_template',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT template_id, template_name FROM source_deal_header_template'
    WHERE  Field_label = 'Template'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Tenor'
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
           'Tenor',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT 1 AS value_id, ''All Tenor'' AS name UNION SELECT 2 AS value_id, ''2 years'' AS name UNION SELECT 3 AS value_id, ''4 years'' AS name UNION SELECT 4 AS value_id, ''BOM'' AS name UNION SELECT 5 AS value_id, ''Real-Time'' AS name',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Tenor'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT 1 AS value_id, ''All Tenor'' AS name UNION SELECT 2 AS value_id, ''2 years'' AS name UNION SELECT 3 AS value_id, ''4 years'' AS name UNION SELECT 4 AS value_id, ''BOM'' AS name UNION SELECT 5 AS value_id, ''Real-Time'' AS name'
    WHERE  Field_label = 'Tenor'
END


/* Insert Generic Mapping Header */
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Approved Trades Matrix')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Approved Trades Matrix',
	4
	)
END


/*Insert into Generic Mapping Defination*/
DECLARE @trader INT
DECLARE @deal_type INT
DECLARE @template INT
DECLARE @tenor INT

SELECT @trader = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Trader'
SELECT @deal_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Type'
SELECT @template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Template'
SELECT @tenor = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Tenor'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Approved Trades Matrix')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Trader',
		clm1_udf_id = @trader,
		clm2_label = 'Deal Type',
		clm2_udf_id = @deal_type,
		clm3_label = 'Template',
		clm3_udf_id = @template,
		clm4_label = 'Tenor',
		clm4_udf_id = @tenor
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Approved Trades Matrix'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id
	)
	SELECT 
		mapping_table_id,
		'Trader', @trader,
		'Deal Type', @deal_type,
		'Template', @template,
		'Tenor', @tenor
	FROM generic_mapping_header 
	WHERE mapping_name = 'Approved Trades Matrix'
END