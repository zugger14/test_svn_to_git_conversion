IF NOT EXISTS (SELECT 1 FROM contract_report_template WHERE template_name = 'No Confirmation')
BEGIN 
	SET IDENTITY_INSERT contract_report_template ON  	
	INSERT INTO contract_report_template
	(
		template_id,
		template_name,
		template_desc,
		sub_id,
		[filename],
		template_type
	)
	VALUES
	(
		'-1',
		'No Confirmation',
		'No Confirmation',
		NULL,
		NULL,
		33
	)      
	SET IDENTITY_INSERT contract_report_template OFF
END

GO

