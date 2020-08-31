SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 872)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (872, 800, 'PriceCurve', 'Function to get the Price curve value', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 872 - PriceCurve.'
END
ELSE
BEGIN
	PRINT 'Static data value 872 - PriceCurve already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF