UPDATE maintain_field_deal 
SET sql_string = 'EXEC spa_counterparty_shipper_info @flag = ''b'''
where farrms_field_id ='status' and header_detail = 'd'

