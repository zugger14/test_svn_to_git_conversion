IF NOT EXISTS(select 1 from contract_report_template where template_name = 'Hedging Template')
BEGIN
INSERT INTO contract_report_template
		  (
			template_name,
			template_desc,
			sub_id,
			[filename],
			template_type,
			[default],
			document_type,
			xml_map_filename,
			template_category
		  )
		VALUES
		  (
			'Hedging Template',
			'Hedging Template',
			NULL,
			'Hedging Template',
			48,
			1,
			'r',
			'',
			0
		  )
  END


 IF NOT EXISTS(select * from contract_report_template where template_name = 'Hedging Template - RSQ')
BEGIN
INSERT INTO contract_report_template
		  (
			template_name,
			template_desc,
			sub_id,
			[filename],
			template_type,
			[default],
			document_type,
			xml_map_filename,
			template_category
		  )
		VALUES
		  (
			'Hedging Template - RSQ',
			'Hedging Template - RSQ',
			NULL,
			'Hedging Template - RSQ',
			48,
			0,
			'r',
			'',
			0
		  )
  END
    
