
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -862)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-862, 800, 'TotalVolume', 'This function returns Total Deal Volume for the passed Book Identifier', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -862 TotalVolume.'
END
ELSE
BEGIN
	PRINT 'Static data value -862 - TotalVolume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

