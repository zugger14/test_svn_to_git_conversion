IF NOT EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'source_deal_header' AND column_name LIKE 'book_transfer_id')
BEGIN
	ALTER TABLE source_deal_header ADD book_transfer_id INT 
	PRINT 'Column book_transfer_id added to table source_deal_header'
END
ELSE
BEGIN
	PRINT 'Column book_transfer_id exists in table source_deal_header'
END
	
	


