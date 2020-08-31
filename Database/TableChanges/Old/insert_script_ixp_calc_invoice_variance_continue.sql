DECLARE @ixp_table_id INT 

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_calc_invoice_volume_variance'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='sap_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'sap_id','Varchar(600)'
END
ELSE  PRINT 'sap_id is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='price')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'price','Varchar(600)'
END
ELSE  PRINT 'price is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='buy_sell')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'buy_sell','Varchar(600)'
END
ELSE  PRINT 'buy_sell is already exists.'