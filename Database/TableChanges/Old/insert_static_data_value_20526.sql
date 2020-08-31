SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20526)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20526, 20500, 'Post SAP Export', 'Post SAP Export', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20526 - Post SAP Export.'
END
ELSE
BEGIN
	PRINT 'Static data value 20526 - Post SAP Export already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF