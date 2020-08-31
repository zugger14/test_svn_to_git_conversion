SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2181)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2181, 2175, 'report_hourly_position_breakdown', 'report hourly position breakdown', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2181 - report_hourly_position_breakdown.'
END
ELSE
BEGIN
	PRINT 'Static data value 2181 - report_hourly_position_breakdown already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
