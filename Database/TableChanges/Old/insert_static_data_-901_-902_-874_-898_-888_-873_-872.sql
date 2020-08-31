SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -901)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-901, 800, 'GetLogicalValue', 'GetLogicalValue', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -901 - GetLogicalValue.'
END
ELSE
BEGIN
	PRINT 'Static data value -901 - GetLogicalValue already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -902)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-902, 800, 'IsNull', 'Returns second arguments if first argument is null else returns first argument.', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -902 - IsNull.'
END
ELSE
BEGIN
	PRINT 'Static data value -902 - IsNull already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -874)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-874, 800, 'Curve15', 'Curve15', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -874 - Curve15.'
END
ELSE
BEGIN
	PRINT 'Static data value -874 - Curve15 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -898)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-898, 800, 'AverageQVol', 'AverageQVol', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -898 - AverageQVol.'
END
ELSE
BEGIN
	PRINT 'Static data value -898 - AverageQVol already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -888)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-888, 800, 'UDFDetailValue', 'UDFDetailValue', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -888 - UDFDetailValue.'
END
ELSE
BEGIN
	PRINT 'Static data value -888 - UDFDetailValue already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -873)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-873, 800, 'AverageYrlyPrice', 'AverageYrlyPrice', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -873 - AverageYrlyPrice.'
END
ELSE
BEGIN
	PRINT 'Static data value -873 - AverageYrlyPrice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -872)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-872, 800, 'AverageMnthlyPrice', 'AverageMnthlyPrice', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -872 - CptCollateral.'
END
ELSE
BEGIN
	PRINT 'Static data value -872 - AverageMnthlyPrice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF






