IF NOT EXISTS (SELECT * FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_cash_apply') 
BEGIN
	 INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)   
	 SELECT 'ixp_cash_apply'  , 'Cash Apply', 'i' 
END

DECLARE @ixp_cash_apply_id INT	
SELECT @ixp_cash_apply_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_cash_apply'

IF @ixp_cash_apply_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'Counterparty' AND ixp_table_id = @ixp_cash_apply_id) 
		BEGIN 
			INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_cash_apply_id, 'Counterparty', 0, NULL
		END

IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'Contract' AND ixp_table_id = @ixp_cash_apply_id) 
		BEGIN 
			INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_cash_apply_id, 'Contract', 0, NULL
		END

IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'Charge Type' AND ixp_table_id = @ixp_cash_apply_id) 
		BEGIN 
			INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_cash_apply_id, 'Charge Type', 0, NULL
		END

IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'Production Month' AND ixp_table_id = @ixp_cash_apply_id) 
		BEGIN 
			INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_cash_apply_id, 'Production Month', 0, NULL
		END

IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'Payment Date' AND ixp_table_id = @ixp_cash_apply_id) 
		BEGIN 
			INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_cash_apply_id, 'Payment Date', 0, NULL
		END

IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'Amount' AND ixp_table_id = @ixp_cash_apply_id) 
		BEGIN 
			INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_cash_apply_id, 'Amount', 0, NULL
		END

IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'Pay/Receive' AND ixp_table_id = @ixp_cash_apply_id) 
		BEGIN 
			INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_cash_apply_id, 'Pay/Receive', 0, NULL
		END
END
ELSE
BEGIN
	SELECT 'ixp_cash_apply not present in ixp_tables'
END

