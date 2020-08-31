IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_wregis_sales_transfer_import_template')
 BEGIN 
	 INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    
	 SELECT 'ixp_wregis_sales_transfer_import_template'  , 'WREGIS Sales/Transfer Import', 'i' --select * from update ixp_tables  set ixp_tables_description = 'WREGIS Sales/Transfer Import' where ixp_tables_id = 91
 END

 -- ixp_wregis_sales_transfer_import_template starts
DECLARE @ixp_wregis_sales_transfer_import_template_id INT	
SELECT @ixp_wregis_sales_transfer_import_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_wregis_sales_transfer_import_template'

IF @ixp_wregis_sales_transfer_import_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'sub_account_name' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'sub_account_name', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'wregis_gu_id' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'wregis_gu_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'generator_plant_unit_name' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'generator_plant_unit_name', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'fuel_type' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'fuel_type', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'month' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'month', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'year' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'year', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'quantity' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'quantity', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'login_name' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'login_name', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'date_transfer' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'date_transfer', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'transferor' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'transferor', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'transferee' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'transferee', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'action' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'action', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'transaction_id' AND ixp_table_id = @ixp_wregis_sales_transfer_import_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_wregis_sales_transfer_import_template_id, 'transaction_id', 0, NULL END	
END
ELSE
BEGIN
	SELECT 'ixp_wregis_sales_transfer_import_template not present in ixp_tables'
END


