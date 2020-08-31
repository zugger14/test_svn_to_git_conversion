SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21305)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21305, 21300, 'Download', 'Download', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21305 - Download.'
END
ELSE
BEGIN
	PRINT 'Static data value 21305 - Download already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
