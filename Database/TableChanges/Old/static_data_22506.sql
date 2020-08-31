IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 22500)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (22500, 'Auto Pre-Post Test', 1, 'Auto Pre-Post Test', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 22500 - Auto Pre-Post Test.'
END
ELSE
BEGIN
	PRINT 'Static data type 22500 - Auto Pre-Post Test already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22500)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22500, 22500, 'Pre-Post Test MTM', 'Pre-Post Test MTM', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22500 - Pre-Post Test MTM.'
END
ELSE
BEGIN
	PRINT 'Static data value 22500 - Pre-Post Test MTM already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22501)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22501, 22500, 'Pre-Post Test Settlement', 'Pre-Post Test Settlement', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22501 - Pre-Post Test Settlement.'
END
ELSE
BEGIN
	PRINT 'Static data value 22501 - Pre-Post Test Settlement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22502)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22502, 22500, 'Pre-Post Test Position', 'Pre-Post Test Position', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22502 - Pre-Post Test Position.'
END
ELSE
BEGIN
	PRINT 'Static data value 22502 - Pre-Post Test Position already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22503)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22503, 22500, 'Pre-Post Test MTM Report', 'Pre-Post Test MTM Report', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22503 - Pre-Post Test MTM Report.'
END
ELSE
BEGIN
	PRINT 'Static data value 22503 - Pre-Post Test MTM Report already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22504)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22504, 22500, 'Hourly Position Report', 'Hourly Position Report', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22504 - Hourly Position Report.'
END
ELSE
BEGIN
	PRINT 'Static data value 22504 - Hourly Position Report already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22505)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22505, 22500, 'Index Position Report', 'Index Position Report', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22505 - Index Position Report.'
END
ELSE
BEGIN
	PRINT 'Static data value 22505 - Index Position Report already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22506)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22506, 22500, 'Load forecast report', 'Load forecast report', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22506 - Load forecast report.'
END
ELSE
BEGIN
	PRINT 'Static data value 22506 - Load forecast report already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22507)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22507, 22500, 'Options Report', 'Options Report', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22507 - Options Report.'
END
ELSE
BEGIN
	PRINT 'Static data value 22507 - Options Report already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22508)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22508, 22500, 'Explain', 'Explain', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22508 - Explain.'
END
ELSE
BEGIN
	PRINT 'Static data value 22508 - Explain already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
