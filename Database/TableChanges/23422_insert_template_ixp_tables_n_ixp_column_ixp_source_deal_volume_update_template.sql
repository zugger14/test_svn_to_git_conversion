IF NOT EXISTS (
       SELECT 1
       FROM   ixp_tables it
       WHERE  it.ixp_tables_name = 'ixp_source_deal_volume_update_template'
   )
BEGIN
    INSERT INTO ixp_tables
      (
        ixp_tables_name,
        ixp_tables_description,
        import_export_flag
      )
    SELECT 'ixp_source_deal_volume_update_template',
           'Deal volume Update',
           'i'
END

DECLARE @ixp_source_deal_volume_update_template_id INT	
SELECT @ixp_source_deal_volume_update_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_source_deal_volume_update_template'

IF @ixp_source_deal_volume_update_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'source_deal_header_id' AND ixp_table_id = @ixp_source_deal_volume_update_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_source_deal_volume_update_template_id, 'source_deal_header_id', 0, NULL 
	END
	
	IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'deal_id' AND ixp_table_id = @ixp_source_deal_volume_update_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_source_deal_volume_update_template_id, 'deal_id', 0, NULL 
	END
	
	IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'deal_volume' AND ixp_table_id = @ixp_source_deal_volume_update_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_source_deal_volume_update_template_id, 'deal_volume', 0, NULL 
	END
	
	IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'actual_volume' AND ixp_table_id = @ixp_source_deal_volume_update_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_source_deal_volume_update_template_id, 'actual_volume', 0, NULL 
	END
	
	IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'schedule_volume' AND ixp_table_id = @ixp_source_deal_volume_update_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_source_deal_volume_update_template_id, 'schedule_volume', 0, NULL 
	END
	
	IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'term_start' AND ixp_table_id = @ixp_source_deal_volume_update_template_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
		SELECT @ixp_source_deal_volume_update_template_id, 'term_start', 0, NULL 
	END
	
	
END

