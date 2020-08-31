/**
* add and update static data values for static data type 'Limit Type' 1580
**/
UPDATE static_data_value SET code = 'Position and Tenor', [description] = 'Position and Tenor' WHERE [value_id] = 1581
PRINT 'Updated Static value 1581 - Position and Tenor.'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1587)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1587, 1580, 'Tenor limit', 'Tenor limit', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1587 - Tenor limit.'
END
ELSE
BEGIN
	PRINT 'Static data value 1587 - Tenor limit already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1588)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1588, 1580, 'Position limit', 'Position limit', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1588 - Position limit.'
END
ELSE
BEGIN
	PRINT 'Static data value 1588 - Position limit already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



