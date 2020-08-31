
EXEC sp_fulltext_column      
@tabname =  'contract_group' , 
@colname =  'contract_name' , 
@action =  'drop' 
GO

-- contract_name
DROP INDEX IX_PT_contract_group_source_system_id ON contract_group

IF COL_LENGTH('contract_group', 'contract_name') IS NOT NULL
BEGIN
    ALTER TABLE contract_group ALTER COLUMN contract_name nvarchar(50)
END
GO

CREATE INDEX IX_PT_contract_group_source_system_id
ON contract_group (source_system_id)

EXEC sp_fulltext_column      
@tabname =  'contract_group' , 
@colname =  'contract_name' , 
@action =  'add' 
GO

-- source_contract_id
IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_contract_group')
BEGIN
	ALTER TABLE contract_group
	DROP CONSTRAINT UC_contract_group
END

-- source_contract_id
IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_source_contract_id')
BEGIN
	ALTER TABLE contract_group
	DROP CONSTRAINT UC_source_contract_id
END

IF COL_LENGTH('contract_group', 'source_contract_id') IS NOT NULL
BEGIN
    ALTER TABLE contract_group ALTER COLUMN source_contract_id nvarchar(50)
END
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_source_contract_id')
BEGIN
	ALTER TABLE contract_group
	ADD CONSTRAINT UC_source_contract_id UNIQUE (source_system_id, source_contract_id)
END


EXEC sp_fulltext_column      
@tabname =  'contract_group' , 
@colname =  'contract_desc' , 
@action =  'drop' 
GO

-- contract_desc
IF COL_LENGTH('contract_group', 'contract_desc') IS NOT NULL
BEGIN
    ALTER TABLE contract_group ALTER COLUMN contract_desc nvarchar(150)
END
GO

EXEC sp_fulltext_column      
@tabname =  'contract_group' , 
@colname =  'contract_desc' , 
@action =  'add' 
GO

