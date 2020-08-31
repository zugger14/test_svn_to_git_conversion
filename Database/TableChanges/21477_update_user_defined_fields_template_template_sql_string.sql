IF COL_LENGTH(N'user_defined_fields_template', N'field_label') IS NOT NULL
BEGIN
	UPDATE user_defined_fields_template 
	SET sql_string = 'SELECT DISTINCT template_id, template_name FROM source_deal_header_template sdht LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id WHERE sdht.is_active = ''y'' ORDER BY template_name'
	WHERE field_label = 'template'
END
GO