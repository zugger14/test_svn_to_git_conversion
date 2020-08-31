IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_Delete')
	BEGIN
		ALTER TABLE [dbo].[contract_group_detail] 
		DROP CONSTRAINT FK_Delete
	END 

--ELSE 
--	IF EXISTS (SELECT 1 FROM [dbo].[contract_group_detail] WHERE invoice_line_item_id NOT IN (SELECT contract_component_id FROM [dbo].[contract_component_mapping] AS ccm))
--		BEGIN 
--			DELETE  FROM [dbo].[contract_group_detail] WHERE invoice_line_item_id NOT IN (SELECT contract_component_id FROM [dbo].[contract_component_mapping] AS ccm)
--		END 

--		ALTER TABLE [dbo].[contract_group_detail]
--		ADD CONSTRAINT FK_Delete
--		FOREIGN KEY (invoice_line_item_id) REFERENCES [dbo].[contract_component_mapping](contract_component_id) 
		
