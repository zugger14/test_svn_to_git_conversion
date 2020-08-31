--insert detail udf 'Nominated Volume'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000141)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000141, 5500, 'Nominated Volume', 'Nominated Volume', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000141 - Nominated Volume.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000141 - Nominated Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
--insert detail udf 'Cashout Volume'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000142)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000142, 5500, 'Cashout Volume', 'Cashout Volume', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000142 - Cashout Volume.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000142 - Cashout Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
--insert detail udf 'Payback Volume'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000143)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000143, 5500, 'Payback Volume', 'Payback Volume', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000143 - Payback Volume.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000143 - Payback Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
--insert detail udf 'Closeout Volume'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000144)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000144, 5500, 'Closeout Volume', 'Closeout Volume', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000144 - Closeout Volume.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000144 - Closeout Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF