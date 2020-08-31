SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23203)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23203, 23200, 'Risk Measurement', 'Risk Measurement', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23203 - Risk Measurement.'
END
ELSE
BEGIN
	PRINT 'Static data value 23203 - Risk Measurement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
