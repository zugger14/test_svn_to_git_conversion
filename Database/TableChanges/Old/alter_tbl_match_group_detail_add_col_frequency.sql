
IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'match_group_detail' and column_name='frequency')
ALTER TABLE dbo.match_group_detail ADD frequency INT

GO
