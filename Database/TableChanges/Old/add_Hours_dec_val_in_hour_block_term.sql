IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE NAME='hours_dec_val' AND [object_id]=OBJECT_ID('hour_block_term'))
alter table hour_block_term ADD hours_dec_val int