IF NOT EXISTS (SELECT 1 FROM admin_email_configuration WHERE email_subject = 'Data Import Error Notification')
BEGIN
	INSERT INTO admin_email_configuration
	(
		cust_id,
		email_subject,
		email_body,
		mail_server_name,
		module_type
	)
	VALUES
	(
		2,
		'Data Import Error Notification',
		'<body><p>Dear <TRM_USER_LAST_NAME>,</p><p>CRITICAL:Import process completed for "<TRM_IMPORT_SOURCE>" for as of date: <TRM_IMPORT_AS_OF_DATE></p><p><TRM_IMPORT_SOURCE_MSG></p><p>Generated on: <TRM_DATE></p></body>',
		'TRMTrackerMail',
		17805
	)
END



