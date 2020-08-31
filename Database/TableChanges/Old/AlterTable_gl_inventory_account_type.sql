/***********************
Alter table gl_inventory_account_type
**********************/
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'gl_inventory_account_type' and column_name = 'location_id')
	Alter table dbo.gl_inventory_account_type ADD location_id INT
GO
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'calcprocess_inventory_deals' and column_name = 'location_id')
	Alter table dbo.calcprocess_inventory_deals ADD location_id INT
GO
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'calcprocess_inventory_wght_avg_cost' and column_name = 'location')
	Alter table dbo.calcprocess_inventory_wght_avg_cost ADD location INT


