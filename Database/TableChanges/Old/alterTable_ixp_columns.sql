BEGIN
	DECLARE @id_for_ixp_source_deal_template INT
	
	SELECT @id_for_ixp_source_deal_template = ixp_tables_id
	FROM   ixp_tables
	WHERE  ixp_tables_name = 'ixp_source_deal_template'
	
	--SELECT @id_for_ixp_source_deal_template
	
	INSERT INTO ixp_columns
	(
	    ixp_columns_name,
	    ixp_table_id,
	    column_datatype,
	    is_major
	)
	SELECT udf_valuen, ixp_table_id, data_type, is_major FROM 
	(
		VALUES('udf_value1', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value2', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value3', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value4', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value5', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value6', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value7', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value8', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value9', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value10', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value11', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value12', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value13', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value14', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value15', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value16', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value17', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value18', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value19', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0),
			  ('udf_value20', @id_for_ixp_source_deal_template, 'VARCHAR(600)', 0)
	) AS x(udf_valuen, ixp_table_id, data_type, is_major)
	WHERE NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = x.udf_valuen AND ixp_table_id = @id_for_ixp_source_deal_template);
END