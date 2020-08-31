/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
GO
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500), [description] VARCHAR (500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Storage Type')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -5715, 5500, 'Storage Type', 'Storage Type'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Storage Type'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Sub Book')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -5674, 5500, 'Sub Book', 'Sub Book'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Sub Book'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Template')
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -5655, 5500, 'Template', 'Template'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, description
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Template' 
END

/* step 1 end */

/* step 2 start*/

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Storage Type'
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
           'Storage Type',
           'd',
           'VARCHAR(150)',
           'n',
           'select ''w'' value, ''Withdrawl'' label union all select ''i'', ''Injection''',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Storage Type'
END
ELSE
	
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'select ''w'' value, ''Withdrawl'' label union all select ''i'', ''Injection'''
    WHERE  Field_label = 'Storage Type'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Sub Book'
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
           'Sub Book',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_GetAllSourceBookMapping NULL, NULL, ''s'', NULL',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Sub Book'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'EXEC spa_GetAllSourceBookMapping NULL, NULL, ''s'', NULL'
    WHERE  Field_label = 'Sub Book'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Template'
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
           'Template',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT  Template_id, Template_name FROM source_deal_header_template sdht
			INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdht.source_deal_type_id
			WHERE sdt.source_deal_type_name = ''Storage'' AND is_active = ''y''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'SELECT  Template_id, Template_name FROM source_deal_header_template sdht
			INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdht.source_deal_type_id
			WHERE sdt.source_deal_type_name = ''Storage'' AND is_active = ''y'''
    WHERE  Field_label = 'Template'
END

DECLARE @subbook INT
DECLARE @Template INT
DECLARE @type INT

SELECT @type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Type'
SELECT @subbook = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sub Book'
SELECT @Template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Template'




/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Scheduling Storage Mapping')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Scheduling Storage Mapping',
		total_columns_used = 3
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Scheduling Storage Mapping'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Scheduling Storage Mapping',
	3
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Scheduling Storage Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Storage Type',
		clm1_udf_id = @type,
		clm2_label = 'Sub Book',
		clm2_udf_id = @subbook,
		clm3_label = 'Template',
		clm3_udf_id = @template
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Scheduling Storage Mapping'
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
		'Storage Type', @type,
		'Sub Book', @subbook,
		'Template', @template
		
		
	FROM generic_mapping_header 
	WHERE mapping_name = 'Scheduling Storage Mapping'
END
