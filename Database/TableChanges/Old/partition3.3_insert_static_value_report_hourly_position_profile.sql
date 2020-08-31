SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2180)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2180, 2175, 'report_hourly_position_profile', 'report hourly position profile', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2180 - report_hourly_position_profile.'
END
ELSE
BEGIN
	PRINT 'Static data value 2180 - report_hourly_position_profile already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
