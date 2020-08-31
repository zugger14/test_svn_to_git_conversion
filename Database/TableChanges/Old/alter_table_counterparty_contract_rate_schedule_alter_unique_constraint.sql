IF COL_LENGTH('counterparty_contract_rate_schedule', 'path_id') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_rate_schedule ADD path_id INT
END
GO

--To alter Constraint Dropping Constraint is neccessary

IF  EXISTS(SELECT tc.Constraint_name
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'counterparty_contract_rate_schedule'
                    AND ccu.COLUMN_NAME IN ('counterparty_id', 'contract_id')
					and tc.Constraint_name ='IX_counterparty_contract'
)
BEGIN

	ALTER TABLE counterparty_contract_rate_schedule DROP CONSTRAINT IX_counterparty_contract
END	


-- Alter Table Create Constraint


IF  not EXISTS(SELECT tc.Constraint_name
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'counterparty_contract_rate_schedule'
                    AND ccu.COLUMN_NAME IN ('counterparty_id', 'contract_id','path_id')
					and tc.Constraint_name ='IX_counterparty_contract_path_id'
)
BEGIN

	 ALTER TABLE counterparty_contract_rate_schedule 
	 ADD CONSTRAINT IX_counterparty_contract_path_id
	 UNIQUE NONCLUSTERED([counterparty_id] ASC, [contract_id] ASC, [path_id] ASC)
END	



