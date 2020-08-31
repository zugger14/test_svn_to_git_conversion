IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_generic_mapping') 
BEGIN 
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) 
	SELECT 'ixp_generic_mapping', 'Generic Mapping', 'i' 
END

--TABLE: ixp_generic_mapping 
     
DECLARE @temp_ixp_tables_id INT

SET @temp_ixp_tables_id = (SELECT it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_generic_mapping')
DECLARE @Counter INT, @clm NVARCHAR(20), @sql NVARCHAR(MAX), @is_required INT
SET @sql = 'IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = ''mapping_name'' 
		AND ixp_table_id = ' + CONVERT(VARCHAR,@temp_ixp_tables_id) + ')
	BEGIN
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, seq, is_required)
		VALUES (' + CONVERT(VARCHAR,@temp_ixp_tables_id) + ', ''mapping_name'', 0, 1, 1)
	END'

EXEC(@sql)

SET @Counter=1
WHILE ( @Counter <= 20)
BEGIN
	
	SET @clm = 'clm' + CONVERT(VARCHAR,@Counter) + '_value'
	SET @sql = 'IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = ''' + @clm + ''' AND ixp_table_id = ' + CONVERT(VARCHAR,@temp_ixp_tables_id) + ')
	BEGIN
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, seq, is_required)
		VALUES (' + CONVERT(VARCHAR,@temp_ixp_tables_id) + ', ''' + @clm + ''', 0, ' + CONVERT(VARCHAR,@Counter+1) +', 0)
	END
	ELSE
	BEGIN
	
		PRINT ''COLUMN ' + @clm + '  ALREADY EXISTS.''
	END'
	
	EXEC(@sql)
   
    SET @Counter  = @Counter  + 1
END
