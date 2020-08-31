IF NOT EXISTS (SELECT 1 FROM my_report WHERE dbo.my_report.my_report_name = 'Measurement Report')
BEGIN 
	INSERT INTO dbo.my_report
	(
		my_report_name,
		dashboard_report_flag,
		paramset_hash,
		dashboard_id,
		criteria,
		tooltip,
		my_report_owner,
		role_id,
		column_order,
		group_id,
		display_name,
		application_function_id
	)
	VALUES
	(
		'Measurement Report',
		's', 
		NULL,
		NULL,
		NULL,
		'Measurement Report',
		NULL, 
		0, 
		0, 
		0, 
		'Measurement Report',
		10234900 
	)
END