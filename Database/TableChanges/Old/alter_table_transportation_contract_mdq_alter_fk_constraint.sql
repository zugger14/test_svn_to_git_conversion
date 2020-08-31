DECLARE @fk_name VARCHAR(100)
DECLARE @sql VARCHAR(1000)

IF EXISTS(SELECT 'X' FROM sys.foreign_keys WHERE referenced_object_id = OBJECT_ID(N'contract_group') AND parent_object_id = OBJECT_ID(N'transportation_contract_mdq'))
BEGIN
	SELECT @fk_name = name 
	FROM sys.foreign_keys
	WHERE referenced_object_id = OBJECT_ID(N'contract_group') AND parent_object_id = OBJECT_ID(N'transportation_contract_mdq')

	SET @sql = '
	ALTER TABLE transportation_contract_mdq DROP CONSTRAINT ' + @fk_name + '
	ALTER TABLE transportation_contract_mdq 
	ADD CONSTRAINT FK_transportation_contract_mdq_contract_group FOREIGN KEY (contract_id) REFERENCES dbo.contract_group(contract_id) ON DELETE CASCADE'
	EXEC(@sql)
END