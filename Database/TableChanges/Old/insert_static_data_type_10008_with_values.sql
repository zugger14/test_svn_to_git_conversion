/**
* inserting static data type 'Report Category' with static data values.
* sligal
* 10/03/2012
**/
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 10008)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (10008, 'Report Category', 0, 'Report Category', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 10008 - Report Category.'
END
ELSE
BEGIN
	PRINT 'Static data type 10008 - Report Category already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10008)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (10008, 10008, 'report category1', 'report category1', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 10008 - report category1.'
END
ELSE
BEGIN
	PRINT 'Static data value 10008 - report category1 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
