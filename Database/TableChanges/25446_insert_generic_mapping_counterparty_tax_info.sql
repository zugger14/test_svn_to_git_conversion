/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] NVARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Counterparty')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Counterparty', 'Counterparty'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Counterparty'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Types')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Types', 'Types'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Types'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'From Date')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'From Date', 'From Date'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'From Date'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'To Date')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'To Date', 'To Date'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'To Date'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Values')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Values', 'Values'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Values'
END

/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Counterparty'
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
           'Counterparty',
           'd',
           'NVARCHAR(150)',
           'n',
           'SELECT source_counterparty_id, counterparty_id FROM source_counterparty',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Counterparty'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_counterparty_id, counterparty_id FROM source_counterparty'
    WHERE  Field_label = 'Counterparty'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Types'
   )
BEGIN
	print 'type not exist'
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
           'Types',
           'd',
           'NVARCHAR(150)',
           'n',
           'Select ''reseller_certificate'' as value,''Reseller Certificate'' as Label UNION ALL SELECT ''energy_tax_exemption'' as Value,''Energy Tax Exemption'' as Label',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Types'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'Select ''reseller_certificate'' as value,''Reseller Certificate'' as Label UNION ALL SELECT ''energy_tax_exemption'' as Value,''Energy Tax Exemption'' as Label'
    WHERE  Field_label = 'Types'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'From Date'
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
           'From Date',
           'a',
           'datetime',
           'n',
           NULL,
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'From Date'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = NULL
    WHERE  Field_label = 'From Date'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'To Date'
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
           'To Date',
           'a',	
           'datetime',
           'n',
           NULL,
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'To Date'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = NULL
    WHERE  Field_label = 'To Date'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Values'
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
           'Values',
           'd',
           'NVARCHAR(150)',
           'n',
           'Select ''n'' as value,''No'' as Label UNION ALL SELECT ''y'' as Value,''Yes'' as Label',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Values'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'Select ''n'' as value,''No'' as Label UNION ALL SELECT ''y'' as Value,''Yes'' as Label'
    WHERE  Field_label = 'Values'
END

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Counterparty Tax Info')
BEGIN
	PRINT 'Mapping Table Already Exists'
	UPDATE generic_mapping_header SET total_columns_used = 5 WHERE mapping_name = 'Counterparty Tax Info'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Counterparty Tax Info',
	5
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
DECLARE @counterparty INT, @Types INT, @from_date INT, @to_date INT, @values INT

SELECT @counterparty = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @Types = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Types'
SELECT @from_date = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'From Date'
SELECT @to_date = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'To Date'
SELECT @values = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Values'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Counterparty Tax Info')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Counterparty',
		clm1_udf_id = @counterparty,
		clm2_label = 'From Date',
		clm2_udf_id = @from_date,
		clm3_label = 'To Date',
		clm3_udf_id = @to_date,
		clm4_label = 'Types',
		clm4_udf_id = @Types,
		clm5_label = 'Values',
		clm5_udf_id = @values,
		required_columns_index = '1'
		--unique_columns_index = '1,2,3',						
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Counterparty Tax Info'
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
		required_columns_index
		--unique_columns_index, 
	)
	SELECT 
		mapping_table_id,
		'Counterparty', @counterparty,
		'From Date', @from_date,
		'To Date', @to_date,
		'Types', @Types,
		'Values', @values,
		'1'
		--'1,2,3',
	FROM generic_mapping_header 
	WHERE mapping_name = 'Counterparty Tax Info'
END