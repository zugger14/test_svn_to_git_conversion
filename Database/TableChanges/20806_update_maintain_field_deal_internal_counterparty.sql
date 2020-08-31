UPDATE maintain_field_deal set sql_string = 'EXEC spa_source_counterparty_maintain @flag = ''c'', @is_active = ''y'''
	WHERE default_label = 'internal counterparty' AND header_detail = 'h'

	