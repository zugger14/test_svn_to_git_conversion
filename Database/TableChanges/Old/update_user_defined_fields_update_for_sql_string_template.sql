UPDATE user_defined_fields_template
SET sql_string = 'SELECT Template_id, Template_name FROM source_deal_header_template sdht INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdht.source_deal_type_id WHERE is_active = ''y'''
WHERE field_label = 'Template'