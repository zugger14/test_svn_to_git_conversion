
IF NOT EXISTS(SELECT 1 FROM ixp_tables where ixp_tables_name = 'ixp_source_facility_template')
BEGIN
		INSERT INTO ixp_tables(ixp_tables_name,ixp_tables_description,import_export_flag)
		VALUES('ixp_source_facility_template','Source facility', 'i')
END
ELSE 
	PRINT 'ixp tables already exists'

DECLARE  @ixp_table_id INT 
SELECT @ixp_table_id  = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_facility_template'
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Book')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'Book','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Facility_Name')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'Facility_Name','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Facility_ID')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'Facility_ID','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Unit_ID')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'Unit_ID','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Jurisdiction')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'Jurisdiction','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Facility_Owner')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'Facility_Owner','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Start_Date')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'Start_Date','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Fuel_Type')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'Fuel_Type','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Technology')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'Technology','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Environment_Product')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'Environment_Product','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Unit_Name')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'Unit_Name','VARCHAR(600)',0
END