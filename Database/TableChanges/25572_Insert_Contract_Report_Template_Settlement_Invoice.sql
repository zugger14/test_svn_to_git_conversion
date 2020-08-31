IF NOT EXISTS(SELECT 1 FROM Contract_report_template WHERE template_name = 'Settlement Invoice' AND template_type = 10000283)
BEGIN
	INSERT INTO Contract_report_template (template_name, template_desc, template_type, [default], template_category, document_type)
	SELECT 'Settlement Invoice', 'Settlement Invoice', 10000283, 0, 0, 'r'
END