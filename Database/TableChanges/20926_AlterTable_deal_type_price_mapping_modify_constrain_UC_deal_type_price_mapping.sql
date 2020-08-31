IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_type_price_mapping')
BEGIN
	ALTER TABLE deal_type_pricing_maping DROP CONSTRAINT UC_deal_type_price_mapping

	ALTER TABLE deal_type_pricing_maping
		ADD CONSTRAINT UC_deal_type_price_mapping UNIQUE (template_id,source_deal_type_id,pricing_type,commodity_id)
END

