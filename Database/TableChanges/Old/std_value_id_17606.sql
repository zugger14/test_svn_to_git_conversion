SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17606)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17606, 17600, 'Cumulative Month Expiration', 'Cumulative Month Expiration', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17606 - Cumulative Month Expiration.'
END
ELSE
BEGIN
	PRINT 'Static data value 17606 - Cumulative Month Expiration already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
