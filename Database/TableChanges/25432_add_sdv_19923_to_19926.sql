SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19923)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (19900, 19923, 'Counterparty Contacts', 'Counterparty Contacts', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 19923 - Counterparty Contacts.'
END
ELSE
BEGIN
    PRINT 'Static data value 19923 - Counterparty Contacts already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19924)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (19900, 19924, 'Counterparty Credit Info', 'Counterparty Credit Info', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 19924 - Counterparty Credit Info.'
END
ELSE
BEGIN
    PRINT 'Static data value 19924 - Counterparty Credit Info already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19925)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (19900, 19925, 'Counterparty Credit Enhancements', 'Counterparty Credit Enhancements', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 19925 - Counterparty Credit Enhancements.'
END
ELSE
BEGIN
    PRINT 'Static data value 19925 - Counterparty Credit Enhancements already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19926)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (19900, 19926, 'Counterparty Credit Limits', 'Counterparty Credit Limits', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 19926 - Counterparty Credit Limits.'
END
ELSE
BEGIN
    PRINT 'Static data value 19926 - Counterparty Credit Limits already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            