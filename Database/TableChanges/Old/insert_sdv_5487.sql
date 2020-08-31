SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5487)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5487, 5450, 'WREGIS_Import', 'WREGIS_Import', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5487 - WREGIS_Import.'
END
ELSE
BEGIN
	PRINT 'Static data value 5487 - WREGIS_Import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
