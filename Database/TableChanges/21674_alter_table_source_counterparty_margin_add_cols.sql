IF COL_LENGTH(N'source_counterparty_margin',  N'margin_account') IS NOT NULL
BEGIN
	ALTER TABLE source_counterparty_margin  ALTER COLUMN  margin_account NUMERIC(38,17) 
END 

IF COL_LENGTH(N'source_counterparty_margin',  N'mtmt_t0') IS NOT NULL
BEGIN
	ALTER TABLE source_counterparty_margin ALTER COLUMN mtmt_t0 NUMERIC(38,17) 
END 

IF COL_LENGTH(N'source_counterparty_margin',  N'mtmt_t1') IS NOT NULL
BEGIN
	ALTER TABLE source_counterparty_margin ALTER COLUMN mtmt_t1 NUMERIC(38,17) 
END   

IF COL_LENGTH(N'source_counterparty_margin',  N'delta_mtm') IS NOT NULL
BEGIN
	ALTER TABLE source_counterparty_margin ALTER COLUMN delta_mtm NUMERIC(38,17) 
END  
   
IF COL_LENGTH(N'source_counterparty_margin',  N'margin_call_price') IS NOT NULL
BEGIN
	ALTER TABLE source_counterparty_margin ALTER COLUMN margin_call_price NUMERIC(38,17) 
END   
  
IF COL_LENGTH(N'source_counterparty_margin',  N'additional_margin') IS NOT NULL
BEGIN
	ALTER TABLE source_counterparty_margin ALTER COLUMN additional_margin NUMERIC(38,17) 
END    
  
IF COL_LENGTH(N'source_counterparty_margin',  N'current_portfolio_value') IS NOT NULL
BEGIN
	ALTER TABLE source_counterparty_margin ALTER COLUMN current_portfolio_value NUMERIC(38,17) 
END  
  
IF COL_LENGTH(N'source_counterparty_margin',  N'maintenance_margin_required') IS NOT NULL
BEGIN
	ALTER TABLE source_counterparty_margin ALTER COLUMN maintenance_margin_required NUMERIC(38,17) 
END   
  
IF COL_LENGTH(N'source_counterparty_margin',  N'margin_call') IS NOT NULL
BEGIN
	ALTER TABLE source_counterparty_margin ALTER COLUMN margin_call NUMERIC(38,17) 
END  

IF COL_LENGTH(N'source_counterparty_margin',  N'margin_excess') IS NOT NULL
BEGIN
	ALTER TABLE source_counterparty_margin ALTER COLUMN margin_excess NUMERIC(38,17) 
END  

IF COL_LENGTH(N'source_counterparty_margin',  N'margin_call') IS NOT NULL
BEGIN
	EXEC sp_RENAME 'source_counterparty_margin.margin_call', 'margin_call_amt', 'COLUMN'
END

IF COL_LENGTH(N'source_counterparty_margin',  N'source_deal_header_id') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD source_deal_header_id INT 
END

IF COL_LENGTH(N'source_counterparty_margin',  N'deal_volume') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD deal_volume NUMERIC(38,17) 
END

IF COL_LENGTH(N'source_counterparty_margin',  N'total_initial_margin') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD total_initial_margin NUMERIC(38,17) 
END

IF COL_LENGTH(N'source_counterparty_margin',  N'total_maintenance_margin') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD total_maintenance_margin NUMERIC(38,17) 
END

IF COL_LENGTH(N'source_counterparty_margin',  N'deal_price') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD deal_price NUMERIC(38,17) 
END

IF COL_LENGTH(N'source_counterparty_margin',  N'curve_value1') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD curve_value1 NUMERIC(38,17) 
END

IF COL_LENGTH(N'source_counterparty_margin',  N'curve_value2') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD curve_value2 NUMERIC(38,17) 
END

IF COL_LENGTH(N'source_counterparty_margin',  N'product_id') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD product_id INT 
END

IF COL_LENGTH(N'source_counterparty_margin',  N'margin_account_balc') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD margin_account_balc  NUMERIC(38,17)  
END

IF COL_LENGTH(N'source_counterparty_margin',  N'beg_balc') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD beg_balc NUMERIC(38, 17)
END

IF COL_LENGTH(N'source_counterparty_margin',  N'end_balc') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD end_balc NUMERIC(38, 17)
END

IF COL_LENGTH(N'source_counterparty_margin',  N'end_balc') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD end_balc NUMERIC(38, 17)
END

IF COL_LENGTH(N'source_counterparty_margin',  N'previous_as_of_date') IS NULL
BEGIN
	ALTER TABLE source_counterparty_margin ADD previous_as_of_date DATETIME
END



