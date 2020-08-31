IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221000)
BEGIN
UPDATE application_functions
SET file_path = '_settlement_billing/maintain_invoice/run.contract.settlement.php'
WHERE function_id = 10221000
END