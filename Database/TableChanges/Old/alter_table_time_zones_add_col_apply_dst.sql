IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'time_zones' and column_name='apply_dst')
ALTER TABLE dbo.time_zones ADD apply_dst VARCHAR(1)