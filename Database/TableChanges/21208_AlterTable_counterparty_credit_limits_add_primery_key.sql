IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND   tc.Table_Name = 'counterparty_credit_limits' 
                    AND ccu.COLUMN_NAME = 'counterparty_credit_limit_id'
)
ALTER TABLE [dbo].[counterparty_credit_limits] WITH NOCHECK ADD CONSTRAINT [PK_counterparty_credit_limits] PRIMARY KEY([counterparty_credit_limit_id])
GO