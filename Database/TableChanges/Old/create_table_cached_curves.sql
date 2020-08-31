--DROP TABLE cached_curves
IF object_id('cached_curves') IS NULL
BEGIN
CREATE TABLE dbo.cached_curves (ROWID INT identity(1,1),curve_id int,strip_month_from TINYINT,lag_months TINYINT ,strip_month_to TINYINT 
,expiration_type VARCHAR(30),expiration_value VARCHAR(30),index_round_value TINYINT,fx_round_value TINYINT,total_round_value TINYINT,fx_curve_id INT
,operation_type varchar(1),mid BIT,bid_ask_round_value TINYINT
)
END

--DROP TABLE cached_curves_value
IF object_id('cached_curves_value') IS NULL
BEGIN
	CREATE TABLE dbo.cached_curves_value (Master_ROWID INT,value_type varchar(1),term DATETIME,pricing_option TINYINT
	,curve_value float,org_mid_value float,org_ask_value float,org_bid_value float,org_fx_value float , as_of_date datetime 
	,curve_source_id INT,create_ts datetime
	)	
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.cached_curves') AND name = N'unq_cur_indx_cached_curves')
BEGIN
	CREATE UNIQUE CLUSTERED INDEX unq_cur_indx_cached_curves ON cached_curves(ROWID)
   PRINT 'Index unq_cur_indx_cached_curves created.'
END
ELSE
BEGIN
	PRINT 'Index unq_cur_indx_cached_curves already exists.'
END
GO


IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.cached_curves') AND name = N'indx_cached_curves_1')
BEGIN
	CREATE  INDEX indx_cached_curves_1 ON cached_curves(Strip_Month_From,Lag_Months,Strip_Month_To)
   PRINT 'Index indx_cached_curves_1 created.'
END
ELSE
BEGIN
	PRINT 'Index indx_cached_curves_1 already exists.'
END
GO


IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.cached_curves') AND name = N'unq_cur_indx_cached_curves_value')
BEGIN
	CREATE UNIQUE CLUSTERED INDEX unq_cur_indx_cached_curves_value ON cached_curves_value(Master_ROWID,as_of_date,term,pricing_option,curve_source_id)
   PRINT 'Index unq_cur_indx_cached_curves_value created.'
END
ELSE
BEGIN
	PRINT 'Index unq_cur_indx_cached_curves_value already exists.'
END
GO

