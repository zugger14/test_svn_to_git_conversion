IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_wregis_rps_import_template')
 BEGIN 
	 INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    
	 SELECT 'ixp_wregis_rps_import_template'  , 'WREGIS RPS Import', 'i'
 END

 -- ixp_wregis_rps_import_template 
DECLARE @ixp_wregis_rps_import_template_id INT	
SELECT @ixp_wregis_rps_import_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_wregis_rps_import_template'

IF @ixp_wregis_rps_import_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'sub_account_name' AND ixp_table_id = @ixp_wregis_rps_import_template_id)
	 BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'sub_account_name', 0, NULL 
	 END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'wregis_gu_id' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'wregis_gu_id', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'generator_plant_unit_name' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'generator_plant_unit_name', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'country' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'country', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'state' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'state', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'fuel_type' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'fuel_type', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'month' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'month', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'year' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'year', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'certificate_serial_number' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'certificate_serial_number', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'quantity' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'quantity', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'az' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'az', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'ca' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'ca', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'co' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'co', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'mt' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'mt', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'nv' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'nv', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'nm' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'nm', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'tx' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'tx', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'wa' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'wa', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'or' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'or', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'ut' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'ut', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'green_energy_eligible' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'green_energy_eligible', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'ecologo_certified' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'ecologo_certified', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hydro_certification' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'hydro_certification', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'smud_eligible' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'smud_eligible', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'etag_matched' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'etag_matched', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'etag' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	   BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'etag', 0, NULL
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'state_province' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'state_province', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'compliance_period' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'compliance_period', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'retirement_type' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'retirement_type', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'additional_detail' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'additional_detail', 0, NULL 
	END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'Reason' AND ixp_table_id = @ixp_wregis_rps_import_template_id) 
	BEGIN 
	   INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_rps_import_template_id, 'Reason', 0, NULL 
	END
END
ELSE
BEGIN
	SELECT 'ixp_wregis_rps_import_template not present in ixp_tables'
END


