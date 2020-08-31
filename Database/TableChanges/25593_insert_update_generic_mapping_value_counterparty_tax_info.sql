/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] NVARCHAR(500))

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
/* step 1 end */
/* step 2 start*/
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
           'NVARCHAR(150)',
           'n',
           'EXEC spa_source_commodity_maintain @flag = ''a''',
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
    SET    sql_string = 'EXEC spa_source_commodity_maintain @flag = ''a'''
    WHERE  Field_label = 'Commodity'
END
/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

/* step 4: Insert into Generic Mapping Defination*/
DECLARE @counterparty INT, @Types INT, @from_date INT, @to_date INT, @values INT, @commodity INT

SELECT @counterparty = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @commodity = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Commodity'
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
		clm2_label = 'Commodity',
		clm2_udf_id = @commodity,
		clm3_label = 'From Date',
		clm3_udf_id = @from_date,
		clm4_label = 'To Date',
		clm4_udf_id = @to_date,
		clm5_label = 'Types',
		clm5_udf_id = @Types,
		clm6_label = 'Values',
		clm6_udf_id = @values,
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
		clm6_label, clm6_udf_id,
		required_columns_index
		--unique_columns_index, 
	)
	SELECT 
		mapping_table_id,
		'Counterparty', @counterparty,
		'Commodity', @commodity,
		'From Date', @from_date,
		'To Date', @to_date,
		'Types', @Types,
		'Values', @values,
		'1'
		--'1,2,3',
	FROM generic_mapping_header 
	WHERE mapping_name = 'Counterparty Tax Info'
END