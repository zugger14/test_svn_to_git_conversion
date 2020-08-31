-- Updated function id of UI to open in counterparty, cotnract and generator
UPDATE maintain_field_deal SET open_ui_function_id = 10105800 WHERE farrms_field_id = 'internal_counterparty' AND field_id = 139
UPDATE maintain_field_deal SET open_ui_function_id = 10105800 WHERE farrms_field_id = 'counterparty_id' AND field_id = 11
UPDATE maintain_field_deal SET open_ui_function_id = 10211200 WHERE farrms_field_id = 'contract_id' AND field_id = 47
UPDATE maintain_field_deal SET open_ui_function_id = 12101700 WHERE farrms_field_id = 'generator_id' AND field_id = 33