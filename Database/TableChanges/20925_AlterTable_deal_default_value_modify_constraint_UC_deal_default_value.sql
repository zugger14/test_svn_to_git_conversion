IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_default_value')
BEGIN
	ALTER TABLE deal_default_value DROP CONSTRAINT UC_deal_default_value
	
	ALTER TABLE deal_default_value
	ADD CONSTRAINT UC_deal_default_value UNIQUE (deal_type_id, pricing_type, commodity, buy_sell_flag)
END