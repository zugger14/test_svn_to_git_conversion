SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000328)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000328, 'VOICE DEAL', 'VOICE DEAL', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000328 - VOICE DEAL.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000328 - VOICE DEAL already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF 


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000329)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000329, 'Initiator/Aggressor', 'Initiator/Aggressor', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000329 - Initiator/Aggressor.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000329 - Initiator/Aggressor already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000330)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000330, 'EXECUTION VENUE ID', 'EXECUTION VENUE ID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000330 - EXECUTION VENUE ID.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000330 - EXECUTION VENUE ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF           


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000331)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000331, 'TRADING CAPACITY', 'TRADING CAPACITY', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000331 - TRADING CAPACITY.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000331 - TRADING CAPACITY already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000028)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000028, 'Product Classification', 'Product Classification', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000028 - Product Classification.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000028 - Product Classification already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000332)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000332, 'FOREIGN CONTRACT ID', 'FOREIGN CONTRACT ID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000332 - FOREIGN CONTRACT ID.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000332 - FOREIGN CONTRACT ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000333)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000333, 'Counterparty Trader', 'Counterparty Trader', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000333 - Counterparty Trader.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000333 - Counterparty Trader already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000335)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000335, 'Sleeve', 'Sleeve', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000335 - Sleeve.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000335 - Sleeve already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000336)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000336, 'Spread', 'Spread', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000336 - Spread.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000336 - Spread already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF          

