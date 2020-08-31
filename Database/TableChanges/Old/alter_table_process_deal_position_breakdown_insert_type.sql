IF COL_LENGTH('process_deal_position_breakdown','insert_type') IS NULL 
	alter table dbo.process_deal_position_breakdown add insert_type int,deal_type int,commodity_id int,fixation int
