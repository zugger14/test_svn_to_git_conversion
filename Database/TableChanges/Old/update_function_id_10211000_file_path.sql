IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211000)
BEGIN
UPDATE application_functions
SET file_path = '_contract_administration/maintain_contract_group/maintain.contract.php'
WHERE function_id = 10211000
END


