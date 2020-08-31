IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_path_id_effective_date')
BEGIN
	ALTER TABLE delivery_path_mdq
	ADD CONSTRAINT UC_path_id_effective_date UNIQUE (path_id,effective_date)
END