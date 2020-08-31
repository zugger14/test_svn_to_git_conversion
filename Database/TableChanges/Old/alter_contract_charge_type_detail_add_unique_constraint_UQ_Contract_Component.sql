IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE type = 'UQ' AND [name] = 'UQ_Contract_Component' AND OBJECT_NAME(parent_object_id) = 'contract_charge_type_detail')
	ALTER TABLE contract_charge_type_detail DROP CONSTRAINT UQ_Contract_Component
GO                    
ALTER TABLE contract_charge_type_detail ADD CONSTRAINT UQ_Contract_Component UNIQUE (contract_charge_type_id,invoice_line_item_id)

/*
* Check duplicate data
SELECT COUNT(ID), MAX(id) FROM contract_charge_type_detail
GROUP BY contract_charge_type_id,invoice_line_item_id 
HAVING COUNT(1) > 1
*/
