

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[hour_block_term]') AND name = N'uci_hour_block_term')
	drop index uci_hour_block_term	on dbo.hour_block_term
	
create  unique clustered index uci_hour_block_term on dbo.hour_block_term(dst_group_value_id, block_define_id, term_date)

IF OBJECT_ID('PK_hourly_block') IS not NULL
	ALTER TABLE [dbo].[hourly_block] DROP CONSTRAINT [PK_hourly_block]

-- alter table hourly_block drop column onpeak_offpeak


IF  EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[hourly_block]') AND name = N'indx_uniq_cur_hourly_block')
	drop index indx_uniq_cur_hourly_block on dbo.hourly_block

create unique clustered index indx_uniq_cur_hourly_block on dbo.hourly_block (block_value_id, week_day)


IF OBJECT_ID('PK_mv90_DST') IS not NULL
	ALTER TABLE [dbo].[mv90_DST] DROP CONSTRAINT [PK_mv90_DST]

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[mv90_dst]') AND name = N'indx_uniq_cur_mv90_dst')
	create unique clustered index indx_uniq_cur_mv90_dst on dbo.mv90_dst (dst_group_value_id,[date])


delete hourly_block where onpeak_offpeak = 'o' 

insert into dbo.mv90_dst(
	[year],
	[date],
	[hour],
	insert_delete,
	create_user,
	create_ts,
	update_user,
	update_ts,
	dst_group_value_id
)
select [year],
	[date],
	[hour],
	insert_delete,
	create_user,
	create_ts,
	update_user,
	update_ts,
	102201 dst_group_value_id
from dbo.mv90_dst
where dst_group_value_id is null

update dbo.mv90_dst set dst_group_value_id=102200 where dst_group_value_id is null

update time_zones set dst_group_value_id=102200 where dst_group_value_id is null