SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42022)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42022, 42000, 'Trade Ticket Collection', ' Collection of Trade Ticket', '33', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42022 - Trade Ticket Collection.'
END
ELSE
BEGIN
    PRINT 'Static data value 42022 - Trade Ticket Collection already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42023)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42023, 42000, 'Confirm Replacement Report Collection', ' Collection of Deal Confirmation', '33', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42023 - Confirm Replacement Report Collection.'
END
ELSE
BEGIN
    PRINT 'Static data value 42023 - Confirm Replacement Report Collection already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42024)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42024, 42000, 'Invoice Report Collection', ' Collection for Invoice Report', '38', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42024 - Invoice Report Collection.'
END
ELSE
BEGIN
    PRINT 'Static data value 42024 - Invoice Report Collection already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF