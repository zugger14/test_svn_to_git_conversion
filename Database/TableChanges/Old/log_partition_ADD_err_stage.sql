IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE [name]='err_stage' AND [object_id]=object_id('log_partition'))
ALTER TABLE log_partition ADD err_stage int