IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 42100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (42100, 'Alert Rule Component', 1, 'Alert Rule Component', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 42100 - Alert Rule Component.'
END
ELSE
BEGIN
	PRINT 'Static data type 42100 - Alert Rule Component already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42101)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (42101, 42100, 'Event Trigger', 'Event Trigger', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 42101 - Event Trigger.'
END
ELSE
BEGIN
	PRINT 'Static data value 42101 - Event Trigger already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42102)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (42102, 42100, 'Rule', 'Rule', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 42102 - Rule.'
END
ELSE
BEGIN
	PRINT 'Static data value 42102 - Rule already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42103)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (42103, 42100, 'Table Object', 'Table Object', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 42103 - Table Object.'
END
ELSE
BEGIN
	PRINT 'Static data value 42103 - Table Object already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42104)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (42104, 42100, 'AND Condition', 'AND Condition', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 42104 - AND Condition.'
END
ELSE
BEGIN
	PRINT 'Static data value 42104 - AND Condition already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42105)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (42105, 42100, 'OR Condition', 'OR Condition', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 42105 - OR Condition.'
END
ELSE
BEGIN
	PRINT 'Static data value 42105 - OR Condition already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42106)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (42106, 42100, 'Action', 'Action', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 42106 - Action.'
END
ELSE
BEGIN
	PRINT 'Static data value 42106 - Action already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42107)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (42107, 42100, 'Message', 'Message', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 42107 - Message.'
END
ELSE
BEGIN
	PRINT 'Static data value 42107 - Message already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42108)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42108, 42100, 'Condition Group', ' ', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42108 - Condition Group.'
END
ELSE
BEGIN
    PRINT 'Static data value 42108 - Condition Group already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF