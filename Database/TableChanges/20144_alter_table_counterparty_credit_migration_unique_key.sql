SELECT MIN(ccm.counterparty_credit_migration_id) AS id,
       ccm.internal_counterparty,
       ccm.[contract],
       ccm.rating
       INTO                              #temp_db
FROM   counterparty_credit_migration  AS ccm
GROUP BY
       ccm.internal_counterparty,
       ccm.[contract],
       ccm.rating
ORDER BY
       MIN(ccm.counterparty_credit_migration_id)

DELETE 
FROM   counterparty_credit_migration
WHERE  counterparty_credit_migration_id NOT IN (SELECT id
                                                FROM   #temp_db)

DROP TABLE #temp_db

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS cc WHERE cc.CONSTRAINT_NAME = 'AK_Unique_fields' AND cc.TABLE_NAME = 'counterparty_credit_migration')
BEGIN
	ALTER TABLE counterparty_credit_migration DROP CONSTRAINT AK_Unique_fields
END

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE type = 'UQ' AND OBJECT_NAME(parent_object_id) = N'counterparty_credit_migration')
BEGIN
	ALTER TABLE counterparty_credit_migration ADD CONSTRAINT AK_Unique_fields UNIQUE NONCLUSTERED (internal_counterparty, [contract], rating)
END 