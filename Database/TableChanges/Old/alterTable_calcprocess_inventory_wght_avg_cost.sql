IF COL_LENGTH('calcprocess_inventory_wght_avg_cost', 'currency_id') IS NULL
BEGIN
	ALTER TABLE calcprocess_inventory_wght_avg_cost ADD currency_id INT
END
GO

IF COL_LENGTH('calcprocess_inventory_wght_avg_cost_forward', 'currency_id') IS NULL
BEGIN
	ALTER TABLE calcprocess_inventory_wght_avg_cost_forward ADD currency_id INT
END
GO


