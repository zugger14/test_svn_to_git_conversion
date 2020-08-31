SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -104900)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-104900, 104900, 'Credit Outlook', 'Credit Outlook', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -104900 - Credit Outlook.'
END
ELSE
BEGIN
    PRINT 'Static data value -104900 - Credit Outlook already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -104901)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-104901, 104900, 'Positive Outlook', 'Positive Outlook', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -104901 - Positive Outlook.'
END
ELSE
BEGIN
    PRINT 'Static data value -104901 - Positive Outlook already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -104902)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-104902, 104900, 'Negative Outlook', 'Negative Outlook', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -104902 - Negative Outlook.'
END
ELSE
BEGIN
    PRINT 'Static data value -104902 - Negative Outlook already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -104903)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-104903, 104900, 'Stable', 'Stable', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -104903 - Stable.'
END
ELSE
BEGIN
    PRINT 'Static data value -104903 - Stable already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -104904)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-104904, 104900, 'Developing', 'Developing', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -104904 - Developing.'
END
ELSE
BEGIN
    PRINT 'Static data value -104904 - Developing already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
