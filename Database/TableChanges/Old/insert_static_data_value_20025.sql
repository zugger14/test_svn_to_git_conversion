SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20025)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20025, 20000, 'End of Delivery Month', 'End of Delivery Month', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20025 - End of Delivery Month.'
END
ELSE
BEGIN
	PRINT 'Static data value 20025 - End of Delivery Month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF