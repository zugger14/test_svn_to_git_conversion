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
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Endex YA Base Settlement')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Endex YA Base Settlement',
           'Endex YA Base Settlement'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500
           AND [code] = 'Endex YA Base Settlement'
END
 
--Second UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Kosten')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Kosten',
           'Kosten'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Kosten'
END


/*Step 2: Defining UDF */
 --First UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Endex YA Base Settlement'
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
           'Endex YA Base Settlement',
           't',
           'FLOAT',
           'n',
           NULL,
           'h',
           NULL,
           150,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Endex YA Base Settlement'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't'
    WHERE  Field_label = 'Endex YA Base Settlement'
END

--Second UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Kosten'
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
           'Kosten',
           't',
           'FLOAT',
           'n',
           NULL,
           'h',
           NULL,
           150,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Kosten'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
     SET    Field_type = 't'
    WHERE  Field_label = 'Kosten'
END


/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Endex Markup')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Endex Markup',
	2
	)
END

/* step 4: Insert into Generic Mapping Defination*/

DECLARE @Endex_YA_Base_Settlement INT
DECLARE @kosten INT

SELECT @Endex_YA_Base_Settlement=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Endex YA Base Settlement'
SELECT @kosten=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Kosten'


IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Endex Markup')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Endex YA Base Settlement',
		clm1_udf_id = @Endex_YA_Base_Settlement,
		clm2_label = 'Kosten',
		clm2_udf_id = @kosten
		
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Endex Markup'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id
	)
	SELECT 
		mapping_table_id,
		'Endex YA Base Settlement', @Endex_YA_Base_Settlement,
		'Kosten', @kosten
	FROM generic_mapping_header 
	WHERE mapping_name = 'Endex Markup'
END
