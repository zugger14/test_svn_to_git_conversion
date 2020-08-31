IF COL_LENGTH('excel_sheet', 'publish_mobile') IS NULL
BEGIN
ALTER TABLE excel_sheet ADD publish_mobile BIT DEFAULT 0
END
ELSE
BEGIN
	PRINT 'Column publish_mobile EXISTS'
END