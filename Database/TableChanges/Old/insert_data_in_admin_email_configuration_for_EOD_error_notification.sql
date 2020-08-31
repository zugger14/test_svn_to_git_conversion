IF NOT EXISTS (SELECT 1 FROM admin_email_configuration WHERE email_subject = 'EOD Error Notification')
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
		3,
		'EOD Error Notification',
		'<body><p>Dear <TRM_USER_LAST_NAME>,</p><p>EOD Process ran for date: <EOD_RUN_DATE> with following status</p><p><EOD_STATUS></p><p>Please check log report for details.</p></body>',
		'',
		17802
	)
END