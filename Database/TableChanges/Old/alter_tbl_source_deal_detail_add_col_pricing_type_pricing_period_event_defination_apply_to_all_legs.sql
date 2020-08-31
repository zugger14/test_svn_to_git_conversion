IF COL_LENGTH('source_deal_detail', 'apply_to_all_legs') IS NULL
BEGIN 
	ALTER TABLE source_deal_detail 
	ADD pricing_type CHAR(1),
	pricing_period CHAR(1),
	event_defination CHAR(1),
	apply_to_all_legs CHAR(1)
END
