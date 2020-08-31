SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4307)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4307, 4300, 'Hedging Documentation', 'Hedging Documentation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4307 - Hedging Documentation.'
END
ELSE
BEGIN
	PRINT 'Static data value 4307 - Hedging Documentation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
