/**
* Update connection string values for ssrs config variable previously stored on farrms.client.config.php
* Set the verified values for following.
* 2016-05-19
* sligal@pioneersolutionsglobal.com
**/

/**
Code commented as this is the sample script file to update the values of connection string, so when committed through svn it may be applied on daily basis but the values are to be set according to the version information. Hence not to update the values with incorrect data codes are commented. This should be applied manually using appropriate values on required version as different version has different setting values.
Renamed to sample on 2016-07-15 0900.
*/


--IF COL_LENGTH('connection_string', 'report_server_url') IS NOT NULL
--BEGIN
--	UPDATE connection_string
--	SET 
--	document_path = '\\SERVER1\shared_docs_TMRTracker_Trunk',
--	report_server_url = 'http://SERVER1/ReportServer',
--	report_server_domain = 'dpcs',
--	report_server_user_name = 'user1',
--	report_server_password = dbo.[FNAEncrypt]('passw0rd'),
--	report_server_datasource_name = 'TRMTracker_Trunk',
--	report_server_target_folder = 'TRMTracker_Trunk',
--	ftp_server_url = 'dev.farrms.us',
--	ftp_server_user_name = 'Pioneer',
--	ftp_server_password = dbo.[FNAEncrypt]('passw0rd'),
--	ftp_server_rss_path = 'D:\\FARRMS_SPTFiles\\RSS\\TRMTracker_Trunk\\ftp.rss',
--	ftp_remote_file_path = 'SSRS_FTP',
--	ftp_local_file_path = 'D:\\RSS_Export'
--	PRINT 'Updated ssrs config values on connection_string.'
--END
--ELSE
--BEGIN
--	PRINT 'report_server_url column does not exist.'
--END