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
--	document_path = '\\PCNAME\shared_docs_TRMTracker_Branch',
--	report_server_url = 'http://PCNAME/ReportServer',
--	report_server_domain = 'dpcs',
--	report_server_user_name = 'user',
--	report_server_password = dbo.[FNAEncrypt]('U$er'),
--	report_server_datasource_name = 'TRMTracker_Branch',
--	report_server_target_folder = 'TRMTracker_Branch',
--	report_folder = 'TRMTracker_Branch'
--	PRINT 'Updated ssrs config values on connection_string.'
--END
--ELSE
--BEGIN
--	PRINT 'report_server_url column does not exist.'
--END

/* UPDATE IMAP SETTINGS VALUES USED FOR INCOMING EMAIL EXTRACTION AND PARSING */
--IF COL_LENGTH('connection_string', 'imap_email_address') IS NOT NULL
--BEGIN
--	UPDATE connection_string
--	SET 
--	imap_email_address = 'kenkko.trm@pioneersolutionsglobal.com',
--	imap_email_password = dbo.FNAEncrypt('Teamnepal1'),
--	imap_server_host = 'outlook.office365.com',
--	imap_server_port = 993,
--	imap_require_ssl = 1
--	PRINT 'Updated imap settings values on connection_string.'
--END
--ELSE
--BEGIN
--	PRINT 'imap_email_address column does not exist.'
--END