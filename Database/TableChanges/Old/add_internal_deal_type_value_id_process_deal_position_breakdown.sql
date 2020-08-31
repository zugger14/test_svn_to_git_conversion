IF COL_LENGTH('process_deal_position_breakdown', 'internal_deal_type_value_id') IS NULL
BEGIN
	alter table dbo.process_deal_position_breakdown add internal_deal_type_value_id int
END
GO

