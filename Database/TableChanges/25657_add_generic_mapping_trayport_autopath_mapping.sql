IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source Product')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Source Product', 'Source Product'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Source Product'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source Book')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Source Book', 'Source Book'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Source Book'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Buy/Sell')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Buy/Sell', 'Buy/Sell'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Buy/Sell'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Delivery Path')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Delivery Path', 'Delivery Path'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Delivery Path'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Product Group')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Product Group', 'Product Group'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Product Group'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Shipper Code 1')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Shipper Code 1', 'Shipper Code 1'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Shipper Code 1'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Shipper Code 2')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Shipper Code 2', 'Shipper Code 2'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Shipper Code 2'
END


/* Insert into user_defined_fields_template */
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Product'
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
           'Source Product',
           't',
           'nvarchar(250)',
           'n',
           NULL,
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Source Product'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Source Product'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Book'
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
           'Source Book',
           't',
           'nvarchar(250)',
           'n',
           NULL,
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Source Book'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Source Book'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Buy/Sell'
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
           'Buy/Sell',
           'd',
           'nvarchar(250)',
           'n',
           'SELECT ''b'' AS value_id, ''Buy'' AS [name] UNION SELECT ''s'' AS value_id, ''Sell'' AS [name]',
           'o',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Buy/Sell'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT ''b'' AS value_id, ''Buy'' AS [name] UNION SELECT ''s'' AS value_id, ''Sell'' AS [name]'
    WHERE  Field_label = 'Buy/Sell'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Delivery Path'
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
           'Delivery Path',
           'd',
           'int',
           'n',
           'EXEC spa_delivery_path ''w''',
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Delivery Path'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_delivery_path ''w'''
    WHERE  Field_label = 'Delivery Path'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Product Group'
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
           'Product Group',
           'd',
           'int',
           'n',
           'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 39800',
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Product Group'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 39800'
    WHERE  Field_label = 'Product Group'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Shipper Code 1'
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
           'Shipper Code 1',
           't',
           'nvarchar(MAX)',
           'n',
           NULL,
           'd',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Shipper Code 1'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Shipper Code 1'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Shipper Code 2'
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
           'Shipper Code 2',
           't',
           'nvarchar(MAX)',
           'n',
           NULL,
           'd',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Shipper Code 2'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Shipper Code 2'
END

/* Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Trayport Autopath Mapping')
BEGIN
	UPDATE generic_mapping_header
	SET total_columns_used = 7
	WHERE mapping_name = 'Trayport Autopath Mapping'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used,
	system_defined
	) VALUES (
	'Trayport Autopath Mapping',
	7,
	0
	)

END

/*Insert into Generic Mapping Defination*/

DECLARE @source_product INT
DECLARE @source_book INT
DECLARE @buy_sell INT
DECLARE @delivery_path INT
DECLARE @product_group INT
DECLARE @shipper_code1 INT
DECLARE @shipper_code2 INT

SELECT @source_product = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Source Product'
SELECT @source_book = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Source Book'
SELECT @buy_sell = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Buy/Sell'
SELECT @delivery_path = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Delivery Path'
SELECT @product_group = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Product Group'
SELECT @shipper_code1 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Shipper Code 1'
SELECT @shipper_code2 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Shipper Code 2'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Trayport Autopath Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Source Product',
		clm1_udf_id = @source_product,
		clm2_label = 'Source Book',
		clm2_udf_id = @source_book,
		clm3_label = 'Buy/Sell',
		clm3_udf_id = @buy_sell,
		clm4_label = 'Delivery Path',
		clm4_udf_id = @delivery_path,
		clm5_label = 'Product Group',
		clm5_udf_id = @product_group,
		clm6_label = 'Shipper Code 1',
		clm6_udf_id = @shipper_code1,
		clm7_label = 'Shipper Code 2',
		clm7_udf_id = @shipper_code2
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Trayport Autopath Mapping'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id,
		clm5_label, clm5_udf_id,
		clm6_label, clm6_udf_id,
		clm7_label, clm7_udf_id
		)
	SELECT 
		mapping_table_id,
		'Source Product', @source_product,
		'Source Book', @source_book,
		'Buy/Sell', @buy_sell,
		'Delivery Path', @delivery_path,
		'Product Group', @product_group,
		'Shipper Code 1', @shipper_code1,
		'Shipper Code 2', @shipper_code2
	FROM generic_mapping_header 
	WHERE mapping_name = 'Trayport Autopath Mapping'
END
