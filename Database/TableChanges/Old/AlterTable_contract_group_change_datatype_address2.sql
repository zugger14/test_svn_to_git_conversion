IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'contract_group'
        AND  COLUMN_NAME = 'address2')
        BEGIN
        	
        	ALTER TABLE contract_group
			ALTER COLUMN address2 VARCHAR(50)
		
        END
        
        IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'contract_group_audit'
        AND  COLUMN_NAME = 'address2')
        BEGIN
			
			ALTER TABLE contract_group_audit
			ALTER COLUMN address2 VARCHAR(50)
						
        END