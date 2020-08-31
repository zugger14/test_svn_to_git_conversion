IF EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
       WHERE  tc.CONSTRAINT_NAME='UK_template_id'
   )
BEGIN
    ALTER TABLE deal_fields_mapping DROP CONSTRAINT UK_template_id
    
    ALTER TABLE deal_fields_mapping ADD CONSTRAINT UK_template_counterparty_id 
    UNIQUE(counterparty_id, template_id)
END