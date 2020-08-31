UPDATE maintain_field_deal
		SET [sql_string] = N'SELECT ''m'' id, ''Generation Month'' code UNION ALL SELECT ''y'', ''Vintage Year'' UNION ALL SELECT ''f'', ''FIFO'' UNION ALL SELECT ''g'', ''Generation Year'''
WHERE farrms_field_id = 'match_type'
AND header_detail = 'h'