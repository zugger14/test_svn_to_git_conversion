DELETE hour_block_term

alter table hour_block_term  ALTER COLUMN [Hr1] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr2] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr3] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr4] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr5] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr6] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr7] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr8] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr9] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr10] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr11] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr12] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr13] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr14] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr15] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr16] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr17] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr18] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr19] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr20] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr21] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr22] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr23] TINYINT
alter table hour_block_term  ALTER COLUMN [Hr24] TINYINT
alter table hour_block_term  ALTER COLUMN  volume_mult int

IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE [name]='add_dst_hour' AND [object_id]=OBJECT_ID('hour_block_term'))
alter table hour_block_term add add_dst_hour TINYINT



