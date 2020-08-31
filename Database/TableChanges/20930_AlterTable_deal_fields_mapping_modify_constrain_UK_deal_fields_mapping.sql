IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UK_deal_fields_mapping')
BEGIN
	ALTER TABLE deal_fields_mapping DROP CONSTRAINT UK_deal_fields_mapping

	ALTER TABLE deal_fields_mapping
		ADD CONSTRAINT UK_deal_fields_mapping UNIQUE (template_id,deal_type_id,commodity_id,counterparty_id,trader_id)
END

