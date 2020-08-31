/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'As Of Date')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'As Of Date', 'As Of Date'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'As Of Date'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Initial Margin')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Initial Margin', 'Initial Margin'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Initial Margin'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Maintenance Margin')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Maintenance Margin', 'Maintenance Margin'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Maintenance Margin'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Initial Portfolio Amount')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Initial Portfolio Amount', 'Initial Portfolio Amount'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Initial Portfolio Amount'
END
/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'As Of Date'
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
           'As Of Date',
           'a',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'As Of Date'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'As Of Date'
END

IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Initial Margin'
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
           'Initial Margin',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Initial Margin'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'Initial Margin'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Maintenance Margin'
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
           'Maintenance Margin',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Maintenance Margin'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'Maintenance Margin'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Initial Portfolio Amount'
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
           'Initial Portfolio Amount',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Initial Portfolio Amount'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'Initial Portfolio Amount'
END
/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Margin Analysis')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Margin Analysis',
		total_columns_used = 6,
		system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Margin Analysis'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Margin Analysis',
	6
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
DECLARE @as_of_date INT, @clearing_counterparty INT, @margin_contract INT, @initial_margin INT, @maintenance_margin INT, @initial_portfolio_amount INT

SELECT @as_of_date = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'As Of Date'
SELECT @clearing_counterparty = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Clearing Counterparty'
SELECT @margin_contract = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Margin Contract'
SELECT @initial_margin = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Initial Margin'
SELECT @maintenance_margin = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Maintenance Margin'
SELECT @initial_portfolio_amount = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Initial Portfolio Amount'
 
 
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Margin Analysis')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'As Of Date',
		clm1_udf_id = @as_of_date,
		clm2_label = 'Clearing Counterparty',
		clm2_udf_id = @clearing_counterparty,
		clm3_label = 'Margin Contract',
		clm3_udf_id = @margin_contract,
		clm4_label = 'Initial Margin',
		clm4_udf_id = @initial_margin,
		clm5_label = 'Maintenance Margin',
		clm5_udf_id = @maintenance_margin,
		clm6_label = 'Initial Portfolio Amount',
		clm6_udf_id = @initial_portfolio_amount
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Margin Analysis'
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
		'As Of Date', @as_of_date,
		'Clearing Counterparty', @clearing_counterparty,
		'Margin Contract', @margin_contract,
		'Initial Margin', @initial_margin,
		'Maintenance Margin', @maintenance_margin,
		'Initial Portfolio Amount', @initial_portfolio_amount
	FROM generic_mapping_header 
	WHERE mapping_name = 'Margin Analysis'
END