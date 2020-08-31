

UPDATE maintain_field_deal
SET    sql_string = 
       'EXEC spa_source_minor_location @flag =''o'', @is_active = ''y'''
WHERE  farrms_field_id = 'location_id'

UPDATE maintain_field_deal
SET    sql_string          = 
       'EXEC spa_source_counterparty_maintain @flag = ''c'', @is_active = ''y'', @not_int_ext_flag = ''b'''
WHERE  farrms_field_id     = 'counterparty_id'

