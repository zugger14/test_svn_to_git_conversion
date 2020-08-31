IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'deal_transfer_mapping' AND column_name LIKE 'formula_id')
BEGIN
	ALTER TABLE deal_transfer_mapping ADD formula_id INT 
	PRINT 'Column formula_id added to deal_transfer_mapping table'
END
ELSE
BEGIN
	PRINT 'Column formula_id already exists in deal_transfer_mapping table'
END