SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 298008)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (298008, 800, 'DaysInPeriod', 'Returns number of days in a period', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 298008 - DaysInPeriod.'
END
ELSE
BEGIN
	PRINT 'Static data value 298008 - DaysInPeriod already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF