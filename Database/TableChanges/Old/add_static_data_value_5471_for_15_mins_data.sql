SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5471)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5471, 5450, '15_Mins_Data', '15 Mins Data', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5471 - 15 Mins Data.'
END
ELSE
BEGIN
	PRINT 'Static data value 5471 - 15 Mins Data already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF