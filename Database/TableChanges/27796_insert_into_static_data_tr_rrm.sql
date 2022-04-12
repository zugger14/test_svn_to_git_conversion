IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 116900)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (116900, 'TR and RRM', 'TR and RRM', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 116900 - TR and RRM.'
END
ELSE
BEGIN
    PRINT 'Static data type 116900 - TR and RRM already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 116900)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (116900, 116900, 'DTCC', 'DTCC', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 116900 - DTCC.'
END
ELSE
BEGIN
    PRINT 'Static data value 116900 - DTCC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 116901)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (116900, 116901, 'Equias', 'Equias', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 116901 - Equias.'
END
ELSE
BEGIN
    PRINT 'Static data value 116901 - Equias already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 116902)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (116900, 116902, 'Nordpool', 'Nordpool', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 116902 - Nordpool.'
END
ELSE
BEGIN
    PRINT 'Static data value 116902 - Nordpool already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 116903)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (116900, 116903, 'AFM', 'AFM', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 116903 - AFM.'
END
ELSE
BEGIN
    PRINT 'Static data value 116903 - AFM already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 116904)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (116900, 116904, 'Tradeweb', 'Tradeweb', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 116904 - Tradeweb.'
END
ELSE
BEGIN
    PRINT 'Static data value 116904 - Tradeweb already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            