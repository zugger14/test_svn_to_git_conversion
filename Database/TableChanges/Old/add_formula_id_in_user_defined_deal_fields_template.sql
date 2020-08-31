--Author: Tara Nath Subedi
--Issue Against: 3122
--Purpose: Adding 'formula_id' column in user_defined_deal_fields_template table.

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='user_defined_deal_fields_template' AND COLUMN_NAME='formula_id')
BEGIN
	ALTER TABLE user_defined_deal_fields_template ADD formula_id INT
	PRINT '''formula_id'' column added in ''user_defined_deal_fields_template'' table.'
END
