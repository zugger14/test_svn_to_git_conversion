DECLARE @fk_name VARCHAR(100)
DECLARE @sql VARCHAR(1000)

IF EXISTS(SELECT 'X' FROM sys.foreign_keys WHERE referenced_object_id = OBJECT_ID(N'delivery_path') AND parent_object_id = OBJECT_ID(N'delivery_path_mdq'))
BEGIN
	SELECT @fk_name = name 
	FROM sys.foreign_keys
	WHERE referenced_object_id = OBJECT_ID(N'delivery_path') AND parent_object_id = OBJECT_ID(N'delivery_path_mdq')

	SET @sql = '
	ALTER TABLE delivery_path_mdq DROP CONSTRAINT ' + @fk_name + '
	ALTER TABLE delivery_path_mdq 
	ADD CONSTRAINT FK_delivery_path_mdq_delivery_path FOREIGN KEY (path_id) REFERENCES dbo.delivery_path(path_id) ON DELETE CASCADE'
	EXEC(@sql)
END

IF EXISTS(SELECT name FROM sys.foreign_keys WHERE referenced_object_id = OBJECT_ID(N'contract_group') AND parent_object_id = OBJECT_ID(N'delivery_path_mdq'))
BEGIN
	SELECT @fk_name = name 
	FROM sys.foreign_keys
	WHERE referenced_object_id = OBJECT_ID(N'contract_group') AND parent_object_id = OBJECT_ID(N'delivery_path_mdq')

	SET @sql = '
	ALTER TABLE delivery_path_mdq DROP CONSTRAINT ' + @fk_name + '
	ALTER TABLE delivery_path_mdq 
	ADD CONSTRAINT FK_delivery_path_mdq_contract_group FOREIGN KEY (contract_id) REFERENCES dbo.contract_group(contract_id) ON DELETE CASCADE'
	EXEC(@sql)
END