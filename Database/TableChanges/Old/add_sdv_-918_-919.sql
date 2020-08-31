SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -918)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-918, 800, 'WACOGWD', 'Returns WACOGWD for storage Deal', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -918 - WACOGWD.'
END
ELSE
BEGIN
	PRINT 'Static data value -918 - WACOGWD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -919)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-919, 800, 'WACOGLocPur', 'Returns WACOG Location Purchase price for injection Deal', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -919 - WACOGLocPur.'
END
ELSE
BEGIN
	PRINT 'Static data value -919 - WACOGLocPur already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

--select * from static_data_value where type_id=27400


IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = -918) 
BEGIN
	INSERT INTO map_function_category(category_id, function_id)
	VALUES(27401, -918)
END
ELSE
	PRINT 'Already Mapped'



IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = -919) 
BEGIN
	INSERT INTO map_function_category(category_id, function_id)
	VALUES(27401, -919)
END
ELSE
	PRINT 'Already Mapped'

