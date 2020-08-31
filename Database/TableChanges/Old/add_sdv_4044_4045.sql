SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4044)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4044, 4000, 'Trayport Interface', 'Trayport Interface', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4044 - Trayport Interface.'
END
ELSE
BEGIN
	PRINT 'Static data value 4044 - Trayport Interface already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4045)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4045, 4000, 'Nominator Request', 'Nominator Request', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4045 - Nominator Request.'
END
ELSE
BEGIN
	PRINT 'Static data value 4045 - Nominator Request already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
