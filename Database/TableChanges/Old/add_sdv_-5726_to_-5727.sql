SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5726)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5726, 5500, 'Link Transaction', 'Link Transaction', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5726 - Link Transaction.'
END
ELSE
BEGIN
	PRINT 'Static data value -5726 - Link Transaction already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5727)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5727, 5500, 'Invoice Date', 'Invoice Date', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5727 - Invoice Date.'
END
ELSE
BEGIN
	PRINT 'Static data value -5727 - Invoice Date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value SET code = 'Link Transaction', [description] = 'Link Transaction' WHERE [value_id] = -5726
PRINT 'Updated Static value -5726 - Link Transaction.'

UPDATE static_data_value SET code = 'Invoice Date', [description] = 'Invoice Date' WHERE [value_id] = -5727
PRINT 'Updated Static value -5727 - Invoice Date.'