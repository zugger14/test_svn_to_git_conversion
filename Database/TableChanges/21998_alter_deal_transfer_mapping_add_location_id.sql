IF COL_LENGTH('deal_transfer_mapping', 'location_id') IS NULL
BEGIN
    ALTER TABLE deal_transfer_mapping
	ADD location_id INT
END
GO

