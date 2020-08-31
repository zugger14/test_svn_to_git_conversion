IF COL_LENGTH('delivery_path', 'loss_factor') IS NULL
BEGIN
	ALTER TABLE delivery_path ADD loss_factor FLOAT NULL	
END
GO

IF COL_LENGTH('delivery_path', 'fuel_factor') IS NULL
BEGIN
	ALTER TABLE delivery_path ADD fuel_factor FLOAT NULL	
END
GO

--SELECT * FROM delivery_path