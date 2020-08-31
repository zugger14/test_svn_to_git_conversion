SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2163)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2163, 2150, 'MTM Reporting', 'MTM Reporting', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2163 - MTM Reporting.'
END
ELSE
BEGIN
	PRINT 'Static data value 2163 - MTM Reporting already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
