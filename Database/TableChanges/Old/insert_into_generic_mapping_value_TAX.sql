IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Buy Sell')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Buy Sell', 'Buy Sell'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Buy Sell'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Receipt Location')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Receipt Location', 'Receipt Location'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Receipt Location'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Delivery Location')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Delivery Location', 'Delivery Location'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Delivery Location'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'NMGRT Tax Rate')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'NMGRT Tax Rate', 'NMGRT Tax Rate'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'NMGRT Tax Rate'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Compensating Tax Rate')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Compensating Tax Rate', 'Compensating Tax Rate'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Compensating Tax Rate'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'County Tax Rate')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'County Tax Rate', 'County Tax Rate'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'County Tax Rate'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'City Tax Rate')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'City Tax Rate', 'City Tax Rate'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'City Tax Rate'
END

/* Insert into user_defined_fields_template */
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Buy Sell'
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
           'Buy Sell',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT 1 AS value_id, ''Buy'' AS name UNION SELECT 2 AS value_id, ''Sell'' AS name',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Buy Sell'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT ''b'' AS value_id, ''Buy'' AS [name] UNION SELECT ''s'' AS value_id, ''Sell'' AS [name]'
    WHERE  Field_label = 'Buy Sell'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Receipt Location'
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
           'Receipt Location',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT sml.source_minor_location_id, sml.Location_Name FROM source_minor_location sml',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Receipt Location'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT sml.source_minor_location_id, sml.Location_Name FROM source_minor_location sml'
    WHERE  Field_label = 'Receipt Location'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Delivery Location'
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
           'Delivery Location',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT sml.source_minor_location_id, sml.Location_Name FROM source_minor_location sml',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Delivery Location'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT sml.source_minor_location_id, sml.Location_Name FROM source_minor_location sml'
    WHERE  Field_label = 'Delivery Location'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'NMGRT Tax Rate'
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
           'NMGRT Tax Rate',
           'd',
           'VARCHAR(150)',
           'n',
           'select source_curve_def_id, curve_id from source_price_curve_def where source_curve_type_value_id = 583',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'NMGRT Tax Rate'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'select source_curve_def_id, curve_id from source_price_curve_def where source_curve_type_value_id = 583'
    WHERE  Field_label = 'NMGRT Tax Rate'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Compensating Tax Rate'
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
           'Compensating Tax Rate',
           'd',
           'VARCHAR(150)',
           'n',
           'select source_curve_def_id, curve_id from source_price_curve_def where source_curve_type_value_id = 583',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Compensating Tax Rate'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'select source_curve_def_id, curve_id from source_price_curve_def where source_curve_type_value_id = 583'
    WHERE  Field_label = 'Compensating Tax Rate'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'County Tax Rate'
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
           'County Tax Rate',
           'd',
           'VARCHAR(150)',
           'n',
           'select source_curve_def_id, curve_id from source_price_curve_def where source_curve_type_value_id = 583',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'County Tax Rate'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'select source_curve_def_id, curve_id from source_price_curve_def where source_curve_type_value_id = 583'
    WHERE  Field_label = 'County Tax Rate'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'City Tax Rate'
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
           'City Tax Rate',
           'd',
           'VARCHAR(150)',
           'n',
           'select source_curve_def_id, curve_id from source_price_curve_def where source_curve_type_value_id = 583',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'City Tax Rate'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'select source_curve_def_id, curve_id from source_price_curve_def where source_curve_type_value_id = 583'
    WHERE  Field_label = 'City Tax Rate'
END

/* Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'TAX Rule Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
	UPDATE generic_mapping_header
	SET total_columns_used = 8
	WHERE mapping_name = 'TAX Rule Mapping'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'TAX Rule Mapping',
	6
	)

END

/*Insert into Generic Mapping Defination*/

DECLARE @buy_sell INT
DECLARE @counterparty INT
DECLARE @receipt_location INT
DECLARE @delivery_location INT
DECLARE @meter INT
DECLARE @NMGRT_tax_rate INT
DECLARE @compensating_tax_rate INT
DECLARE @country_tax_rate INT
DECLARE @city_tax INT

SELECT @buy_sell=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Buy Sell'
SELECT @counterparty=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @receipt_location=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Receipt Location'
SELECT @delivery_location=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Delivery Location'
SELECT @meter=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Meter ID'
SELECT @NMGRT_tax_rate=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'NMGRT Tax Rate'
SELECT @compensating_tax_rate=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Compensating Tax Rate'
SELECT @country_tax_rate=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'County Tax Rate'

SELECT @city_tax = udf_template_id 
FROM user_defined_fields_template 
WHERE  Field_label = 'City Tax Rate'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'TAX Rule Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Buy Sell',
		clm1_udf_id = @buy_sell,
		clm2_label = 'Counterparty',
		clm2_udf_id = @counterparty,
		clm3_label = 'Receipt Location',
		clm3_udf_id = @receipt_location,
		clm4_label = 'Delivery Location',
		clm4_udf_id = @delivery_location,
		clm5_label = 'Meter ID',
		clm5_udf_id = @meter,
		clm6_label = 'NMGRT Tax Rate',
		clm6_udf_id = @NMGRT_tax_rate,
		clm7_label = 'Compensating Tax Rate',
		clm7_udf_id = @compensating_tax_rate,
		clm8_label = 'County Tax Rate',
		clm8_udf_id = @country_tax_rate,
		clm9_label = 'City Tax Rate',
		clm9_udf_id = @city_tax
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'TAX Rule Mapping'
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
		clm7_label, clm7_udf_id,
		clm8_label, clm8_udf_id,
		clm9_label, clm9_udf_id
	)
	SELECT 
		mapping_table_id,
		'Buy Sell', @buy_sell,
		'Counterparty', @counterparty,
		'Receipt Location', @receipt_location,
		'Delivery Location', @delivery_location,
		'Meter ID', @meter,
		'NMGRT Tax Rate', @NMGRT_tax_rate,
		'Compensating Tax Rate', @compensating_tax_rate,
		'County Tax Rate', @country_tax_rate,
		'City Tax Rate', @city_tax
	FROM generic_mapping_header 
	WHERE mapping_name = 'TAX Rule Mapping'
END