SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19307)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19307, 19300, 'Today', 'Today', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19307 - Today.'
END
ELSE
BEGIN
	PRINT 'Static data value 19307 - Today already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19308)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19308, 19300, 'Next Day', 'Next Day', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19308 - Next Day.'
END
ELSE
BEGIN
	PRINT 'Static data value 19308 - Next Day already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19309)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19309, 19300, 'Next Business Day', 'Next Business Day', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19309 - Next Business Day.'
END
ELSE
BEGIN
	PRINT 'Static data value 19309 - Next Business Day already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19310)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19310, 19300, 'Prior Day', 'Prior Day', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19310 - Prior Day.'
END
ELSE
BEGIN
	PRINT 'Static data value 19310 - Prior Day already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19311)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19311, 19300, 'Next Week', 'Next Week', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19311 - Next Week.'
END
ELSE
BEGIN
	PRINT 'Static data value 19311 - Next Week already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19312)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19312, 19300, 'Next Month', 'Next Month', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19312 - Next Month.'
END
ELSE
BEGIN
	PRINT 'Static data value 19312 - Next Month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19313)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19313, 19300, 'Next Quarter', 'Next Quarter', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19313 - Next Quarter.'
END
ELSE
BEGIN
	PRINT 'Static data value 19313 - Next Quarter already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19314)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19314, 19300, 'Next year', 'Next year', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19314 - Next year.'
END
ELSE
BEGIN
	PRINT 'Static data value 19314 - Next year already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
