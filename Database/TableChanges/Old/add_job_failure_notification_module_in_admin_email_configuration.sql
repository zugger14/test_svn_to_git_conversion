IF NOT EXISTS(SELECT 1 FROM admin_email_configuration WHERE module_type = 17801)
BEGIN
	INSERT INTO admin_email_configuration (cust_id, email_body, email_subject, module_type)
	SELECT 2, '<body>
			<p>Dear <TRM_USER_LAST_NAME>,</p>
			<p>Following error has occured while running job "<TRM_JOB_NAME>":</p>
			<p><TRM_ERROR></p>
			<p>Generated on: <TRM_DATE></p>
			</body>', 'TRMTracker Job Failure', 17801
END