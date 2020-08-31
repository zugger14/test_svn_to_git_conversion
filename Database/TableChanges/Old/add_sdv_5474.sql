SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5474)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5474, 5450, 'Imbalance_Volume', 'Imbalance Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5474 - Imbalance_Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value 5474 - Imbalance_Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
