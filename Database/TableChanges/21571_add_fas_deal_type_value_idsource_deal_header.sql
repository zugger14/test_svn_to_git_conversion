


IF COL_LENGTH('source_deal_header', 'fas_deal_type_value_id') IS NULL
BEGIN
	alter table dbo.source_deal_header add fas_deal_type_value_id int
END




