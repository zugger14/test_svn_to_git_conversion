IF COL_LENGTH('deal_transfer_mapping', 'template_id_to') IS NULL
BEGIN
    ALTER TABLE deal_transfer_mapping
	ADD template_id_to INT
END
GO