IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 44500)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (44500, 'Generator Data Type', 1, 'Generator Data Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 44500 - Generator Data Type.'
END
ELSE
BEGIN

	UPDATE static_data_type
	SET [type_name] = 'Generator Data Type',
		[description] = 'Generator Data Type',
		internal = 1
		WHERE [type_id] = 44500
	PRINT 'Updated static data type 44500 - Generator Data Type.'

END



IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44500)
BEGIN

	SET IDENTITY_INSERT static_data_value ON
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44500, 44500, 'Contractual Unit Min', ' Contractual Unit Min', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44500 - Contractual Unit Min.'
	SET IDENTITY_INSERT static_data_value OFF

END
ELSE
BEGIN
    UPDATE static_data_value
    SET code = 'Contractual Unit Min',
    [category_id] = ''
    WHERE [value_id] = 44500
	
	PRINT 'Updated Static value 44500 - Contractual Unit Min.'
END



IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44501)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44501, 44500, 'OM1', ' Operation and Management Cost1.', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44501 - O n M 1.'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	UPDATE static_data_value
		SET code = 'OM1',
		[category_id] = ''
		WHERE [value_id] = 44501
	PRINT 'Updated Static value 44501 - O n M 1.'

END



IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44502)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44502, 44500, 'OM2', ' Operation and Management Cost2.', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44502 - OM2.'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	UPDATE static_data_value
		SET code = 'OM2',
		[category_id] = ''
		WHERE [value_id] = 44502
	PRINT 'Updated Static value 44502 - OM2.'

END



IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44503)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44503, 44500, 'OM3', ' Operation and Management Cost3.', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44503 - OM3'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	UPDATE static_data_value
		SET code = 'OM3',
		[category_id] = ''
		WHERE [value_id] = 44503
	PRINT 'Updated Static value 44503 - OM3.'

END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44504)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44504, 44500, 'OM4', ' Operation and Management Cost4.', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44504 -OM4.'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	UPDATE static_data_value
		SET code = 'OM4',
		[category_id] = ''
		WHERE [value_id] = 44504
	PRINT 'Updated Static value 44504 -OM4.'

END


--IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44505)
--BEGIN
--	SET IDENTITY_INSERT static_data_value ON
--    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
--    VALUES (44505, 44500, 'Online Indicator', 'Online Indicator.', '', 'farrms_admin', GETDATE())
--    PRINT 'Inserted static data value 44505 - Online Indicator.'
--	SET IDENTITY_INSERT static_data_value OFF
--END
--ELSE
--BEGIN
--	UPDATE static_data_value
--		SET code = 'Online Indicator',
--		[category_id] = ''
--		WHERE [value_id] = 44505
--	PRINT 'Updated Static value 44505 - Online Indicator.'

--END


--IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44506)
--BEGIN
--	SET IDENTITY_INSERT static_data_value ON
--    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
--    VALUES (44506, 44500, 'Must Run Indicator', ' Must Run Indicator.', '', 'farrms_admin', GETDATE())
--    PRINT 'Inserted static data value 44506 - Must Run Indicator.'
--	SET IDENTITY_INSERT static_data_value OFF
--END
--ELSE
--BEGIN
--	UPDATE static_data_value
--		SET code = 'Must Run Indicator',
--		[category_id] = ''
--		WHERE [value_id] = 44506
--	PRINT 'Updated Static value 44506 - Must Run Indicator.'

--END

	
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44507)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44507, 44500, 'Operation Limit Constraints', 'Operation Limit Constraints.', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44507 - Operation Limit Constraints.'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	UPDATE static_data_value
		SET code = 'Operation Limit Constraints',
		[category_id] = ''
	WHERE [value_id] = 44507
	PRINT 'Updated Static value 44507 - Operation Limit Constraints.'

END



IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44508)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44508, 44500, 'Seasonal Variations', 'Seasonal Variations.', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44508 - Seasonal Variations.'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	UPDATE static_data_value
		SET code = 'Seasonal Variations',
		[category_id] = ''
		WHERE [value_id] = 44508
	PRINT 'Updated Static value 44508 - Seasonal Variations.'

END



--IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44509)
--BEGIN
--	SET IDENTITY_INSERT static_data_value ON
--    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
--    VALUES (44509, 44500, 'Fuel Type', 'Fuel Type.', '', 'farrms_admin', GETDATE())
--    PRINT 'Inserted static data value 44509 - Fuel Type.'
--	SET IDENTITY_INSERT static_data_value OFF
--END
--ELSE
--BEGIN
--	UPDATE static_data_value
--		SET code = 'Fuel Type',
--		[category_id] = ''
--		WHERE [value_id] = 44509
--	PRINT 'Updated Static value 44509 -  Fuel Type.'

--END
