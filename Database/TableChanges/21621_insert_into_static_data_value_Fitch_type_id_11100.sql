SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000231)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000231, 'AAA', 'AAA', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000231 - AAA.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000231 - AAA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000232)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000232, 'AA+', 'AA+', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000232 - AA+.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000232 - AA+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000233)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000233, 'AA', 'AA', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000233 - AA.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000233 - AA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000234)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000234, 'AA-', 'AA-', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000234 - AA-.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000234 - AA- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000235)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000235, 'A+', 'A+', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000235 - A+.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000235 - A+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000236)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000236, 'A', 'A', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000236 - A.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000236 - A already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000237)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000237, 'A-', 'A-', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000237 - A-.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000237 - A- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000238)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000238, 'BBB+', 'BBB+', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000238 - BBB+.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000238 - BBB+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000239)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000239, 'BBB', 'BBB', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000239 - BBB.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000239 - BBB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000240)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000240, 'BBB-', 'BBB-', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000240 - BBB-.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000240 - BBB- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000241)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000241, 'BB+', 'BB+', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000241 - BB+.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000241 - BB+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000242)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000242, 'BB', 'BB', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000242 - BB.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000242 - BB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000243)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000243, 'BB-', 'BB-', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000243 - BB-.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000243 - BB- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000244)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000244, 'B+', 'B+', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000244 - B+.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000244 - B+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000245)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000245, 'B', 'B', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000245 - B.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000245 - B already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000246)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000246, 'B-', 'B-', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000246 - B-.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000246 - B- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000247)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000247, 'CCC', 'CCC', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000247 - CCC.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000247 - CCC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000248)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000248, 'DDD', 'DDD', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000248 - DDD.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000248 - DDD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000249)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000249, 'DD', 'DD', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000249 - DD.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000249 - DD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000250)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11100, 10000250, 'D', 'D', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000250 - D.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000250 - D already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF   
