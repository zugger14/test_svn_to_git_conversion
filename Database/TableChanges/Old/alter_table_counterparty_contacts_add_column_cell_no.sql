IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'counterparty_contacts' AND COLUMN_NAME = 'cell_no')
BEGIN
	ALTER TABLE counterparty_contacts
	ADD cell_no VARCHAR(20)
END
ELSE 
BEGIN
	PRINT 'Column name cell_no already exists.'
END