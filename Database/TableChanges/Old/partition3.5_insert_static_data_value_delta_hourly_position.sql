SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2182)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2182, 2175, 'delta_report_hourly_position', 'Delta report hourly position', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2182 - delta_report_hourly_position.'
END
ELSE
BEGIN
	PRINT 'Static data value 2182 - delta_report_hourly_position already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
