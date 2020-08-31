
IF EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'setup_workflow'      --table name
                    AND ccu.COLUMN_NAME = 'menu_name'       --column name where UNIQUE constaint/index is to be created
)
ALTER TABLE [dbo].[setup_workflow] DROP CONSTRAINT [UIX_setup_workflow_menu_name]