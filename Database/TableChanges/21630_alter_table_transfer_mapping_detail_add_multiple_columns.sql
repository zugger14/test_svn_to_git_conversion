IF COL_LENGTH('transfer_mapping_detail','location_id') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD location_id VARCHAR(100) NULL
END

IF COL_LENGTH('transfer_mapping_detail','transfer_volume') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD transfer_volume float NULL

END

IF COL_LENGTH('transfer_mapping_detail','volume_per') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD volume_per float NULL
END

IF COL_LENGTH('transfer_mapping_detail','pricing_options') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD pricing_options VARCHAR(100) NULL
END

IF COL_LENGTH('transfer_mapping_detail','fixed_price') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD fixed_price float NULL
END

IF COL_LENGTH('transfer_mapping_detail','transfer_date') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD transfer_date float NULL
END