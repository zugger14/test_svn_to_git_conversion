SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42019)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42019, 42000, 'Trade Ticket', ' Trade Ticket', '33', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42019 - Trade Ticket.'
END
ELSE
BEGIN
    PRINT 'Static data value 42019 - Trade Ticket already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 48)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (48, 25, 'Hedge Documentation', ' Hedge Documentation', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 48 - Hedge Documentation.'
END
ELSE
BEGIN
    PRINT 'Static data value 48 - Hedge Documentation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO