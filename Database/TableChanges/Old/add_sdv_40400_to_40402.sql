SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 40402)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (40402, 40400, 'Buyer’s Call', ' Buyer’s Call', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 40402 - Buyer’s Call.'
END
ELSE
BEGIN
    PRINT 'Static data value 40402 - Buyer’s Call already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 40401)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (40401, 40400, 'Seller’s Option', ' Seller’s Option', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 40401 - Seller’s Option.'
END
ELSE
BEGIN
    PRINT 'Static data value 40401 - Seller’s Option already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 40400)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (40400, 40400, 'Buyer’s Option', ' Buyer’s Option', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 40400 - Buyer’s Option.'
END
ELSE
BEGIN
    PRINT 'Static data value 40400 - Buyer’s Option already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF