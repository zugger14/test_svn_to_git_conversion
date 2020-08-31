IF COL_LENGTH('delivery_path', 'path_code') IS NOT NULL
BEGIN
    ALTER TABLE delivery_path ALTER COLUMN  path_code VARCHAR(100)
END
GO

IF COL_LENGTH('delivery_path', 'path_name') IS NOT NULL
BEGIN
    ALTER TABLE delivery_path ALTER COLUMN path_name VARCHAR(100)
END
GO

