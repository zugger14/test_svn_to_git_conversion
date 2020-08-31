UPDATE maintain_field_deal 
SET sql_string = 'EXEC spa_counterparty_shipper_info @flag = ''l'''
WHERE farrms_field_id = 'shipper_code1'

UPDATE maintain_field_deal 
SET sql_string = 'EXEC spa_counterparty_shipper_info @flag = ''l'''
WHERE farrms_field_id = 'shipper_code2'