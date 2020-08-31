SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20541)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20541, 20500, 'Counterparty - Pre Insert', 'Counterparty - Pre Insert', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20541 - Counterparty - Pre Insert.'
END
ELSE
BEGIN
    PRINT 'Static data value 20541 - Counterparty - Pre Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20542)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20542, 20500, 'Counterparty - Post Insert', 'Counterparty - Post Insert', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20542 - Counterparty - Post Insert.'
END
ELSE
BEGIN
    PRINT 'Static data value 20542 - Counterparty - Post Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20543)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20543, 20500, 'Counterparty - Pre Update', 'Counterparty - Pre Update', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20543 - Counterparty - Pre Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20543 - Counterparty - Pre Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20544)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20544, 20500, 'Counterparty - Post Update', 'Counterparty - Post Update', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20544 - Counterparty - Post Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20544 - Counterparty - Post Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20545)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20545, 20500, 'Counterparty - Pre Delete', 'Counterparty - Pre Delete', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20545 - Counterparty - Pre Delete.'
END
ELSE
BEGIN
    PRINT 'Static data value 20545 - Counterparty - Pre Delete already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20546)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20546, 20500, 'Counterparty - Post Delete', 'Counterparty - Post Delete', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20546 - Counterparty - Post Delete.'
END
ELSE
BEGIN
    PRINT 'Static data value 20546 - Counterparty - Post Delete already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF