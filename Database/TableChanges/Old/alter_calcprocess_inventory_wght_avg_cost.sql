/*
* Alter table confirm_status START
*/
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = 'calcprocess_inventory_wght_avg_cost' AND c.COLUMN_NAME = 'uom_id' AND c.DATA_TYPE = 'INT')
BEGIN
	ALTER TABLE calcprocess_inventory_wght_avg_cost
	ADD [uom_id] INT

END

