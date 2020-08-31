/**
* inserting static data value Capacity based and Deal Volume based Daily fee.
**/

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18719)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18719,18700, 'Deal Volume based Daily fee', 'Deal Volume based Daily fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18719 - Deal Volume based Daily fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18719 - report category1 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18720)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18720,18700, 'Capacity based Daily fee', 'Capacity based Daily fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18720 - Capacity based Daily fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18720 - Capacity based Daily fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
