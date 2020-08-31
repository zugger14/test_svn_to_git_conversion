IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211200)
BEGIN
	UPDATE application_functions SET file_path = '_contract_administration/maintain_contract_group/maintain.contract.php' WHERE function_id = 10211200
END
ELSE
BEGIN
	PRINT 'Application Function Id 10211200 does not EXIST'
END