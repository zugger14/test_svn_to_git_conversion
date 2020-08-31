IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Deal Type')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, field_type, data_type, is_required, sql_string, udf_type, Field_size, field_id)
	SELECT '300374'	,'Deal Type',	'd'	,'VARCHAR(150)'	,'n'	,'SELECT source_deal_type_id, source_deal_type_name FROM source_deal_type sdt WHERE  (sdt.sub_type IS NULL OR  sdt.sub_type <> ''y'') AND sdt.source_system_id = 3 ORDER BY source_deal_type_name', 'h', 120, 300374
	
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Book ID2')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, field_type, data_type, is_required, sql_string, udf_type, Field_size, field_id)
	SELECT '300375'	,'Book ID2',	'd'	,'VARCHAR(150)'	,'n'	,'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 51 ORDER BY source_book_name', 'h', 120, 300375
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Invoice Title')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, field_type, data_type, is_required, sql_string, udf_type, Field_size, field_id)
	SELECT '300376'	,'Invoice Title',	't'	,'VARCHAR(150)'	,'n'	,'', 'h', 120, 300376
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Invoice Subject')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, field_type, data_type, is_required, sql_string, udf_type, Field_size, field_id)
	SELECT '300377'	,'Invoice Subject',	'm'	,'VARCHAR(150)'	,'n'	,'', 'h', 120, 300377
END

UPDATE user_defined_fields_template set sql_string = 'SELECT value, label FROM (SELECT ''''b'''' AS [value], ''''Buy'''' AS [label] UNION ALL SELECT ''''s'''' AS [value], ''''Sell'''' AS [label]) p' WHERE field_label = 'buy sell'
UPDATE user_defined_fields_template SET sql_string = 'SELECT value, label FROM (SELECT ''''y'''' AS [value], ''''Yes'''' AS [label] UNION ALL SELECT ''''n'''' AS [value], ''''No'''' AS [label]) p' WHERE field_label = 'Entrepotnumber'
UPDATE user_defined_fields_template SET sql_string = 'SELECT value, label FROM (SELECT ''''40'''' AS [value], ''''40'''' AS [label] UNION ALL SELECT ''''50'''' AS [value], ''''50'''' AS [label]) p' WHERE field_label = 'Accounting Key'
