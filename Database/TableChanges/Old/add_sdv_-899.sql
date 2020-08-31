SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -899)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-899, 800, 'AverageQtrDailyPrice', 'AverageQtrDailyPrice', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -899 - AverageQtrDailyPrice.'
END
ELSE
BEGIN
	PRINT 'Static data value -899 - AverageQtrDailyPrice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


