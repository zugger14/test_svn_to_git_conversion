SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 4046)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4046, 4000, 'Shaped Hourly Data Import', 'Shaped Hourly Data Import', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4046 - Shaped Hourly Import.'
END
ELSE
BEGIN
	PRINT 'Static data value 4046 - Shaped Hourly Data Import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF