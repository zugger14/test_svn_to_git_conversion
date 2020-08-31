IF COL_LENGTH('status_rule_activity','status_rule_detail_id') IS NULL 
ALTER TABLE status_rule_activity ADD status_rule_detail_id INT

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'status_rule_activity'      --table name
                    AND ccu.COLUMN_NAME = 'status_rule_detail_id'       --column
               )
ALTER TABLE status_rule_activity ADD CONSTRAINT [FK_status_rule_detail_id] FOREIGN KEY (status_rule_detail_id)
REFERENCES status_rule_detail(status_rule_detail_id)

    