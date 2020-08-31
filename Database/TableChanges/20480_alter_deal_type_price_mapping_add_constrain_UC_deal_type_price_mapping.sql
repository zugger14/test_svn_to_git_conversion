IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_type_price_mapping')
BEGIN
	ALTER TABLE deal_type_pricing_maping
		ADD CONSTRAINT UC_deal_type_price_mapping UNIQUE (template_id,source_deal_type_id,pricing_type)
END

