/*Step 1:Create a UDF */

IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
 
CREATE TABLE #insert_output_sdv_external
 
(
      value_id     INT,
      [type_id]    INT,
      [type_name]  VARCHAR(500)
)
 
-- First UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Product Group')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Product Group',
           'Product Group'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500
           AND [code] = 'Product Group'
END
 
--Second UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Region')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Region',
           'Region'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Region'
END

--Third UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Entrepot-number')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Entrepot-number',
           'Entrepot-number'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Entrepot-number'
END

--Fourth UDF
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'IC(within fiscal unit)')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'IC(within fiscal unit)',
           'IC(within fiscal unit)'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'IC(within fiscal unit)'
END

--Fifth UDF
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Curve')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Curve',
           'Curve'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Curve'
END

--Sixth UDF
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'VAT Code Sale')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'VAT Code Sale',
           'VAT Code Sale'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'VAT Code Sale'
END

--Seventh UDF
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'VAT GL Account Sale')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'VAT GL Account Sale',
           'VAT GL Account Sale'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'VAT GL Account Sale'
END

--Eight UDF
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'VAT Code Buy')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'VAT Code Buy',
           'VAT Code Buy'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'VAT Code Buy'
END

--Ninth UDF
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'VAT GL Account Buy')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'VAT GL Account Buy',
           'VAT GL Account Buy'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'VAT GL Account Buy'
END


/*Step 2: Defining UDF */
 --First UDF
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
           'VARCHAR(150)',
           'n',
           'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id]=27000',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Product Group'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id]=27000'
    WHERE  Field_label = 'Product Group'
END

--Second UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Region'
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
           'Region',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id]=11150',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Region'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id]=11150'
    WHERE  Field_label = 'Region'
END


--Third UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Entrepot-number'
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
           'Entrepot-number',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''y'' AS id , ''Yes'' VALUE UNION ALL SELECT ''n'', ''No''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Entrepot-number'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''y'' AS id , ''Yes'' VALUE UNION ALL SELECT ''n'', ''No'''
    WHERE  Field_label = 'Entrepot-number'
END

--Forth UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'IC(within fiscal unit)'
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
           'IC(within fiscal unit)',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''y'' AS id , ''Yes'' VALUE UNION ALL SELECT ''n'', ''No''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'IC(within fiscal unit)'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''y'' AS id , ''Yes'' VALUE UNION ALL SELECT ''n'', ''No'''
    WHERE  Field_label = 'IC(within fiscal unit)'
END

--Fifth UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Curve'
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
           'Curve',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_curve_def_id,curve_name FROM source_price_curve_def',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Curve'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_curve_def_id,curve_name FROM source_price_curve_def'
    WHERE  Field_label = 'Curve'
END

--Sixth UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'VAT Code Sale'
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
           'VAT Code Sale',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id, code FROM static_data_value  WHERE [type_id]=10004',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'VAT Code Sale'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value sdv WHERE [type_id]=10004'
    WHERE  Field_label = 'VAT Code Sale'
END

--Seventh UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'VAT GL Account Sale'
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
           'VAT GL Account Sale',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id, code FROM static_data_value WHERE [type_id] = 29800',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'VAT GL Account Sale'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value WHERE [type_id] = 29800'
    WHERE  Field_label = 'VAT GL Account Sale'
END

--Eigth UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'VAT Code Buy'
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
           'VAT Code Buy',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id, code FROM static_data_value  WHERE [type_id]=10004',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'VAT Code Buy'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value  WHERE [type_id]=10004'
    WHERE  Field_label = 'VAT Code Buy'
END

--Ninth UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'VAT GL Account Buy'
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
           'VAT GL Account Buy',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id, code FROM static_data_value WHERE [type_id] = 29800',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'VAT GL Account Buy'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value WHERE [type_id] = 29800'
    WHERE  Field_label = 'VAT GL Account Buy'
END

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Non EFET VAT Rule Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Non EFET VAT Rule Mapping',
	9
	)
END


/* step 4: Insert into Generic Mapping Defination*/

DECLARE @product_group INT
DECLARE @region_id INT
DECLARE @entrepot_number_available INT
DECLARE @ic_available INT 
DECLARE @curve_id INT
DECLARE @vat_code_sale INT
DECLARE @account_gl_vat_sale INT
DECLARE @vat_code_buy INT
DECLARE @account_gl_vat_buy INT

SELECT @product_group=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Product Group'
SELECT @region_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Region'
SELECT @entrepot_number_available=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Entrepot-number'
SELECT @ic_available=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'IC(within fiscal unit)'
SELECT @curve_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Curve'
SELECT @vat_code_sale=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'VAT Code Sale'
SELECT @account_gl_vat_sale=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'VAT GL Account Sale'
SELECT @vat_code_buy=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'VAT Code Buy'
SELECT @account_gl_vat_buy=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'VAT GL Account Buy'
 


IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Non EFET VAT Rule Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Product Group',
		clm1_udf_id = @product_group,
		clm2_label = 'Region',
		clm2_udf_id = @region_id,
		clm3_label = 'Entrepot-number',
		clm3_udf_id = @entrepot_number_available,
		clm4_label = 'IC(within fiscal unit)',
		clm4_udf_id = @ic_available,
		clm5_label = 'Curve',
		clm5_udf_id = @curve_id,
		clm6_label = 'VAT Code Sale',
		clm6_udf_id = @vat_code_sale,
		clm7_label = 'VAT GL Account Sale',
		clm7_udf_id = @account_gl_vat_sale,
		clm8_label = 'VAT Code Buy',
		clm8_udf_id = @vat_code_buy,
		clm9_label = 'VAT GL Account Buy',
		clm9_udf_id = @account_gl_vat_buy
		
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Non EFET VAT Rule Mapping'
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
		'Product Group', @product_group,
		'Region', @region_id,
		'Entrepot-number', @entrepot_number_available,
		'IC(within fiscal unit)', @ic_available,
		'Curve', @curve_id,
		'VAT Code Sale', @vat_code_sale,
		'VAT GL Account Sale', @account_gl_vat_sale,
		'VAT Code Buy', @vat_code_buy,
		'VAT GL Account Buy',@account_gl_vat_buy
	FROM generic_mapping_header 
	WHERE mapping_name = 'Non EFET VAT Rule Mapping'
END

--Unique Column Index
DECLARE @mapping_table_id INT 
SELECT @mapping_table_id =  mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Non EFET VAT Rule Mapping'
IF @mapping_table_id IS NOT NULL
	UPDATE generic_mapping_definition
	SET    unique_columns_index     = '1,2,3,4'
	WHERE  mapping_table_id         = @mapping_table_id
--SELECT * FROM generic_mapping_definition WHERE mapping_table_id=23




