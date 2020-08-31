--Author: Tara Nath Subedi
--Issue Against: 3122
--Purpose: Adding 'udf_tabgroup' column in user_defined_deal_fields_template table.

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='user_defined_deal_fields_template' AND COLUMN_NAME='udf_tabgroup')
BEGIN
	ALTER TABLE user_defined_deal_fields_template ADD udf_tabgroup INT
	PRINT '''udf_tabgroup'' column added in ''user_defined_deal_fields_template'' table.'
END
