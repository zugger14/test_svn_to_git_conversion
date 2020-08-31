IF NOT EXISTS(SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_custom_tables')
BEGIN
		INSERT INTO ixp_tables(ixp_tables_name,ixp_tables_description,import_export_flag)
		VALUES('ixp_custom_tables','Custom user Defined Tables','i')

END
ELSE 
	PRINT 'Table already exists'


DECLARE @ixp_table_id INT 

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_custom_tables'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column1')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column1','VARCHAR(600)'
END
ELSE  PRINT 'column1 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column2')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column2','VARCHAR(600)'
END
ELSE  PRINT 'column2 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column3')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column3','VARCHAR(600)'
END
ELSE  PRINT 'column3 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column4')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column4','VARCHAR(600)'
END
ELSE  PRINT 'column4 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column5')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column5','VARCHAR(600)'
END
ELSE  PRINT 'column5 is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column6')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column6','VARCHAR(600)'
END
ELSE  PRINT 'column6 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column7')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column7','VARCHAR(600)'
END
ELSE  PRINT 'column7 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column8')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column8','VARCHAR(600)'
END
ELSE  PRINT 'column8 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column9')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column9','VARCHAR(600)'
END
ELSE  PRINT 'column9 is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column10')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column10','VARCHAR(600)'
END
ELSE  PRINT 'column10 is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column11')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column11','VARCHAR(600)'
END
ELSE  PRINT 'column11 is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column12')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column12','VARCHAR(600)'
END
ELSE  PRINT 'column12 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column13')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column13','VARCHAR(600)'
END
ELSE  PRINT 'column13 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column14')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column14','VARCHAR(600)'
END
ELSE  PRINT 'column14 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column15')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column15','VARCHAR(600)'
END
ELSE  PRINT 'column15 is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column16')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column16','VARCHAR(600)'
END
ELSE  PRINT 'column16 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column17')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column17','VARCHAR(600)'
END
ELSE  PRINT 'column17 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column18')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column18','VARCHAR(600)'
END
ELSE  PRINT 'column18 is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column19')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column19','VARCHAR(600)'
END
ELSE  PRINT 'column19 is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='column20')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	SELECT @ixp_table_id,'column20','VARCHAR(600)'
END
ELSE  PRINT 'column20 is already exists.'