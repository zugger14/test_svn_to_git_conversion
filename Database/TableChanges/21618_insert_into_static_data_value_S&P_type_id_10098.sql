---insert new internal static_Data_value
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000200)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000200, 'AAA', 'AAA', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000200 - AAA.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000200 - AAA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000201)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000201, 'AA+', 'AA+', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000201 - AA+.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000201 - AA+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF        

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000202)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000202, 'AA', 'AA', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000202 - AA.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000202 - AA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000203)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000203, 'AA-', 'AA-', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000203 - AA-.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000203 - AA- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000204)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000204, 'A+', 'A+', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000204 - A+.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000204 - A+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000205)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000205, 'A', 'A', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000205 - A.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000205 - A already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF  
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000206)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000206, 'A-', 'A-', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000206 - A-.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000206 - A- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000207)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000207, 'BBB+', 'BBB+', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000207 - BBB+.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000207 - BBB+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000208)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000208, 'BBB', 'BBB', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000208 - BBB.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000208 - BBB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000209)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000209, 'BBB-', 'BBB-', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000209 - BBB-.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000209 - BBB- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000210)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000210, 'BB+', 'BB+', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000210 - BB+.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000210 - BB+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000211)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000211, 'BB', 'BB', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000211 - BB.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000211 - BB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000212)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000212, 'BB-', 'BB-', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000212 - BB-.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000212 - BB- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000213)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000213, 'B+', 'B+', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000213 - B+.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000213 - B+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
    

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000214)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000214, 'B', 'B', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000214 - B.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000214 - B already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000215)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000215, 'B-', 'B-', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000215 - B-.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000215 - B- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000216)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000216, 'CCC+', 'CCC+', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000216 - CCC+.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000216 - CCC+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000217)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000217, 'CCC', 'CCC', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000217 - CCC.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000217 - CCC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000218)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000218, 'CCC-', 'CCC-', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000218 - CCC-.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000218 - CCC- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000219)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000219, 'CC', 'CC', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000219 - CC.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000219 - CC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000220)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000220, 'C', 'C', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000220 - C.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000220 - C already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000221)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10098, 10000221, 'D', 'D', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000221 - D.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000221 - D already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      