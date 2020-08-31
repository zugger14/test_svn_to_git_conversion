IF COL_LENGTH('delivery_path', 'blocked') IS NULL
BEGIN
    ALTER TABLE delivery_path ADD is_backhaul CHAR(1) NULL
END
ELSE
	PRINT('Column is_backhaul already exists.')
GO

IF COL_LENGTH('delivery_path', 'backhaul_path_id') IS NULL
BEGIN
    ALTER TABLE delivery_path ADD backhaul_path_id INT NULL
END
ELSE
	PRINT('Column is_backhaul already exists.')
GO

