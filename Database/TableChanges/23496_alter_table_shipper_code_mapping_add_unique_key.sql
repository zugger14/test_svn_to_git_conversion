IF NOT EXISTS(
       SELECT 'X'
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS
       WHERE  CONSTRAINT_NAME = 'UC_shipper_code_mapping'
   )
BEGIN
    ALTER TABLE shipper_code_mapping
    ADD CONSTRAINT UC_shipper_code_mapping UNIQUE(effective_date,counterparty_id,location_id)
END


