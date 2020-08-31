IF COL_LENGTH(N'deal_confirmation_rule', 'counterparty_id') is not null
BEGIN
	ALTER TABLE deal_confirmation_rule ALTER COLUMN counterparty_id INT NULL

END

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='UQ_confirmation_rule')
BEGIN
	ALTER TABLE deal_confirmation_rule ADD CONSTRAINT UQ_confirmation_rule UNIQUE (counterparty_id, buy_sell_flag, commodity_id, contract_id, 
																					deal_type_id, confirm_template_id, revision_confirm_template_id,																					deal_template_id, deal_sub_type, origin)
END
