
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[gen_hedge_group_detail]') AND name = N'ind_gen_hedge_group_detail_gen_hedge_group_id')
create index ind_gen_hedge_group_detail_gen_hedge_group_id on dbo.gen_hedge_group_detail (gen_hedge_group_id)

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[gen_fas_link_header]') AND name = N'ind_gen_hedge_group_id_gen_fas_link_header')
create index ind_gen_hedge_group_id_gen_fas_link_header on dbo.gen_fas_link_header (gen_hedge_group_id)


alter table dbo.gen_fas_link_detail alter column percentage_included numeric(18,16)
alter table dbo.fas_link_detail alter column percentage_included numeric(18,16)
	         