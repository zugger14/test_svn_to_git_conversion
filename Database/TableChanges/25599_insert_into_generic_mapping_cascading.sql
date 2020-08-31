BEGIN TRY
	BEGIN TRAN
	IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
		DROP TABLE #insert_output_sdv_external
 
	CREATE TABLE #insert_output_sdv_external (
		value_id INT,
		[type_id] INT,
		[type_name] VARCHAR(500)
	)

	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Index') 
	BEGIN
		INSERT INTO static_data_value ([type_id], code, [description])
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
		SELECT '5500', 'Index', 'Index'
	END
	ELSE
	BEGIN
		INSERT INTO #insert_output_sdv_external
		SELECT value_id, [type_id], code
		FROM static_data_value
		WHERE [type_id] = 5500
			AND [code] = 'Index'
	END
 
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Venue')
	BEGIN
		INSERT INTO static_data_value ([type_id], code, [description])
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
		SELECT '5500', 'Venue', 'Venue'
	END
	ELSE
	BEGIN
		INSERT INTO #insert_output_sdv_external
		SELECT value_id, [type_id], code
		FROM static_data_value
		WHERE [type_id] = 5500 
			AND [code] = 'Venue'
	END

	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Block1')
	BEGIN
		INSERT INTO static_data_value ([type_id], code, [description])
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
		SELECT '5500', 'Block1', 'Block1'
	END
	ELSE
	BEGIN
		INSERT INTO #insert_output_sdv_external
		SELECT value_id, [type_id], code
		FROM static_data_value
		WHERE [type_id] = 5500 
			AND [code] = 'Block1'
	END

	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Block2') 
	BEGIN
		INSERT INTO static_data_value ([type_id], code, [description])
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
		SELECT '5500', 'Block2', 'Block2'
	END
	ELSE
	BEGIN
		INSERT INTO #insert_output_sdv_external
		SELECT value_id, [type_id], code
		FROM static_data_value
		WHERE [type_id] = 5500
			AND [code] = 'Block2'
	END

	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Block3')
	BEGIN
		INSERT INTO static_data_value ([type_id], code, [description])
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
		SELECT '5500', 'Block3', 'Block3'
	END
	ELSE
	BEGIN
		INSERT INTO #insert_output_sdv_external
		SELECT value_id, [type_id], code
		FROM static_data_value
		WHERE [type_id] = 5500 
			AND [code] = 'Block3'
	END

	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Block4')
	BEGIN
		INSERT INTO static_data_value ([type_id], code, [description])
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
		SELECT '5500', 'Block4', 'Block4'
	END
	ELSE
	BEGIN
		INSERT INTO #insert_output_sdv_external
		SELECT value_id, [type_id], code
		FROM static_data_value
		WHERE [type_id] = 5500 
			AND [code] = 'Block4'
	END

	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Block5')
	BEGIN
		INSERT INTO static_data_value ([type_id], code, [description])
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
		SELECT '5500', 'Block5', 'Block5'
	END
	ELSE
	BEGIN
		INSERT INTO #insert_output_sdv_external
		SELECT value_id, [type_id], code
		FROM static_data_value
		WHERE [type_id] = 5500 
			AND [code] = 'Block5'
	END

	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Block6')
	 BEGIN
		INSERT INTO static_data_value ([type_id], code, [description])
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
		SELECT '5500', 'Block6', 'Block6'
	END
	ELSE
	BEGIN
		INSERT INTO #insert_output_sdv_external
		SELECT value_id, [type_id], code
		FROM static_data_value
		WHERE [type_id] = 5500
			AND [code] = 'Block6'
	END

	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Cascade Granularity')
	BEGIN
		INSERT INTO static_data_value ([type_id], code, [description])
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
		SELECT '5500', 'Cascade Granularity', 'Cascade Granularity'
	END
	ELSE
	BEGIN
		INSERT INTO #insert_output_sdv_external
		SELECT value_id, [type_id], code
		FROM static_data_value
		WHERE [type_id] = 5500 
			AND [code] = 'Cascade Granularity'
	END

	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Date')
	BEGIN
		INSERT INTO static_data_value ([type_id], code, [description])
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
		SELECT '5500', 'Date', 'Date'
	END
	ELSE
	BEGIN
		INSERT INTO #insert_output_sdv_external
		SELECT value_id, [type_id], code
		FROM static_data_value
		WHERE [type_id] = 5500 
			AND [code] = 'Date'
	END
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Status')
	BEGIN
		INSERT INTO static_data_value ([type_id], code, [description])
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
		SELECT '5500', 'Deal Status', 'Deal Status'
	END
	ELSE
	BEGIN
		INSERT INTO #insert_output_sdv_external
		SELECT value_id, [type_id], code
		FROM static_data_value
		WHERE [type_id] = 5500 
			AND [code] = 'Deal Status'
	END

	--UDFs
	IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Index')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
		SELECT iose.value_id,
			   'Index',
			   'd',
			   'VARCHAR(150)',
			   'n',
			   'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
			   'h',
			   NULL,
			   30,
			   iose.value_id
		FROM #insert_output_sdv_external iose
		WHERE iose.[type_name] = 'Index'
	END
	ELSE
	BEGIN
		UPDATE user_defined_fields_template
		SET Field_type = 'd',
			sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
		WHERE Field_label = 'Index'
	END

	IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Venue')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
		SELECT iose.value_id,
			   'Venue',
			   'd',
			   'VARCHAR(150)',
			   'n',
			   'SELECT item venue_id, item venue_name from FNASplit(''ICE,EEX,CME,NASDAQ,Others'', '','')',
			   'h',
			   NULL,
			   30,
			   iose.value_id
		FROM   #insert_output_sdv_external iose
		WHERE  iose.[type_name] = 'Venue'
	END
	ELSE
	BEGIN
		UPDATE user_defined_fields_template
		SET    sql_string = 'SELECT item venue_id, item venue_name from FNASplit(''ICE,EEX,CME,NASDAQ,Others'', '','')'
		WHERE  Field_label = 'Venue'
	END


	--Third UDF
	IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Block1')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
		SELECT iose.value_id,
			   'Block1',
			   'd',
			   'VARCHAR(150)',
			   'n',
			   'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
			   'h',
			   NULL,
			   30,
			   iose.value_id
		FROM #insert_output_sdv_external iose
		WHERE iose.[type_name] = 'Block1'
	END
	ELSE
	BEGIN
		UPDATE user_defined_fields_template
		SET sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
		WHERE  Field_label = 'Block1'
	END

	IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Block2')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
		SELECT iose.value_id,
			   'Block2',
			   'd',
			   'VARCHAR(150)',
			   'n',
			   'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
			   'h',
			   NULL,
			   30,
			   iose.value_id
		FROM #insert_output_sdv_external iose
		WHERE iose.[type_name] = 'Block2'
	END
	ELSE
	BEGIN
		UPDATE user_defined_fields_template
		SET sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
		WHERE Field_label = 'Block2'
	END

	IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Block3')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
		SELECT iose.value_id,
			   'Block3',
			   'd',
			   'VARCHAR(150)',
			   'n',
			   'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
			   'h',
			   NULL,
			   30,
			   iose.value_id
		FROM #insert_output_sdv_external iose
		WHERE iose.[type_name] = 'Block3'
	END
	ELSE
	BEGIN
		UPDATE user_defined_fields_template
		SET sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
		WHERE Field_label = 'Block3'
	END

	IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Block4')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
		SELECT iose.value_id,
			   'Block4',
			   'd',
			   'VARCHAR(150)',
			   'n',
			   'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
			   'h',
			   NULL,
			   30,
			   iose.value_id
		FROM #insert_output_sdv_external iose
		WHERE iose.[type_name] = 'Block4'
	END
	ELSE
	BEGIN
		UPDATE user_defined_fields_template
		SET sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
		WHERE  Field_label = 'Block4'
	END

	IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Block5')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
		SELECT iose.value_id,
			   'Block5',
			   'd',
			   'VARCHAR(150)',
			   'n',
			   'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
			   'h',
			   NULL,
			   30,
			   iose.value_id
		FROM #insert_output_sdv_external iose
		WHERE iose.[type_name] = 'Block5'
	END
	ELSE
	BEGIN
		UPDATE user_defined_fields_template
		SET sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
		WHERE Field_label = 'Block5'
	END

	IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Block6')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
		SELECT iose.value_id,
			   'Block6',
			   'd',
			   'VARCHAR(150)',
			   'n',
			   'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
			   'h',
			   NULL,
			   30,
			   iose.value_id
		FROM   #insert_output_sdv_external iose
		WHERE  iose.[type_name] = 'Block6'
	END
	ELSE
	BEGIN
		UPDATE user_defined_fields_template
		SET    sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
		WHERE  Field_label = 'Block6'
	END

	IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Cascade Granularity')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
		SELECT iose.value_id,
			   'Cascade Granularity',
			   'd',
			   'VARCHAR(150)',
			   'n',
			   'SELECT 1 AS [id], ''Annually'' [Name] UNION ALL SELECT 2, ''Quarterly'' UNION ALL SELECT 3, ''Seasonally''',
			   'h',
			   NULL,
			   30,
			   iose.value_id
		FROM #insert_output_sdv_external iose
		WHERE iose.[type_name] = 'Cascade Granularity'
	END
	ELSE
	BEGIN
		UPDATE user_defined_fields_template
		SET sql_string = 'SELECT 1 AS [id], ''Annually'' [Name] UNION ALL SELECT 2, ''Quarterly'' UNION ALL SELECT 3, ''Seasonally'''
		WHERE Field_label = 'Cascade Granularity'
	END

	IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Date')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
		SELECT iose.value_id,
			   'Date',
			   'a',
			   'VARCHAR(150)',
			   'n',
			   NULL,
			   'h',
			   NULL,
			   30,
			   iose.value_id
		FROM #insert_output_sdv_external iose
		WHERE  iose.[type_name] = 'Date'
	END
	ELSE
	BEGIN
		UPDATE user_defined_fields_template
		SET Field_type = 'a'
		WHERE Field_label = 'Date'
	END

	IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Deal Status')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
		SELECT iose.value_id,
			   'Deal Status',
			   'd',
			   'VARCHAR(150)',
			   'n',
			   'EXEC spa_StaticDataValues @flag=h, @type_id=5600',
			   'h',
			   NULL,
			   30,
			   iose.value_id
		FROM #insert_output_sdv_external iose
		WHERE  iose.[type_name] = 'Deal Status'
	END
	ELSE
	BEGIN
		UPDATE user_defined_fields_template
		SET Field_type = 'd',
			sql_string = 'EXEC spa_StaticDataValues @flag=h, @type_id=5600'
		WHERE Field_label = 'Deal Status'
	END

	IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Cascading')
	BEGIN
		UPDATE generic_mapping_header
		SET total_columns_used = 11
		WHERE mapping_name = 'Cascading'
	END
	ELSE 
	BEGIN 
		INSERT INTO generic_mapping_header (mapping_name, total_columns_used)
		VALUES ('Cascading', 11)
	END

	DECLARE @Index INT, @Venue INT, @Block1 INT, @Block2 INT, @Block3 INT, @Block4 INT, @Block5 INT, @Block6 INT, @Block7 INT, @Date INT, @Deal_Status INT

	SELECT @Index = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Index'
	SELECT @Venue = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Venue'
	SELECT @Block1 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Block1'
	SELECT @Block2 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Block2'
	SELECT @Block3 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Block3'
	SELECT @Block4 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Block4'
	SELECT @Block5 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Block5'
	SELECT @Block6 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Block6'
	SELECT @Block7 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Cascade Granularity'
	SELECT @Date = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Date'
	SELECT @Deal_Status = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Status'
 

	IF EXISTS (
		SELECT 1 
		FROM generic_mapping_definition gmd
		INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
		WHERE gmh.mapping_name = 'Cascading'
	)
	BEGIN
		UPDATE gmd
		SET clm2_label = 'Index', clm2_udf_id = @Index, clm1_label = 'Venue', clm1_udf_id = @Venue, clm3_label = 'Block1', clm3_udf_id = @Block1, clm4_label = 'Block2',
			clm4_udf_id = @Block2, clm5_label = 'Block3', clm5_udf_id = @Block3, clm6_label = 'Block4', clm6_udf_id = @Block4, clm7_label = 'Block5', clm7_udf_id = @Block5,
			clm8_label = 'Block6', clm8_udf_id = @Block6, clm9_label = 'Cascade Granularity', clm9_udf_id = @Block7, clm11_label = 'Date', clm11_udf_id = @Date, clm10_label = 'Deal Status',
			clm10_udf_id = @Deal_Status
		FROM generic_mapping_definition gmd
		INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
		WHERE gmh.mapping_name = 'Cascading'
	END
	ELSE
	BEGIN
		INSERT INTO generic_mapping_definition (
			mapping_table_id,
			clm2_label, clm2_udf_id,
			clm1_label, clm1_udf_id,
			clm3_label, clm3_udf_id,
			clm4_label, clm4_udf_id,
			clm5_label, clm5_udf_id,
			clm6_label, clm6_udf_id,
			clm7_label, clm7_udf_id,
			clm8_label, clm8_udf_id,
			clm9_label, clm9_udf_id,
			clm11_label, clm11_udf_id,
			clm10_label, clm10_udf_id
		)
		SELECT mapping_table_id, 'Index', @Index, 'Venue', @Venue, 'Block1', @Block1, 'Block2', @Block2,		
			   'Block3', @Block3, 'Block4', @Block4, 'Block5', @Block5, 'Block6', @Block6, 'Cascade Granularity', @Block7,
			   'Date', @Date, 'Deal Status',@Deal_Status
		FROM generic_mapping_header 
		WHERE mapping_name = 'Cascading'
	END

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
	PRINT ERROR_MESSAGE()
END CATCH
GO