IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'tbl_sims_status' and column_name='create_ts')
ALTER TABLE dbo.tbl_sims_status ADD create_ts DATETIME DEFAULT GETDATE()

GO

IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'tbl_sims_status' and column_name='create_user')
ALTER TABLE dbo.tbl_sims_status ADD create_user VARCHAR(100)

GO

IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'tbl_sims_status' and column_name='update_ts')
ALTER TABLE dbo.tbl_sims_status ADD update_ts DATETIME 

GO

