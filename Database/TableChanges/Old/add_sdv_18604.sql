SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18604)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18604, 18600, 'Minimum Working Gas Volume', 'Minimum Working Gas Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18604 - Minimum Working Gas Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value 18604 - Minimum Working Gas Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18603)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18603, 18600, 'Maximum Working Gas Volume', 'Maximum Working Gas Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18603 - Maximum Working Gas Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value 18603 - Maximum Working Gas Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


