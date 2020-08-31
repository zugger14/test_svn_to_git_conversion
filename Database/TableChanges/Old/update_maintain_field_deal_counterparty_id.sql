UPDATE maintain_field_deal 
SET sql_string = 'SELECT source_counterparty_id, counterparty_name FROM dbo.source_counterparty WHERE int_ext_flag <> ''b'' ORDER BY counterparty_name'
WHERE field_id = 11 AND farrms_field_id = 'counterparty_id'