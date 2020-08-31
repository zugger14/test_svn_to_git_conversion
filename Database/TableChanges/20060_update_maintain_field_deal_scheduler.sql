UPDATE maintain_field_deal
SET sql_string = 'SELECT cc.counterparty_contact_id, cc.name FROM counterparty_contacts cc INNER JOIN static_data_value sdv ON cc.contact_type = sdv.value_id INNER JOIN source_counterparty sc ON sc.source_counterparty_id = cc.counterparty_id WHERE sdv.type_id = 32200 AND sdv.code = ''scheduler'' AND sc.int_ext_flag = ''i'''
WHERE field_id = 164