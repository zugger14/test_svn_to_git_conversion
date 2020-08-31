IF COL_LENGTH('process_deal_position_breakdown','error_description') IS NULL 
	alter table dbo.process_deal_position_breakdown add error_description varchar(5000)