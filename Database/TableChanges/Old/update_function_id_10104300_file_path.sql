IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104300)
BEGIN
UPDATE application_functions
SET file_path = '_setup/setup_contract_component_mapping/setup.contract.component.mapping.php'
WHERE function_id = 10104300
END
--SELECT * FROM application_functions WHERE function_id = 10104300
