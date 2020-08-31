DECLARE @ixp_table_id INT 

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_calc_invoice_volume_variance'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='as_of_date')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'as_of_date','Varchar(600)'
END
ELSE  PRINT 'as of date is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='counterparty_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'counterparty_id','Varchar(600)'
END
ELSE  PRINT 'counterparty_id is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='generator_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'generator_id','Varchar(600)'
END
ELSE  PRINT 'generator_id is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='contract_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'contract_id','Varchar(600)'
END
ELSE  PRINT 'contract_id is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='prod_date')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'prod_date','Varchar(600)'
END
ELSE  PRINT 'Prod_Date is already exists.'
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='uom')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'uom','Varchar(600)'
END
ELSE  PRINT 'uom is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='invoice_number')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'invoice_number','Varchar(600)'
END
ELSE  PRINT 'invoice_number is already exists.'
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='invoice_status')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'invoice_status','Varchar(600)'
END
ELSE  PRINT 'Invoice_status is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='invoice_lock')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'invoice_lock','Varchar(600)'
END
ELSE  PRINT 'Invoice_lock is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='finalized')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'finalized','Varchar(600)'
END
ELSE  PRINT 'Finalized is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='invoice_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'invoice_id','Varchar(600)'
END
ELSE  PRINT 'invoice_id is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='deal_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'deal_id','Varchar(600)'
END
ELSE  PRINT 'deal_id is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='create_user')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'create_user','Varchar(600)'
END
ELSE  PRINT 'create_user is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='create_ts')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'create_ts','Varchar(600)'
END
ELSE  PRINT 'create_ts is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='estimated')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'estimated','Varchar(600)'
END
ELSE  PRINT 'estimated is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='calculation_time')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'calculation_time','Varchar(600)'
END
ELSE  PRINT 'calculation_time is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='invoice_type')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'invoice_type','Varchar(600)'
END
ELSE  PRINT 'invoice_type is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='prod_date_to')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'prod_date_to','Varchar(600)'
END
ELSE  PRINT 'prod_date_to is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='settlement_date')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'settlement_date','Varchar(600)'
END
ELSE  PRINT 'settlement_date is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='netting_group_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'netting_group_id','Varchar(600)'
END
ELSE  PRINT 'netting_group_id is already exists.'


--Insert Script calc_invoice_volume
PRINT 'Inserting Script calc_invoice_volume'
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='invoice_line_item_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'invoice_line_item_id','Varchar(600)'
END
ELSE  PRINT 'invoice_line_item_id is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='Value')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'Value','Varchar(600)'
END
ELSE  PRINT 'Value is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='Volume')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'Volume','Varchar(600)'
END
ELSE  PRINT 'Volume is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='default_gl_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'default_gl_id','Varchar(600)'
END
ELSE  PRINT 'default_gl_id is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='manual_input')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'manual_input','Varchar(600)'
END
ELSE  PRINT 'manual_input is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='uom_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'uom_id','Varchar(600)'
END
ELSE  PRINT 'uom_id is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='price_or_formula')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'price_or_formula','Varchar(600)'
END
ELSE  PRINT 'price_or_formula is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='onpeak_offpeak')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'onpeak_offpeak','Varchar(600)'
END
ELSE  PRINT 'onpeak_offpeak is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='remarks')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'remarks','Varchar(600)'
END
ELSE  PRINT 'remarks is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='finalized')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'finalized','Varchar(600)'
END
ELSE  PRINT 'finalized is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='finalized_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'finalized_id','Varchar(600)'
END
ELSE  PRINT 'finalized_id is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='default_gl_id_estimate')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'default_gl_id_estimate','Varchar(600)'
END
ELSE  PRINT 'default_gl_id_estimate is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='include_volume')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'include_volume','Varchar(600)'
END
ELSE  PRINT 'include_volume is already exists.'



IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name ='inv_prod_date')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'inv_prod_date','Varchar(600)'
END
ELSE  PRINT 'inv_prod_date is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id 
AND ixp_columns_name ='status')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'status','Varchar(600)'
END
ELSE  PRINT 'status is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id 
AND ixp_columns_name ='deal_type_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'deal_type_id','Varchar(600)'
END
ELSE  PRINT 'deal_type_id is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id 
AND ixp_columns_name ='inventory')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'inventory','Varchar(600)'
END
ELSE  PRINT 'inventory is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id
 AND ixp_columns_name ='apply_cash_calc_detail_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'apply_cash_calc_detail_id','Varchar(600)'
END
ELSE  PRINT 'apply_cash_calc_detail_id is already exists.'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id
 AND ixp_columns_name ='finalized_date')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'finalized_date','Varchar(600)'
END
ELSE  PRINT 'finalized_date is already exists.'


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id
 AND ixp_columns_name ='payment_date')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype)
	Select @ixp_table_id,'payment_date','Varchar(600)'
END
ELSE  PRINT 'payment_date is already exists.'