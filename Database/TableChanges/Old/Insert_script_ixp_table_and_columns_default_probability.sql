IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_default_probability_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_default_probability_template'  , 'Default Probability', 'i' END

INSERT INTO ixp_table_meta_data (ixp_tables_id, table_name)
SELECT it.ixp_tables_id,
       it.ixp_tables_name
FROM   ixp_tables it
LEFT JOIN ixp_table_meta_data itmd ON itmd.ixp_tables_id = it.ixp_tables_id
WHERE itmd.ixp_table_meta_data_table_id IS NULL



-- ixp_default_probability_template starts
DECLARE @ixp_default_probability_template_id INT	
SELECT @ixp_default_probability_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_default_probability_template'

IF @ixp_default_probability_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'effective_date' AND ixp_table_id = @ixp_default_probability_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_default_probability_template_id, 'effective_date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'debt_rating' AND ixp_table_id = @ixp_default_probability_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_default_probability_template_id, 'debt_rating', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'recovery' AND ixp_table_id = @ixp_default_probability_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_default_probability_template_id, 'recovery', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'months' AND ixp_table_id = @ixp_default_probability_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_default_probability_template_id, 'months', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'probability' AND ixp_table_id = @ixp_default_probability_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_default_probability_template_id, 'probability', 0, NULL END
END
ELSE
BEGIN
	SELECT 'ixp_default_probability_template not present in ixp_tables'
END


