IF EXISTS (SELECT 1 FROM static_data_type WHERE [type_id] = 4300 AND [type_name] = 'Template Type')
BEGIN
		DELETE crt2
	FROM Contract_report_template AS crt2
	INNER JOIN static_data_value AS sdv ON sdv.value_id = crt2.template_type
	INNER JOIN static_data_type AS sdt ON sdv.[type_id] = sdt.[type_id]
	WHERE sdv.type_id = 4300 AND sdt.[type_name] = 'Template Type'
	
END
GO

