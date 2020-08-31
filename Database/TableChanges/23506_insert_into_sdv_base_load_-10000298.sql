IF EXISTS(SELECT 1 FROM static_data_value WHERE code = 'Base Load')
BEGIN
	DECLARE @base_load_old INT

	SELECT @base_load_old = value_id FROM static_data_value WHERE code = 'Base Load'

	--Insert New base load with differnet name not to get engaged in unique key constraint
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000298)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (10018, -10000298, 'Base Loads', 'Base Load', NULL, 'farrms_admin', GETDATE())
		PRINT 'Inserted static data value -10000298 - Base Load.'
	END
	ELSE
	BEGIN
		PRINT 'Static data value -10000298 - Base Load already EXISTS.'
	END
	SET IDENTITY_INSERT static_data_value OFF

	--Update block_define_id in source_price_curve_def, source_deal_header with new sdv for base load
	UPDATE source_price_curve_def SET block_define_id = -10000298 WHERE block_define_id = @base_load_old
	UPDATE source_deal_header SET block_define_id = -10000298 WHERE block_define_id = @base_load_old
	UPDATE block_type_group SET block_type_group_id = -10000298 WHERE block_type_group_id = @base_load_old
	UPDATE block_type_group SET hourly_block_id = -10000298 WHERE hourly_block_id = @base_load_old
	UPDATE hourly_block SET block_value_id = -10000298 WHERE block_value_id = @base_load_old
END
ELSE
BEGIN
	--Insert New base load with differnet name not to get engaged in unique key constraint
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000298)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (10018, -10000298, 'Base Loads', 'Base Load', NULL, 'farrms_admin', GETDATE())
		PRINT 'Inserted static data value -10000298 - Base Load.'
	END
	ELSE
	BEGIN
		PRINT 'Static data value -10000298 - Base Load already EXISTS.'
	END
	SET IDENTITY_INSERT static_data_value OFF
END

IF EXISTS(SELECT 1 FROM static_data_value WHERE code = 'Base Load')
BEGIN
	IF EXISTS(SELECT 1 FROM static_data_value WHERE code = 'Base Loads')
	BEGIN
		--delete old id and update name to 'Base Load' to new id
		DELETE FROM static_data_value WHERE value_id  = @base_load_old
	END
END

UPDATE static_data_value SET code = 'Base Load' where value_id = -10000298

--repopulate table hour_block_term with new id
EXEC spa_generate_hour_block_term null,2000,2030
