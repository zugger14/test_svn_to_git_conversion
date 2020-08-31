
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Commodity')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Commodity', 'Commodity'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Commodity'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Location')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Location', 'Location'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Location'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Region')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Region', 'Region'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Region'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Entrepotnumber')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Entrepotnumber', 'Entrepotnumber'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Entrepotnumber'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Curve')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Curve', 'Curve'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Curve'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'VAT Code Sale')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'VAT Code Sale', 'VAT code SALE'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'VAT Code Sale'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'GL Account VAT Sale')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'GL Account VAT Sale', 'GL Account VAT SALE'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'GL Account VAT Sale'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Invoice Remarks')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Invoice Remarks', 'Remark Invoice'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Invoice Remarks'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'VAT Code Buy')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'VAT Code Buy', 'VAT code BUY'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'VAT Code Buy'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'GL Account VAT Buy')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'GL Account VAT Buy', 'GL Account VAT BUY'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'GL Account VAT Buy'
END


--Step 2
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Commodity'
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
           'Commodity',
           'd',
           'VARCHAR(150)',
           'n',
           'select source_book_id,source_book_name from source_book where source_system_book_type_value_id=51',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Commodity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'select source_book_id,source_book_name from source_book where source_system_book_type_value_id=51'
    WHERE  Field_label = 'Commodity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Location'
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
           'Location',
           'd',
           'VARCHAR(150)',
           'n',
           'select source_book_id,source_book_name from source_book where source_system_book_type_value_id=52',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Location'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'select source_book_id,source_book_name from source_book where source_system_book_type_value_id=52'
    WHERE  Field_label = 'Location'
END

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

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Entrepotnumber'
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
           'Entrepotnumber',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''y'' AS id , ''Yes'' VALUE UNION ALL SELECT ''n'', ''No''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Entrepotnumber'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''y'' AS id , ''Yes'' VALUE UNION ALL SELECT ''n'', ''No'''
    WHERE  Field_label = 'Entrepotnumber'
END

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
           'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id]=10004',
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
    SET    sql_string = 'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id]=10004'
    WHERE  Field_label = 'VAT Code Sale'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'GL Account VAT Sale'
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
           'GL Account VAT Sale',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT gl_number_id, gl_account_number FROM gl_system_mapping',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'GL Account VAT Sale'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT gl_number_id, gl_account_number FROM gl_system_mapping'
    WHERE  Field_label = 'GL Account VAT Sale'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Invoice Remarks'
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
           'Invoice Remarks',
           'm',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Invoice Remarks'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = '',
		   field_type = 'm'	 
    WHERE  Field_label = 'Invoice Remarks'
END

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
           'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id]=10004',
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
    SET    sql_string = 'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id]=10004'
    WHERE  Field_label = 'VAT Code Buy'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'GL Account VAT Buy'
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
           'GL Account VAT Buy',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT gl_number_id, gl_account_number FROM gl_system_mapping',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'GL Account VAT Buy'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT gl_number_id, gl_account_number FROM gl_system_mapping'
    WHERE  Field_label = 'GL Account VAT Buy'
END


/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'VAT Rule Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'VAT Rule Mapping',
	10
	)
END

/* step 4: Insert into Generic Mapping Defination*/

DECLARE @Commodity_id INT
DECLARE @location_id INT
DECLARE @region_id INT
DECLARE @entrepotnumber_available INT
DECLARE @curve_id INT
DECLARE @vat_code_sale INT
DECLARE @gl_account_vat_sale INT
DECLARE @invoice_remarks INT
DECLARE @vat_code_buy INT
DECLARE @gl_account_vat_buy INT

SELECT @Commodity_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Commodity'
SELECT @location_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Location'
SELECT @region_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Region'
SELECT @entrepotnumber_available=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Entrepotnumber'
SELECT @curve_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Curve'
SELECT @vat_code_sale=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'VAT Code Sale'
SELECT @gl_account_vat_sale=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'GL Account VAT Sale'
SELECT @invoice_remarks=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Invoice Remarks'
SELECT @vat_code_buy=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'VAT Code Buy'
SELECT @gl_account_vat_buy=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'GL Account VAT Buy'
 


IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'VAT Rule Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Commodity',
		clm1_udf_id = @Commodity_id,
		clm2_label = 'Location',
		clm2_udf_id = @location_id,
		clm3_label = 'Region',
		clm3_udf_id = @region_id,
		clm4_label = 'Entrepotnumber',
		clm4_udf_id = @entrepotnumber_available,
		clm5_label = 'Curve',
		clm5_udf_id = @curve_id,
		clm6_label = 'VAT Code Sale',
		clm6_udf_id = @vat_code_sale,
		clm7_label = 'GL Account VAT Sale',
		clm7_udf_id = @gl_account_vat_sale,
		clm8_label = 'Invoice Remarks',
		clm8_udf_id = @invoice_remarks,
		clm9_label = 'VAT Code Buy',
		clm9_udf_id = @vat_code_buy,
		clm10_label = 'GL Account VAT Buy',
		clm10_udf_id = @gl_account_vat_buy
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'VAT Rule Mapping'
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
		clm9_label, clm9_udf_id,
		clm10_label, clm10_udf_id
	)
	SELECT 
		mapping_table_id,
		'Commodity', @Commodity_id,
		'Location', @location_id,
		'Region', @region_id,
		'Entrepotnumber', @entrepotnumber_available,
		'Curve', @curve_id,
		'VAT Code Sale', @vat_code_sale,
		'GL Account VAT Sale', @gl_account_vat_sale,
		'Invoice Remarks',@invoice_remarks,
		'VAT Code Buy', @vat_code_buy,
		'GL Account VAT Buy',@gl_account_vat_buy
	FROM generic_mapping_header 
	WHERE mapping_name = 'VAT Rule Mapping'
END