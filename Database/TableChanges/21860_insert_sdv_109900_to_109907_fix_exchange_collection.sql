-- FIX Exhange collections definitions
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 109900)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (109900, 'FIX Exchange Collection', 'FIX Exchange Collection Definitions', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 109900 - FIX Exchange Collection.'
END
ELSE
BEGIN
    PRINT 'Static data type 109900 - FIX Exchange Collection already EXISTS.'
END            

UPDATE static_data_type
SET [type_name] = 'FIX Exchange Collection',
    [description] = 'FIX Exchange Collection Definitions',
    [internal] = 1, 
    [is_active] = 1
WHERE [type_id] = 109900
PRINT 'Updated static data type 109900 - FIX Exchange Collection.'  

-- Exchange
-- ICE
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109900)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109900, 109900, 'ICE', 'Intercontinental Exchange', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109900 - ICE.'
END
ELSE
BEGIN
    PRINT 'Static data value 109900 - ICE already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF      

UPDATE static_data_value
    SET [code] = 'ICE',
        [category_id] = NULL
    WHERE [value_id] = 109900
PRINT 'Updated Static value 109900 - ICE.'         

-- EEX
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109901)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109900, 109901, 'EEX', 'European Energy Exchange', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109901 - EEX.'
END
ELSE
BEGIN
    PRINT 'Static data value 109901 - EEX already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'EEX',
        [category_id] = NULL
    WHERE [value_id] = 109901
PRINT 'Updated Static value 109901 - EEX.'            

-- CME
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109902)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109900, 109902, 'CME', 'Chicago Mercantile Exchange', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109902 - CME.'
END
ELSE
BEGIN
    PRINT 'Static data value 109902 - CME already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'CME',
        [category_id] = NULL
    WHERE [value_id] = 109902
PRINT 'Updated Static value 109902 - CME.'            

-- TradeWeb
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109903)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109900, 109903, 'TWEB', 'Trade Web', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109903 - TWEB.'
END
ELSE
BEGIN
    PRINT 'Static data value 109903 - TWEB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF 

UPDATE static_data_value
    SET [code] = 'TWEB',
        [category_id] = NULL
    WHERE [value_id] = 109903
PRINT 'Updated Static value 109903 - TWEB.'                       
   
-- EEX Security
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109904)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109900, 109904, 'EEXSEC', 'EEX Security', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109904 - EEXSEC.'
END
ELSE
BEGIN
    PRINT 'Static data value 109904 - EEXSEC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'EEXSEC',
        [category_id] = NULL
    WHERE [value_id] = 109904
PRINT 'Updated Static value 109904 - EEXSEC.'            

-- ICE Security
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109905)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109900, 109905, 'ICESEC', 'Intercontinental Exchange Security', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109905 - ICESEC.'
END
ELSE
BEGIN
    PRINT 'Static data value 109905 - ICESEC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'ICESEC',
        [category_id] = NULL
    WHERE [value_id] = 109905
PRINT 'Updated Static value 109905 - ICESEC.'            

-- NASDAQ 
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109906)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109900, 109906, 'NASDAQ', 'NASDAQ', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109906 - NASDAQ.'
END
ELSE
BEGIN
    PRINT 'Static data value 109906 - NASDAQ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'NASDAQ',
        [category_id] = NULL
    WHERE [value_id] = 109906
PRINT 'Updated Static value 109906 - NASDAQ.'     

-- EPEX SPOT
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109907)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109900, 109907, 'EPEXSPOT', 'EPEXSPOT', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109907 - EPEXSPOT.'
END
ELSE
BEGIN
    PRINT 'Static data value 109907 - EPEXSPOT already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'EPEXSPOT',
        [category_id] = NULL
    WHERE [value_id] = 109907
PRINT 'Updated Static value 109907 - EPEXSPOT.'                                   