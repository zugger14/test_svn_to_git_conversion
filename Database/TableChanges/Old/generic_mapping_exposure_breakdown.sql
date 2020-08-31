/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [TYPE_ID] INT , [TYPE_NAME] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [TYPE_ID] = 5500 AND code = 'Index')
BEGIN
	INSERT INTO static_data_value ([TYPE_ID], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Index', 'Index'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [TYPE_ID], code
	  FROM static_data_value WHERE [TYPE_ID] = 5500 AND [code] = 'Index'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [TYPE_ID] = 5500 AND code = 'Exposure Type')
BEGIN
	INSERT INTO static_data_value ([TYPE_ID], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Exposure Type', 'Exposure Type'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [TYPE_ID], code
	 FROM static_data_value WHERE [TYPE_ID] = 5500 AND [code] = 'Exposure Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [TYPE_ID] = 5500 AND code = 'Exposure Index')
BEGIN
	INSERT INTO static_data_value ([TYPE_ID], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Exposure Index', 'Exposure Index'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [TYPE_ID], code
	 FROM static_data_value WHERE [TYPE_ID] = 5500 AND [code] = 'Exposure Index'
END

/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Index'
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
        SEQUENCE,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Index',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_GetAllPriceCurveDefinitions @flag=''a'', @is_active=''y''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Index'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_GetAllPriceCurveDefinitions @flag=''a'', @is_active=''y'''
    WHERE  Field_label = 'Index'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Exposure Type'
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
        SEQUENCE,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Exposure Type',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT 1 [value_id], ''Basis'' [code] UNION ALL SELECT 2 [value_id], ''Nymex'' [code] UNION ALL SELECT 3 [value_id], ''Index Prem'' [code]',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Exposure Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT 1 [value_id], ''Basis'' [code] UNION ALL SELECT 2 [value_id], ''Nymex'' [code] UNION ALL SELECT 3 [value_id], ''Index Prem'' [code]'
    WHERE  Field_label = 'Exposure Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Exposure Index'
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
        SEQUENCE,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Exposure Index',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_GetAllPriceCurveDefinitions @flag=''a'', @is_active=''y''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Exposure Index'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_GetAllPriceCurveDefinitions @flag=''a'', @is_active=''y'''
    WHERE  Field_label = 'Exposure Index'
END
/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Exposure Breakdown')
BEGIN
	PRINT 'Mapping Table Already Exists.'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Exposure Breakdown',
	3
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
DECLARE @Index INT
DECLARE @exposure_type INT
DECLARE @exposure_index INT

SELECT @Index =  udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Index'
SELECT @exposure_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Exposure Type'
SELECT @exposure_index = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Exposure Index'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Exposure Breakdown')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Index',
		clm1_udf_id = @Index,
		clm2_label = 'Exposure Type',
		clm2_udf_id = @exposure_type,
		clm3_label = 'Exposure Index',
		clm3_udf_id = @exposure_index
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Exposure Breakdown'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id
	)
	SELECT 
		mapping_table_id,
		'Index', @Index,
		'Exposure Type',@exposure_type,
		'Exposure Index',@exposure_index
	FROM generic_mapping_header 
	WHERE mapping_name = 'Exposure Breakdown'
END