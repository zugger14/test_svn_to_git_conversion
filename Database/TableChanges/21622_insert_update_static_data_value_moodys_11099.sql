--select * from static_data_Value where type_id = 11099
--Moodys
--previously Aa
UPDATE static_data_value
    SET [code] = 'Aa1',
        [category_id] = NULL,
		[description] = 'Aa1'
    WHERE [value_id] = 10000223
PRINT 'Updated Static value 10000223 - Aa1.'        

--previously A
UPDATE static_data_value
    SET [code] = 'A1',
        [category_id] = NULL,
		[description] = 'A1'
    WHERE [value_id] = 10000224
PRINT 'Updated Static value 10000224 - A1.'        

--previously Baa
UPDATE static_data_value
    SET [code] = 'Baa1',
        [category_id] = NULL,
		[description] = 'Baa1'
    WHERE [value_id] = 10000225
PRINT 'Updated Static value 10000225 - Baa1.'        

--previously Ba
UPDATE static_data_value
    SET [code] = 'Ba1',
        [category_id] = NULL,
		[description] = 'Ba1'
    WHERE [value_id] = 10000226
PRINT 'Updated Static value 10000226 - Ba1.'        

--previously B
UPDATE static_data_value
    SET [code] = 'B1',
        [category_id] = NULL,
		[description] = 'B1'
    WHERE [value_id] = 10000227
PRINT 'Updated Static value 10000227 - B1.'        

--previously Caa
UPDATE static_data_value
    SET [code] = 'Caa1',
        [category_id] = NULL,
		[description] = 'Caa1'
    WHERE [value_id] = 10000228
PRINT 'Updated Static value 10000228 - Caa1.'        

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000268)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000268, 'Aa2', 'Aa2', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000268 - Aa2.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000268 - Aa2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000269)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000269, 'Aa3', 'Aa3', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000269 - Aa3.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000269 - Aa3 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000270)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000270, 'A2', 'A2', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000270 - A2.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000270 - A2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000271)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000271, 'A3', 'A3', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000271 - A3.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000271 - A3 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000272)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000272, 'Baa2', 'Baa2', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000272 - Baa2.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000272 - Baa2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000273)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000273, 'Baa3', 'Baa3', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000273 - Baa3.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000273 - Baa3 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000274)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000274, 'Ba2', 'Ba2', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000274 - Ba2.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000274 - Ba2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000275)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000275, 'Ba3', 'Ba3', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000275 - Ba3.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000275 - Ba3 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000276)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000276, 'B2', 'B2', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000276 - B2.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000276 - B2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000277)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000277, 'B3', 'B3', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000277 - B3.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000277 - B3 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000278)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000278, 'Caa2', 'Caa2', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000278 - Caa2.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000278 - Caa2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000279)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (11099, 10000279, 'Caa3', 'Caa3', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000279 - Caa3.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000279 - Caa3 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       
  