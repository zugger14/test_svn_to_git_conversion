/**
* adding static data type 'Portfolio Mapping Source' 24000 with static data values
* sligal
* 13th may 2013
**/

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 23200)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (23200, 'Portfolio Mapping Source', 1, 'Different Mapping Source for Portfolio', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 23200 - Portfolio Mapping Source.'
END
ELSE
BEGIN
	PRINT 'Static data type 23200 - Portfolio Mapping Source already EXISTS.'
END
	
-- inserting static data values	
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23200)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23200, 23200, 'Maintain Limit', 'Maintain Limit', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23200 - Maintain Limit.'
END
ELSE
BEGIN
	PRINT 'Static data value 23200 - Maintain Limit already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--inserting sdv whatif
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23201)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23201, 23200, 'Whatif', 'Whatif', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23201 - Whatif.'
END
ELSE
BEGIN
	PRINT 'Static data value 23201 - Whatif already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

	