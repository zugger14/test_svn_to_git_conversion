IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='UC_contract_group')
BEGIN
	ALTER TABLE [dbo].[contract_group] DROP CONSTRAINT [UC_contract_group]
END
GO

ALTER TABLE [dbo].[contract_group] ADD  CONSTRAINT [UC_contract_group] UNIQUE NONCLUSTERED 
(
	[source_system_id] ASC,
	[source_contract_id] ASC,
	[contract_type_def_id] ASC
)


