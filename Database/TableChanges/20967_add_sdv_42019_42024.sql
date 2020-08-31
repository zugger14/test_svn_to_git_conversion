SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42022)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42022, 42000, 'Trade Ticket Collection', 'Collection of Trade Ticket', '33', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42022 - Trade Ticket Collection.'
END
ELSE
BEGIN
    PRINT 'Static data value 42022 - Trade Ticket Collection already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


UPDATE static_data_value
    SET code = 'Trade Ticket Collection',
    [category_id] = '33'
    WHERE [value_id] = 42022
PRINT 'Updated Static value 42022 - Trade Ticket Collection.'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42023)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42023, 42000, 'Confirm Replacement Report Collection', 'Collection of Deal Confirmation', '33', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42023 - Confirm Replacement Report Collection.'
END
ELSE
BEGIN
    PRINT 'Static data value 42023 - Confirm Replacement Report Collection already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


UPDATE static_data_value
    SET code = 'Confirm Replacement Report Collection',
    [category_id] = '33'
    WHERE [value_id] = 42023
PRINT 'Updated Static value 42023 - Confirm Replacement Report Collection.'


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42024)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42024, 42000, 'Invoice Report Collection', 'Collection for Invoice Report', '38', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42024 - Invoice Report Collection.'
END
ELSE
BEGIN
    PRINT 'Static data value 42024 - Invoice Report Collection already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



UPDATE static_data_value
    SET code = 'Invoice Report Collection',
    [category_id] = '38'
    WHERE [value_id] = 42024
PRINT 'Updated Static value 42024 - Invoice Report Collection.'


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42019)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42019, 42000, 'Trade Ticket', 'Trade Ticket', '33', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42019 - Trade Ticket.'
END
ELSE
BEGIN
    PRINT 'Static data value 42019 - Trade Ticket already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value
    SET code = 'Trade Ticket',
    [category_id] = '33'
    WHERE [value_id] = 42019
PRINT 'Updated Static value 42019 - Trade Ticket.'