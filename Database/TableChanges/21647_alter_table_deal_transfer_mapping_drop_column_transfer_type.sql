IF COL_LENGTH('deal_transfer_mapping_detail','transfer_type') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping_detail
	DROP COLUMN transfer_type
END