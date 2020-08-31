--drop table dbo.source_deal_pnl_breakdown
IF OBJECT_ID('source_deal_pnl_breakdown') IS NULL 
begin 
	CREATE TABLE dbo.source_deal_pnl_breakdown (
		row_id BIGINT IDENTITY(1,1),
		[as_of_date] datetime,
		[source_deal_header_id] [int] NOT NULL ,
		[deal_id] varchar(50),
		[term_date] datetime,
		[hours] TINYINT,
		[is_dst] bit,
		period TINYINT,
		[term_start] [datetime] NOT NULL ,
		[term_end] [datetime] NOT NULL ,
		[curve_id] [int] NULL ,
		[leg_mtm] [float] NULL,
		[leg_set] [float] NULL,
		[extrinsic_value] [float] NULL,
		[accrued_interest] [float] NULL,
		[volume] [float] NULL,
		[leg] [int] NULL,
		[price] [float] NULL,
		[discount_rate] [float] NULL,
		no_days_left [INT] NULL,
		days_year [INT] NULL,
		[discount_factor] [float] NULL,
		[expired_term] varchar(1) NULL,
		[curve_as_of_date] datetime NULL,
		[internal_deal_type_value_id] INT  NULL,
		[internal_deal_subtype_value_id] INT  NULL,
		curve_uom_conv_factor FLOAT NULL,
		curve_fx_conv_factor FLOAT NULL,
		price_fx_conv_factor FLOAT NULL,
		curve_value FLOAT NULL,
		fixed_cost float NULL,
		fixed_price float NULL,
		formula_value float NULL,
		price_adder float NULL,
		price_multiplier float NULL,
		strike_price float NULL,
		buy_sell_flag varchar(1) NULL,
		physical_financial_flag varchar(1) NULL,
		fixed_cost_fx_conv_factor float,
		formula_fx_conv_factor float,
		price_adder1_fx_conv_factor float,
		price_adder2_fx_conv_factor float,
		volume_multiplier float,
		volume_multiplier2 float,
		price_adder2 float,
		pay_opposite varchar(1),
		--error_deal INT,
		--error_deal_reason varchar(500),
		curve_uom_id INT, 
		deal_volume_uom_id INT, 
		fixed_price_currency_id INT, 
		price_adder_currency INT, 
		price_adder2_currency INT, 
		func_cur_id INT, 
		formula_currency INT, 
		fixed_cost_currency INT,
		market_value FLOAT,
		contract_value FLOAT,
		formula_rounding INT,
		formula_conv_factor FLOAT,
		formula_id INT,
		contract_id INT,
		product_id INT,
		source_deal_detail_id INT,
		formula_curve_id INT,
		allocation_volume FLOAT,
		contract_price FLOAT,
		market_price FLOAT,
		deal_volume FLOAT,[create_ts] datetime,[create_user] VARCHAR(30)
		) ON [PRIMARY]
	
	
END

GO


IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.source_deal_pnl_breakdown') AND name = N'unq_cl_indx_source_deal_pnl_breakdown')
BEGIN
	CREATE UNIQUE CLUSTERED INDEX unq_cl_indx_source_deal_pnl_breakdown ON dbo.source_deal_pnl_breakdown(
		as_of_date,
		source_deal_header_id,
		leg,
		term_date,
		period,
		[hours],
		is_dst
	)
   PRINT 'Index unq_cl_indx_source_deal_pnl_breakdown created.'
END
ELSE
BEGIN
	PRINT 'Index unq_cl_indx_source_deal_pnl_breakdown already exists.'
END
GO



--drop table dbo.source_deal_settlement_breakdown
IF OBJECT_ID('source_deal_settlement_breakdown') IS NULL 
begin 
	CREATE TABLE dbo.source_deal_settlement_breakdown (
		row_id BIGINT IDENTITY(1,1),
		[as_of_date] datetime,
		[source_deal_header_id] [int] NOT NULL ,
		[deal_id] varchar(50),
		[term_date] datetime,
		[hours] TINYINT,
		[is_dst] bit,
		period TINYINT,
		[term_start] [datetime] NOT NULL ,
		[term_end] [datetime] NOT NULL ,
		[curve_id] [int] NULL ,
		[leg_mtm] [float] NULL,
		[leg_set] [float] NULL,
		[extrinsic_value] [float] NULL,
		[accrued_interest] [float] NULL,
		[volume] [float] NULL,
		[leg] [int] NULL,
		[price] [float] NULL,
		[discount_rate] [float] NULL,
		no_days_left [INT] NULL,
		days_year [INT] NULL,
		[discount_factor] [float] NULL,
		[expired_term] varchar(1) NULL,
		[curve_as_of_date] datetime NULL,
		[internal_deal_type_value_id] INT  NULL,
		[internal_deal_subtype_value_id] INT  NULL,
		curve_uom_conv_factor FLOAT NULL,
		curve_fx_conv_factor FLOAT NULL,
		price_fx_conv_factor FLOAT NULL,
		curve_value FLOAT NULL,
		fixed_cost float NULL,
		fixed_price float NULL,
		formula_value float NULL,
		price_adder float NULL,
		price_multiplier float NULL,
		strike_price float NULL,
		buy_sell_flag varchar(1) NULL,
		physical_financial_flag varchar(1) NULL,
		fixed_cost_fx_conv_factor float,
		formula_fx_conv_factor float,
		price_adder1_fx_conv_factor float,
		price_adder2_fx_conv_factor float,
		volume_multiplier float,
		volume_multiplier2 float,
		price_adder2 float,
		pay_opposite varchar(1),
		--error_deal INT,
		--error_deal_reason varchar(500),
		curve_uom_id INT, 
		deal_volume_uom_id INT, 
		fixed_price_currency_id INT, 
		price_adder_currency INT, 
		price_adder2_currency INT, 
		func_cur_id INT, 
		formula_currency INT, 
		fixed_cost_currency INT,
		market_value FLOAT,
		contract_value FLOAT,
		formula_rounding INT,
		formula_conv_factor FLOAT,
		formula_id INT,
		contract_id INT,
		product_id INT,
		source_deal_detail_id INT,
		formula_curve_id INT,
		allocation_volume FLOAT,
		contract_price FLOAT,
		market_price FLOAT,
		deal_volume FLOAT,[create_ts] datetime,[create_user] VARCHAR(30)
	) ON [PRIMARY]
		
END

GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.source_deal_settlement_breakdown') AND name = N'unq_cl_indx_source_deal_settlement_breakdown')
BEGIN
	CREATE UNIQUE CLUSTERED INDEX unq_cl_indx_source_deal_settlement_breakdown ON dbo.source_deal_settlement_breakdown(
		as_of_date,
		source_deal_header_id,
		leg,
		term_date,
		period,
		[hours],
		is_dst
	)
   PRINT 'Index unq_cl_indx_source_deal_settlement_breakdown created.'
END
ELSE
BEGIN
	PRINT 'Index unq_cl_indx_source_deal_settlement_breakdown already exists.'
END
GO
