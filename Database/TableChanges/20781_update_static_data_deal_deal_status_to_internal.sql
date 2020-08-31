ALTER TABLE forecast_profile NOCHECK CONSTRAINT ALL
ALTER TABLE static_data_value NOCHECK CONSTRAINT ALL

DELETE FROM static_data_value WHERE [type_id] = 25000

UPDATE static_data_type 
SET internal = 1
WHERE [type_id] = 25000

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25000)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25000, 25000, 'Ready for Schedule', 'Ready for Schedule', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25000 - Ready for Schedule.'
END
ELSE
BEGIN
    PRINT 'Static data value 25000 - Ready for Schedule already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25001)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25001, 25000, 'Closed', 'Closed', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25001 - Closed.'
END
ELSE
BEGIN
    PRINT 'Static data value 25001 - Closed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25002)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25002, 25000, 'Forecast', 'Forecast', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25002 - Forecast.'
END
ELSE
BEGIN
    PRINT 'Static data value 25002 - Forecast already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25003)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25003, 25000, 'Actual', 'Actual', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25003 - Actual.'
END
ELSE
BEGIN
    PRINT 'Static data value 25003 - Actual already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25004)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25004, 25000, 'Certified', 'Certified', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25004 - Certified.'
END
ELSE
BEGIN
    PRINT 'Static data value 25004 - Certified already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25005)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25005, 25000, 'Compliance', 'Compliance', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25005 - Compliance.'
END
ELSE
BEGIN
    PRINT 'Static data value 25005 - Compliance already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25006)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25006, 25000, 'Transferred', 'Transferred', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25006 - Transferred.'
END
ELSE
BEGIN
    PRINT 'Static data value 25006 - Transferred already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25007)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25007, 25000, 'Generated', 'Generated', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25007 - Generated.'
END
ELSE
BEGIN
    PRINT 'Static data value 25007 - Generated already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25008)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25008, 25000, 'Contractual', 'Contractual', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25008 - Contractual.'
END
ELSE
BEGIN
    PRINT 'Static data value 25008 - Contractual already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25009)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25009, 25000, 'Invoiced', 'Invoiced', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25009 - Invoiced.'
END
ELSE
BEGIN
    PRINT 'Static data value 25009 - Invoiced already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25010)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25010, 25000, 'Open', 'Open', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25010 - Open.'
END
ELSE
BEGIN
    PRINT 'Static data value 25010 - Open already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25011)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25011, 25000, 'Ready for Invoice', 'Ready for Invoice', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25011 - Ready for Invoice.'
END
ELSE
BEGIN
    PRINT 'Static data value 25011 - Ready for Invoice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25012)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25012, 25000, 'Retired', 'Retired', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25012 - Retired.'
END
ELSE
BEGIN
    PRINT 'Static data value 25012 - Retired already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE fp 
SET fp.profile_type = 25002
FROM forecast_profile fp
WHERE fp.profile_type = 307504

ALTER TABLE forecast_profile CHECK CONSTRAINT ALL
ALTER TABLE static_data_value CHECK CONSTRAINT ALL