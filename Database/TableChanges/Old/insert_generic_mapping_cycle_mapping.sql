IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [value_name] VARCHAR(500))

IF NOT EXISTS(SELECT 'X' FROM generic_mapping_header WHERE mapping_name = 'Cycle Mapping')
BEGIN
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used)
	SELECT 'Cycle Mapping', 3
END
GO

IF NOT EXISTS(
       SELECT 'X'
       FROM   static_data_value
       WHERE  code = 'Cycle'
)
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT 5500, 'Cycle', 'Cycle'
END
ELSE 
BEGIN
	INSERT INTO #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Cycle'
END


IF NOT EXISTS(
       SELECT 'X'
       FROM   static_data_value
       WHERE  code = 'Cycle Hour'
   )
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT 5500, 'Cycle Hour', 'Cycle Hour'
END
ELSE 
BEGIN
	INSERT INTO #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Cycle Hour'
END

IF NOT EXISTS(
       SELECT 'X'
       FROM   static_data_value
       WHERE  code = 'Cycle Minute'
   )
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT 5500, 'Cycle Minute', 'Cycle Minute'
END
ELSE 
BEGIN
	INSERT INTO #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Cycle Minute'
END


UPDATE user_defined_fields_template
SET    field_name = iose.value_id,
       Field_label = iose.[value_name],
       Field_type = CASE WHEN iose.[value_name] = 'Cycle Minute' THEN 't' ELSE 'd' END,
       data_type = 'VARCHAR(150)',
       is_required = 'n',
       sql_string = CASE iose.[value_name]
                         WHEN 'Cycle' THEN 'SELECT 1 AS [id], ''1'' [name] UNION ALL   SELECT 2, ''2'' UNION ALL  SELECT 3, ''3'' UNION ALL  SELECT 4, ''4'' UNION ALL  SELECT 5, ''5'''
                         WHEN 'Cycle Hour' THEN 'SELECT 0 [id],0 [name] UNION SELECT 1,1 UNION SELECT 2,2 UNION SELECT 3,3 UNION SELECT 4,4 UNION SELECT 5,5 UNION SELECT 6,6 UNION SELECT 7,7 UNION SELECT 8,8 UNION SELECT 9,9 UNION SELECT 10,10 UNION SELECT 11,11 UNION SELECT 12,12 UNION SELECT 13,13 UNION SELECT 14,14 UNION SELECT 15,15 UNION SELECT 16,16 UNION SELECT 17,17 UNION SELECT 18,18 UNION SELECT 19,19 UNION SELECT 20,20 UNION SELECT 21,21 UNION SELECT 22,22 UNION SELECT 23,23'
                         WHEN 'Cycle Minute' THEN NULL
                    END,
       udf_type = 'h',
       sequence = NULL,
       field_size = 30,
       field_id = iose.value_id
FROM   #insert_output_sdv_external iose
INNER JOIN user_defined_fields_template udft ON  iose.value_name = udft.Field_label

INSERT INTO user_defined_fields_template (
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
       iose.[value_name],
        CASE WHEN iose.[value_name] = 'Cycle Minute' THEN 't' ELSE 'd' END,
       'VARCHAR(150)',
       'n',
       CASE iose.[value_name] 
		   WHEN 'Cycle' THEN 'SELECT 1 AS [id], ''1'' [name] UNION ALL   SELECT 2, ''2'' UNION ALL  SELECT 3, ''3'' UNION ALL  SELECT 4, ''4'' UNION ALL  SELECT 5, ''5'''
		   WHEN 'Cycle Hour' THEN 'SELECT 0 [id],0 [name] UNION SELECT 1,1 UNION SELECT 2,2 UNION SELECT 3,3 UNION SELECT 4,4 UNION SELECT 5,5 UNION SELECT 6,6 UNION SELECT 7,7 UNION SELECT 8,8 UNION SELECT 9,9 UNION SELECT 10,10 UNION SELECT 11,11 UNION SELECT 12,12 UNION SELECT 13,13 UNION SELECT 14,14 UNION SELECT 15,15 UNION SELECT 16,16 UNION SELECT 17,17 UNION SELECT 18,18 UNION SELECT 19,19 UNION SELECT 20,20 UNION SELECT 21,21 UNION SELECT 22,22 UNION SELECT 23,23'
		   WHEN 'Cycle Minute' THEN NULL	
       END,
       'h',
       NULL,
       30,
       iose.value_id
FROM #insert_output_sdv_external iose
LEFT JOIN user_defined_fields_template udft ON iose.value_name = udft.Field_label
WHERE udft.udf_template_id IS NULL


DECLARE @cycle_id         VARCHAR(100),
        @cycle_hour_id    VARCHAR(100),
        @cycle_minute_id  VARCHAR(100),
        @mapping_id       INT
        
SELECT @cycle_id = udf_template_id from user_defined_fields_template WHERE Field_label = 'Cycle'
SELECT @cycle_hour_id = udf_template_id from user_defined_fields_template WHERE Field_label='Cycle Hour'
SELECT @cycle_minute_id = udf_template_id from user_defined_fields_template WHERE Field_label='Cycle Minute'

SELECT @mapping_id = gmh.mapping_table_id FROM generic_mapping_header gmh WHERE gmh.mapping_name = 'Cycle Mapping'

IF NOT EXISTS(
       SELECT 'X'
       FROM   generic_mapping_definition
       WHERE  mapping_table_id = @mapping_id
)
BEGIN
	INSERT INTO generic_mapping_definition (
        mapping_table_id,
        clm1_label,
        clm1_udf_id,
        clm2_label,
        clm2_udf_id,
        clm3_label,
        clm3_udf_id
      )
    SELECT @mapping_id,
           'Cycle Hour',
           @cycle_hour_id,
           'Cycle Minute',
           @cycle_minute_id,
           'Cycle',
           @cycle_id
END
ELSE
BEGIN
	UPDATE generic_mapping_definition
	SET clm1_label = 'Cycle Hour',
		clm1_udf_id = @cycle_hour_id,
		clm2_label = 'Cycle Minute',
		clm2_udf_id = @cycle_minute_id,
		clm3_label = 'Cycle',
		clm3_udf_id = @cycle_id
	WHERE mapping_table_id = @mapping_id
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_values gmv WHERE gmv.mapping_table_id =  CAST(@mapping_id AS VARCHAR(10)) AND gmv.clm3_value = CAST(1 AS VARCHAR(10)))
BEGIN
	INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value)
	VALUES(@mapping_id, 10, 30, 1) 
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_values gmv WHERE gmv.mapping_table_id =  CAST(@mapping_id AS VARCHAR(10)) AND gmv.clm3_value =  CAST(2 AS VARCHAR(10)))
BEGIN
	INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value)
	SELECT @mapping_id, 17, NULL, 2
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_values gmv WHERE gmv.mapping_table_id =  CAST(@mapping_id AS VARCHAR(10)) AND gmv.clm3_value =  CAST(3 AS VARCHAR(10)))
BEGIN
	INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value)
	SELECT @mapping_id, 9, NULL, 3
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_values gmv WHERE gmv.mapping_table_id =  CAST(@mapping_id AS VARCHAR(10)) AND gmv.clm3_value =  CAST(4 AS VARCHAR(10)))
BEGIN
	INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value)
	SELECT @mapping_id, 16, NULL, 4
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_values gmv WHERE gmv.mapping_table_id =  CAST(@mapping_id AS VARCHAR(10)) AND gmv.clm3_value =  CAST(5 AS VARCHAR(10)))
BEGIN
	INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value)
	SELECT @mapping_id, 16, NULL, 5
END

