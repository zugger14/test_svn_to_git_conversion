SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300000)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (300000, 5500, 'Index', 'Index')
	PRINT 'Inserted'
END
ELSE
BEGIN
	PRINT 'Already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300001)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (300001, 5500, 'Tenor Bucket', 'Tenor Bucket')
	PRINT 'Inserted'
END
ELSE
BEGIN
	PRINT 'Already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300002)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (300002, 5500, 'Projection Index Group', 'Projection Index Group')
	PRINT 'Inserted'
END
ELSE
BEGIN
	PRINT 'Already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300003)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (300003, 5500, 'UOM From', 'UOM From')
	PRINT 'Inserted'
END
ELSE
BEGIN
	PRINT 'Already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300004)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (300004, 5500, 'UOM To', 'UOM To')
	PRINT 'Inserted'
END
ELSE
BEGIN
	PRINT 'Already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300005)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (300005, 5500, 'Ice Trader', 'Ice Trader')
	PRINT 'Inserted'
END
ELSE
BEGIN
	PRINT 'Already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300006)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (300006, 5500, 'TRM Trader', 'TRM Trader')
	PRINT 'Inserted'
END
ELSE
BEGIN
	PRINT 'Already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300007)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (300007, 5500, 'Ice Broker', 'Ice Broker')
	PRINT 'Inserted'
END
ELSE
BEGIN
	PRINT 'Already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300008)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (300008, 5500, 'TRM Broker', 'TRM Broker')
	PRINT 'Inserted'
END
ELSE
BEGIN
	PRINT 'Already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300009)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (300009, 5500, 'Ice Counterparty', 'Ice Counterparty')
	PRINT 'Inserted'
END
ELSE
BEGIN
	PRINT 'Already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300010)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (300010, 5500, 'TRM Counterparty', 'TRM Counterparty')
	PRINT 'Inserted'
END
ELSE
BEGIN
	PRINT 'Already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
