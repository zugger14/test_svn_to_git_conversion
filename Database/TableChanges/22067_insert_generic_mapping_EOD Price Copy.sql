IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Curve ID')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Curve ID', 'Curve ID'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Curve ID'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Holiday Copy Curve')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Holiday Copy Curve', 'Holiday Copy Curve'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Holiday Copy Curve'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Expiration Copy Curve')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Expiration Copy Curve', 'Expiration Copy Curve'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Expiration Copy Curve'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Holiday Calendar')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Holiday Calendar', 'Holiday Calendar'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Holiday Calendar'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Expiration Calendar')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Expiration Calendar', 'Expiration Calendar'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Expiration Calendar'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Expected Start Maturity')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Expected Start Maturity', 'Expected Start Maturity'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Expected Start Maturity'

END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Expected End Maturity')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Expected End Maturity', 'Expected End Maturity'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Expected End Maturity'

END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Forward Settled')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Forward Settled', 'Forward Settled'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Forward Settled'

END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Check DST')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Check DST', 'Check DST'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Check DST'

END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Halt Process')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Halt Process', 'Halt Process'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Halt Process'

END


--Step 2
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Curve ID'
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
           'Curve ID',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Curve ID'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
	, field_size = 30
    WHERE  Field_label = 'Curve ID'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Holiday Copy Curve'
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
           'Holiday Copy Curve',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Holiday Copy Curve'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
    WHERE  Field_label = 'Holiday Copy Curve'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Expiration Copy Curve'
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
           'Expiration Copy Curve',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Expiration Copy Curve'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
    WHERE  Field_label = 'Expiration Copy Curve'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Holiday Calendar'
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
           'Holiday Calendar',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10017',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Holiday Calendar'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10017'
    WHERE  Field_label = 'Holiday Calendar'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Expiration Calendar'
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
           'Expiration Calendar',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT DISTINCT sdv.value_id, sdv.code FROM static_data_value sdv INNER JOIN holiday_group hg ON  hg.hol_group_value_id = sdv.value_id WHERE  sdv.[type_id] = 10017',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Expiration Calendar'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT DISTINCT sdv.value_id, sdv.code FROM static_data_value sdv INNER JOIN holiday_group hg ON  hg.hol_group_value_id = sdv.value_id WHERE  sdv.[type_id] = 10017'
    WHERE  Field_label = 'Expiration Calendar'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Expected Start Maturity'
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
           'Expected Start Maturity',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Expected Start Maturity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'Expected Start Maturity'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Expected End Maturity'
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
           'Expected End Maturity',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Expected End Maturity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'Expected End Maturity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Forward Settled'
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
           'Forward Settled',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''f'' [id], ''Forward'' [Name] UNION ALL SELECT ''s'', ''Settled''',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Forward Settled'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''f'' [id], ''Forward'' [Name] UNION ALL SELECT ''s'', ''Settled'''
    WHERE  Field_label = 'Forward Settled'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Check DST'
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
           'Check DST',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''y'' [id], ''Yes'' [Name] UNION ALL SELECT ''n'', ''No''',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Check DST'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''y'' [id], ''Yes'' [Name] UNION ALL SELECT ''n'', ''No'''
    WHERE  Field_label = 'Check DST'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Halt Process'
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
           'Halt Process',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''y'' [id], ''Halt'' [Name] UNION ALL SELECT ''n'', ''Continue''',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Halt Process'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''y'' [id], ''Halt'' [Name] UNION ALL SELECT ''n'', ''Continue'''
    WHERE  Field_label = 'Halt Process'
END


IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'EOD Price Copy')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'EOD Price Copy',
	10
	)
END


DECLARE   @curve_id INT
        , @holiday_copy_curve INT
		, @expiration_copy_curve INT
		, @holiday_calendar INT 
		, @expiration_calendar INT 
		, @expected_start_maturity INT 
		, @expected_end_maturity INT 
		, @forward_settled INT 
		, @check_DST INT
		, @halt_process INT
		
SELECT @curve_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Curve ID'
SELECT @holiday_copy_curve=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Holiday Copy Curve'
SELECT @expiration_copy_curve=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Expiration Copy Curve'
SELECT @holiday_calendar=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Holiday Calendar'
SELECT @expiration_calendar =udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Expiration Calendar'
SELECT @expected_start_maturity=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Expected Start Maturity'
SELECT @expected_end_maturity =udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Expected End Maturity'
SELECT @forward_settled=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Forward Settled'
SELECT @check_DST=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Check DST'
SELECT @halt_process=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Halt Process'



IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'EOD Price Copy')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Curve ID',
		clm1_udf_id = @curve_id,
		clm2_label = 'Holiday Copy Curve',
		clm2_udf_id = @holiday_copy_curve,
		clm3_label = 'Expiration Copy Curve',
		clm3_udf_id = @expiration_copy_curve,
		clm4_label = 'Holiday Calendar',
		clm4_udf_id = @holiday_calendar,
		clm5_label = 'Expiration Calendar',
		clm5_udf_id = @expiration_calendar,
		clm6_label = 'Expected Start Maturity',
		clm6_udf_id = @expected_start_maturity,
		clm7_label = 'Expected End Maturity',
		clm7_udf_id = @expected_end_maturity,
		clm8_label = 'Forward Settled',
		clm8_udf_id = @forward_settled,
		clm9_label = 'Check DST',
		clm9_udf_id = @check_DST,
		clm10_label = 'Halt Process',
		clm10_udf_id = @halt_process
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'EOD Price Copy'
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
		clm10_label, clm10_udf_id
	)
	SELECT 
		mapping_table_id,
		'Curve ID',@curve_id,
		'Holiday Copy Curve', @holiday_copy_curve,
		'Expiration Copy Curve', @expiration_copy_curve,
		'Holiday Calendar', @holiday_calendar,
		'Expiration Calendar', @expiration_calendar,
		'Expected Start Maturity', @expected_start_maturity,
		'Expected End Maturity', @expected_end_maturity,
		'Forward Settled', @forward_settled,
		'Check DST', @check_DST,
		'Halt Process', @halt_process
	FROM generic_mapping_header 
	WHERE mapping_name = 'EOD Price Copy'
END





