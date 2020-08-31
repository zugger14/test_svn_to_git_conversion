SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1603)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1603, 1600, 'Daily Weighted Avg', 'Daily Weighted Avg', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1603 - Daily Weighted Avg.'
END
ELSE
BEGIN
	PRINT 'Static data value 1603 - Daily Weighted Avg already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

