IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
		AND tc.CONSTRAINT_TYPE = 'UNIQUE'
		AND tc.TABLE_NAME = 'contract_group'
		AND ccu.COLUMN_NAME = 'source_contract_id'
		AND tc.CONSTRAINT_NAME = 'UC_contract_group'
)
BEGIN
	ALTER TABLE [contract_group] DROP CONSTRAINT [UC_contract_group]
	PRINT 'Constraint Removed'
END

IF NOT EXISTS(SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
        AND tc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.TABLE_NAME = 'contract_group'
        AND ccu.COLUMN_NAME = 'source_contract_id'
)
BEGIN
	ALTER TABLE [dbo].[contract_group] WITH NOCHECK ADD CONSTRAINT [UC_source_contract_id] UNIQUE(source_system_id, source_contract_id)
	PRINT 'Constraint UC_source_contract_id added'
END
ELSE
BEGIN
	PRINT 'Constraint UC_source_contract_id exists'
END

GO