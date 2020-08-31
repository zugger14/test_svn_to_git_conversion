IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 18500)
BEGIN
     INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
     VALUES (18500, 'Storage Type', 1, 'Storage Type', 'farrms_admin', GETDATE())
     PRINT 'Inserted static data type 18500 - Storage Type.'
END
ELSE
BEGIN
    PRINT 'Static data type 18500 - Storage Type already exists.'
END   

SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18501)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
    VALUES (18501, 18500, 'Virtual ', 'Virtual ', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18501 - Virtual .'
END
ELSE
BEGIN
    PRINT 'Static data value 18501 - Virtual already exists.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18502)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
    VALUES (18502, 18500, 'Physical', 'Physical', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18502 - Physical.'
END
ELSE
BEGIN
    PRINT 'Static data value 18502 - Physical already exists.'
END

SET IDENTITY_INSERT static_data_value OFF
