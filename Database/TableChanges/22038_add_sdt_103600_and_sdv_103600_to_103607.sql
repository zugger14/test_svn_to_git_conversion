IF NOT EXISTS (SELECT 1 FROM static_data_type WHERE [type_id] = 103600)
BEGIN
	INSERT INTO static_data_type ([type_id], [type_name], [internal], [description], [is_active])
	VALUES (103600, 'Complex Pricing Type', 1 , 'Complex Pricing Type', 1)
END
ELSE
BEGIN
	UPDATE static_data_type
	SET [type_name] = 'Complex Pricing Type',
		[internal] = 1,
		[description] = 'Complex Pricing Type',
		[is_active] = 1
	WHERE [type_id] = 103600
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 103607)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], [code], [description])
	VALUES (103607, 103600, 'Adjustment', 'Adjustment')
END
ELSE
BEGIN
	UPDATE static_data_value
	SET code = 'Adjustment',
		[description] = 'Adjustment'
	WHERE value_id = 103607
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 103605)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], [code], [description])
	VALUES (103605, 103600, 'Custom Event', 'Custom Event')
END
ELSE
BEGIN
	UPDATE static_data_value
	SET code = 'Custom Event',
		[description] = 'Custom Event'
	WHERE value_id = 103605
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [value_id] = 103604)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], [code], [description])
	VALUES (103604, 103600, 'Fixed Cost', 'Fixed Cost')
END
ELSE
BEGIN
	UPDATE static_data_value
	SET code = 'Fixed Cost',
		[description] = 'Fixed Cost'
	WHERE value_id = 103604
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [value_id] = 103600)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], [code], [description])
	VALUES (103600, 103600, 'Fixed Price', 'Fixed Price')
END
ELSE
BEGIN
	UPDATE static_data_value
	SET code = 'Fixed Price',
		[description] = 'Fixed Price'
	WHERE value_id = 103600
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [value_id] = 103602)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], [code], [description])
	VALUES (103602, 103600, 'Formula', 'Formula')
END
ELSE
BEGIN
	UPDATE static_data_value
	SET code = 'Formula',
		[description] = 'Formula'
	WHERE value_id = 103602
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [value_id] = 103601)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], [code], [description])
	VALUES (103601, 103600, 'Indexed', 'Indexed')
END
ELSE
BEGIN
	UPDATE static_data_value
	SET code = 'Indexed',
		[description] = 'Indexed'
	WHERE value_id = 103601
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [value_id] = 103606)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], [code], [description])
	VALUES (103606, 103600, 'Pre-defined Formula', 'Pre-defined Formula')
END
ELSE
BEGIN
	UPDATE static_data_value
	SET code = 'Pre-defined Formula',
		[description] = 'Pre-defined Formula'
	WHERE value_id = 103606
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [value_id] = 103603)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], [code], [description])
	VALUES (103603, 103600, 'Standard Event', 'Event')
END
ELSE
BEGIN
	UPDATE static_data_value
	SET code = 'Standard Event',
		[description] = 'Standard Event'
	WHERE value_id = 103603
END
SET IDENTITY_INSERT static_data_value OFF
