IF COL_LENGTH('transfer_mapping_detail','transfer_date') IS NOT NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	DROP COLUMN transfer_date
END

IF COL_LENGTH('transfer_mapping_detail','transfer_date') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD transfer_date DATE
END
