
IF  EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventory_account_type_group' AND COLUMN_NAME = 'account_type_value_id')
	BEGIN
		ALTER TABLE inventory_account_type_group drop column account_type_value_id  
	END

	ALter table inventory_account_type_group ADD account_type_value_id INT
