IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 105200)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (105200, 'Collateral Status Type', 'Collateral Status Type', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 105200 - Collateral Status Type.'
END
ELSE
BEGIN
	UPDATE static_data_type SET [internal] = 1 WHERE [type_id] = 105200
    PRINT 'Static data type 105200 - updated to Internal.'
	DELETE FROM static_data_value WHERE [type_id] = 105200 
	 PRINT 'Deleted all Static Data value in Static data type 105200'
END            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105200)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105200, 105200, 'Approved', 'Approved', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105200 - Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value 105200 - Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105200)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105200, 105200, 'Approved', 'Approved', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105200 - Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value 105200 - Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105201)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105200, 105201, 'On Hold', 'On Hold', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105201 - On Hold.'
END
ELSE
BEGIN
    PRINT 'Static data value 105201 - On Hold already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105202)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105200, 105202, 'Unapproved', 'Unapproved', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105202 - Unapproved.'
END
ELSE
BEGIN
    PRINT 'Static data value 105202 - Unapproved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105203)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105200, 105203, 'New', 'New', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105203 - New.'
END
ELSE
BEGIN
    PRINT 'Static data value 105203 - New already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105204)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105200, 105204, 'Credit Analyst Approved', 'Credit Analyst Approved', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105204 - Credit Analyst Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value 105204 - Credit Analyst Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

------ SDT Limit Status -------

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105400)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105400, 105400, 'Approved', 'Approved', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105400 - Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value 105400 - Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105401)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105400, 105401, 'On Hold', 'On Hold', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105401 - On Hold.'
END
ELSE
BEGIN
    PRINT 'Static data value 105401 - On Hold already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105405)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105400, 105405, 'Unapproved', 'Unapproved', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105405 - Unapproved.'
END
ELSE
BEGIN
    PRINT 'Static data value 105405 - Unapproved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105406)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105400, 105406, 'New', 'New', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105406 - New.'
END
ELSE
BEGIN
    PRINT 'Static data value 105406 - New already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105407)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105400, 105407, 'Credit Analyst Approved', 'Credit Analyst Approved', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105407 - Credit Analyst Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value 105407 - Credit Analyst Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF