SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27308)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27308, 27300, 'Generation', 'Generation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27308 - Generation.'
END
ELSE
BEGIN
	PRINT 'Static data value 27308 - Generation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
