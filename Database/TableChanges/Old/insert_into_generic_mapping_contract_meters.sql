IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Contract')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Contract', 'Contract'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Contract'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Meter ID')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Meter ID', 'Meter ID'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Meter ID'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Logical Meter Name')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Logical Meter Name', 'Logical Meter Name'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Logical Meter Name'
END


/* Insert into user_defined_fields_template */
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
           'VARCHAR(150)',
           'n',
           'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc',
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
    SET    Field_type = 'd',
		   sql_string = 'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc'
    WHERE  Field_label = 'Counterparty'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Contract'
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
           'Contract',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT cg.contract_id ,cg.[contract_name] FROM contract_group cg',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Contract'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT cg.contract_id ,cg.[contract_name] FROM contract_group cg'
    WHERE  Field_label = 'Contract'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Meter ID'
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
           'Meter ID',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT mi.meter_id, mi.recorderid FROM meter_id mi',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Meter ID'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT mi.meter_id, mi.recorderid FROM meter_id mi'
    WHERE  Field_label = 'Meter ID'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Logical Meter Name'
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
           'Logical Meter Name',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Logical Meter Name'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = ''
    WHERE  Field_label = 'Logical Meter Name'
END


/* Insert Generic Mapping Header */
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Contract Meters')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Contract Meters',
	4
	)
END


/*Insert into Generic Mapping Defination*/


DECLARE @counterparty INT
DECLARE @contract INT
DECLARE @meter_id INT
DECLARE @logical_meter_name INT

SELECT @counterparty=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @contract=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'
SELECT @meter_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Meter ID'
SELECT @logical_meter_name=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Logical Meter Name'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Contract Meters')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Counterparty',
		clm1_udf_id = @counterparty,
		clm2_label = 'Contract',
		clm2_udf_id = @contract,
		clm3_label = 'Logical Meter Name',
		clm3_udf_id = @logical_meter_name,
		clm4_label = 'Meter Id',
		clm4_udf_id = @meter_id
		,unique_columns_index = '1,2,3'
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Contract Meters'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id
		,unique_columns_index
	)
	SELECT 
		mapping_table_id,
		'Counterparty', @counterparty,
		'Contract', @contract,
		'Logical Meter Name', @logical_meter_name,
		'Meter ID', @meter_id
		, '1,2,3' 
	FROM generic_mapping_header 
	WHERE mapping_name = 'Contract Meters'
END