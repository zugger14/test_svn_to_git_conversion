

IF OBJECT_ID('tempdb..#contract_report_template_to_be_delete') IS NOT NULL
	DROP TABLE #contract_report_template_to_be_delete
CREATE table #contract_report_template_to_be_delete(template_id INT , template_name VARCHAR(500))

INSERT INTO #contract_report_template_to_be_delete
SELECT template_id, template_name FROM contract_report_template
		WHERE template_name   NOT IN   (
				'Charge Type Level'
				,'Charge Type Level with Deal'
				,'Charge Type Level with Deal Without VAT'
				,'Charge Type Level Without VAT'
				,'Deal Level'
				,'Deal Level without VAT'
				,'EEI Deal Confirmation'
				,'Gas Confirmation'
				,'Gas Confirmation Collection'
				,'ISDA Deal Confirmation'
				,'WSPP Deal Confirmation'
				,'Trade Ticket'
				,'Trade Ticket Collection'
				, 'EFET Template' 
				, 'Invoice Report Collection'
				)

UPDATE ng
	SET ng.invoice_template = NULL
FROM #contract_report_template_to_be_delete cd
INNER JOIN netting_group ng ON cd.template_id = ng.invoice_template

UPDATE sng
	SET sng.template_id = NULL
FROM #contract_report_template_to_be_delete cd
INNER JOIN settlement_netting_group sng ON cd.template_id = sng.template_id

UPDATE sdh
	SET sdh.confirmation_template = NULL
FROM #contract_report_template_to_be_delete cd
INNER JOIN source_deal_header sdh ON cd.template_id = sdh.confirmation_template



DELETE FROM contract_report_template
WHERE template_name   NOT IN   (
		'Charge Type Level'
		,'Charge Type Level with Deal'
		,'Charge Type Level with Deal Without VAT'
		,'Charge Type Level Without VAT'
		,'Deal Level'
		,'Deal Level without VAT'
		,'EEI Deal Confirmation'
		,'Gas Confirmation'
		,'Gas Confirmation Collection'
		,'ISDA Deal Confirmation'
		,'WSPP Deal Confirmation'
		,'Trade Ticket'
		,'Trade Ticket Collection'
		, 'EFET Template' 
		, 'Invoice Report Collection'
		)
		
				
UPDATE admin_email_configuration SET  template_name =  'Email Template'  WHERE  template_name =  'Invoice Template' and module_type = 17804
