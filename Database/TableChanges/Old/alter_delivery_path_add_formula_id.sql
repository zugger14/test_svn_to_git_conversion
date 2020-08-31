IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delivery_path' AND COLUMN_NAME = 'formula_from')
BEGIN
	ALTER TABLE delivery_path add [formula_from] INT NULL
END

IF NOT EXISTS(SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'delivery_path' AND column_name LIKE 'formula_to')
BEGIN
	ALTER TABLE delivery_path add [formula_to] INT NULL
END




SELECT * FROM delivery_path_detail
SELECT * FROM delivery_path
