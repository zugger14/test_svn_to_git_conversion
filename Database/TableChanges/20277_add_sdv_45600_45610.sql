/**
* inserting static data value Capacity based and Deal Volume based Daily fee.
**/

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45600)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45600,45600, 'Current Day', 'Current Day', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45600 - Current Day.'
END
ELSE
BEGIN
	PRINT 'Static data value 45600 - Current Day already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45601)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45601,45600, 'Current Business Day', 'Current Business Day', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45601 - Current Business Day.'
END
ELSE
BEGIN
	PRINT 'Static data value 45601 - Current Business Day already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45602)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45602,45600, 'First day of month', 'First day of month', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45602 - First day of month.'
END
ELSE
BEGIN
	PRINT 'Static data value 45602 - First day of month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45603)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45603,45600, 'Last Day of the Month', 'Last Day of the Month', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45603 - Last Day of the Month.'
END
ELSE
BEGIN
	PRINT 'Static data value 45603 - Last Day of the Month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45604)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45604,45600, 'First business day of month', 'First business day of month', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45604 - First business day of month.'
END
ELSE
BEGIN
	PRINT 'Static data value 45604 - First business day of month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45605)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45605,45600, 'Last business day of month', 'Last business day of month', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45605 - Last business day of month.'
END
ELSE
BEGIN
	PRINT 'Static data value 45605 - Last business day of month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45606)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45606,45600, 'First day of week', 'First day of week', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45606 - First day of week.'
END
ELSE
BEGIN
	PRINT 'Static data value 45606 - First day of week already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45607)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45607,45600, 'Last Day Of Week', 'Last Day Of Week', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45607 - Last Day Of Week.'
END
ELSE
BEGIN
	PRINT 'Static data value 45607 - Last Day Of Week already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45608)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45608,45600, 'First Business Day Of Week', 'First Business Day Of Week', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45608 - First Business Day Of Week.'
END
ELSE
BEGIN
	PRINT 'Static data value 45608 - First Business Day Of Week already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45609)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45609,45600, 'Last Business Day Of Week', 'Last Business Day Of Week', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45609 - Last Business Day Of Week.'
END
ELSE
BEGIN
	PRINT 'Static data value 45609 - Last Business Day Of Week already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45610)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45610,45600, 'Use report setting', 'Use report setting', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45610 - Use report setting.'
END
ELSE
BEGIN
	PRINT 'Static data value 45610 - Use report setting already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


