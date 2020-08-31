SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 101503)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (101503, 101500, 'Risk Oversight Committee Approved', 'Risk Oversight Committee Approved', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 101503 - Risk Oversight Committee Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value 101503 - Risk Oversight Committee Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 101502)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (101502, 101500, 'Director Approved', 'Director Approved', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 101502 - Director Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value 101502 - Director Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 101501)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (101501, 101500, 'Director of Marketing and Sales Approved', 'Director of Marketing and Sales Approved', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 101501 - Director of Marketing and Sales Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value 101501 - Director of Marketing and Sales Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 101500)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (101500, 101500, 'Director of Marketing and Sales Approved Final', 'Director of Marketing and Sales Approved Final', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 101500 - Director of Marketing and Sales Approved Final.'
END
ELSE
BEGIN
    PRINT 'Static data value 101500 - Director of Marketing and Sales Approved Final already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF