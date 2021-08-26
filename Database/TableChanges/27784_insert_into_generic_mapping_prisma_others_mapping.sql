/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Source', 'Source'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Source'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Network Point Name (EXIT)')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Network Point Name (EXIT)', 'Network Point Name (EXIT)'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Network Point Name (EXIT)'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Network Point ID (EXIT)')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Network Point ID (EXIT)', 'Network Point ID (EXIT)'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Network Point ID (EXIT)'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Network Point Name (ENTRY)')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Network Point Name (ENTRY)', 'Network Point Name (ENTRY)'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Network Point Name (ENTRY)'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Network Point ID (ENTRY)')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Network Point ID (ENTRY)', 'Network Point ID (ENTRY)'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Network Point ID (ENTRY)'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Undiscount/Discount Flag')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Undiscount/Discount Flag', 'Undiscount/Discount Flag'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Undiscount/Discount Flag'
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Template')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Template', 'Template'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Template'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Location Leg 1')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Location Leg 1', 'Location Leg 1'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Location Leg 1'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Index Leg 1')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Index Leg 1', 'Index Leg 1'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Index Leg 1'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Location Leg 2')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Location Leg 2', 'Location Leg 2'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Location Leg 2'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Index Leg 2')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Index Leg 2', 'Index Leg 2'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Index Leg 2'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TRM SubBook')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'TRM Subbook', 'TRM Subbook'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TRM Subbook'
END

/* step 1 end */

/* step 2 start*/
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
           'NVARCHAR(150)',
           'n',
           'SELECT template_id, template_name 
			FROM source_deal_header_template sdht 
			WHERE sdht.is_active = ''y'' ORDER BY template_name',
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
    SET    sql_string = 'SELECT template_id, template_name 
							FROM source_deal_header_template sdht 
							WHERE sdht.is_active = ''y'' ORDER BY template_name'
    WHERE  Field_label = 'Template'
END

IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Network Point Name (EXIT)'
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
           'Network Point Name (EXIT)',
           't',
           'NVARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Network Point Name (EXIT)'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = NULL
    WHERE  Field_label = 'Network Point Name (EXIT)'
END

IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source'
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
           'Source',
           't',
           'NVARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Source'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = NULL
    WHERE  Field_label = 'Source'
END

IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Network Point ID (EXIT)'
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
           'Network Point ID (EXIT)',
           't',
           'NVARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Network Point ID (EXIT)'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = NULL
    WHERE  Field_label = 'Network Point ID (EXIT)'
END

IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Network Point Name (ENTRY)'
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
           'Network Point Name (ENTRY)',
           't',
           'NVARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Network Point Name (ENTRY)'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = NULL
    WHERE  Field_label = 'Network Point Name (ENTRY)'
END

IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Network Point ID (ENTRY)'
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
           'Network Point ID (ENTRY)',
           't',
           'NVARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Network Point ID (ENTRY)'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = NULL
    WHERE  Field_label = 'Network Point ID (ENTRY)'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Undiscount/Discount Flag'
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
           'Undiscount/Discount Flag',
           'd',
           'NVARCHAR(150)',
           'n',
           'SELECT ''t'' id, ''True'' value UNION SELECT ''f'', ''False''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Undiscount/Discount Flag'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''t'' id, ''True'' value UNION SELECT ''f'', ''False'''
    WHERE  Field_label = 'Undiscount/Discount Flag'
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
           'NVARCHAR(150)',
           'y',
           'EXEC spa_contract_group @flag = ''n''',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Contract'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string =  'EXEC spa_contract_group @flag = ''n'''
    WHERE  Field_label = 'Contract'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Location Leg 1'
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
           'Location Leg 1',
           'd',
           'NVARCHAR(150)',
           'n',
           'EXEC spa_source_minor_location ''o''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Location Leg 1'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_source_minor_location ''o'''
    WHERE  Field_label = 'Location Leg 1'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Index Leg 1'
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
           'Index Leg 1',
           'd',
           'NVARCHAR(150)',
           'n',
           'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Index Leg 1'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
    WHERE  Field_label = 'Index Leg 1'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Location Leg 2'
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
           'Location Leg 2',
           'd',
           'NVARCHAR(150)',
           'n',
           'EXEC spa_source_minor_location ''o''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Location Leg 2'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_source_minor_location ''o'''
    WHERE  Field_label = 'Location Leg 2'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Index Leg 2'
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
           'Index Leg 2',
           'd',
           'NVARCHAR(150)',
           'n',
           'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Index Leg 2'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
    WHERE  Field_label = 'Index Leg 2'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'TRM Subbook'
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
           'TRM Subbook',
           'd',
           'NVARCHAR(150)',
           'n',
           'SELECT ssbm.book_deal_type_map_id id, ssbm.logical_name VALUE FROM source_system_book_map ssbm ORDER BY 2',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TRM Subbook'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ssbm.book_deal_type_map_id id, ssbm.logical_name VALUE FROM source_system_book_map ssbm ORDER BY 2'
    WHERE  Field_label = 'TRM Subbook'
END

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Prisma Others Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Prisma Others Mapping',
	13
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
DECLARE @source INT
DECLARE @network_point_exit INT
DECLARE @network_point_id_exit INT
DECLARE @network_point_entry INT
DECLARE @network_point_id_entry INT
DECLARE @undis_dis_flg INT
DECLARE @contract INT
DECLARE @template INT
DECLARE @location_leg1 INT
DECLARE @index_leg1 INT
DECLARE @location_leg2 INT
DECLARE @index_leg2 INT
DECLARE @trm_sub_book INT

SELECT @source = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Source'
SELECT @network_point_exit = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Network Point Name (EXIT)'
SELECT @network_point_id_exit = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Network Point ID (EXIT)'  
SELECT @network_point_entry = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Network Point Name (ENTRY)'
SELECT @network_point_id_entry = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Network Point ID (ENTRY)'  
SELECT @undis_dis_flg = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Undiscount/Discount Flag'
SELECT @contract = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'
SELECT @template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Template'
SELECT @location_leg1 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Location Leg 1'
SELECT @index_leg1 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Index Leg 1'
SELECT @location_leg2 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Location Leg 2'
SELECT @index_leg2 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Index Leg 2'
SELECT @trm_sub_book = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'TRM Subbook'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Prisma Others Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Source',
		clm1_udf_id = @source,
		clm2_label = 'Network Point Name (EXIT)',
		clm2_udf_id = @network_point_exit,
		clm3_label = 'Network Point ID (EXIT)',
		clm3_udf_id = @network_point_id_exit,
		clm4_label = 'Network Point Name (ENTRY)',
		clm4_udf_id = @network_point_entry,
		clm5_label = 'Network Point ID (ENTRY)',
		clm5_udf_id = @network_point_id_entry,
		clm6_label = 'Undiscount/Discount Flag',
		clm6_udf_id = @undis_dis_flg,
		clm7_label = 'Contract',
		clm7_udf_id = @contract,
		clm8_label = 'Template',
		clm8_udf_id = @template,
		clm9_label = 'Location Leg 1',
		clm9_udf_id = @location_leg1,
		clm10_label = 'Index Leg 1',
		clm10_udf_id = @index_leg1,
		clm11_label = 'Location Leg 2',
		clm11_udf_id = @location_leg2,
		clm12_label = 'Index Leg 2',
		clm12_udf_id = @index_leg2,
		clm13_label = 'TRM Subbook',
		clm13_udf_id = @trm_sub_book
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Prisma Others Mapping'
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
		clm8_label, clm8_udf_id,
		clm9_label, clm9_udf_id,
		clm10_label, clm10_udf_id,
		clm11_label, clm11_udf_id,
		clm12_label, clm12_udf_id,
		clm13_label, clm13_udf_id 
	)
	SELECT 
		mapping_table_id,
		'Source', @source,
		'Network Point Name (EXIT)', @network_point_exit,
		'Network Point ID (EXIT)', @network_point_id_exit,
		'Network Point Name (ENTRY)',@network_point_entry,
		'Network Point ID (ENTRY)', @network_point_id_entry,
		'Undiscount/Discount Flag', @undis_dis_flg,
		'Contract', @contract,
		'Template', @template,
		'Location Leg 1', @location_leg1,
		'Index Leg 1', @index_leg1,
		'Location Leg 2', @location_leg2,
		'Index Leg 2', @index_leg2,
		'TRM Subbook', @trm_sub_book
	FROM generic_mapping_header 
	WHERE mapping_name = 'Prisma Others Mapping'
END

