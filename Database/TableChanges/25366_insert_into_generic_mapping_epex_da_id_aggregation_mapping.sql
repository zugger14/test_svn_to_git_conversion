IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Auction Name')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Auction Name', 'Auction Name'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Auction Name'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Portfolio Name')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Portfolio Name', 'Portfolio Name'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Portfolio Name'
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Sale/Purchase')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Sale/Purchase', 'Sale/Purchase'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Sale/Purchase'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Profile')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Profile', 'Profile'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Profile'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Curve ID')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Curve ID', 'Curve ID'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Curve ID'
END


/* Insert into user_defined_fields_template */
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Auction Name'
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
           'Auction Name',
           'd',
           'INT',
           'n',
           'EXEC spa_StaticDataValues ''h'', 112600',
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Auction Name'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_StaticDataValues ''h'', 112600'
    WHERE  Field_label = 'Auction Name'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Portfolio Name'
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
           'Portfolio Name',
           't',
           'nvarchar(100)',
           'n',
           NULL,
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Portfolio Name'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Portfolio Name'
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
           't',
           'nvarchar(100)',
           'n',
           NULL,
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Product'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Product'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Sale/Purchase'
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
           'Sale/Purchase',
           't',
           'nvarchar(100)',
           'n',
           NULL,
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Sale/Purchase'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Sale/Purchase'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Profile'
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
           'Profile',
           'd',
           'INT',
           'n',
           'EXEC spa_forecast_profile ''x''',
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Profile'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_forecast_profile ''x'''
    WHERE  Field_label = 'Profile'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Curve ID'
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
           'Curve ID',
           'd',
           'INT',
           'n',
           'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Curve ID'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
    WHERE  Field_label = 'Curve ID'
END

/* Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'EPEX DA/ID Aggregation Mapping')
BEGIN
	PRINT 'EPEX DA/ID Aggregation Mapping'
	UPDATE generic_mapping_header
	SET total_columns_used = 6
	WHERE mapping_name = 'EPEX DA/ID Aggregation Mapping'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used,
	system_defined
	) VALUES (
	'EPEX DA/ID Aggregation Mapping',
	6,
	0
	)

END

/*Insert into Generic Mapping Defination*/

DECLARE @auction_name INT
DECLARE @portfolio_name INT
DECLARE @product INT
DECLARE @sale_purchase INT
DECLARE @profile INT
DECLARE @curve_id INT

SELECT @auction_name = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Auction Name'
SELECT @portfolio_name = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Portfolio Name'
SELECT @product = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Product'
SELECT @sale_purchase = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sale/Purchase'
SELECT @curve_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Curve ID'
SELECT @profile = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Profile'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'EPEX DA/ID Aggregation Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Auction Name',
		clm1_udf_id = @auction_name,
		clm2_label = 'Portfolio Name',
		clm2_udf_id = @portfolio_name,
		clm3_label = 'Product',
		clm3_udf_id = @product,
		clm4_label = 'Sale/Purchase',
		clm4_udf_id = @sale_purchase,
		clm5_label = 'Profile',
		clm5_udf_id = @profile,
		clm6_label = 'Curve ID',
		clm6_udf_id = @curve_id
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'EPEX DA/ID Aggregation Mapping'
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
		clm6_label, clm6_udf_id
	)
	SELECT 
		mapping_table_id,
		'Auction Name', @auction_name,
		'Portfolio Name', @portfolio_name,
		'Product', @product,
		'Sale/Purchase', @sale_purchase,
		'Profile', @profile,
		'Curve ID', @curve_id
	FROM generic_mapping_header 
	WHERE mapping_name = 'EPEX DA/ID Aggregation Mapping'
END
