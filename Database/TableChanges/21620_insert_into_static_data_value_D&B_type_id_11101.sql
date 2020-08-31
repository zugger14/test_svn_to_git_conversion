--D&B
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000251)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000251, '5A', '5A', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000251 - 5A.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000251 - 5A already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000252)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000252, '4A', '4A', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000252 - 4A.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000252 - 4A already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000253)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000253, '3A', '3A', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000253 - 3A.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000253 - 3A already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000254)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000254, '2A', '2A', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000254 - 2A.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000254 - 2A already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000255)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000255, '1A', '1A', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000255 - 1A.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000255 - 1A already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000256)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000256, 'BA', 'BA', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000256 - BA.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000256 - BA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000257)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000257, 'BB', 'BB', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000257 - BB.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000257 - BB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000258)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000258, 'CB', 'CB', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000258 - CB.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000258 - CB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000259)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000259, 'CC', 'CC', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000259 - CC.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000259 - CC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000260)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000260, 'DC', 'DC', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000260 - DC.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000260 - DC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000261)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000261, 'DD', 'DD', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000261 - DD.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000261 - DD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000262)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000262, 'EE', 'EE', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000262 - EE.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000262 - EE already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000263)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000263, 'EF', 'EF', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000263 - EF.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000263 - EF already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000264)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000264, 'GG', 'GG', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000264 - GG.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000264 - GG already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000265)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000265, 'HH', 'HH', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000265 - HH.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000265 - HH already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000266)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000266, '1R', '1R', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000266 - 1R.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000266 - 1R already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000267)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11101, 10000267, '2R', '2R', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000267 - 2R.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000267 - 2R already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         