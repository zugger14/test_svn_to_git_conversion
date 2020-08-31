SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22509)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22509, 22500, 'Other Pre-Post Report', 'Other Pre-Post Report', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22509 - Other Pre-Post Report.'
END
ELSE
BEGIN
	PRINT 'Static data value 22509 - Other Pre-Post Report already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22510)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22510, 22500, 'Other Pre-Post Table', 'Other Pre-Post Table', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22510 - Other Pre-Post Table.'
END
ELSE
BEGIN
	PRINT 'Static data value 22510 - Other Pre-Post Table already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
