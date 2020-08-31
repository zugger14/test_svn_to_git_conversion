SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 47)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (47, 25, 'Deal Required Documents', 'Deal Required Documents', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 47 - Deal Required Documents.'
END
ELSE
BEGIN
	PRINT 'Static data value 47 - Deal Required Documents already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF