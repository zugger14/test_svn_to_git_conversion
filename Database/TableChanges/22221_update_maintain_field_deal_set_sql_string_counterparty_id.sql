UPDATE maintain_field_deal 
	SET sql_string = 'EXEC spa_source_counterparty_maintain @flag = ''c'', @is_active = ''y'', @not_int_ext_flag = ''b'', @filter_value = ''<FILTER_VALUE>'''
WHERE farrms_field_id = 'counterparty_id' AND header_detail = 'h'