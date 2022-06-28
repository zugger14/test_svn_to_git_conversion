IF EXISTS(SELECT 1 FROM alert_sql WHERE alert_sql_name = 'Update Execute Timestamp')
BEGIN
	UPDATE alert_sql 
	SET sql_statement = '
	DECLARE @udf_field_id VARCHAR(20)
	SELECT @udf_field_id = field_id From user_defined_fields_template where field_label = ''Execution Timestamp''

	UPDATE uddf
	SET uddf.udf_value = CONVERT(VARCHAR(10), sdh.deal_date, 126) + ''T'' + CAST(CAST(sdh.create_ts as time) AS VARCHAR(12))
	FROM staging_table.alert_deal_process_id_ad st
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = st.source_deal_header_id
	INNER JOIN source_deal_header_template sdht 
		ON sdht.template_id = sdh.template_id 
	INNER JOIN user_defined_deal_fields_template uddft
		ON uddft.field_id = @udf_field_id
		AND uddft.template_id = sdh.template_id
		AND uddft.udf_type = ''h''
	INNER JOIN user_defined_deal_fields uddf
		ON uddf.source_deal_header_id = sdh.source_deal_header_id
		AND uddf.udf_template_id = uddft.udf_template_id

	INSERT INTO user_defined_deal_fields (source_deal_header_id, udf_template_id, udf_value) 
	SELECT sdh.source_deal_header_id, uddft.udf_template_id, CONVERT(VARCHAR(10), sdh.deal_date, 126) + ''T'' + CAST(CAST(sdh.create_ts as time) AS VARCHAR(12))
	FROM staging_table.alert_deal_process_id_ad st
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = st.source_deal_header_id
	INNER JOIN source_deal_header_template sdht 
		ON sdht.template_id = sdh.template_id 
	INNER JOIN user_defined_deal_fields_template uddft
		ON uddft.field_id = @udf_field_id
		AND uddft.template_id = sdh.template_id
		AND uddft.udf_type = ''h''
	LEFT JOIN user_defined_deal_fields uddf
		ON uddf.source_deal_header_id = sdh.source_deal_header_id
		AND uddf.udf_template_id = uddft.udf_template_id
	WHERE uddf.udf_deal_id IS NULL' 
	WHERE alert_sql_name = 'Update Execute Timestamp'
	
	PRINT 'Updated ''sql_statement'' in alert_sql for ''Update Execute Timestamp''.'
END
ELSE
BEGIN
	PRINT 'Error: Could not find alert_sql for ''Update Execute Timestamp''.'
END