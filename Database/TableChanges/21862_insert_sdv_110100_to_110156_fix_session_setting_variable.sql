-- FIX Session settings variables collections
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 110100)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (110100, 'FIX Session Settings Variables', 'FIX Session Settings Variables', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 110100 - FIX Session Settings Variables.'
END
ELSE
BEGIN
    PRINT 'Static data type 110100 - FIX Session Settings Variables already EXISTS.'
END            

UPDATE static_data_type
SET [type_name] = 'FIX Session Settings Variables',
    [description] = 'FIX Session Settings Variables',
    [internal] = 1, 
    [is_active] = 1
WHERE [type_id] = 110100
PRINT 'Updated static data type 110100 - FIX Session Settings Variables.'            

--AppDataDictionary
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110100)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110100, 'AppDataDictionary', 'APP_DATA_DICTIONARY', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110100 - AppDataDictionary.'
END
ELSE
BEGIN
    PRINT 'Static data value 110100 - AppDataDictionary already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'AppDataDictionary',
        [category_id] = NULL
    WHERE [value_id] = 110100
PRINT 'Updated Static value 110100 - AppDataDictionary.'            

-- BeginString
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110101)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110101, 'BeginString', 'BEGINSTRING', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110101 - BeginString.'
END
ELSE
BEGIN
    PRINT 'Static data value 110101 - BeginString already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'BeginString',
        [category_id] = NULL
    WHERE [value_id] = 110101
PRINT 'Updated Static value 110101 - BeginString.'      

-- ConnectionType
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110102)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110102, 'ConnectionType', 'CONNECTION_TYPE', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110102 - ConnectionType.'
END
ELSE
BEGIN
    PRINT 'Static data value 110102 - ConnectionType already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'ConnectionType',
        [category_id] = NULL
    WHERE [value_id] = 110102
PRINT 'Updated Static value 110102 - ConnectionType.'

-- DataDictionary
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110103)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110103, 'DataDictionary', 'DATA_DICTIONARY', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110103 - DataDictionary.'
END
ELSE
BEGIN
    PRINT 'Static data value 110103 - DataDictionary already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'DataDictionary',
        [category_id] = NULL
    WHERE [value_id] = 110103
PRINT 'Updated Static value 110103 - DataDictionary.' 

-- DebugFileLogPath
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110104)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110104, 'DebugFileLogPath', 'DEBUG_FILE_LOG_PATH', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110104 - DebugFileLogPath.'
END
ELSE
BEGIN
    PRINT 'Static data value 110104 - DebugFileLogPath already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value
    SET [code] = 'DebugFileLogPath',
        [category_id] = NULL
    WHERE [value_id] = 110104
PRINT 'Updated Static value 110104 - DebugFileLogPath.' 

-- DefaultApplVerID
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110105)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110105, 'DefaultApplVerID', 'DEFAULT_APPLVERID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110105 - DefaultApplVerID.'
END
ELSE
BEGIN
    PRINT 'Static data value 110105 - DefaultApplVerID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF     

UPDATE static_data_value
    SET [code] = 'DefaultApplVerID',
        [category_id] = NULL
    WHERE [value_id] = 110105
PRINT 'Updated Static value 110105 - DefaultApplVerID.'     

-- EnableLastMsgSeqNumProcessed
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110106)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110106, 'EnableLastMsgSeqNumProcessed', 'ENABLE_LAST_MSG_SEQ_NUM_PROCESSED', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110106 - EnableLastMsgSeqNumProcessed.'
END
ELSE
BEGIN
    PRINT 'Static data value 110106 - EnableLastMsgSeqNumProcessed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   

UPDATE static_data_value
    SET [code] = 'EnableLastMsgSeqNumProcessed',
        [category_id] = NULL
    WHERE [value_id] = 110106
PRINT 'Updated Static value 110106 - EnableLastMsgSeqNumProcessed.'            

-- EndDay
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110107)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110107, 'EndDay', 'END_DAY', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110107 - EndDay.'
END
ELSE
BEGIN
    PRINT 'Static data value 110107 - EndDay already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF                                                                       

UPDATE static_data_value
    SET [code] = 'EndDay',
        [category_id] = NULL
    WHERE [value_id] = 110107
PRINT 'Updated Static value 110107 - EndDay.'            

--EndTime
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110108)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110108, 'EndTime', 'END_TIME', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110108 - EndTime.'
END
ELSE
BEGIN
    PRINT 'Static data value 110108 - EndTime already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'EndTime',
        [category_id] = NULL
    WHERE [value_id] = 110108
PRINT 'Updated Static value 110108 - EndTime.'         

-- FileLogPath
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110109)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110109, 'FileLogPath', 'FILE_LOG_PATH', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110109 - FileLogPath.'
END
ELSE
BEGIN
    PRINT 'Static data value 110109 - FileLogPath already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'FileLogPath',
        [category_id] = NULL
    WHERE [value_id] = 110109
PRINT 'Updated Static value 110109 - FileLogPath.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110110)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110110, 'FileStorePath', 'FILE_STORE_PATH', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110110 - FileStorePath.'
END
ELSE
BEGIN
    PRINT 'Static data value 110110 - FileStorePath already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'FileStorePath',
        [category_id] = NULL
    WHERE [value_id] = 110110
PRINT 'Updated Static value 110110 - FileStorePath.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110111)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110111, 'HeartBtInt', 'HEARTBTINT', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110111 - HeartBtInt.'
END
ELSE
BEGIN
    PRINT 'Static data value 110111 - HeartBtInt already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'HeartBtInt',
        [category_id] = NULL
    WHERE [value_id] = 110111
PRINT 'Updated Static value 110111 - HeartBtInt.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110112)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110112, 'IgnorePossDupResendRequests', 'IGNORE_POSSDUP_RESEND_REQUESTS', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110112 - IgnorePossDupResendRequests.'
END
ELSE
BEGIN
    PRINT 'Static data value 110112 - IgnorePossDupResendRequests already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'IgnorePossDupResendRequests',
        [category_id] = NULL
    WHERE [value_id] = 110112
PRINT 'Updated Static value 110112 - IgnorePossDupResendRequests.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110113)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110113, 'LogonTimeout', 'LOGON_TIMEOUT', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110113 - LogonTimeout.'
END
ELSE
BEGIN
    PRINT 'Static data value 110113 - LogonTimeout already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'LogonTimeout',
        [category_id] = NULL
    WHERE [value_id] = 110113
PRINT 'Updated Static value 110113 - LogonTimeout.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110114)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110114, 'LogoutTimeout', 'LOGOUT_TIMEOUT', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110114 - LogoutTimeout.'
END
ELSE
BEGIN
    PRINT 'Static data value 110114 - LogoutTimeout already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'LogoutTimeout',
        [category_id] = NULL
    WHERE [value_id] = 110114
PRINT 'Updated Static value 110114 - LogoutTimeout.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110116)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110116, 'MaxMessagesInResendRequest', 'MAX_MESSAGES_IN_RESEND_REQUEST', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110116 - MaxMessagesInResendRequest.'
END
ELSE
BEGIN
    PRINT 'Static data value 110116 - MaxMessagesInResendRequest already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'MaxMessagesInResendRequest',
        [category_id] = NULL
    WHERE [value_id] = 110116
PRINT 'Updated Static value 110116 - MaxMessagesInResendRequest.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110117)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110117, 'MillisecondsInTimeStamp', 'MILLISECONDS_IN_TIMESTAMP', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110117 - MillisecondsInTimeStamp.'
END
ELSE
BEGIN
    PRINT 'Static data value 110117 - MillisecondsInTimeStamp already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'MillisecondsInTimeStamp',
        [category_id] = NULL
    WHERE [value_id] = 110117
PRINT 'Updated Static value 110117 - MillisecondsInTimeStamp.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110118)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110118, 'PersistMessages', 'PERSIST_MESSAGES', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110118 - PersistMessages.'
END
ELSE
BEGIN
    PRINT 'Static data value 110118 - PersistMessages already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'PersistMessages',
        [category_id] = NULL
    WHERE [value_id] = 110118
PRINT 'Updated Static value 110118 - PersistMessages.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110119)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110119, 'ReconnectInterval', 'RECONNECT_INTERVAL', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110119 - ReconnectInterval.'
END
ELSE
BEGIN
    PRINT 'Static data value 110119 - ReconnectInterval already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'ReconnectInterval',
        [category_id] = NULL
    WHERE [value_id] = 110119
PRINT 'Updated Static value 110119 - ReconnectInterval.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110120)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110120, 'RefreshOnLogon', 'REFRESH_ON_LOGON', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110120 - RefreshOnLogon.'
END
ELSE
BEGIN
    PRINT 'Static data value 110120 - RefreshOnLogon already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'RefreshOnLogon',
        [category_id] = NULL
    WHERE [value_id] = 110120
PRINT 'Updated Static value 110120 - RefreshOnLogon.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110121)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110121, 'ResetOnDisconnect', 'RESET_ON_DISCONNECT', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110121 - ResetOnDisconnect.'
END
ELSE
BEGIN
    PRINT 'Static data value 110121 - ResetOnDisconnect already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'ResetOnDisconnect',
        [category_id] = NULL
    WHERE [value_id] = 110121
PRINT 'Updated Static value 110121 - ResetOnDisconnect.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110122)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110122, 'ResetOnLogon', 'RESET_ON_LOGON', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110122 - ResetOnLogon.'
END
ELSE
BEGIN
    PRINT 'Static data value 110122 - ResetOnLogon already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'ResetOnLogon',
        [category_id] = NULL
    WHERE [value_id] = 110122
PRINT 'Updated Static value 110122 - ResetOnLogon.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110123)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110123, 'ResetOnLogout', 'RESET_ON_LOGOUT', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110123 - ResetOnLogout.'
END
ELSE
BEGIN
    PRINT 'Static data value 110123 - ResetOnLogout already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


UPDATE static_data_value
    SET [code] = 'ResetOnLogout',
        [category_id] = NULL
    WHERE [value_id] = 110123
PRINT 'Updated Static value 110123 - ResetOnLogout.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110124)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110124, 'RequiresOrigSendingTime', 'RESETSEQUENCE_MESSAGE_REQUIRES_ORIGSENDINGTIME', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110124 - RequiresOrigSendingTime.'
END
ELSE
BEGIN
    PRINT 'Static data value 110124 - RequiresOrigSendingTime already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'RequiresOrigSendingTime',
        [category_id] = NULL
    WHERE [value_id] = 110124
PRINT 'Updated Static value 110124 - RequiresOrigSendingTime.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110125)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110125, 'SendLogoutBeforeDisconnectFromTimeout', 'SEND_LOGOUT_BEFORE_TIMEOUT_DISCONNECT', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110125 - SendLogoutBeforeDisconnectFromTimeout.'
END
ELSE
BEGIN
    PRINT 'Static data value 110125 - SendLogoutBeforeDisconnectFromTimeout already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SendLogoutBeforeDisconnectFromTimeout',
        [category_id] = NULL
    WHERE [value_id] = 110125
PRINT 'Updated Static value 110125 - SendLogoutBeforeDisconnectFromTimeout.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110126)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110126, 'SendRedundantResendRequests', 'SEND_REDUNDANT_RESENDREQUESTS', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110126 - SendRedundantResendRequests.'
END
ELSE
BEGIN
    PRINT 'Static data value 110126 - SendRedundantResendRequests already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SendRedundantResendRequests',
        [category_id] = NULL
    WHERE [value_id] = 110126
PRINT 'Updated Static value 110126 - SendRedundantResendRequests.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110127)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110127, 'SenderCompID', 'SENDERCOMPID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110127 - SenderCompID.'
END
ELSE
BEGIN
    PRINT 'Static data value 110127 - SenderCompID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SenderCompID',
        [category_id] = NULL
    WHERE [value_id] = 110127
PRINT 'Updated Static value 110127 - SenderCompID.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110128)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110128, 'SenderLocationID', 'SENDERLOCID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110128 - SenderLocationID.'
END
ELSE
BEGIN
    PRINT 'Static data value 110128 - SenderLocationID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SenderLocationID',
        [category_id] = NULL
    WHERE [value_id] = 110128
PRINT 'Updated Static value 110128 - SenderLocationID.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110129)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110129, 'SenderSubID', 'SENDERSUBID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110129 - SenderSubID.'
END
ELSE
BEGIN
    PRINT 'Static data value 110129 - SenderSubID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SenderSubID',
        [category_id] = NULL
    WHERE [value_id] = 110129
PRINT 'Updated Static value 110129 - SenderSubID.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110130)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110130, 'SessionQualifier', 'SESSION_QUALIFIER', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110130 - SessionQualifier.'
END
ELSE
BEGIN
    PRINT 'Static data value 110130 - SessionQualifier already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SessionQualifier',
        [category_id] = NULL
    WHERE [value_id] = 110130
PRINT 'Updated Static value 110130 - SessionQualifier.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110131)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110131, 'SocketAcceptHost', 'SOCKET_ACCEPT_HOST', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110131 - SocketAcceptHost.'
END
ELSE
BEGIN
    PRINT 'Static data value 110131 - SocketAcceptHost already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SocketAcceptHost',
        [category_id] = NULL
    WHERE [value_id] = 110131
PRINT 'Updated Static value 110131 - SocketAcceptHost.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110132)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110132, 'SocketAcceptPort', 'SOCKET_ACCEPT_PORT', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110132 - SocketAcceptPort.'
END
ELSE
BEGIN
    PRINT 'Static data value 110132 - SocketAcceptPort already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SocketAcceptPort',
        [category_id] = NULL
    WHERE [value_id] = 110132
PRINT 'Updated Static value 110132 - SocketAcceptPort.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110133)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110133, 'SocketConnectHost', 'SOCKET_CONNECT_HOST', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110133 - SocketConnectHost.'
END
ELSE
BEGIN
    PRINT 'Static data value 110133 - SocketConnectHost already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SocketConnectHost',
        [category_id] = NULL
    WHERE [value_id] = 110133
PRINT 'Updated Static value 110133 - SocketConnectHost.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110134)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110134, 'SocketConnectPort', 'SOCKET_CONNECT_PORT', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110134 - SocketConnectPort.'
END
ELSE
BEGIN
    PRINT 'Static data value 110134 - SocketConnectPort already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SocketConnectPort',
        [category_id] = NULL
    WHERE [value_id] = 110134
PRINT 'Updated Static value 110134 - SocketConnectPort.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110135)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110135, 'SocketNodelay', 'SOCKET_NODELAY', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110135 - SocketNodelay.'
END
ELSE
BEGIN
    PRINT 'Static data value 110135 - SocketNodelay already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SocketNodelay',
        [category_id] = NULL
    WHERE [value_id] = 110135
PRINT 'Updated Static value 110135 - SocketNodelay.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110136)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110136, 'SSLCACertificate', 'SSL_CA_CERTIFICATE', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110136 - SSLCACertificate.'
END
ELSE
BEGIN
    PRINT 'Static data value 110136 - SSLCACertificate already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SSLCACertificate',
        [category_id] = NULL
    WHERE [value_id] = 110136
PRINT 'Updated Static value 110136 - SSLCACertificate.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110137)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110137, 'SSLCertificate', 'SSL_CERTIFICATE', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110137 - SSLCertificate.'
END
ELSE
BEGIN
    PRINT 'Static data value 110137 - SSLCertificate already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SSLCertificate',
        [category_id] = NULL
    WHERE [value_id] = 110137
PRINT 'Updated Static value 110137 - SSLCertificate.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110138)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110138, 'SSLCertificatePassword', 'SSL_CERTIFICATE_PASSWORD', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110138 - SSLCertificatePassword.'
END
ELSE
BEGIN
    PRINT 'Static data value 110138 - SSLCertificatePassword already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SSLCertificatePassword',
        [category_id] = NULL
    WHERE [value_id] = 110138
PRINT 'Updated Static value 110138 - SSLCertificatePassword.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110139)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110139, 'SSLCheckCertificateRevocation', 'SSL_CHECK_CERTIFICATE_REVOCATION', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110139 - SSLCheckCertificateRevocation.'
END
ELSE
BEGIN
    PRINT 'Static data value 110139 - SSLCheckCertificateRevocation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SSLCheckCertificateRevocation',
        [category_id] = NULL
    WHERE [value_id] = 110139
PRINT 'Updated Static value 110139 - SSLCheckCertificateRevocation.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110140)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110140, 'SSLEnable', 'SSL_ENABLE', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110140 - SSLEnable.'
END
ELSE
BEGIN
    PRINT 'Static data value 110140 - SSLEnable already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SSLEnable',
        [category_id] = NULL
    WHERE [value_id] = 110140
PRINT 'Updated Static value 110140 - SSLEnable.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110141)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110141, 'SSLProtocols', 'SSL_PROTOCOLS', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110141 - SSLProtocols.'
END
ELSE
BEGIN
    PRINT 'Static data value 110141 - SSLProtocols already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SSLProtocols',
        [category_id] = NULL
    WHERE [value_id] = 110141
PRINT 'Updated Static value 110141 - SSLProtocols.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110142)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110142, 'SSLRequireClientCertificate', 'SSL_REQUIRE_CLIENT_CERTIFICATE', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110142 - SSLRequireClientCertificate.'
END
ELSE
BEGIN
    PRINT 'Static data value 110142 - SSLRequireClientCertificate already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SSLRequireClientCertificate',
        [category_id] = NULL
    WHERE [value_id] = 110142
PRINT 'Updated Static value 110142 - SSLRequireClientCertificate.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110143)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110143, 'SSLServerName', 'SSL_SERVERNAME', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110143 - SSLServerName.'
END
ELSE
BEGIN
    PRINT 'Static data value 110143 - SSLServerName already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SSLServerName',
        [category_id] = NULL
    WHERE [value_id] = 110143
PRINT 'Updated Static value 110143 - SSLServerName.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110144)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110144, 'SSLValidateCertificates', 'SSL_VALIDATE_CERTIFICATES', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110144 - SSLValidateCertificates.'
END
ELSE
BEGIN
    PRINT 'Static data value 110144 - SSLValidateCertificates already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'SSLValidateCertificates',
        [category_id] = NULL
    WHERE [value_id] = 110144
PRINT 'Updated Static value 110144 - SSLValidateCertificates.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110145)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110145, 'StartDay', 'START_DAY', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110145 - StartDay.'
END
ELSE
BEGIN
    PRINT 'Static data value 110145 - StartDay already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'StartDay',
        [category_id] = NULL
    WHERE [value_id] = 110145
PRINT 'Updated Static value 110145 - StartDay.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110146)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110146, 'StartTime', 'START_TIME', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110146 - StartTime.'
END
ELSE
BEGIN
    PRINT 'Static data value 110146 - StartTime already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'StartTime',
        [category_id] = NULL
    WHERE [value_id] = 110146
PRINT 'Updated Static value 110146 - StartTime.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110147)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110147, 'TargetCompID', 'TARGETCOMPID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110147 - TargetCompID.'
END
ELSE
BEGIN
    PRINT 'Static data value 110147 - TargetCompID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'TargetCompID',
        [category_id] = NULL
    WHERE [value_id] = 110147
PRINT 'Updated Static value 110147 - TargetCompID.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110149)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110149, 'TargetSubID', 'TARGETSUBID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110149 - TargetSubID.'
END
ELSE
BEGIN
    PRINT 'Static data value 110149 - TargetSubID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'TargetSubID',
        [category_id] = NULL
    WHERE [value_id] = 110149
PRINT 'Updated Static value 110149 - TargetSubID.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110150)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110150, 'TimeZone', 'TIME_ZONE', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110150 - TimeZone.'
END
ELSE
BEGIN
    PRINT 'Static data value 110150 - TimeZone already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'TimeZone',
        [category_id] = NULL
    WHERE [value_id] = 110150
PRINT 'Updated Static value 110150 - TimeZone.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110151)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110151, 'TransportDataDictionary', 'TRANSPORT_DATA_DICTIONARY', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110151 - TransportDataDictionary.'
END
ELSE
BEGIN
    PRINT 'Static data value 110151 - TransportDataDictionary already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'TransportDataDictionary',
        [category_id] = NULL
    WHERE [value_id] = 110151
PRINT 'Updated Static value 110151 - TransportDataDictionary.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110152)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110152, 'UseDataDictionary', 'USE_DATA_DICTIONARY', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110152 - UseDataDictionary.'
END
ELSE
BEGIN
    PRINT 'Static data value 110152 - UseDataDictionary already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'UseDataDictionary',
        [category_id] = NULL
    WHERE [value_id] = 110152
PRINT 'Updated Static value 110152 - UseDataDictionary.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110153)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110153, 'UseLocalTime', 'USE_LOCAL_TIME', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110153 - UseLocalTime.'
END
ELSE
BEGIN
    PRINT 'Static data value 110153 - UseLocalTime already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'UseLocalTime',
        [category_id] = NULL
    WHERE [value_id] = 110153
PRINT 'Updated Static value 110153 - UseLocalTime.'            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110154)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110154, 'ValidateFieldsHaveValues', 'VALIDATE_FIELDS_HAVE_VALUES', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110154 - ValidateFieldsHaveValues.'
END
ELSE
BEGIN
    PRINT 'Static data value 110154 - ValidateFieldsHaveValues already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'ValidateFieldsHaveValues',
        [category_id] = NULL
    WHERE [value_id] = 110154
PRINT 'Updated Static value 110154 - ValidateFieldsHaveValues.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110155)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110155, 'ValidateFieldsOutOfOrder', 'VALIDATE_FIELDS_OUT_OF_ORDER', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110155 - ValidateFieldsOutOfOrder.'
END
ELSE
BEGIN
    PRINT 'Static data value 110155 - ValidateFieldsOutOfOrder already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'ValidateFieldsOutOfOrder',
        [category_id] = NULL
    WHERE [value_id] = 110155
PRINT 'Updated Static value 110155 - ValidateFieldsOutOfOrder.'            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110156)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110100, 110156, 'ValidateUserDefinedFields', 'VALIDATE_USER_DEFINED_FIELDS', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110156 - ValidateUserDefinedFields.'
END
ELSE
BEGIN
    PRINT 'Static data value 110156 - ValidateUserDefinedFields already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

UPDATE static_data_value
    SET [code] = 'ValidateUserDefinedFields',
        [category_id] = NULL
    WHERE [value_id] = 110156
PRINT 'Updated Static value 110156 - ValidateUserDefinedFields.'            