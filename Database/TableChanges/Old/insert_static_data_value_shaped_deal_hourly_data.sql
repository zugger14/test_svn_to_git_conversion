SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4037)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4037, 4000, 'Source_deal_detail_hour', 'Shaped Deal Houly Data', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4037 - Source_deal_detail_hour.'
END
ELSE
BEGIN
	PRINT 'Static data value 4037 - Source_deal_detail_hour already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5470)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5470, 5450, 'Shaped_deal_hourly_data', 'Shaped Deal Hourly Data', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5470 - Shaped_deal_hourly_data.'
END
ELSE
BEGIN
	PRINT 'Static data value 5470 - Shaped_deal_hourly_data already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	

