IF EXISTS(SELECT 1  
FROM sys.objects  
WHERE type = 'UQ' AND OBJECT_NAME(parent_object_id) = N'Contract_group' and name = 'UC_source_contract_id' )
BEGIN
	ALTER TABLE dbo.Contract_group  
	/**
	  Delete the unique constraint.
	*/
	DROP CONSTRAINT UC_source_contract_id;  
END
GO  

IF COL_LENGTH('Contract_group','source_contract_id') IS NOT NULL
BEGIN
	ALTER TABLE [Contract_group]
	/**
        Column
        [source_contract_id] : [source_contract_id]
    */
	ALTER COLUMN [source_contract_id] NVARCHAR(200)
END
GO

IF COL_LENGTH('Contract_group','contract_name') IS NOT NULL
BEGIN
	ALTER TABLE [Contract_group]
	/**
        Column
        [contract_name] : [contract_name]
    */
	ALTER COLUMN [contract_name] NVARCHAR(200)
END
GO

IF COL_LENGTH('Contract_group','contract_desc') IS NOT NULL
BEGIN
	ALTER TABLE [Contract_group]
	/**
        Column
        [contract_desc] : [contract_desc]
    */
	ALTER COLUMN [contract_desc] NVARCHAR(400)
END

IF COL_LENGTH('contract_group_audit','source_contract_id') IS NOT NULL
BEGIN
	ALTER TABLE [contract_group_audit]
	/**
        Column
        [source_contract_id] : [source_contract_id]
    */
	ALTER COLUMN [source_contract_id] NVARCHAR(200)
END
GO

IF COL_LENGTH('contract_group_audit','contract_name') IS NOT NULL
BEGIN
	ALTER TABLE [contract_group_audit]
	/**
        Column
        [contract_name] : [contract_name]
    */
	ALTER COLUMN [contract_name] NVARCHAR(200)
END
GO

IF COL_LENGTH('contract_group_audit','contract_desc') IS NOT NULL
BEGIN
	ALTER TABLE [contract_group_audit]
	/**
        Column
        [contract_desc] : [contract_desc]
    */
	ALTER COLUMN [contract_desc] NVARCHAR(400)
END

GO

IF NOT EXISTS(SELECT 1  
FROM sys.objects  
WHERE type = 'UQ' AND OBJECT_NAME(parent_object_id) = N'contract_group' and name = 'UC_source_contract_id' )

BEGIN
    ALTER TABLE Contract_group
	/**
	  Add unique constraint.
	*/
    ADD CONSTRAINT UC_source_contract_id UNIQUE(source_system_id, source_contract_id)
END
