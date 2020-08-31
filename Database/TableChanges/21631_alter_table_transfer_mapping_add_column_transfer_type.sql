IF COL_LENGTH('transfer_mapping','transfer_type') IS NULL
BEGIN
	ALTER TABLE transfer_mapping
	ADD transfer_type VARCHAR(100)
END