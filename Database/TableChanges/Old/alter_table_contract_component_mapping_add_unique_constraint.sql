IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'contract_component')
	BEGIN
		ALTER TABLE [dbo].[contract_component_mapping] 
		DROP CONSTRAINT [contract_component]
	END 

GO 
		ALTER TABLE [dbo].[contract_component_mapping] 
		ADD CONSTRAINT [contract_component] UNIQUE (contract_component_id);



 
