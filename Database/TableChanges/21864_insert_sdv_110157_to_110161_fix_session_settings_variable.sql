SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110157)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110157, 'AllowUnknownMsgFields', 'AllowUnknownMsgFields', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110157 - AllowUnknownMsgFields.'
END
ELSE
BEGIN
    PRINT 'Static data value 110157 - AllowUnknownMsgFields already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'AllowUnknownMsgFields',
        [category_id] = NULL
    WHERE [value_id] = 110157
PRINT 'Updated Static value 110157 - AllowUnknownMsgFields.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110158)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110158, 'SocketUseSSL', 'SocketUseSSL', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110158 - SocketUseSSL.'
END
ELSE
BEGIN
    PRINT 'Static data value 110158 - SocketUseSSL already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SocketUseSSL',
        [category_id] = NULL
    WHERE [value_id] = 110158
PRINT 'Updated Static value 110158 - SocketUseSSL.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110159)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110159, 'CheckLatency', 'CheckLatency', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110159 - CheckLatency.'
END
ELSE
BEGIN
    PRINT 'Static data value 110159 - CheckLatency already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'CheckLatency',
        [category_id] = NULL
    WHERE [value_id] = 110159
PRINT 'Updated Static value 110159 - CheckLatency.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110160)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110160, 'user_login_id', 'user_login_id', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110160 - user_login_id.'
END
ELSE
BEGIN
    PRINT 'Static data value 110160 - user_login_id already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'user_login_id',
        [category_id] = NULL
    WHERE [value_id] = 110160
PRINT 'Updated Static value 110160 - user_login_id.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110161)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110161, 'password', 'PASSWORD', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110161 - password.'
END
ELSE
BEGIN
    PRINT 'Static data value 110161 - password already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'password',
        [category_id] = NULL
    WHERE [value_id] = 110161
PRINT 'Updated Static value 110161 - password.'            