SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45400)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45400, 45400, 'WACOG', 'WACOG', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45400 - WACOG.'
END
ELSE
BEGIN
    PRINT 'Static data value 45400 - WACOG already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45401)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45401, 45400, 'FIFO', 'FIFO', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45401 - FIFO.'
END
ELSE
BEGIN
    PRINT 'Static data value 45401 - FIFO already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45402)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45402, 45400, 'LIFO', 'LIFO', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45402 - LIFO.'
END
ELSE
BEGIN
    PRINT 'Static data value 45402 - LIFO already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF