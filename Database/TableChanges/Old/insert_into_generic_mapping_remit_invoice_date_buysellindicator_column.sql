/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'BuySell Indicator')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'BuySell Indicator', 'BuySell Indicator'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'BuySell Indicator'
END

/* step 2 start*/
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'BuySell Indicator')
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
           'BuySell Indicator',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''b'' [Id], ''Buy'' [Name] UNION SELECT ''s'' [Id], ''Sell'' [Name] ORDER BY Id',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'BuySell Indicator'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''b'' [Id], ''Buy'' [Name] UNION SELECT ''s'' [Id], ''Sell'' [Name] ORDER BY Id'
    WHERE  Field_label = 'BuySell Indicator'
END


/* end of part 2 */

DECLARE @buysell_indicator INT


SELECT @buysell_indicator = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'BuySell Indicator'


/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Remit Invoice Date')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Remit Invoice Date',
		total_columns_used = 5
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Remit Invoice Date'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Remit Invoice Date',
	5
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Remit Invoice Date')
BEGIN
	UPDATE gmd
	SET
		clm5_label = 'BuySell Indicator',
		clm5_udf_id = @buysell_indicator
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Remit Invoice Date'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm5_label, clm5_udf_id
	)
	SELECT 
		mapping_table_id,
		'BuySell Indicator', @buysell_indicator
	FROM generic_mapping_header 
	WHERE mapping_name = 'Remit Invoice Date'
END

