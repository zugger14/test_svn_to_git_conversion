--Author: Santosh Gupta
--Dated: January 24 2012
--Issue against: 5784
--Purpose: Inserting Email Template in Admin_email_configuration.
--adding in Maintain Config 
DELETE admin_email_configuration WHERE cust_id = 4
insert into admin_email_configuration (cust_id,email_subject,email_body,mail_server_name,module_type)
values(4,'DB-Maintenance: Tempdb Size Limit Exceeded!!!','<body><p>Dear Team, </p><p><b>Please be informed that TempDb size exceeded than limit.</b><p><br> Total DB Size :<TRM_TEMPDB_TOT_SIZE> GB <P>Maximum Size Limit : <TRM_TEMPDB_SIZE_LIMIT> GB<p> Instance Name : <TRM_TEMPDB_INSTANCE><HR><P> 
SUGGESTION: Perform following DBCC maintenance commands to release used space <P>
USE TEMPDB <P>GO <P>DBCC FREESYSTEMCACHE("ALL"); <P>DBCC FREESESSIONCACHE; <P>
DBCC SHRINKDATABASE (N"tempdb", TRUNCATEONLY) <P>GO <p><p><p><br> Thanks </body>',null,17803)
GO