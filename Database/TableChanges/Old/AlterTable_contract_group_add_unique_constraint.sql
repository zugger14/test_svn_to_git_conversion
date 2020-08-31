UPDATE contract_group
SET    source_contract_id = contract_name
WHERE  source_contract_id IS NULL

BEGIN
	WITH CTE AS (
		SELECT * , ROW_NUMBER () OVER (PARTITION BY source_contract_id ORDER BY source_contract_id) row_id
		FROM   contract_group 
	)

	UPDATE CTE SET source_contract_id = source_contract_id + CAST(row_id AS VARCHAR(20))  WHERE row_id > 1	
END


IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'contract_group'
                    --AND ccu.COLUMN_NAME = 'source_system_id, source_contract_id'
)
BEGIN
	ALTER TABLE [dbo].[contract_group] WITH NOCHECK ADD CONSTRAINT [UC_contract_group] UNIQUE(source_system_id, source_contract_id)
	PRINT 'Unique Constraints added on contract_group.'	
END
ELSE
BEGIN
	PRINT 'Unique Constraints on contract_group already exists.'
END	