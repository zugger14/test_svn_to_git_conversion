
UPDATE maintain_field_deal
SET    sql_string = 'SELECT sb.source_broker_id,sb.broker_name FROM source_brokers sb',
	   window_function_id = 10101111
WHERE  field_deal_id = 29
       AND farrms_field_id = 'broker_id'
