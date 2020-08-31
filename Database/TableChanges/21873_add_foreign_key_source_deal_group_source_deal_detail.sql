IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_deal_groups'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_deal_groups ADD CONSTRAINT PK_source_deal_groups PRIMARY KEY CLUSTERED (source_deal_groups_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_source_deal_groups already exist in source_deal_groups'
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_deal_groups_source_deal_detail]')
					 AND parent_object_id = OBJECT_ID(N'[dbo].[source_deal_detail]'))
BEGIN
	ALTER TABLE [dbo].[source_deal_detail] ADD CONSTRAINT [FK_source_deal_groups_source_deal_detail] 
	FOREIGN KEY([source_deal_group_id])
	REFERENCES [dbo].[source_deal_groups] ([source_deal_groups_id])
END