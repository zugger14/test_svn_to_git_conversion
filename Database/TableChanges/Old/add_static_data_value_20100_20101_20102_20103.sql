/* 
Added by sbantawa@pioneerglobalsolution.com (24th May, 2012) 
Inserts static data value Credit Limit, Trader Limit, Scoring Model and Financial Model
*/

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20100)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20100, 20100, 'Credit Limit', 'Credit Limit', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20100 - Credit Limit.'
END
ELSE
BEGIN
	PRINT 'Static data value 20100 - Credit Limit already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20101)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20101, 20100, 'Trader Limit', 'Trader Limit', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20101 - Trader Limit.'
END
ELSE
BEGIN
	PRINT 'Static data value 20101 - Trader Limit already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20102)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20102, 20100, 'Scoring Model', 'Scoring Model', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20102 - Scoring Model.'
END
ELSE
BEGIN
	PRINT 'Static data value 20102 - Scoring Model already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20103)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20103, 20100, 'Financial Model', 'Financial Model', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20103 - Financial Model.'
END
ELSE
BEGIN
	PRINT 'Static data value 20103 - Financial Model already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF