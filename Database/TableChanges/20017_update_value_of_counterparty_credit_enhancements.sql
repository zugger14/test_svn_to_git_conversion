UPDATE counterparty_credit_enhancements
SET  contract_id = IIF(contract_id = '' OR contract_id = 0,NULL,contract_id)
	,internal_counterparty = IIF(internal_counterparty = '' OR internal_counterparty = 0,NULL,internal_counterparty)
	,deal_id = IIF(deal_id = '' OR deal_id = 0,NULL,deal_id)
WHERE contract_id = '' OR contract_id = 0 
	OR internal_counterparty = '' OR internal_counterparty = 0
	OR deal_id = '' OR deal_id = 0
	
	