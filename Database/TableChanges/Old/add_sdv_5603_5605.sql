SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5603)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5603, 5600, 'Approved', 'Approved', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5604 - Approved.'
END
ELSE
BEGIN
	PRINT 'Static data value 5603 - Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5605)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5605, 5600, 'Draft', 'Draft', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5605 - Approved.'
END
ELSE
BEGIN
	PRINT 'Static data value 5605 - Draft already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF