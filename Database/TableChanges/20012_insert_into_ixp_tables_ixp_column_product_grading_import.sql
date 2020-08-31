IF NOT EXISTS(SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_product_grading_structure_template')
BEGIN
		INSERT INTO ixp_tables(ixp_tables_name,ixp_tables_description,import_export_flag)
		VALUES('ixp_product_grading_structure_template','Product Grading Structure','i')

END
ELSE 
	PRINT 'Table already exists'


DECLARE @ixp_table_id INT 

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_product_grading_structure_template'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='commodity')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'commodity','VARCHAR(600)'
END
ELSE  PRINT 'commodity is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='commodity_type')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'commodity_type','VARCHAR(600)'
END
ELSE  PRINT 'commodity_type is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='origin')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'origin','VARCHAR(600)'
END
ELSE  PRINT 'origin is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='form')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'form','VARCHAR(600)'
END
ELSE  PRINT 'form is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='attribute1')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'attribute1','VARCHAR(600)'
END
ELSE  PRINT 'attribute1 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='attribute2')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'attribute2','VARCHAR(600)'
END
ELSE  PRINT 'attribute2 is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='attribute3')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'attribute3','VARCHAR(600)'
END
ELSE  PRINT 'attribute3 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='attribute4')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'attribute4','VARCHAR(600)'
END
ELSE  PRINT 'attribute4 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='attribute5')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'attribute5','VARCHAR(600)'
END
ELSE  PRINT 'attribute5 is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='attribute1_type')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'attribute1_type','VARCHAR(600)'
END
ELSE  PRINT 'attribute1_type is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='attribute2_type')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'attribute2_type','VARCHAR(600)'
END
ELSE  PRINT 'attribute2_type is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='attribute3_type')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'attribute3_type','VARCHAR(600)'
END
ELSE  PRINT 'attribute3_type is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='attribute4_type')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'attribute4_type','VARCHAR(600)'
END
ELSE  PRINT 'attribute4_type is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='attribute5_type')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'attribute5_type','VARCHAR(600)'
END
ELSE  PRINT 'attribute5_type is already exists.'