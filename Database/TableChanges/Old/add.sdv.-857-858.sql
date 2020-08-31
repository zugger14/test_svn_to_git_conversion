-- inserting the static data value for the 'PrevEvents'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -857)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-857, 800, 'PrevEvents', 'PrevEvents', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -857 - PrevEvents.'
END
ELSE
BEGIN
	PRINT 'Static data value -857 - PrevEvents already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -858)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-858, 800, 'EODHours', 'EODHours', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -858 - EODHours.'
END
ELSE
BEGIN
	PRINT 'Static data value -858 - EODHours already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF