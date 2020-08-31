IF OBJECT_ID('UQ_confirmation_rule', 'UQ') IS NOT NULL 
BEGIN
	ALTER TABLE deal_confirmation_rule 
	DROP CONSTRAINT UQ_confirmation_rule 

	ALTER TABLE deal_confirmation_rule
	ADD CONSTRAINT UQ_confirmation_rule
	UNIQUE (counterparty_id, buy_sell_flag, commodity_id, contract_id, deal_type_id, confirm_template_id, revision_confirm_template_id, deal_template_id, deal_sub_type, origin, deal_status, confirm_status)

	PRINT 'Unique Constraint UQ_confirmation_rule has been Updated successfully.'
END
ELSE
	PRINT 'Constraint UQ_confirmation_rule not exists.'


