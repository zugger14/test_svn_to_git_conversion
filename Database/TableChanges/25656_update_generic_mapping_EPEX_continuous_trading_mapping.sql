IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Text')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Text', 'Text'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Text'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TSO Name')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'TSO Name', 'TSO Name'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TSO Name'
END

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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Price Sign')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Price Sign', 'Price Sign'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Price Sign'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Analysis Info')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Analysis Info', 'Analysis Info'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Analysis Info'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Reference')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Deal Reference', 'Deal Reference'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Deal Reference'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Internal Profile')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Internal Profile', 'Internal Profile'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Internal Profile'
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

/* Insert into user_defined_fields_template */
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Text'
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
           'Text',
           't',
           'nvarchar(100)',
           'n',
           NULL,
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Text'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Text'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'TSO Name'
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
           'TSO Name',
           't',
           'nvarchar(100)',
           'n',
           NULL,
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TSO Name'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'TSO Name'
END

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
           'nchar(1)',
           'n',
           'SELECT ''b'' AS value_id, ''Buy'' AS [name] UNION SELECT ''s'' AS value_id, ''Sell'' AS [name]',
           'h',
           NULL,
           120,
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
       WHERE  Field_label = 'Price Sign'
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
           'Price Sign',
           'd',
           'nchar(1)',
           'n',
           'SELECT ''p'' AS value_id, ''Positive'' AS [name] UNION SELECT ''n'' AS value_id, ''Negative'' AS [name]',
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Price Sign'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT ''p'' AS value_id, ''Positive'' AS [name] UNION SELECT ''n'' AS value_id, ''Negative'' AS [name]'
    WHERE  Field_label = 'Price Sign'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Analysis Info'
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
           'Analysis Info',
           't',
           'nvarchar(100)',
           'n',
           NULL,
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Analysis Info'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Analysis Info'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Deal Reference'
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
           'Deal Reference',
           't',
           'nvarchar(100)',
           'n',
           NULL,
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Reference'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Deal Reference'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Internal Profile'
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
           'Internal Profile',
           'd',
           'INT',
           'n',
           'EXEC spa_forecast_profile ''x''',
           'o',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Internal Profile'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_forecast_profile ''x'''
    WHERE  Field_label = 'Internal Profile'
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

/* Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'EPEX Continuous Trading Mapping')
BEGIN
	UPDATE generic_mapping_header
	SET total_columns_used = 8
	WHERE mapping_name = 'EPEX Continuous Trading Mapping'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used,
	system_defined
	) VALUES (
	'EPEX Continuous Trading Mapping',
	8,
	0
	)

END

/*Insert into Generic Mapping Defination*/

DECLARE @text INT
DECLARE @tso_name INT
DECLARE @buy_sell INT
DECLARE @price_sign INT
DECLARE @analysis INT
DECLARE @deal_ref INT
DECLARE @internal_profile INT
DECLARE @profile INT

SELECT @text = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Text'
SELECT @tso_name = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'TSO Name'
SELECT @buy_sell = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Buy Sell'
SELECT @price_sign = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Price Sign'
SELECT @analysis = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Analysis Info'
SELECT @deal_ref = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Reference'
SELECT @internal_profile = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Internal Profile'
SELECT @profile = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Profile'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'EPEX Continuous Trading Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Text',
		clm1_udf_id = @text,
		clm2_label = 'TSO Name',
		clm2_udf_id = @tso_name,
		clm3_label = 'Buy Sell',
		clm3_udf_id = @buy_sell,
		clm4_label = 'Price Sign',
		clm4_udf_id = @price_sign,
		clm5_label = 'Analysis Info',
		clm5_udf_id = @analysis,
		clm6_label = 'Deal Reference',
		clm6_udf_id = @deal_ref,
		clm7_label = 'Internal Profile',
		clm7_udf_id = @internal_profile,
		clm8_label = 'Profile',
		clm8_udf_id = @profile
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'EPEX Continuous Trading Mapping'
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
		clm8_label, clm8_udf_id
		)
	SELECT 
		mapping_table_id,
		'Text', @text,
		'TSO Name', @tso_name,
		'Buy Sell', @buy_sell,
		'Price Sign', @price_sign,
		'Analysis Info', @analysis,
		'Deal Reference', @deal_ref,
		'Internal Profile', @internal_profile,
		'Profile', @profile
	FROM generic_mapping_header 
	WHERE mapping_name = 'EPEX Continuous Trading Mapping'
END
