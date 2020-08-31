SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20519)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20519, 20500, 'Post - Outage Information Changed', 'Post - Outage Information Changed', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20519 - Post - Outage Information Changed.'
END
ELSE
BEGIN
	PRINT 'Static data value 20519 - Post - Outage Information Changed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
