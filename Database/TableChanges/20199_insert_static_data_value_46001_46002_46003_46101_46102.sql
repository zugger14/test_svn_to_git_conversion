SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46001)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46001, 46000, 'rprop+', 'rprop+', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46001 - rprop+.'
END
ELSE
BEGIN
    PRINT 'Static data value 46001 - rprop+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46002)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46002, 46000, 'rprop-', 'rprop-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46002 - rprop-.'
END
ELSE
BEGIN
    PRINT 'Static data value 46002 - rprop- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46003)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46003, 46000, 'backprop', 'backprop', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46003 - backprop.'
END
ELSE
BEGIN
    PRINT 'Static data value 46003 - backprop already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46101)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46101, 46100, 'ce', 'ce', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46101 - ce.'
END
ELSE
BEGIN
    PRINT 'Static data value 46101 - ce already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46102)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46102, 46100, 'sse', 'sse', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46102 - sse.'
END
ELSE
BEGIN
    PRINT 'Static data value 46102 - sse already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
