IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventory_account_type' AND COLUMN_NAME = 'unit_expense')
BEGIN
	ALter table inventory_account_type ADD unit_expense CHAR(1)

END