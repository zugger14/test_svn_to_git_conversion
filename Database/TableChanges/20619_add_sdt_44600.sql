IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 44600)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (44600, 'Workflow Icons', 1, 'Workflow Icons', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 44600 - Workflow Icons.'
END
ELSE
BEGIN
	PRINT 'Static data type 44600 - Workflow Icons already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44608)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44608, 44600, 'Weather_data', ' Weather Data', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44608 - Weather_data.'
END
ELSE
BEGIN
    PRINT 'Static data value 44608 - Weather_data already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44607)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44607, 44600, 'User_and_role', ' User and Role', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44607 - User_and_role.'
END
ELSE
BEGIN
    PRINT 'Static data value 44607 - User_and_role already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44606)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44606, 44600, 'Setup', ' Setup', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44606 - Setup.'
END
ELSE
BEGIN
    PRINT 'Static data value 44606 - Setup already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44605)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44605, 44600, 'Reporting', ' Reporting', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44605 - Reporting.'
END
ELSE
BEGIN
    PRINT 'Static data value 44605 - Reporting already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44604)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44604, 44600, 'Price_Curve', ' Price Curve', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44604 - Price_Curve.'
END
ELSE
BEGIN
    PRINT 'Static data value 44604 - Price_Curve already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44603)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44603, 44600, 'Nomination', ' Nomination', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44603 - Nomination.'
END
ELSE
BEGIN
    PRINT 'Static data value 44603 - Nomination already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44602)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44602, 44600, 'Deal', ' Deal', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44602 - Deal.'
END
ELSE
BEGIN
    PRINT 'Static data value 44602 - Deal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44601)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44601, 44600, 'Accounting', ' Accounting', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44601 - Accounting.'
END
ELSE
BEGIN
    PRINT 'Static data value 44601 - Accounting already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44600)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44600, 44600, 'Admin', 'Admin', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44600 - admin.'
END
ELSE
BEGIN
    PRINT 'Static data value 44600 - admin already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF