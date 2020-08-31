SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -104700)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (104700, -104700, 'Deal', 'Deal', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -104700 - Deal.'
END
ELSE
BEGIN
    PRINT 'Static data value -104700 - Deal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -104701)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (104700, -104701, 'Counterparty', 'Counterparty', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -104701 - Counterparty.'
END
ELSE
BEGIN
    PRINT 'Static data value -104701 - Counterparty already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -104702)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (104700, -104702, 'Price', 'Price', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -104702 - Price.'
END
ELSE
BEGIN
    PRINT 'Static data value -104702 - Price already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -104703)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (104700, -104703, 'Location', 'Location', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -104703 - Location.'
END
ELSE
BEGIN
    PRINT 'Static data value -104703 - Location already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -104704)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (104700, -104704, 'Contract', 'Contract', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -104704 - Contract.'
END
ELSE
BEGIN
    PRINT 'Static data value -104704 - Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            