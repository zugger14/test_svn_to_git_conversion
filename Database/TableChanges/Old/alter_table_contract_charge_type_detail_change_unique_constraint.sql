
IF NOT EXISTS (
           SELECT 1
           FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
           WHERE  TABLE_NAME              = 'contract_charge_type_detail'
                  AND CONSTRAINT_TYPE     = 'UNIQUE'
                  AND CONSTRAINT_NAME     = 'IX_contract_charge_type_detail_template'
       )
    BEGIN
        ALTER TABLE contract_charge_type_detail
        ADD CONSTRAINT IX_contract_charge_type_detail_template UNIQUE(contract_charge_type_id, invoice_line_item_id)
    END
ELSE
    BEGIN
        PRINT  'Already exists unique contraint IX_contract_charge_type_detail_template  .'
    END 
GO