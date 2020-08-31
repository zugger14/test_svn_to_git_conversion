IF NOT EXISTS(SELECT 1 
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc 
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME 
                AND tc.Constraint_name = ccu.Constraint_name     
                AND tc.CONSTRAINT_TYPE = 'UNIQUE' 
                AND tc.Table_Name = 'gen_hedge_group'     
                AND ccu.COLUMN_NAME = 'gen_hedge_group_name' 
) 
ALTER TABLE [dbo].gen_hedge_group WITH NOCHECK ADD CONSTRAINT [UC_GEN_HEDGE_GROUP_NAME] UNIQUE(gen_hedge_group_name) 

GO 

IF NOT EXISTS(SELECT 1 
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc 
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME 
                AND tc.Constraint_name = ccu.Constraint_name     
                AND tc.CONSTRAINT_TYPE = 'UNIQUE' 
                AND tc.Table_Name = 'fas_eff_hedge_rel_type'     
                AND ccu.COLUMN_NAME = 'eff_test_name' 
) 
ALTER TABLE [dbo].fas_eff_hedge_rel_type WITH NOCHECK ADD CONSTRAINT [UC_EFF_TEST_NAME] UNIQUE(eff_test_name) 

GO

