
IF COL_LENGTH('stmt_invoice', 'original_id_for_void') IS NULL
BEGIN
	ALTER TABLE stmt_invoice ADD original_id_for_void INT
END
GO