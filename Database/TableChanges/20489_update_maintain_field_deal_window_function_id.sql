UPDATE maintain_field_deal 
SET window_function_id = (SELECT function_id FROM application_functions WHERE function_name = 'Setup Counterparty') 
WHERE farrms_field_id IN ('counterparty_id', 'broker_id')

UPDATE maintain_field_deal 
SET window_function_id = NULL
WHERE farrms_field_id IN ('trader_id', 'block_define_id')

UPDATE maintain_field_deal 
SET window_function_id = NULL
WHERE farrms_field_id = 'confirm_status_type'

UPDATE application_functions
SET file_path = '_deal_capture/maintain_deals/confirm.status.history.php'
WHERE function_id = 10131013


UPDATE maintain_field_deal 
SET window_function_id = (SELECT function_id FROM application_functions WHERE function_name = 'Maintain Deal Template')
WHERE farrms_field_id IN ('template_id')