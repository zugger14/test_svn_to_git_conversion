--source_remit_standard
IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'source_remit_standard' and column_name='update_user')
ALTER TABLE source_remit_standard ADD update_user VARCHAR(50)
IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'source_remit_standard' and column_name='update_ts')
ALTER TABLE source_remit_standard ADD update_ts DATETIME

--source_remit_non_standard
IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'source_remit_non_standard' and column_name='update_user')
ALTER TABLE source_remit_non_standard ADD update_user VARCHAR(50)
IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'source_remit_non_standard' and column_name='update_ts')
ALTER TABLE source_remit_non_standard ADD update_ts DATETIME
