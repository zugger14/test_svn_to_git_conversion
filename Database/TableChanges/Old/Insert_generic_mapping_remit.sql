/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
GO
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Counterparty')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '307188', '5500', 'Counterparty', 'Counterparty'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Contract'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Contract')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '307189', '5500', 'Contract', 'Contract'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Contract'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Sub Book')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-5718', '5500', 'Sub Book', 'Sub Book'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Sub Book'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Profile')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-5717', '5500', 'Profile', 'Profile'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Profile'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Group')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-5719', '5500', 'Deal Group', 'Deal Group'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Deal Group'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Transaction Time (HH:MM:SS)')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Transaction Time (HH:MM:SS)',
           'Transaction Time (HH:MM:SS)'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Transaction Time (HH:MM:SS)'
END

/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Counterparty')
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
           'SELECT source_counterparty_id id, counterparty_name value FROM source_counterparty WHERE is_active = ''y'' ORDER BY 2',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Counterparty'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'SELECT source_counterparty_id id, counterparty_name value FROM source_counterparty WHERE is_active = ''y'' ORDER BY 2'
    WHERE  Field_label = 'Counterparty'
END


IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Contract')
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
           'SELECT contract_id id, contract_name value  FROM contract_group value ORDER BY 2',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Contract'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'SELECT contract_id id, contract_name value  FROM contract_group value ORDER BY 2'
    WHERE  Field_label = 'Contract'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Profile')
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
           'VARCHAR(150)',
           'n',
           'SELECT value_id id, code value FROM static_data_value  WHERE [type_id] = 17300 ORDER BY 1',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Profile'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'SELECT value_id id, code value FROM static_data_value  WHERE [type_id] = 17300 ORDER BY 1'
    WHERE  Field_label = 'Profile'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Sub Book')
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
           'SELECT ssbm.book_deal_type_map_id id, ssbm.logical_name VALUE FROM source_system_book_map ssbm ORDER BY 2',
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
		sql_string = 'SELECT ssbm.book_deal_type_map_id id, ssbm.logical_name VALUE FROM source_system_book_map ssbm ORDER BY 2'
    WHERE  Field_label = 'Sub Book'
END


IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Deal Group')
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
           'Deal Group',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT 1 id, ''PWR DA'' value UNION SELECT 2, ''PWR BL/Pk'' UNION SELECT 3, ''GAS DA/ID'' UNION SELECT 4, ''PWR SHAPED'' UNION SELECT 0, ''Others'' ORDER BY 1',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Group'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'SELECT 1 id, ''PWR DA'' value UNION SELECT 2, ''PWR BL/Pk'' UNION SELECT 3, ''GAS DA/ID'' UNION SELECT 4, ''PWR SHAPED'' UNION SELECT 0, ''Others'' ORDER BY 1'
    WHERE  Field_label = 'Deal Group'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Transaction Time (HH:MM:SS)')
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
           'Transaction Time (HH:MM:SS)',
           't',
           'VARCHAR(150)',
           'n',
			NULL,
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Transaction Time (HH:MM:SS)'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400
    WHERE  Field_label = 'Transaction Time (HH:MM:SS)'
END

DECLARE @counterparty_id INT
DECLARE @contract_id INT
DECLARE @profile_id INT
DECLARE @sub_book_id INT
DECLARE @deal_group_id INT
DECLARE @transaction_time INT 


SELECT @counterparty_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @contract_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'
SELECT @profile_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Profile'
SELECT @sub_book_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sub Book'
SELECT @deal_group_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Group'
SELECT @transaction_time = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Transaction Time (HH:MM:SS)'

/* end of part 2 */
/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Remit')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Remit',
		total_columns_used = 6,
		system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Remit'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Remit',
	6
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Remit')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Counterparty',
		clm1_udf_id = @counterparty_id,
		clm2_label = 'Contract',
		clm2_udf_id = @contract_id,
		clm3_label = 'Profile',
		clm3_udf_id = @profile_id,
		clm4_label = 'Sub Book',
		clm4_udf_id = @sub_book_id,
		clm5_label = 'Deal Group',
		clm5_udf_id = @deal_group_id,
		clm6_label = 'Transaction Time (HH:MM:SS)',
		clm6_udf_id = @transaction_time
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Remit'
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
		'Counterparty', @contract_id,
		'Contract', @contract_id,
		'Profile', @profile_id,
		'Sub Book', @sub_book_id,
		'Deal Group', @deal_group_id,
		'Transaction Time (HH:MM:SS)', @transaction_time
		
	FROM generic_mapping_header 
	WHERE mapping_name = 'Remit'
END

