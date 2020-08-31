--Added Up K ID and K ID

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5634)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5634, 5500, 'Up K ID', 'Up K ID', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5634 - Up K ID.'
END
ELSE
BEGIN
	PRINT 'Static data value -5634 - Up K ID already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5635)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5635, 5500, 'K ID', 'K ID', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5635 - K ID.'
END
ELSE
BEGIN
	PRINT 'Static data value -5635 - K ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
