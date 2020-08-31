SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4053)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4053, 4000, 'source_broker', 'source_broker', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4053 - source_broker.'
END
ELSE
BEGIN
	PRINT 'Static data value 4053 - source_broker already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
