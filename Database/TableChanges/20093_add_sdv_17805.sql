SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17805)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17805, 17800, 'Data Import Notification', 'Data Import Notification', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17805 - Data Import Notification'
END
ELSE
BEGIN
	PRINT 'Static data value 17805 - Data Import Notification already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF






