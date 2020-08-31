UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_source_counterparty_maintain @flag = ''c'', @is_active = ''y'', @int_ext_flag = ''b'''
where farrms_field_id = 'broker_id'