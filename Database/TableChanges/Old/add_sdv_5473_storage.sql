SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5473)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5473, 5450, 'Storage_Schedule_Import', 'Storage Schedule Import', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5473 -Storage Schedule Import.'
END
ELSE
BEGIN
	PRINT 'Static data value 5473 - Storage Schedule Import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
