SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5656)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5656, 5500, 'Convert UOM', 'Convert UOM', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5656 - Convert UOM.'
END
ELSE
BEGIN
	PRINT 'Static data value -5656 - Convert UOM already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


