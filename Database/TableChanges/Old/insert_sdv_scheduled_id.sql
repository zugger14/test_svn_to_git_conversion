SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5607)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5607, 5500, 'Scheduled ID', 'Scheduled ID', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5607 - Scheduled ID.'
END
ELSE
BEGIN
	PRINT 'Static data value -5607 - Scheduled ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
