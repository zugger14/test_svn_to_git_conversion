SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39101)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39101, 39100, 'Point-Point', 'Point-Point', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39101 - Point-Point.'
END
ELSE
BEGIN
	PRINT 'Static data value 39101 - Point-Point already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39102)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39102, 39100, 'Point-Zone', 'Point-Zone', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39102 - Point-Zone.'
END
ELSE
BEGIN
	PRINT 'Static data value 39102 - Point-Zone already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39103)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39103, 39100, 'Zone-Point', 'Zone-Point', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39103 - Zone-Point.'
END
ELSE
BEGIN
	PRINT 'Static data value 39103 - Zone-Point already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39104)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39104, 39100, 'Zone-Zone', 'Zone-Zone', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39104 - Zone-Zone.'
END
ELSE
BEGIN
	PRINT 'Static data value 39104 - Zone-Zone already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
