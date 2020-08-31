-- UPDATE Deal Confirm and Deal Confirm Collection
UPDATE Contract_report_template
SET template_type = 33,
	document_type = 'r',
	template_category = 42018
WHERE template_type IN (4303, 4305)

-- UPDATE Invoice and Invoice Collection
UPDATE Contract_report_template
SET template_type = 38,
	document_type = 'r'
WHERE template_type IN (4300, 4301)

-- UPDATE Trade Ticket and Trade Ticket Collection
UPDATE Contract_report_template
SET template_type = 33,
	document_type = 'r',
	template_category = 42019
WHERE template_type IN (4302, 4306) 

-- UPDATE Hedge Documentation and Hedge Documentation Collection
UPDATE Contract_report_template
SET template_type = 48,
	document_type = 'r'
WHERE template_type IN (4307, 4308) 