UPDATE user_defined_fields_template
SET sql_string = 'SELECT ''F'' id, ''Financial'' code UNION ALL SELECT ''N'', ''Non-Financial'' UNION ALL SELECT ''C'', ''Central Counterparty'' UNION ALL SELECT ''O'', ''Other'''
WHERE field_name = -10000019