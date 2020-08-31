IF COL_LENGTH('delivery_path', 'imbalance') IS NOT NULL
BEGIN
	ALTER TABLE delivery_path DROP COLUMN imbalance	
END
GO

IF COL_LENGTH('delivery_path', 'imbalance_from') IS NULL
BEGIN
	ALTER TABLE delivery_path ADD imbalance_from CHAR NULL 
END
GO

IF COL_LENGTH('delivery_path', 'imbalance_to') IS NULL
BEGIN
	ALTER TABLE delivery_path ADD imbalance_to CHAR NULL 
END
GO
