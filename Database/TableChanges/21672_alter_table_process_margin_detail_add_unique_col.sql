


IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'process_margin_detail'     
					AND tc.CONSTRAINT_NAME = 'UC_process_margin_detail'
      
)
BEGIN
	ALTER TABLE process_margin_detail ADD CONSTRAINT UC_process_margin_detail UNIQUE (process_margin_header_id, effective_date)
END 

