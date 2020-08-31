IF COL_LENGTH('gen_deal_header', 'gen_hedge_group_id') IS NULL
BEGIN
	alter table gen_deal_header add gen_hedge_group_id int
	alter table gen_hedge_group add process_id varchar(50)
	alter table gen_hedge_group_detail add  process_id varchar(50)

END
GO


