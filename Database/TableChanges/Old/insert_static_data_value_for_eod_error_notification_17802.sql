SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17802)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17802, 17800, 'EOD Error Notification', 'EOD Error Notification', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17802 - EOD Error Notification.'
END
ELSE
BEGIN
	PRINT 'Static data value 17802 - EOD Error Notification already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF