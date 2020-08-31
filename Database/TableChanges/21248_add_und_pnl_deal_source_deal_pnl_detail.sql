
IF COL_LENGTH('source_deal_pnl_detail', 'und_pnl_deal') IS NULL
BEGIN

	--  select * from source_deal_pnl_detail
	alter table source_deal_pnl_detail add [und_pnl_deal] [float]
	alter table source_deal_pnl_detail add [und_pnl_inv] [float]
	alter table source_deal_pnl_detail add deal_cur_id int
	alter table source_deal_pnl_detail add inv_cur_id int

	--  select * from source_deal_pnl
	alter table source_deal_pnl add [und_pnl_deal] [float]
	alter table source_deal_pnl add [und_pnl_inv] [float]
	alter table source_deal_pnl add deal_cur_id int
	alter table source_deal_pnl add inv_cur_id int


		--  select * from source_deal_pnl_settlement
	alter table source_deal_pnl_settlement add [und_pnl_deal] [float]
	alter table source_deal_pnl_settlement add [und_pnl_inv] [float]
	alter table source_deal_pnl_settlement add deal_cur_id int
	alter table source_deal_pnl_settlement add inv_cur_id int

	--  select * from source_deal_pnl_breakdown
	alter table source_deal_pnl_breakdown add [leg_mtm_deal] [float]
	alter table source_deal_pnl_breakdown add [leg_mtm_inv] [float]
	alter table source_deal_pnl_breakdown add [leg_set_deal] [float]
	alter table source_deal_pnl_breakdown add [leg_set_inv] [float]
	alter table source_deal_pnl_breakdown add deal_cur_id int
	alter table source_deal_pnl_breakdown add inv_cur_id int

	--  select * from index_fees_breakdown
	alter table index_fees_breakdown add [value_deal] [float]
	alter table index_fees_breakdown add [value_inv] [float]
	alter table index_fees_breakdown add deal_cur_id int
	alter table index_fees_breakdown add inv_cur_id int

	--  select * from source_deal_settlement --settlement_amount
	alter table source_deal_settlement add [settlement_amount_deal] [float]
	alter table source_deal_settlement add [settlement_amount_inv] [float]
	alter table source_deal_settlement add deal_cur_id int
	alter table source_deal_settlement add inv_cur_id int

	--select * from source_deal_settlement_breakdown
	alter table source_deal_settlement_breakdown add [leg_mtm_deal] [float]
	alter table source_deal_settlement_breakdown add [leg_mtm_inv] [float]
	alter table source_deal_settlement_breakdown add [leg_set_deal] [float]
	alter table source_deal_settlement_breakdown add [leg_set_inv] [float]
	alter table source_deal_settlement_breakdown add deal_cur_id int
	alter table source_deal_settlement_breakdown add inv_cur_id int

	--  select * from index_fees_breakdown_settlement
	alter table index_fees_breakdown_settlement add [value_deal] [float]
	alter table index_fees_breakdown_settlement add [value_inv] [float]
	alter table index_fees_breakdown_settlement add deal_cur_id int
	alter table index_fees_breakdown_settlement add inv_cur_id int


end



/*


	--  select * from source_deal_pnl_detail
	alter table source_deal_pnl_detail drop column [und_pnl_deal] 
	alter table source_deal_pnl_detail drop column [und_pnl_inv] 
	alter table source_deal_pnl_detail drop column deal_cur_id 
	alter table source_deal_pnl_detail drop column inv_cur_id 

	--  select * from source_deal_pnl
	alter table source_deal_pnl drop column [und_pnl_deal] 
	alter table source_deal_pnl drop column [und_pnl_inv] 
	alter table source_deal_pnl drop column deal_cur_id 
	alter table source_deal_pnl drop column inv_cur_id 

	--  select * from source_deal_pnl_breakdown
	alter table source_deal_pnl_breakdown drop column [und_pnl_deal] 
	alter table source_deal_pnl_breakdown drop column [und_pnl_inv] 
	alter table source_deal_pnl_breakdown drop column deal_cur_id 
	alter table source_deal_pnl_breakdown drop column inv_cur_id 

	--  select * from index_fees_breakdown
	alter table index_fees_breakdown drop column [value_deal] 
	alter table index_fees_breakdown drop column [value_inv] 
	alter table index_fees_breakdown drop column deal_cur_id 
	alter table index_fees_breakdown drop column inv_cur_id 

	--  select * from source_deal_settlement --settlement_amount
	alter table source_deal_settlement drop column [settlement_amount_deal] 
	alter table source_deal_settlement drop column [settlement_amount_inv] 
	alter table source_deal_settlement drop column deal_cur_id 
	alter table source_deal_settlement drop column inv_cur_id 

	--select * from source_deal_settlement_breakdown
	alter table source_deal_settlement_breakdown drop column [leg_mtm_deal] 
	alter table source_deal_settlement_breakdown drop column [leg_mtm_inv] 
	alter table source_deal_settlement_breakdown drop column [leg_set_deal] 
	alter table source_deal_settlement_breakdown drop column [leg_set_inv] 
	alter table source_deal_settlement_breakdown drop column deal_cur_id 
	alter table source_deal_settlement_breakdown drop column inv_cur_id 

	--  select * from index_fees_breakdown_settlement
	alter table index_fees_breakdown_settlement drop column [value_deal] 
	alter table index_fees_breakdown_settlement drop column [value_inv] 
	alter table index_fees_breakdown_settlement drop column deal_cur_id 
	alter table index_fees_breakdown_settlement drop column inv_cur_id 




*/