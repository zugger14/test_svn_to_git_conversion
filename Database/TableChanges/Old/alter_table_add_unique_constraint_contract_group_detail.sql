IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'contract_group_detail'
                    AND ccu.COLUMN_NAME IN ('invoice_line_item_id', 'contract_id')
)
BEGIN
	ALTER TABLE [dbo].[contract_group_detail] WITH NOCHECK ADD CONSTRAINT [UC_contract_group_detail] UNIQUE(invoice_line_item_id, contract_id)
	PRINT 'Unique Constraints added on contract_group_detail.'	
END
ELSE
BEGIN
	PRINT 'Unique Constraints on contract_group_detail already exists.'
END	