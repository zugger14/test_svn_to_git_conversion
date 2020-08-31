UPDATE maintain_field_deal
SET sql_string = 'SELECT  ''m'' id,''Monthly'' val UNION SELECT ''q'', ''Quarterly'' UNION SELECT ''h'',''Hourly'' UNION SELECT ''s'',''Semi-Annually'' UNION SELECT ''a'', ''Annually'' UNION SELECT ''d'', ''Daily'' UNION SELECT ''z'', ''term'''
WHERE farrms_field_id = 'term_frequency'


UPDATE maintain_field_deal
SET sql_string = 'SELECT ''y'' code, ''Yes'' value UNION select ''n'',''No'' UNION SELECT ''x'', ''Not Applicable''',
	field_type = 'd'
WHERE farrms_field_id IN ('sample_control', 'detail_sample_control')