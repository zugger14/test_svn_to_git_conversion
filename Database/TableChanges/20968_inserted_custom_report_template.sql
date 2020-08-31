
/* Delete all custom report template */
UPDATE ng
	SET ng.invoice_template = NULL
FROM contract_report_template cd
INNER JOIN netting_group ng ON cd.template_id = ng.invoice_template

UPDATE sng
	SET sng.template_id = NULL
FROM contract_report_template cd
INNER JOIN settlement_netting_group sng ON cd.template_id = sng.template_id

UPDATE sdh
	SET sdh.confirmation_template = NULL
FROM contract_report_template cd
INNER JOIN source_deal_header sdh ON cd.template_id = sdh.confirmation_template

DELETE FROM contract_report_template



/*Insert report template*/

--DEAL TEMPLATE
IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'Confirm Replacement Report Collection')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'Confirm Replacement Report Collection',
		'Confirm Replacement Report Collection', 
		null
		, 'Confirm Replacement Report Collection'
		, 33
		, 1
		, 42023
		, 'r'
		, null
	)
END
 

IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'WSPP Deal')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'WSPP Deal',
		'WSPP Deal', 
		null
		, 'DCR1'
		, 33
		, 0
		, 42018
		, 'r'
		, null
	)
END

IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'ISDA Deal')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'ISDA Deal',
		'ISDA Deal', 
		null
		, 'DCR2'
		, 33
		, 1
		, 42018
		, 'r'
		, null
	)
END


IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'EEI Deal')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'EEI Deal',
		'EEI Deal', 
		null
		, 'DCR3'
		, 33
		, 0
		, 42018
		, 'r'
		, null
	)
END

IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'EFET Deal')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'EFET Deal',
		'EFET Deal', 
		null
		, 'DCR4'
		, 33
		, 0
		, 42018
		, 'r'
		, null
	)
END

-- INVOICE TEMPLATE

IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'Invoice Report Collection')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'Invoice Report Collection',
		'Invoice Report Collection', 
		null
		, 'Invoice Report Collection'
		, 38
		, 1
		, 42024
		, 'r'
		, null
	)
END


IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'Charge Type Level with Deal')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'Charge Type Level with Deal',
		'Charge Type Level with Deal', 
		null
		, 'I1'
		, 38
		, 0
		, 1
		, 'r'
		, null
	)
END


IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'Charge Type Level')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'Charge Type Level',
		'Charge Type Level', 
		null
		, 'I2'
		, 38
		, 0
		, null
		, 'r'
		, null
	)
END


IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'Deal Level Without VAT')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'Deal Level Without VAT',
		'Deal Level Without VAT', 
		null
		, 'I3'
		, 38
		, 0
		, 0
		, 'r'
		, null
	)
END



IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'Charge Type Level Without VAT')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'Charge Type Level Without VAT',
		'Charge Type Level Without VAT', 
		null
		, 'I4'
		, 38
		, 0
		, 0
		, 'r'
		, null
	)
END


IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'Charge Type Level with Deal Without VAT')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'Charge Type Level with Deal Without VAT',
		'Charge Type Level with Deal Without VAT', 
		null
		, 'I5'
		, 38
		, 0
		, 0
		, 'r'
		, null
	)
END


IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'Deal Level')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'Deal Level',
		'Deal Level', 
		null
		, 'I6'
		, 38
		, 0
		, 0
		, 'r'
		, null
	)
END


-- Trade Ticket Template
IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'Trade Ticket Collection')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'Trade Ticket Collection',
		'Trade Ticket Collection', 
		null
		, 'Trade Ticket Collection'
		, 33
		, 1
		, 42022
		, 'r'
		, null
	)
END

IF NOT EXISTS(SELECT 1 FROM contract_report_template WHERE template_name = 'Trade Ticket')
BEGIN 
	INSERT INTO contract_report_template ( template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES (
		'Trade Ticket',
		'Trade Ticket', 
		null
		, 'TT1'
		, 33
		, 1
		, 42019
		, 'r'
		, null
	)
END
