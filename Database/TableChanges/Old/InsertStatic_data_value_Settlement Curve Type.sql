
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 18400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (18400, 'Settlement Curve Type', 1, 'Settlement Curve Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 18400 - Settlement Curve Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 18400 - Settlement Curve Type already EXISTS.'
END

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18400)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18400, 18400, 'Daily Settled', 'Daily Settled', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18400 - Daily Settled.'
END
ELSE
BEGIN
	PRINT 'Static data value 18400 - Daily Settled already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18401)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18401, 18400, 'Day Ahead Settled', 'Day Ahead Settled', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18401 - Day Ahead Settled.'
END
ELSE
BEGIN
	PRINT 'Static data value 18401 - Day Ahead Settled already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18402)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18402, 18400, 'Monthly Settled', 'Monthly Settled', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18402 - Monthly Settled.'
END
ELSE
BEGIN
	PRINT 'Static data value 18402 - Monthly Settled already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO



