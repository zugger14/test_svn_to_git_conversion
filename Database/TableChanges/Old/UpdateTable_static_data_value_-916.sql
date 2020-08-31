SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -916)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-916, 800, 'GetCurveValue', 'Generic Function for Curve Price', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -916 - GetCurveValue.'
END
ELSE
BEGIN
	PRINT 'Static data value -916 - GetCurveValue already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF