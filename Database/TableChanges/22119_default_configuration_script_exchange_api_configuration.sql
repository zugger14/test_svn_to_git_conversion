IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'ConnectionType')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'ConnectionType', 'initiator')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'ReconnectInterval')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'ReconnectInterval', '20')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'FileStorePath')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'FileStorePath', 'Logs')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'FileLogPath')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'FileLogPath', 'Logs')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'StartTime')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'StartTime', '00:00:00')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'EndTime')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'EndTime', '00:00:00')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'UseDataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'UseDataDictionary', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'DataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'DataDictionary', 'ICE-FIX44.xml')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'SocketConnectHost')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'SocketConnectHost', '63.247.113.201')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'SocketConnectPort')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'SocketConnectPort', '80')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'LogoutTimeout')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'LogoutTimeout', '60')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'SSLRequireClientCertificate')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'SSLRequireClientCertificate', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'ResetOnLogout')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'ResetOnLogout', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'ResetOnDisconnect')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'ResetOnDisconnect', 'N')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'ValidateFieldsOutOfOrder')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'ValidateFieldsOutOfOrder', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'SocketUseSSL')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'SocketUseSSL', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'CheckLatency')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[DEFAULT]', 'CheckLatency', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'BeginString')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[SESSION]', 'BeginString', 'FIX.4.4')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'SenderCompID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[SESSION]', 'SenderCompID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'SenderSubID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[SESSION]', 'SenderSubID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'TargetCompID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[SESSION]', 'TargetCompID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'HeartBtInt')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[SESSION]', 'HeartBtInt', '10')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'user_login_id')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[SYSTEM]', 'user_login_id', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109900 AND variable_name = 'password')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109900, '[SYSTEM]', 'password', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'ConnectionType')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'ConnectionType', 'initiator')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'ReconnectInterval')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'ReconnectInterval', '20')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'FileStorePath')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'FileStorePath', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'FileLogPath')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'FileLogPath', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'StartTime')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'StartTime', '00:00:00')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'EndTime')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'EndTime', '00:00:00')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'SocketConnectHost')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'SocketConnectHost', '127.0.0.1')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'SocketConnectPort')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'SocketConnectPort', '6550')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'LogoutTimeout')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'LogoutTimeout', '60')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'ResetOnLogon')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'ResetOnLogon', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'ResetOnLogout')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'ResetOnLogout', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'ResetOnDisconnect')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'ResetOnDisconnect', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'ValidateFieldsOutOfOrder')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'ValidateFieldsOutOfOrder', 'N')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'SocketUseSSL')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'SocketUseSSL', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'BeginString')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[SESSION]', 'BeginString', 'FIX.4.4')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'SenderCompID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[SESSION]', 'SenderCompID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'TargetCompID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[SESSION]', 'TargetCompID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'HeartBtInt')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[SESSION]', 'HeartBtInt', '5')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'user_login_id')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[SYSTEM]', 'user_login_id', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'password')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[SYSTEM]', 'password', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'TargetSubID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[SESSION]', 'TargetSubID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'AllowUnknownMsgFields')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'AllowUnknownMsgFields', 'N')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'SendRedundantResendRequests')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'SendRedundantResendRequests', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'UseDataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'UseDataDictionary', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'DataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[DEFAULT]', 'DataDictionary', 'CME-FIX44.xml')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'ConnectionType')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'ConnectionType', 'initiator')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'ReconnectInterval')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'ReconnectInterval', '20')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'AllowUnknownMsgFields')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'AllowUnknownMsgFields', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'FileLogPath')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'FileLogPath', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'StartTime')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'StartTime', '00:00:00')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'EndTime')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'EndTime', '00:00:00')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'UseDataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'UseDataDictionary', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'SocketConnectHost')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'SocketConnectHost', '127.0.0.1')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'SocketConnectPort')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'SocketConnectPort', '6552')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'LogoutTimeout')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'LogoutTimeout', '120')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'ResetOnLogon')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'ResetOnLogon', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'ResetOnLogout')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'ResetOnLogout', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'ResetOnDisconnect')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'ResetOnDisconnect', 'N')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'ValidateFieldsOutOfOrder')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'ValidateFieldsOutOfOrder', 'N')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'SocketUseSSL')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'SocketUseSSL', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'CheckLatency')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'CheckLatency', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'BeginString')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[SESSION]', 'BeginString', 'FIXT.1.1')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'SenderCompID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[SESSION]', 'SenderCompID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'TargetCompID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[SESSION]', 'TargetCompID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'HeartBtInt')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[SESSION]', 'HeartBtInt', '5')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'TransportDataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[SESSION]', 'TransportDataDictionary', 'FIXT.1.1.xml')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'user_login_id')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[SYSTEM]', 'user_login_id', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'password')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[SYSTEM]', 'password', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'DefaultApplVerID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[SESSION]', 'DefaultApplVerID', 'FIX.5.0')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'FileStorePath')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'FileStorePath', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109908 AND variable_name = 'AppDataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109908, '[DEFAULT]', 'AppDataDictionary', 'FIX50.xml')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'ConnectionType')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'ConnectionType', 'initiator')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'ReconnectInterval')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'ReconnectInterval', '20')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'FileStorePath')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'FileStorePath', 'Logs')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'FileLogPath')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'FileLogPath', 'Logs')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'StartTime')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'StartTime', '00:00:00')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'EndTime')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'EndTime', '00:00:00')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'UseDataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'UseDataDictionary', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'AppDataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'AppDataDictionary', 'FIXT.1.1.xml')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'SocketConnectHost')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'SocketConnectHost', '127.0.0.1')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'SocketConnectPort')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'SocketConnectPort', '6556')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'LogoutTimeout')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'LogoutTimeout', '60')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'ResetOnLogon')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'ResetOnLogon', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'ResetOnLogout')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'ResetOnLogout', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'ResetOnDisconnect')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'ResetOnDisconnect', 'N')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'ValidateFieldsOutOfOrder')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'ValidateFieldsOutOfOrder', 'N')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'SocketUseSSL')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'SocketUseSSL', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'CheckLatency')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[DEFAULT]', 'CheckLatency', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'BeginString')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[SESSION]', 'BeginString', 'FIXT.1.1')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'SenderCompID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[SESSION]', 'SenderCompID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'SenderSubID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[SESSION]', 'SenderSubID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'TargetCompID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[SESSION]', 'TargetCompID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'HeartBtInt')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[SESSION]', 'HeartBtInt', '5')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'user_login_id')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[SYSTEM]', 'user_login_id', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'password')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[SYSTEM]', 'password', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'TransportDataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[SESSION]', 'TransportDataDictionary', 'FIXT.1.1.xml')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109906 AND variable_name = 'DefaultApplVerID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109906, '[SESSION]', 'DefaultApplVerID', 'FIX.5.0SP2')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'ConnectionType')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'ConnectionType', 'initiator')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'ReconnectInterval')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'ReconnectInterval', '20')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'FileStorePath')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'FileStorePath', 'Logs')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'FileLogPath')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'FileLogPath', 'Logs')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'StartTime')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'StartTime', '00:00:00')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'EndTime')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'EndTime', '00:00:00')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'UseDataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'UseDataDictionary', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'DataDictionary')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'DataDictionary', 'EEX-FIX42.xml')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'SocketConnectHost')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'SocketConnectHost', 'fixsecurityinfo-ext-uat-cert.trade.tt')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'SocketConnectPort')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'SocketConnectPort', '11503')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'LogoutTimeout')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'LogoutTimeout', '60')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'ResetOnLogon')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'ResetOnLogon', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'ResetOnLogout')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'ResetOnLogout', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'ResetOnDisconnect')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'ResetOnDisconnect', 'N')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'ValidateFieldsOutOfOrder')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'ValidateFieldsOutOfOrder', 'N')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'SocketUseSSL')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'SocketUseSSL', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'CheckLatency')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[DEFAULT]', 'CheckLatency', 'Y')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'BeginString')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[SESSION]', 'BeginString', 'FIX.4.2')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'SenderCompID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[SESSION]', 'SenderCompID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'SenderSubID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[SESSION]', 'SenderSubID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'TargetCompID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[SESSION]', 'TargetCompID', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'HeartBtInt')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[SESSION]', 'HeartBtInt', '10')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'user_login_id')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[SYSTEM]', 'user_login_id', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109901 AND variable_name = 'password')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109901, '[SYSTEM]', 'password', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109909 AND variable_name = 'SocketConnectHost')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109909, '[DEFAULT]', 'SocketConnectHost', 'jouledirecttest')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109909 AND variable_name = 'SocketConnectPort')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109909, '[DEFAULT]', 'SocketConnectPort', '443')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109909 AND variable_name = 'user_login_id')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109909, '[DEFAULT]', 'user_login_id', '')
END  
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109909 AND variable_name = 'password')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109909, '[DEFAULT]', 'password', '')
END  