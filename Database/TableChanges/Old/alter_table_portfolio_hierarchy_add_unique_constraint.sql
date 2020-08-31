IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'portfolio_hierarchy'
                    AND ccu.COLUMN_NAME IN  ('entity_name', 'heerarchy_level','parent_entity_id')                   
)
BEGIN
 ALTER TABLE [dbo].portfolio_hierarchy WITH NOCHECK ADD CONSTRAINT uc_portfolio_hierarchy UNIQUE(entity_name, hierarchy_level,parent_entity_id)
 PRINT 'Unique Constraints added on hierarchy_level, entity_name,parent_entity_id.' 
END
ELSE
BEGIN
 PRINT 'Unique Constraints on hierarchy_level, entity_name, parent_entity_id already exists.'
END



