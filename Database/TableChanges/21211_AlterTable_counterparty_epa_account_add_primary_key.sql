IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND   tc.Table_Name = 'counterparty_epa_account' 
                    AND ccu.COLUMN_NAME = 'counterparty_epa_account_id'
)
ALTER TABLE [dbo].[counterparty_epa_account] WITH NOCHECK ADD CONSTRAINT [PK_counterparty_epa_account] PRIMARY KEY([counterparty_epa_account_id])
GO