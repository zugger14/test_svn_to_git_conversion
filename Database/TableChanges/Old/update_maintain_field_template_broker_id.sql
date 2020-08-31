UPDATE maintain_field_deal
SET    sql_string = 
       'SELECT sc.source_counterparty_id, sc.counterparty_name FROM  source_counterparty sc WHERE  sc.int_ext_flag = ''b'' ', window_function_id = '10101115'
WHERE  farrms_field_id = 'broker_id'



