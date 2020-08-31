UPDATE static_data_value
    SET [code] = 'Broker Fees by Deal Date',
        [category_id] = NULL,
        [description] = 'Broker Fees by Deal Date'
    WHERE [value_id] = 18723
PRINT 'Updated Static value 18723 - Broker Fees by Deal Date.'    

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18739)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (18700, 18739, 'Broker Fees by Delivery Date', 'Broker Fees by Delivery Date', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18739 - Broker Fees by Delivery Date.'
END
ELSE
BEGIN
    PRINT 'Static data value 18739 - Broker Fees by Delivery Date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18740)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (18700, 18740, 'Clearing Fees by Deal Date', 'Clearing Fees by Deal Date', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18740 - Clearing Fees by Deal Date.'
END
ELSE
BEGIN
    PRINT 'Static data value 18740 - Clearing Fees by Deal Date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18741)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (18700, 18741, 'Clearing Fees by Delivery Date', 'Clearing Fees by Delivery Date', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18741 - Clearing Fees by Delivery Date.'
END
ELSE
BEGIN
    PRINT 'Static data value 18741 - Clearing Fees by Delivery Date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF     


