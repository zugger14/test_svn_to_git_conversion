SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5657)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5657, 5500, 'Margin Contract', 'Margin Contract', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5657 - Margin Contract.'
END
ELSE
BEGIN
	PRINT 'Static data value -5657 - Margin Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF