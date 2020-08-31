IF COL_LENGTH('source_deal_detail', 'syv_time_of_use') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail DROP COLUMN syv_time_of_use	
END
