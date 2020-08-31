IF EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
       WHERE  tc.CONSTRAINT_NAME='UK_template_counterparty_id'
   )
BEGIN
    ALTER TABLE deal_fields_mapping DROP CONSTRAINT UK_template_counterparty_id
    
    ALTER TABLE deal_fields_mapping ADD CONSTRAINT UK_deal_fields_mapping 
    UNIQUE(template_id, deal_type_id, commodity_id, counterparty_id)
END

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_fields_mapping_locations')
BEGIN
	ALTER TABLE deal_fields_mapping_locations DROP CONSTRAINT UC_deal_fields_mapping_locations
	 
	ALTER TABLE deal_fields_mapping_locations
	ADD CONSTRAINT UC_deal_fields_mapping_locations UNIQUE (deal_fields_mapping_id,location_group,commodity_id,location_id)
END

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_fields_mapping_contracts')
BEGIN
	ALTER TABLE deal_fields_mapping_contracts DROP CONSTRAINT UC_deal_fields_mapping_contracts
	 
	ALTER TABLE deal_fields_mapping_contracts
	ADD CONSTRAINT UC_deal_fields_mapping_contracts UNIQUE (deal_fields_mapping_id,subsidiary_id,contract_id)
END

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_fields_mapping_curves')
BEGIN
	ALTER TABLE deal_fields_mapping_curves DROP CONSTRAINT UC_deal_fields_mapping_curves
	 
	ALTER TABLE deal_fields_mapping_curves
	ADD CONSTRAINT UC_deal_fields_mapping_curves UNIQUE (deal_fields_mapping_id,index_group,market,commodity_id,curve_id)
END

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_fields_mapping_formula_curves')
BEGIN
	ALTER TABLE deal_fields_mapping_formula_curves DROP CONSTRAINT UC_deal_fields_mapping_formula_curves
	 
	ALTER TABLE deal_fields_mapping_formula_curves
	ADD CONSTRAINT UC_deal_fields_mapping_formula_curves UNIQUE (deal_fields_mapping_id,index_group,market,commodity_id,formula_curve_id)
END

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_fields_mapping_counterparty')
BEGIN
	ALTER TABLE deal_fields_mapping_counterparty DROP CONSTRAINT UC_deal_fields_mapping_counterparty
	 
	ALTER TABLE deal_fields_mapping_counterparty
	ADD CONSTRAINT UC_deal_fields_mapping_counterparty UNIQUE (deal_fields_mapping_id,counterparty_type,entity_type,counterparty_id)
END
ELSE
BEGIN
	ALTER TABLE deal_fields_mapping_counterparty
	ADD CONSTRAINT UC_deal_fields_mapping_counterparty UNIQUE (deal_fields_mapping_id,counterparty_type,entity_type,counterparty_id)
END