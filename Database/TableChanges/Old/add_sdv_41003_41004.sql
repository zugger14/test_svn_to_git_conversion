SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 41003)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (41003, 41000, 'ID3', 'ID3', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 41003 - ID3.'
END
ELSE
BEGIN
	PRINT 'Static data value 41003 - ID3 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 41004)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (41004, 41000, 'ID4', 'ID4', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 41004 - ID4.'
END
ELSE
BEGIN
	PRINT 'Static data value 41004 - ID4 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
