IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'REC Confirmation Template-1')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'REC Confirmation Template-1',
		'REC Confirmation Template-1', 
		NULL
		, 'DCR6'
		, 33
		, 0
		, 42018
		, 'r'
		, null
	)
END




