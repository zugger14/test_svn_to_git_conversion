IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
		INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.constraint_name = kcu.constraint_name
			AND kcu.column_name = 'ixp_rule_hash'
			AND tc.table_name = 'ixp_rules'
			AND tc.constraint_type = 'UNIQUE'
		)
BEGIN
	ALTER TABLE [dbo].[ixp_rules] ADD CONSTRAINT UQ_ixp_rule_hash UNIQUE (ixp_rule_hash)
END
