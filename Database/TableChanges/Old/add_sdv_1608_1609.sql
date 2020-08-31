SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1608)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1608, 1600, 'Calendar Month Average', 'Calendar Month Average', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1608 - Calendar Month Average.'
END
ELSE
BEGIN
	PRINT 'Static data value 1608 - Calendar Month Average already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1609)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1609, 1600, 'Crude Trade Month Average', 'Crude Trade Month Average', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1609 - Crude Trade Month Average.'
END
ELSE
BEGIN
	PRINT 'Static data value 1609 - Crude Trade Month Average already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1610)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1610, 1600, 'Posted Price', 'Posted Price', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1610 - Posted Price.'
END
ELSE
BEGIN
	PRINT 'Static data value 1610 - Posted Price.'
END
SET IDENTITY_INSERT static_data_value OFF


--DELETE FROM static_data_value WHERE value_id IN(1605,1607,1600,1606,1601,1602,1603,1604) and type_id=1600

--select pricing,* from source_deal_header where pricing is not null
