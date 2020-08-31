/*
Alter table calc_formula_value
*/
IF  NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'calc_formula_value' AND COLUMN_NAME = 'deal_id')
	BEGIN
		ALTER TABLE calc_formula_value ADD deal_id INT

	END