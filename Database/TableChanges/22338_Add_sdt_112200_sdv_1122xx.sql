IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 112200)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (112200, 'Import Filter', 'Import Filter', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 112200 - Import Filter.'
END
ELSE
BEGIN
    PRINT 'Static data type 112200 - Import Filter already EXISTS.'
END            

UPDATE static_data_type
SET [type_name] = 'Import Filter',
    [description] = 'Import Filter',
    [internal] = 1, 
    [is_active] = 1
WHERE [type_id] = 112200
PRINT 'Updated static data type 112200 - Import Filter.'     



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112200)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112200, 'From', 'From', 21409, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112200 - From.'
END
ELSE
BEGIN
    PRINT 'Static data value 112200 - From already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'From',
        [category_id] = 21409,
        [description] = 'From'
    WHERE [value_id] = 112200
PRINT 'Updated Static value 112200 - From.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112201)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112201, 'Subject Contains', 'Subject Contains', 21409, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112201 - Subject Contains.'
END
ELSE
BEGIN
    PRINT 'Static data value 112201 - Subject Contains already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'Subject Contains',
        [category_id] = 21409,
        [description] = 'Subject Contains'
    WHERE [value_id] = 112201
PRINT 'Updated Static value 112201 - Subject Contains.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112202)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112202, 'Body Contains', 'Body Contains', 21409, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112202 - Body Contains.'
END
ELSE
BEGIN
    PRINT 'Static data value 112202 - Body Contains already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'Body Contains',
        [category_id] = 21409,
        [description] = 'Body Contains'
    WHERE [value_id] = 112202
PRINT 'Updated Static value 112202 - Body Contains.'            



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112203)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112203, 'With Send To', 'With Send To', 21409, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112203 - With Send To.'
END
ELSE
BEGIN
    PRINT 'Static data value 112203 - With Send To already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


UPDATE static_data_value
    SET [code] = 'With Send To',
        [category_id] = 21409,
        [description] = 'With Send To'
    WHERE [value_id] = 112203
PRINT 'Updated Static value 112203 - With Send To.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112204)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112204, 'With CC', 'With CC', 21409, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112204 - With CC.'
END
ELSE
BEGIN
    PRINT 'Static data value 112204 - With CC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


UPDATE static_data_value
    SET [code] = 'With CC',
        [category_id] = 21409,
        [description] = 'With CC'
    WHERE [value_id] = 112204
PRINT 'Updated Static value 112204 - With CC.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112205)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112205, 'With BCC', 'With BCC', 21409, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112205 - With BCC.'
END
ELSE
BEGIN
    PRINT 'Static data value 112205 - With BCC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


UPDATE static_data_value
    SET [code] = 'With BCC',
        [category_id] = 21409,
        [description] = 'With BCC'
    WHERE [value_id] = 112205
PRINT 'Updated Static value 112205 - With BCC.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112206)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112206, 'With attachment file size', 'With attachment file size', 21409, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112206 - With attachment file size.'
END
ELSE
BEGIN
    PRINT 'Static data value 112206 - With attachment file size already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


UPDATE static_data_value
    SET [code] = 'With attachment file size',
        [category_id] = 21409,
        [description] = 'With attachment file size'
    WHERE [value_id] = 112206
PRINT 'Updated Static value 112206 - With attachment file size.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112207)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112207, 'With attachment file size less than', 'With attachment file size less than', 21409, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112207 - With attachment file size less than.'
END
ELSE
BEGIN
    PRINT 'Static data value 112207 - With attachment file size less than already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


UPDATE static_data_value
    SET [code] = 'With attachment file size less than',
        [category_id] = 21409,
        [description] = 'With attachment file size less than'
    WHERE [value_id] = 112207
PRINT 'Updated Static value 112207 - With attachment file size less than.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112208)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112208, 'With attachment file size more than', 'With attachment file size more than', 21409, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112208 - With attachment file size more than.'
END
ELSE
BEGIN
    PRINT 'Static data value 112208 - With attachment file size more than already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            



UPDATE static_data_value
    SET [code] = 'With attachment file size more than',
        [category_id] = 21409,
        [description] = 'With attachment file size more than'
    WHERE [value_id] = 112208
PRINT 'Updated Static value 112208 - With attachment file size more than.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112209)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112209, 'With attachment file extension', 'With attachment file extension', 21409, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112209 - With attachment file extension.'
END
ELSE
BEGIN
    PRINT 'Static data value 112209 - With attachment file extension already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            



UPDATE static_data_value
    SET [code] = 'With attachment file extension',
        [category_id] = 21409,
        [description] = 'With attachment file extension'
    WHERE [value_id] = 112209
PRINT 'Updated Static value 112209 - With attachment file extension.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112210)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112210, 'With attachment filename contains', 'With attachment filename contains', 21409, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112210 - With attachment filename contains.'
END
ELSE
BEGIN
    PRINT 'Static data value 112210 - With attachment filename contains already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'With attachment filename contains',
        [category_id] = 21409,
        [description] = 'With attachment filename contains'
    WHERE [value_id] = 112210
PRINT 'Updated Static value 112210 - With attachment filename contains.'            