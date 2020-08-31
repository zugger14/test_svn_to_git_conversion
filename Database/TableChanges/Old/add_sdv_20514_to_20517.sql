SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20514)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20514, 20500, 'Pre Import', 'Pre Import', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20514 - Pre Import.'
END
ELSE
BEGIN
	PRINT 'Static data value 20514 - Pre Import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20515)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20515, 20500, 'Post Import', 'Post Import', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20515 - Post Import.'
END
ELSE
BEGIN
	PRINT 'Static data value 20515 - Post Import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20516)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20516, 20500, 'Pre Export', 'Pre Export', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20516 - Pre Export.'
END
ELSE
BEGIN
	PRINT 'Static data value 20516 - Pre Export already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20517)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20517, 20500, 'Post Export', 'Post Export', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20517 - Post Export.'
END
ELSE
BEGIN
	PRINT 'Static data value 20517 - Post Export already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
