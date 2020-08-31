
/****** Object:  StoredProcedure [dbo].[spa_deal_settlement_view]    Script Date: 06/12/2012 21:51:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_deal_settlement_view]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].spa_deal_settlement_view
GO
/****** Object:  StoredProcedure [dbo].[spa_Create_MTM_Period_Report_TRM]    Script Date: 06/12/2012 21:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC spa_deal_settlement_view
	@as_of_date VARCHAR(50),
	@sub_entity_id VARCHAR(8000) = NULL, 
	@strategy_entity_id VARCHAR(8000) = NULL, 
	@book_entity_id VARCHAR(8000) = NULL, 
	@sub_book_id VARCHAR(8000) = NULL,
	@discount_option CHAR(1) = NULL, 
	@settlement_option CHAR(1) = NULL, 
	@report_type CHAR(1) = NULL, 
	@summary_option CHAR(2),
	@counterparty_id VARCHAR(MAX)= NULL, 
	@tenor_from VARCHAR(50)= NULL,
	@tenor_to VARCHAR(50) = NULL,
	@previous_as_of_date VARCHAR(50) = NULL,
	@trader_id INT = NULL,
	@include_item CHAR(1)='n', -- to include item in cash flow hedge
	@source_system_book_id1 INT=NULL, 
	@source_system_book_id2 INT=NULL, 
	@source_system_book_id3 INT=NULL, 
	@source_system_book_id4 INT=NULL, 
	@show_firstday_gain_loss CHAR(1)='n', -- To Show First Day Gain/Loss
	@transaction_type VARCHAR(500)=NULL,
	@deal_id_from INT=NULL,
	@deal_id_to INT=NULL,
	@deal_id VARCHAR(100)=NULL,
	@threshold_values FLOAT=NULL,
	@show_prior_processed_values CHAR(1)='n',
	@exceed_threshold_value CHAR(1)='n',   -- For First Day gain Loss Treatment selection
	@show_only_for_deal_date CHAR(1)='y',
	@use_create_date CHAR(1)='n',
	@round_value CHAR(1) = '0',
	@counterparty CHAR(1) = 'a', --i means only internal and e means only external, a means all
	@mapped CHAR(1) = 'm', --m means mapped only, n means non-mapped only,
	@match_id CHAR(1) = 'n', --'y' means use like for deal ids and 'n' means use 
	@cpty_type_id INT = NULL,  
	@curve_source_id INT=4500,
	@deal_sub_type CHAR(4)='t',
	@deal_date_from VARCHAR(20)=NULL,
	@deal_date_to VARCHAR(20)=NULL,
	@phy_fin VARCHAR(1)='b',
	@deal_type_id INT=NULL,
	@period_report VARCHAR(1)='n',
	@term_start VARCHAR(20)=NULL,
	@term_end VARCHAR(20)=NULL,
	@settlement_date_from VARCHAR(20)=NULL,
	@settlement_date_to VARCHAR(20)=NULL,
	@settlement_only CHAR(1)='n',
	@drill1 VARCHAR(100)=NULL,
	@drill2 VARCHAR(100)=NULL,
	@drill3 VARCHAR(100)=NULL,
	@drill4 VARCHAR(100)=NULL,
	@drill5 VARCHAR(100)=NULL,
	@drill6 VARCHAR(100)=NULL,
	--Add Parameters Here
	@risk_bucket_header_id INT=NULL,
	@risk_bucket_detail_id INT=NULL,
	@commodity_id INT = NULL, 
	@deal_status VARCHAR(500) = NULL,
	@convert_uom INT=NULL,	
	@show_by VARCHAR(1)='t',
	@parent_counterparty INT = NULL,
	@graph CHAR(1)=NULL,
	@source_deal_header_list VARCHAR(500) = NULL,	
	@detail_option CHAR(1) = NULL,
	@contract_ids VARCHAR(MAX) = NULL,
	@currency VARCHAR(100) = NULL,
	--END
	@batch_process_id VARCHAR(50)=NULL,
	@batch_report_param VARCHAR(1000)=NULL,
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS
/* 
@as_of_date VARCHAR(50) = '2015-06-26',
	@sub_entity_id VARCHAR(8000) = NULL, 
	@strategy_entity_id VARCHAR(8000) = NULL, 
	@book_entity_id VARCHAR(8000) = NULL, 
	@discount_option CHAR(1) = 'u', 
	@settlement_option CHAR(1) = 'a', 
	@report_type CHAR(1) = 'a', 
	@summary_option CHAR(2) = 14,
	@counterparty_id VARCHAR(MAX)= NULL, 
	@tenor_from VARCHAR(50)= NULL,
	@tenor_to VARCHAR(50) = NULL,
	@previous_as_of_date VARCHAR(50) = NULL,
	@trader_id INT = NULL,
	@include_item CHAR(1)='n', -- to include item in cash flow hedge
	@source_system_book_id1 INT=NULL, 
	@source_system_book_id2 INT=NULL, 
	@source_system_book_id3 INT=NULL, 
	@source_system_book_id4 INT=NULL, 
	@show_firstday_gain_loss CHAR(1)='n', -- To Show First Day Gain/Loss
	@transaction_type VARCHAR(500)=NULL,
	@deal_id_from INT=NULL,
	@deal_id_to INT=NULL,
	@deal_id VARCHAR(100)=NULL,
	@threshold_values FLOAT=NULL,
	@show_prior_processed_values CHAR(1)='n',
	@exceed_threshold_value CHAR(1)='n',   -- For First Day gain Loss Treatment selection
	@show_only_for_deal_date CHAR(1)='y',
	@use_create_date CHAR(1)='n',
	@round_value CHAR(1) = '2',
	@counterparty CHAR(1) = 'a', --i means only internal and e means only external, a means all
	@mapped CHAR(1) = 'm', --m means mapped only, n means non-mapped only,
	@match_id CHAR(1) = 'n', --'y' means use like for deal ids and 'n' means use 
	@cpty_type_id INT = NULL,  
	@curve_source_id INT=4500,
	@deal_sub_type CHAR(4)='b',
	@deal_date_from VARCHAR(20)=NULL,
	@deal_date_to VARCHAR(20)=NULL,
	@phy_fin VARCHAR(1)='b',
	@deal_type_id INT=NULL,
	@period_report VARCHAR(1)='n',
	@term_start VARCHAR(20)=NULL,
	@term_end VARCHAR(20)=NULL,
	@settlement_date_from VARCHAR(20)=NULL,
	@settlement_date_to VARCHAR(20)=NULL,
	@settlement_only CHAR(1)='y',
	@drill1 VARCHAR(100)=NULL,
	@drill2 VARCHAR(100)=NULL,
	@drill3 VARCHAR(100)=NULL,
	@drill4 VARCHAR(100)=NULL,
	@drill5 VARCHAR(100)=NULL,
	@drill6 VARCHAR(100)=NULL,
	@risk_bucket_header_id INT=NULL,
	@risk_bucket_detail_id INT=NULL,
	@commodity_id INT = NULL, 
	@deal_status VARCHAR(500) = '5606,5603,5607,5613,5612,5632,5604,5605',
	@convert_uom INT=1,	
	@show_by VARCHAR(1)='t',
	@parent_counterparty INT = NULL,
	@graph CHAR(1)=NULL,
	@source_deal_header_list VARCHAR(500) = NULL,	
	@detail_option CHAR(1) = 'p',
	@contract_ids VARCHAR(MAX) = NULL,
	@currency VARCHAR(100) = NULL,
	--END
	@batch_process_id VARCHAR(50)=NULL,
	@batch_report_param VARCHAR(1000)=NULL,
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
--*/

DECLARE @is_batch BIT
DECLARE @user_login_id VARCHAR(50)

SET @user_login_id = dbo.FNADBUser() 

DECLARE @disable_hyperlink VARCHAR(2) = CASE WHEN @is_batch = 1 THEN '1'
											ELSE '1' END

DECLARE @save_pnl_option INT
SELECT  @save_pnl_option =  var_value
FROM         adiha_default_codes_values
WHERE     (instance_no = 1) AND (default_code_id = 39) AND (seq_no = 1)

IF @save_pnl_option IS NULL
	SET @save_pnl_option = 0
	
CREATE TABLE #temp ( deal_id VARCHAR(30) COLLATE DATABASE_DEFAULT )
IF @source_deal_header_list IS NOT NULL
 BEGIN
 	DECLARE @sql_deal VARCHAR(MAX)
 	
 	SET @sql_deal = 'INSERT INTO #temp
 	                 SELECT DISTINCT source_deal_header_id
 	                 FROM   ' + @source_deal_header_list
	--PRINT (@sql_deal)
	EXEC (@sql_deal)
END

IF @deal_id_from=0
	SET @deal_id_from = NULL
	
IF @deal_id_to=0
	SET @deal_id_to = NULL


IF @deal_id_from IS NULL AND @deal_id IS NOT NULL
		SELECT @deal_id_from=source_deal_header_id FROM source_deal_header WHERE deal_id = @deal_id


DECLARE @mtm_clm_name varchar(20)
if @report_type='m'
	set @mtm_clm_name = 'MTM'
else if @report_type='c'
	set @mtm_clm_name = 'Cashflow'
else
	set @mtm_clm_name = 'Earnings'

--########### Find out whether to use Balance of the Month Logic from config Parameter
DECLARE @use_bom_logic INT
SELECT  @use_bom_logic   = var_value 
FROM         adiha_default_codes_values
WHERE     (instance_no = '1') AND (default_code_id = 37) AND (seq_no = 1)

IF @use_bom_logic  IS NULL
	SET @use_bom_logic = 1
  
IF ( @deal_id_from IS NOT NULL AND @deal_id_to IS NULL )
	SET @deal_id_to = @deal_id_from
ELSE IF ( @deal_id_from IS NULL AND @deal_id_to IS NOT NULL ) 
	SET @deal_id_from = @deal_id_to
IF (@deal_date_from IS NOT NULL AND @deal_date_to IS NULL)
	SET @deal_date_to = @deal_date_from
IF (@deal_date_to IS NOT NULL AND @deal_date_from IS NULL)
	SET @deal_date_from = @deal_date_to
IF (@term_start IS NOT NULL AND @term_end IS NULL)
	SET @term_end = @term_start
IF (@term_end IS NOT NULL AND @term_start IS NULL)
	SET @term_start = @term_end


DECLARE @Sql VARCHAR(MAX)
DECLARE @Sql1 VARCHAR(8000)
DECLARE @sql2 VARCHAR(8000)
DECLARE @SqlG VARCHAR(500)
DECLARE @SqlW VARCHAR(500)
DECLARE @DiscountTableName VARCHAR(128)
DECLARE @DiscountTableName0 VARCHAR(128)

DECLARE @process_id VARCHAR(50)
--DECLARE @drill VARCHAR(1)
DECLARE @prior_summary_option VARCHAR(1)

DECLARE @tenor_from_month_year VARCHAR(10),@tenor_to_month_year VARCHAR(10)
DECLARE @sql_from VARCHAR(MAX)
DECLARE @sql_select VARCHAR(MAX)
DECLARE @premium_id INT


SET @premium_id = 2
IF @exceed_threshold_value = 'y'
	SET @discount_option = 'u'

IF @mapped IS NULL
	SET @mapped = 'm'

IF @counterparty IS NULL
	SET @counterparty = 'a'

IF @match_id IS NULL
	SET @match_id = 'n'

IF @settlement_only IS NULL
	SET @settlement_only='n'
	
SET @SqlW = ''

-- For the Deal sub type filter
DECLARE @deal_sub_type_id INT 

IF @deal_sub_type = 't'
	SELECT @deal_sub_type_id=source_deal_type_id FROM source_deal_type WHERE deal_type_id LIKE 'Term'
ELSE IF @deal_sub_type = 's'
	SELECT @deal_sub_type_id=source_deal_type_id FROM source_deal_type WHERE deal_type_id LIKE 'Spot'

DECLARE @Sql_WhereB VARCHAR(MAX)
DECLARE @Sql_SelectB VARCHAR(8000)
SET @Sql_WhereB = ''        

CREATE TABLE #books (fas_book_id INT,source_system_book_id1 INT,
source_system_book_id2 INT,
source_system_book_id3 INT,
source_system_book_id4 INT,	fas_deal_type_value_id INT ,
book_deal_type_map_id INT,
sub_id INT
) 

SET @Sql_SelectB=        
	'INSERT INTO  #books (fas_book_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,	fas_deal_type_value_id,book_deal_type_map_id,sub_id) 
	SELECT distinct 
		book.entity_id 
		fas_book_id,
		source_system_book_id1,
		source_system_book_id2,
		source_system_book_id3,
		source_system_book_id4,	
		fas_deal_type_value_id,
		ssbm.book_deal_type_map_id,
		stra.parent_entity_id
	FROM portfolio_hierarchy book (nolock) 
	INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id 
	INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
	WHERE 1 = 1 '   
	IF @sub_entity_id IS NOT NULL        
	  SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '         
	IF @strategy_entity_id IS NOT NULL        
	  SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        
	IF @book_entity_id IS NOT NULL        
	  SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN(' + @book_entity_id + ')) '
	IF @sub_book_id IS NOT NULL        
	  SET @Sql_WhereB = @Sql_WhereB + ' AND (ssbm.book_deal_type_map_id IN(' + @sub_book_id + ')) '       
      
	SET @Sql_SelectB=@Sql_SelectB+@Sql_WhereB             
	EXEC (@Sql_SelectB)

DECLARE @mwh INT
SELECT @mwh=source_uom_id FROM source_uom WHERE uom_id='MWh'
SET @convert_uom=COALESCE(@convert_uom,@mwh,-1)
		
DECLARE @dis_clm_name VARCHAR(10)
SET @dis_clm_name  = CASE WHEN @discount_option = 'd' THEN 'dis_' ELSE '' END 

SET @process_id = REPLACE(newid(),'-','_')
SET @DiscountTableName = dbo.FNAProcessTableName('calcprocess_discount_factor', dbo.FNADBUser(), @process_id)

CREATE TABLE [#deal_pnl1](
	[Sub] [VARCHAR](100)  NULL,
	[Strategy] [VARCHAR](100)  NULL,
	[Book] [VARCHAR](100)  NULL,
	[Counterparty] [VARCHAR](100)  NULL,
	[Parent Counterparty] [VARCHAR] (100)  NULL,
	[DealNumber] [VARCHAR](500)  NULL,
	[DealRefNumber] [VARCHAR](500)  NULL,
	[DealDate] [VARCHAR](50)  NULL,
	[PNLDate] [VARCHAR](50)  NULL,
	[TYPE] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
	[Phy/Fin] [VARCHAR](3) COLLATE DATABASE_DEFAULT  NULL,
	[Expiration] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
	[CumulativeFV] [FLOAT] NULL,
	[term_start] DATETIME NULL, --new clm
	[source_deal_header_id] INT, --new clm
	[pnl_as_of_date] DATETIME, --new clm,
	[buy_sell_flag] VARCHAR(1) COLLATE DATABASE_DEFAULT ,
	[ContractValue] FLOAT,
	[MarketValue] FLOAT,
	Volume FLOAT,
	sbm1 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm2 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm3 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm4 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	Trader VARCHAR(500) COLLATE DATABASE_DEFAULT ,
	Currency VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	[term_end] DATETIME,
	[price] FLOAT,
	[price_uom] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	[Location] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	[volume_uom] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	MwhEquivalentVol NUMERIC(38,20),
	DealPriceCurrency VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	ContractName VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	pricing VARCHAR(60) COLLATE DATABASE_DEFAULT ,
	DealStatus VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	[IndexName] VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Leg INT,
	DealTermStart DATETIME,
	DealTermEnd DATETIME,
	TemplateName VARCHAR(200) COLLATE DATABASE_DEFAULT ,		
	[PROFILE] VARCHAR(30) COLLATE DATABASE_DEFAULT ,
	Commodity VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	BlockDefinition VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Reference VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Description1 VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Description2 VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Description3 VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	CreatedBy VARCHAR(40) COLLATE DATABASE_DEFAULT ,
	CreatedDate DATETIME,
	UpdateBy VARCHAR(40) COLLATE DATABASE_DEFAULT ,
	UpdateDate DATETIME,
	term_start_orig DATETIME,
	[mtm] FLOAT,
	[dis_mtm] FLOAT, 
	[dis_contract_value] float, 
	[dis_market_value] float,
	[book_deal_type_map_id] [int] ,
	[broker_id] [int] ,
	[internal_desk_id] [int] ,
	[source_deal_type_id] [int] ,
	[trader_id] [int] ,
	[contract_id] [int] ,
	[internal_portfolio_id] [int] ,
	[template_id] [int] ,
	[deal_status] [int] ,
	[counterparty_id] [int] ,
	[block_define_id] [int] ,
	[curve_id] [int] ,
	[pv_party] [int] ,
	[location_id] [int] ,
	[pnl_currency_id] [int] ,
	physical_financial_flag CHAR(10) COLLATE DATABASE_DEFAULT ,
	[und_pnl] [float] ,
	[dis_pnl] [float] ,
	[market_value] [float] ,
	[charge_type] [varchar](100) COLLATE DATABASE_DEFAULT ,
	[charge_type_id] INT ,
	[cashflow_date] DATETIME,
	[pnl_date] DATETIME,
	[category_id] INT,
	[location_group] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	deal_volume FLOAT,
	deal_volume_uom VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	country VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	grid VARCHAR(100) COLLATE DATABASE_DEFAULT ,	
	category VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	forward_actual_flag CHAR(1) COLLATE DATABASE_DEFAULT ,
	product_id INT,
	sub_id INT				
)

CREATE TABLE [#deal_pnl0](
	[Sub] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
	[Strategy] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
	[Book] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
	[Counterparty] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
	[DealNumber] [VARCHAR](500) COLLATE DATABASE_DEFAULT  NULL,
	[DealRefNumber] [VARCHAR](500) COLLATE DATABASE_DEFAULT  NULL,
	[DealDate] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
	[PNLDate] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
	[TYPE] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
	[Phy/Fin] [VARCHAR](3) COLLATE DATABASE_DEFAULT  NULL,
	[Expiration] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
	[CumulativeFV] [FLOAT] NULL,
	[term_start] DATETIME NULL, --new clm
	[source_deal_header_id] INT, --new clm
	[pnl_as_of_date] DATETIME, --new clm
	[buy_sell_flag] VARCHAR(1) COLLATE DATABASE_DEFAULT ,
	[ContractValue] FLOAT,
	[MarketValue] FLOAT,
	Volume FLOAT,
	sbm1 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm2 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm3 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm4 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	Trader VARCHAR(500) COLLATE DATABASE_DEFAULT ,
	Currency VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	[term_end] DATETIME,
	[price] FLOAT,
	[price_uom] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
	[Location] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	[volume_uom] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	MwhEquivalentVol NUMERIC(38,20),
	DealPriceCurrency VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	ContractName VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	pricing VARCHAR(60) COLLATE DATABASE_DEFAULT ,
	DealStatus VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	[IndexName] VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Leg INT,
	DealTermStart DATETIME,
	DealTermEnd DATETIME,
	TemplateName VARCHAR(200) COLLATE DATABASE_DEFAULT ,		
	[PROFILE] VARCHAR(30) COLLATE DATABASE_DEFAULT ,
	Commodity VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	BlockDefinition VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Reference VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Description1 VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Description2 VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Description3 VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	CreatedBy VARCHAR(40) COLLATE DATABASE_DEFAULT ,
	CreatedDate DATETIME,
	UpdateBy VARCHAR(40) COLLATE DATABASE_DEFAULT ,
	UpdateDate DATETIME,
	[term_start_orig] DATETIME NULL,
	[mtm] FLOAT,
	[dis_mtm] FLOAT, 
	[dis_contract_value] float, 
	[dis_market_value] float,
	[book_deal_type_map_id] [int] ,
	[broker_id] [int] ,
	[internal_desk_id] [int] ,
	[source_deal_type_id] [int] ,
	[trader_id] [int] ,
	[contract_id] [int] ,
	[internal_portfolio_id] [int] ,
	[template_id] [int] ,
	[deal_status] [int] ,
	[counterparty_id] [int] ,
	[block_define_id] [int] ,
	[curve_id] [int] ,
	[pv_party] [int] ,
	[location_id] [int] ,
	[pnl_currency_id] [int] ,
	physical_financial_flag CHAR(10) COLLATE DATABASE_DEFAULT ,
	[und_pnl] [float] ,
	[dis_pnl] [float] ,
	[market_value] [float] ,
	[charge_type] [varchar](100) COLLATE DATABASE_DEFAULT ,
	[charge_type_id] INT ,
	[cashflow_date] DATETIME,
	[pnl_date] DATETIME,
	[category_id] INT,
	[location_group] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	deal_volume FLOAT,
	deal_volume_uom VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	country VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	grid VARCHAR(100) COLLATE DATABASE_DEFAULT ,	
	category VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	forward_actual_flag CHAR(1) COLLATE DATABASE_DEFAULT ,
	product_id INT,
	sub_id INT			
)

	CREATE TABLE [#deal_pnl](
		[Sub] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Strategy] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Book] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Counterparty] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[DealNumber] [VARCHAR](500) COLLATE DATABASE_DEFAULT  NULL,
		[DealRefNumber] [VARCHAR](500) COLLATE DATABASE_DEFAULT  NULL,
		[DealDate] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[PNLDate] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[TYPE] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Phy/Fin] [VARCHAR](3) COLLATE DATABASE_DEFAULT  NULL,
		[Expiration] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[CumulativeFV] [FLOAT] NULL,
		[term_start] DATETIME NULL, --new clm
		[source_deal_header_id] INT, --new clm
		[pnl_as_of_date] DATETIME, --new clm
		[buy_sell_flag] VARCHAR(1) COLLATE DATABASE_DEFAULT ,
		[ContractValue] FLOAT,
		[MarketValue] FLOAT,
		Volume FLOAT,
		sbm1 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		sbm2 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		sbm3 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		sbm4 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		Trader VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		Currency VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		[term_end] DATETIME,
		[price] FLOAT,
		[price_uom] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
		[Location] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		[volume_uom] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		MwhEquivalentVol NUMERIC(38,20),
		DealPriceCurrency VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		ContractName VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		pricing VARCHAR(60) COLLATE DATABASE_DEFAULT ,
		DealStatus VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		[IndexName] VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		Leg INT,
		DealTermStart DATETIME,
		DealTermEnd DATETIME,
		TemplateName VARCHAR(200) COLLATE DATABASE_DEFAULT ,		
		[PROFILE] VARCHAR(30) COLLATE DATABASE_DEFAULT ,
		Commodity VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		BlockDefinition VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		Reference VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		Description1 VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		Description2 VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		Description3 VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		CreatedBy VARCHAR(40) COLLATE DATABASE_DEFAULT ,
		CreatedDate DATETIME,
		UpdateBy VARCHAR(40) COLLATE DATABASE_DEFAULT ,
		UpdateDate DATETIME,
		[term_start_orig] DATETIME NULL,
		[mtm] FLOAT,
		[dis_mtm] FLOAT, 
		[dis_contract_value] float, 
		[dis_market_value] float,
		[book_deal_type_map_id] [int] ,
		[broker_id] [int] ,
		[internal_desk_id] [int] ,
		[source_deal_type_id] [int] ,
		[trader_id] [int] ,
		[contract_id] [int] ,
		[internal_portfolio_id] [int] ,
		[template_id] [int] ,
		[deal_status] [int] ,
		[counterparty_id] [int] ,
		[block_define_id] [int] ,
		[curve_id] [int] ,
		[pv_party] [int] ,
		[location_id] [int] ,
		[pnl_currency_id] [int] ,
		physical_financial_flag CHAR(10) COLLATE DATABASE_DEFAULT ,
		[und_pnl] [float] ,
		[dis_pnl] [float] ,
		[market_value] [float] ,
		[charge_type] [varchar](100) COLLATE DATABASE_DEFAULT ,
		[charge_type_id] INT ,
		[cashflow_date] DATETIME,
		[pnl_date] DATETIME,
		[category_id] INT,
		[location_group] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		deal_volume FLOAT,
		deal_volume_uom VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		country VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		grid VARCHAR(100) COLLATE DATABASE_DEFAULT ,	
		category VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		forward_actual_flag CHAR(1) COLLATE DATABASE_DEFAULT ,
		product_id INT,
		sub_id INT				
		
	) 

	DECLARE @save_sql VARCHAR(8000)
	
	CREATE TABLE #payment_calendar(contract_id INT,term_start DATETIME,payment_calendar DATETIME,pnl_calendar DATETIME)
	
	CREATE TABLE #hedge_deferral1(as_of_date DATETIME,source_deal_header_id INT, cash_flow_term DATETIME, pnl_term DATETIME, a_und_pnl float, a_dis_pnl float, per_alloc float,deal_volume float,pnl_currency_id INT,market_value FLOAT,contract_value FLOAT,dis_market_value FLOAT,dis_contract_value FLOAT,market_value_pnl FLOAT,contract_value_pnl FLOAT,dis_market_value_pnl FLOAT,dis_contract_value_pnl FLOAT)
	CREATE TABLE #hedge_deferral0(as_of_date DATETIME,source_deal_header_id INT, cash_flow_term DATETIME, pnl_term DATETIME, a_und_pnl float, a_dis_pnl float, per_alloc float,deal_volume float,pnl_currency_id INT,market_value FLOAT,contract_value FLOAT,dis_market_value FLOAT,dis_contract_value FLOAT,market_value_pnl FLOAT,contract_value_pnl FLOAT,dis_market_value_pnl FLOAT,dis_contract_value_pnl FLOAT)
	CREATE TABLE #hedge_deferral2(as_of_date DATETIME,source_deal_header_id INT, cash_flow_term DATETIME, pnl_term DATETIME, a_und_pnl float, a_dis_pnl float, per_alloc float,deal_volume float,pnl_currency_id INT,market_value FLOAT,contract_value FLOAT,dis_market_value FLOAT,dis_contract_value FLOAT,market_value_pnl FLOAT,contract_value_pnl FLOAT,dis_market_value_pnl FLOAT,dis_contract_value_pnl FLOAT)

	SET @sql_WhereB=
				--CASE WHEN @settlement_only<>'y' THEN ' And ISNULL(NULLIF(sdp.pnl_source_value_id,775),4500)=	'+CAST(@curve_source_id AS VARCHAR)+ ' '   ELSE '' END+
				CASE WHEN @source_deal_header_list IS NOT NULL  THEN ' AND sdh.source_deal_header_id IN (SELECT deal_id FROM #temp) ' ELSE '' END +
				CASE WHEN (@source_deal_header_list IS NULL) THEN 
					CASE WHEN (@deal_id_from IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR) +' AND ' + CAST(@deal_id_to AS VARCHAR) ELSE '' END +
					CASE WHEN (@deal_id_from IS NOT NULL AND @match_id = 'y') THEN ' AND cast(sdh.source_deal_header_id as varchar) LIKE cast(' + CAST(@deal_id_from AS VARCHAR) + ' as varchar) + ''%''' ELSE '' END +
					CASE WHEN (@deal_id IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.deal_id = ''' + @deal_id + '''' ELSE  '' END +
					CASE WHEN (@deal_id IS NOT NULL AND @match_id = 'y') THEN ' AND sdh.deal_id LIKE ''' + @deal_id + '%''' ELSE  '' END +
					CASE WHEN (@deal_id_from IS NULL AND @deal_id IS NULL) THEN
						CASE WHEN (@trader_id IS NOT NULL) THEN ' AND sdh.trader_id = ' + CAST(@trader_id AS VARCHAR) ELSE  '' END +
						CASE WHEN (@deal_type_id IS NOT NULL) THEN ' AND sdh.source_deal_type_id = ' + CAST(@deal_type_id AS VARCHAR) ELSE  '' END +
						CASE WHEN (@deal_sub_type_id IS NOT NULL) THEN ' AND sdh.deal_sub_type_type_id = ' + CAST(@deal_sub_type_id AS VARCHAR) ELSE  '' END +
						CASE WHEN (@counterparty_id IS NOT NULL) THEN ' AND (sdh.counterparty_id IN (' + @counterparty_id + ')) ' ELSE  '' END +
						CASE WHEN (@source_system_book_id1 IS NOT NULL) THEN ' AND (sdh.source_system_book_id1 =' + CAST(@source_system_book_id1 AS VARCHAR)+ ') ' ELSE  '' END +
						CASE WHEN (@source_system_book_id2 IS NOT NULL) THEN ' AND (sdh.source_system_book_id2 =' + CAST(@source_system_book_id2 AS VARCHAR)+ ') ' ELSE  '' END +
						CASE WHEN (@source_system_book_id3 IS NOT NULL) THEN ' AND (sdh.source_system_book_id3 =' + CAST(@source_system_book_id3 AS VARCHAR)+ ') ' ELSE  '' END +
						CASE WHEN (@source_system_book_id4 IS NOT NULL) THEN ' AND (sdh.source_system_book_id4 =' + CAST(@source_system_book_id4 AS VARCHAR)+ ') ' ELSE  '' END +
						CASE WHEN (@deal_date_from IS NOT NULL) THEN ' AND sdh.deal_date  BETWEEN ''' + @deal_date_from + ''' AND ''' +  @deal_date_to + ''' ' ELSE  '' END +
						CASE WHEN (@term_start IS NOT NULL)  AND @detail_option <> 'p' THEN ' AND ISNULL(hd.pnl_term,sdp.term_start) BETWEEN '''  + @term_start + ''' AND ''' +  @term_end + ''' ' ELSE  '' END +
						CASE WHEN (@phy_fin<>'b') THEN ' AND sdh.physical_financial_flag = ''' + @phy_fin + ''' ' ELSE  '' END +
						CASE WHEN (@commodity_id IS NOT NULL) THEN ' AND ISNULL(spcd.commodity_id,sdh.commodity_id) = ' + CAST(@commodity_id AS VARCHAR) ELSE  '' END  +
						CASE WHEN (@counterparty<>'a') THEN ' AND sc.int_ext_flag = ''' + @counterparty + '''' ELSE  '' END +
						CASE WHEN (@cpty_type_id IS NOT NULL) THEN ' AND sc.type_of_entity = ' + CAST(@cpty_type_id AS VARCHAR) ELSE  '' END +
						CASE WHEN (@mapped = 'm') THEN ' AND ssbm.fas_book_id is NOT NULL ' ELSE '' END +
						CASE WHEN (@mapped = 'n') THEN ' AND ssbm.fas_book_id IS NOT NULL ' ELSE '' END + 
						CASE WHEN @deal_status IS NOT NULL THEN ' AND sdh.deal_status IN (' + @deal_status + ')' ELSE '' END +
						CASE WHEN @contract_ids IS NOT NULL THEN ' AND sdh.contract_id IN (' + @contract_ids + ')' ELSE  '' END 

					ELSE '' END
				ELSE '' END		
				--IF @drill1 IS NOT NULL
				--SET @sql_WhereB = @sql_WhereB + ' AND sub.entity_name like ''%' + @drill1 + '%'''

				--IF @drill2 IS NOT NULL
				--SET @sql_WhereB = @sql_WhereB + ' AND stra.entity_name like ''%' + @drill2 + '%'''

				--IF @drill3 IS NOT NULL
				--SET @sql_WhereB = @sql_WhereB + ' AND book.entity_name like ''%' + @drill3 + '%'''

				--IF @drill4 IS NOT NULL
				--SET @sql_WhereB = @sql_WhereB + ' AND sc.counterparty_name like ''%' + @drill4 + '%'''

				--IF @drill5 IS NOT NULL
				--SET @sql_WhereB = @sql_WhereB + ' AND sdp.term_start = dbo.FNAStdDate(''' + @drill5 + ''')'

				--IF @drill6 IS NOT NULL
				--SET @sql_WhereB = @sql_WhereB + ' AND st.trader_name like ''%' + @drill6 + '%'''
						
				IF @transaction_type IS NOT NULL 
				SET @sql_WhereB = @sql_WhereB +  ' AND ssbm.fas_deal_type_value_id IN( ' + CAST(@transaction_type AS VARCHAR(500))+')'
				
				IF @parent_counterparty IS NOT NULL 
				SET @sql_WhereB = @sql_WhereB +  ' AND sc.parent_counterparty_id = '''+CAST(@parent_counterparty AS VARCHAR(100)) +''''


	-- populate hedge deferral values for current as of dat
	CREATE INDEX [IDX_hd1] ON #hedge_deferral0(source_deal_header_id,cash_flow_term,pnl_term)
	CREATE INDEX [IDX_hd2] ON #hedge_deferral1(source_deal_header_id,cash_flow_term,pnl_term)
	CREATE INDEX [IDX_hd3] ON #hedge_deferral2(source_deal_header_id,cash_flow_term,pnl_term)

	
----######### save the premiums in temp table
		IF (@settlement_only='y' OR @summary_option='21')
		BEGIN
			CREATE TABLE #premium(source_deal_header_id INT,leg INT,term_start DATETIME,premium FLOAT,fs_type CHAR(1) COLLATE DATABASE_DEFAULT )
			SET @sql_from= '
				INSERT INTO #premium
				SELECT ifb.source_deal_header_id,ifb.leg,ifb.term_start, SUM(value) premium,''f''					
				FROM 
					index_fees_breakdown ifb 				
					INNER JOIN static_data_value s ON s.value_id = ifb.field_id AND s.category_id = '+CAST(@premium_id AS VARCHAR)+'
					INNER JOIN source_deal_header sdh ON ifb.source_deal_header_id=sdh.source_deal_header_id' +
						CASE WHEN (@mapped = 'm' AND (@deal_id_from IS NULL AND @deal_id IS NULL)) THEN ' INNER JOIN #books bk ON 
								bk.source_system_book_id1 = sdh.source_system_book_id1 AND
								bk.source_system_book_id2 = sdh.source_system_book_id2 AND
								bk.source_system_book_id3 = sdh.source_system_book_id3 AND
								bk.source_system_book_id4 = sdh.source_system_book_id4 '
						ELSE '' END + 	'
				  WHERE
					ifb.as_of_date='''+@as_of_date+''''+
					CASE WHEN @source_deal_header_list IS NOT NULL  THEN ' AND sdh.source_deal_header_id IN (SELECT deal_id FROM #temp) ' ELSE '' END +
					CASE WHEN (@source_deal_header_list is NULL AND @deal_id_from IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR) +' AND ' + CAST(@deal_id_to AS VARCHAR) ELSE '' END +
					CASE WHEN (@source_deal_header_list is NULL AND @deal_id_from IS NOT NULL AND @match_id = 'y') THEN ' AND cast(sdh.source_deal_header_id as varchar) LIKE cast(' + CAST(@deal_id_from AS VARCHAR) + ' as varchar) + ''%''' ELSE '' END +
					CASE WHEN (@source_deal_header_list is NULL AND @deal_id IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.deal_id = ''' + @deal_id + '''' ELSE  '' END +
					CASE WHEN (@source_deal_header_list is NULL AND @deal_id IS NOT NULL AND @match_id = 'y') THEN ' AND sdh.deal_id LIKE ''' + @deal_id + '%''' ELSE  '' END +
				 ' GROUP BY ifb.source_deal_header_id,ifb.leg,ifb.term_start'

				CREATE INDEX [IDX_pr1] ON #premium(source_deal_header_id,term_start,leg)
			
		EXEC (@sql_from)	
		END

	IF @period_report = 'y' AND @previous_as_of_date IS NOT NULL

		-- populate hedge deferral values for prior as of date
		If @report_type = 'e' 
		BEGIN
		
			SET @sql_from= 'INSERT INTO #hedge_deferral0
			SELECT h.as_of_date,h.source_deal_header_id, cash_flow_term, pnl_term, SUM(und_pnl) a_und_pnl, SUM(dis_pnl) a_dis_pnl, max(per_alloc) per_alloc,
					SUM(deal_volume) deal_volume,MAX(pnl_currency_id)pnl_currency_id,
					SUM(market_value),SUM(contract_value),SUM(dis_market_value),SUM(dis_contract_value),
					SUM(market_value_pnl),SUM(contract_value_pnl),SUM(dis_market_value_pnl),SUM(dis_contract_value_pnl)
			FROM	hedge_deferral_values h
					INNER JOIN source_deal_header sdh ON h.source_deal_header_id=sdh.source_deal_header_id' +
					CASE WHEN (@mapped = 'm' AND (@deal_id_from IS NULL AND @deal_id IS NULL)) THEN ' INNER JOIN #books bk ON 
							bk.source_system_book_id1 = sdh.source_system_book_id1 AND
							bk.source_system_book_id2 = sdh.source_system_book_id2 AND
							bk.source_system_book_id3 = sdh.source_system_book_id3 AND
							bk.source_system_book_id4 = sdh.source_system_book_id4 '
					ELSE '' END + 	'
			WHERE	h.set_type = ''y''
				   and h.as_of_date = case when (h.set_type=''f'') then '''+@previous_as_of_date+''' else h.as_of_date end			   
				   and ('''+@settlement_only+''' = ''y''))'+
				CASE WHEN @source_deal_header_list IS NOT NULL  THEN ' AND sdh.source_deal_header_id IN (SELECT deal_id FROM #temp) ' ELSE '' END +
				CASE WHEN (@source_deal_header_list is NULL AND @deal_id_from IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR) +' AND ' + CAST(@deal_id_to AS VARCHAR) ELSE '' END +
				CASE WHEN (@source_deal_header_list is NULL AND @deal_id_from IS NOT NULL AND @match_id = 'y') THEN ' AND cast(sdh.source_deal_header_id as varchar) LIKE cast(' + CAST(@deal_id_from AS VARCHAR) + ' as varchar) + ''%''' ELSE '' END +
				CASE WHEN (@source_deal_header_list is NULL AND @deal_id IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.deal_id = ''' + @deal_id + '''' ELSE  '' END +
				CASE WHEN (@source_deal_header_list is NULL AND @deal_id IS NOT NULL AND @match_id = 'y') THEN ' AND sdh.deal_id LIKE ''' + @deal_id + '%''' ELSE  '' END +					
			' GROUP BY h.source_deal_header_id, cash_flow_term, pnl_term,h.as_of_date'
		
			EXEC(@sql_from)
		END
	
		DECLARE @time_map varchar(500),@time_map_end varchar(500)
		SET @time_map =
					CASE WHEN @detail_option IN('c') THEN --CASH FLOW
							' sdp.term_start' 
						 WHEN @detail_option IN('p') OR @summary_option IN('21') THEN
							'CASE	WHEN (hd.pnl_term IS NOT NULL) THEN hd.pnl_term 
									ELSE sdp.term_start END ' 
						 ELSE 
							'sdp.term_start '  --MTM 
						 END 
		SET @time_map_end =	'DATEADD(m,1,'+@time_map+')'
		
	IF @settlement_only='y'
	BEGIN
		
		SET @sql_from= ' INNER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id 
					INNER JOIN source_traders st on st.source_trader_id = sdh.trader_id ' +
					CASE WHEN (@mapped = 'm' AND (@deal_id_from IS NULL AND @deal_id IS NULL)) THEN ' INNER JOIN #books bk ON 
							bk.source_system_book_id1 = sdh.source_system_book_id1 AND
							bk.source_system_book_id2 = sdh.source_system_book_id2 AND
							bk.source_system_book_id3 = sdh.source_system_book_id3 AND
							bk.source_system_book_id4 = sdh.source_system_book_id4 '
					ELSE '' END + 	'
					LEFT OUTER JOIN source_counterparty sc1 ON sc.parent_counterparty_id = sc1.source_counterparty_id			
					LEFT OUTER JOIN source_book sb1 ON sb1.source_book_id = sdh.source_system_book_id1 
					LEFT OUTER JOIN source_book sb2 ON sb2.source_book_id = sdh.source_system_book_id2
					LEFT OUTER JOIN source_book sb3 ON sb3.source_book_id = sdh.source_system_book_id3
					LEFT OUTER JOIN source_book sb4 ON sb4.source_book_id = sdh.source_system_book_id4
					LEFT OUTER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
													sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND 
													sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
													sdh.source_system_book_id4 = ssbm.source_system_book_id4
					LEFT OUTER JOIN portfolio_hierarchy book on book.entity_id = ssbm.fas_book_id
					LEFT OUTER JOIN portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id
					LEFT OUTER JOIN portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id
					LEFT OUTER JOIN fas_strategy fs on fs.fas_strategy_id = stra.entity_id 
					LEFT JOIN fas_subsidiaries fs1 On fs1.fas_subsidiary_id = sub.entity_id
					LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
					LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id	
					LEFT JOIN source_uom su ON su.source_uom_id=spcd.uom_id
					LEFT JOIN source_uom su1 ON su1.source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)
					left JOIN source_currency cur on cur.source_currency_id = sdd.fixed_price_currency_id
					'    + CASE WHEN  (@deal_status IS NULL AND @deal_id_from IS NULL AND @deal_id IS NULL) THEN 'INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status' ELSE '' END +
				    '
					LEFT JOIN rec_volume_unit_conversion uc on uc.from_source_uom_id=su1.source_uom_id AND uc.to_source_uom_id='+CAST(@convert_uom AS VARCHAR) +'
					LEFT JOIN contract_group cg on cg.contract_id=sdh.contract_id
					LEFT JOIN static_data_value sdv on sdv.value_id=sdh.pricing
					LEFT JOIN static_data_value sdv1 on sdv1.value_id=sdh.deal_status
					LEFT JOIN static_data_value sdv2 on sdv2.value_id=sdh.internal_desk_id
					LEFT JOIN static_data_value sdv3 on sdv3.value_id=coalesce(spcd.block_define_id,sdh.block_define_id)
					LEFT JOIN source_deal_header_template sdht on sdht.template_id=sdh.template_id
					LEFT JOIN source_commodity com on com.source_commodity_id=spcd.commodity_id --AND com.source_commodity_id=-1
					LEFT JOIN source_major_location smj ON smj.source_major_location_ID=sml.source_major_location_ID
					LEFT JOIN source_uom su2 ON su2.source_uom_id=sdd.deal_volume_uom_id
					LEFT JOIN static_data_value sdv_c ON sdv_c.value_id=sml.country
					LEFT JOIN static_data_value sdv_g ON sdv_g.value_id=sml.grid_value_id
					LEFT JOIN source_deal_type sdt on sdt.source_deal_type_id = sdh.source_deal_type_id
					LEFT JOIN static_data_value sdv_cat ON sdv_cat.value_id = sdd.category
					'
		
		SET @sql_select= '	SELECT max(sub.entity_name) Sub, 
					max(stra.entity_name) Strategy, 
					max(book.entity_name) Book,
					max(sc.counterparty_name+CASE WHEN hd.pnl_term IS NOT NULL THEN '' -Released'' ELSE '''' END) Counterparty,
					max(sc1.counterparty_name) [Parent Counterparty],					
					dbo.FNAHyperLink(10131024,(cast(sdh.source_deal_header_id as varchar) + '' ('' + sdh.deal_id + '')''),sdh.source_deal_header_id, ''' + @disable_hyperlink + ''') [Deal Number], 	 
					sdh.deal_id [Deal Ref Number],
					(max(sdh.deal_date)) [Deal Date],
					max(sdt.source_deal_type_name) [Type], 
					max(case when (sdh.physical_financial_flag = ''p'') then ''Phy'' else ''Fin'' end) [Physical/Financial],
					sdh.source_deal_header_id,max(sdh.header_buy_sell_flag) header_buy_sell_flag, 
					max(sb1.source_book_name) sbm1, max(sb2.source_book_name) sbm2, max(sb3.source_book_name) sbm3, max(sb4.source_book_name) sbm4,
					max(st.trader_name) Trader, max(scur.currency_name) Currency,
					MAX(CASE WHEN hd.pnl_term IS NOT NULL THEN DATEADD(m,1,sdd.term_start)-1 ELSE sdd.term_end END) term_end, 
					MAX(su.uom_name) [price_uom],MAX(sml.Location_Name) [Location],MAX(su1.uom_name)[volume_uom],
					max(cur.currency_name) DealPriceCurrency,
					max(cg.contract_name) ContractName,max(sdv.code)  Pricing,max(sdv1.code)  DealStatus,spcd.curve_name [IndexName],
					max(sdd.Leg),max(sdh.entire_term_start) DealTermStart,max(sdh.entire_term_end) DealTermEnd ,
					max(sdht.template_name) TemplateName,max(sdv2.code) [Profile],max(com.commodity_name) Commodity,max(sdv3.code) BlockDefinition,MAX(sdh.reference) Reference,
					max(sdh.Description1),max(sdh.Description2),max(sdh.Description3),max(sdh.create_user) CreatedBy , (max(sdh.create_ts)) CreatedDate,
					max(sdh.update_user) UpdatBy,(max(sdh.update_ts)) UpdateDate,MAX(sdv_c.code)country,MAX(sdv_g.code) Grid,
					
					'
		
	SET @Sql ='
			insert into #deal_pnl1 ([Sub],[Strategy],[Book],[Counterparty],[Parent Counterparty],[DealNumber],[DealRefNumber],[DealDate],
				[Type],[Phy/Fin] ,[source_deal_header_id],
				buy_sell_flag, sbm1, sbm2, sbm3, sbm4, Trader, Currency,[term_end],[price_uom],[Location]
				,[volume_uom],DealPriceCurrency,ContractName,pricing ,DealStatus,[IndexName],
				Leg,DealTermStart,DealTermEnd ,TemplateName,[Profile],Commodity,BlockDefinition,Reference,
				Description1,Description2,Description3,CreatedBy ,CreatedDate,UpdateBy,UpdateDate,country,grid,[Expiration],[PNLDate],[CumulativeFV],[pnl_as_of_date],Volume,[price],[term_start_orig],[mtm],[dis_mtm],[marketvalue],[dis_market_value],[contractvalue],[dis_contract_value],[charge_type] ,[charge_type_id],[location_group],deal_volume,deal_volume_uom,cashflow_date,pnl_date,category,MwhEquivalentVol,source_deal_type_id,[contract_id],product_id,[counterparty_id],[term_start],sub_id
				)'
				+ @sql_select+
					'MAX(ISNULL(sdp.settlement_date,sdp1.term_end)) Expiration,MAX(ISNULL(sdp.as_of_date,sdp1.pnl_as_of_date)) [PNLDate],
					sum(COALESCE('+CASE WHEN @discount_option = 'u' THEN 'hd.a_und_pnl' ELSE 'hd.a_dis_pnl' END+',
							CASE WHEN hd1.source_deal_header_id IS NOT NULL AND (CONVERT(varchar(7), sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) AND '''+@detail_option+''' IN(''p'') THEN 0  
							WHEN  (CONVERT(varchar(7),ISNULL(sdp.term_start,sdp1.term_start), 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) THEN ISNULL(sdp1.und_pnl_set,0)+ISNULL(sdp.settlement_amount,0)'+CASE WHEN @summary_option<>'21' THEN '+ISNULL(premium,0)' ELSE '-ISNULL(premium,0)' END+' ELSE	settlement_amount'+CASE WHEN @summary_option='21' THEN '-ISNULL(premium,0)' ELSE '' END+' END, 0)) Settlement,
					MAX(ISNULL(sdp.as_of_date,sdp1.pnl_as_of_date)) pnl_as_of_date,
					SUM(COALESCE(hd.deal_volume,CASE WHEN hd1.source_deal_header_id IS NOT NULL AND (CONVERT(varchar(7), sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) AND '''+@detail_option+'''IN(''p'') THEN 0  
							WHEN  (CONVERT(varchar(7),ISNULL(sdp.term_start,sdp1.term_start), 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) THEN ISNULL(sdp1.deal_volume*CASE WHEN sdd.buy_sell_flag=''s'' THEN -1 ELSE 1 END,0)+ISNULL(CASE WHEN sdd.physical_financial_flag=''f'' THEN sdp.fin_volume ELSE sdp.volume END,0) ELSE ISNULL(CASE WHEN sdd.physical_financial_flag=''f'' THEN sdp.fin_volume ELSE sdp.volume END,sdd.deal_volume*CASE WHEN sdd.buy_sell_flag=''s'' THEN -1 ELSE 1 END) END)) Volume,
							MAX(sdp.net_price) [price],
					MAX(CASE WHEN hd.pnl_term IS NOT NULL THEN sdd.term_start ELSE NULL END),
					sum(COALESCE(hd.a_und_pnl,
							CASE WHEN hd1.source_deal_header_id IS NOT NULL AND (CONVERT(varchar(7), sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) AND '''+@detail_option+''' IN(''p'') THEN 0  
							WHEN  (CONVERT(varchar(7),ISNULL(sdp.term_start,sdp1.term_start), 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) THEN ISNULL(sdp1.und_pnl_set,0)+ISNULL(sdp.settlement_amount,0)'+CASE WHEN @summary_option<>'21' THEN '+ISNULL(premium,0)' ELSE '-ISNULL(premium,0)' END+' ELSE	settlement_amount'+CASE WHEN @summary_option='21' THEN '-ISNULL(premium,0)' ELSE '' END+' END, 0)) mtm,
					sum(COALESCE(hd.a_dis_pnl,
							CASE WHEN hd1.source_deal_header_id IS NOT NULL AND (CONVERT(varchar(7), sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) AND '''+@detail_option+''' IN(''p'') THEN 0  
							WHEN  (CONVERT(varchar(7),ISNULL(sdp.term_start,sdp1.term_start), 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) THEN ISNULL(sdp1.und_pnl_set,0)+ISNULL(sdp.settlement_amount,0)'+CASE WHEN @summary_option<>'21' THEN '+ISNULL(premium,0)' ELSE '-ISNULL(premium,0)' END+' ELSE	settlement_amount'+CASE WHEN @summary_option='21' THEN '-ISNULL(premium,0)' ELSE '' END+' END, 0)) dis_mtm,
					sum(COALESCE(hd.market_value_pnl,
							CASE WHEN hd1.source_deal_header_id IS NOT NULL AND (CONVERT(varchar(7), sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) AND '''+@detail_option+''' IN(''p'') THEN 0  
							WHEN  (CONVERT(varchar(7),ISNULL(sdp.term_start,sdp1.term_start), 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) THEN ISNULL(sdp1.market_value,0)+ISNULL(sdp.market_value,0) ELSE sdp.market_value END, 0)) market_value,
					sum(COALESCE(hd.dis_market_value_pnl,
							CASE WHEN hd1.source_deal_header_id IS NOT NULL AND (CONVERT(varchar(7), sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) AND '''+@detail_option+''' IN(''p'') THEN 0  
							WHEN  (CONVERT(varchar(7),ISNULL(sdp.term_start,sdp1.term_start), 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) THEN ISNULL(sdp1.dis_market_value,0)+ISNULL(sdp.market_value,0) ELSE	sdp.market_value END, 0)) dis_market_value,
					sum(COALESCE(hd.contract_value_pnl,
							CASE WHEN hd1.source_deal_header_id IS NOT NULL AND (CONVERT(varchar(7), sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) AND '''+@detail_option+''' IN(''p'') THEN 0  
							WHEN  (CONVERT(varchar(7),ISNULL(sdp.term_start,sdp1.term_start), 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) THEN ISNULL(sdp1.contract_value,0)+ISNULL(sdp.contract_value,0) ELSE sdp.contract_value END, 0)) contract_value,
					sum(COALESCE(hd.dis_contract_value_pnl,
							CASE WHEN hd1.source_deal_header_id IS NOT NULL AND (CONVERT(varchar(7), sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) AND '''+@detail_option+''' IN(''p'') THEN 0  
							WHEN  (CONVERT(varchar(7),ISNULL(sdp.term_start,sdp1.term_start), 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) THEN ISNULL(sdp1.dis_contract_value,0)+ISNULL(sdp.contract_value,0) ELSE	sdp.contract_value END, 0)) dis_contract_value
					,''Commodity''+CASE WHEN hd.pnl_term IS NOT NULL THEN '' -Released'' ELSE '''' END AS charge_type,CASE WHEN hd.pnl_term IS NOT NULL THEN 1 ELSE 2 END AS charge_type_id,
					MAX(smj.location_name),SUM(sdd.deal_volume*CASE WHEN sdd.buy_sell_flag=''s'' THEN -1 ELSE 1 END),MAX(su2.uom_name),
					ISNULL('+@time_map+',sdp1.term_start)[cashflow_date],ISNULL('+@time_map+',sdp1.term_start) [pnl_date],MAX(sdv_cat.code),
					SUM(COALESCE(hd.deal_volume,CASE WHEN hd1.source_deal_header_id IS NOT NULL AND (CONVERT(varchar(7), sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) AND '''+@detail_option+''' IN(''p'') THEN 0  
							WHEN  (CONVERT(varchar(7),ISNULL(sdp.term_start,sdp1.term_start), 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120)) THEN ISNULL(sdp1.deal_volume*CASE WHEN sdd.buy_sell_flag=''s'' THEN -1 ELSE 1 END,0)+ISNULL(CASE WHEN sdd.physical_financial_flag=''f'' THEN sdp.fin_volume ELSE sdp.volume END,0) ELSE ISNULL(CASE WHEN sdd.physical_financial_flag=''f'' THEN sdp.fin_volume ELSE sdp.volume END,sdd.deal_volume*CASE WHEN sdd.buy_sell_flag=''s'' THEN -1 ELSE 1 END) END))*MAX(ISNULL(uc.conversion_factor,1)) MwhEquivalentVol,MAX(sdh.source_deal_type_id),MAX(sdh.contract_id),MAX(sdh.product_id),MAX(sdh.counterparty_id),ISNULL('+@time_map+',sdp1.term_start) term_start,MAX(sub.entity_id)
				 FROM	
					source_deal_header sdh 
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
					INNER JOIN source_deal_settlement sdp ON sdh.source_deal_header_id=sdp.source_deal_header_id 
						AND sdp.term_start=sdd.term_start	
						AND ISNULL(sdp.leg,1)=sdd.leg
						AND (sdp.set_type = ''f'' AND sdp.as_of_date = '''+@as_of_date+''' OR ( sdp.set_type = ''s'' AND '''+@as_of_date+'''>=sdp.term_end))
					'+@sql_from+'
					LEFT OUTER JOIN #hedge_deferral1 hd ON hd.source_deal_header_id = sdd.source_deal_header_id 
						AND hd.cash_flow_term = sdd.term_start
					LEFT JOIN source_deal_pnl_detail sdp1 ON sdh.source_deal_header_id=sdp1.source_deal_header_id 
						AND sdp1.term_start=sdd.term_start						
						AND sdp1.pnl_as_of_date='''+@as_of_date+'''
						AND sdp1.leg=sdd.leg and sdp1.pnl_source_value_id =' +CAST(@curve_source_id as varchar) +'
					LEFT JOIN #premium ifb  ON ifb.source_deal_header_id =  sdh.source_deal_header_id 
						AND ifb.term_start = sdd.term_start						
						AND ifb.leg = sdd.leg		
						AND ifb.fs_type=''f''				
					LEFT OUTER JOIN (SELECT DISTINCT source_deal_header_id FROM #hedge_deferral2) hd1 ON hd1.source_deal_header_id = sdd.source_deal_header_id 		
					LEFT JOIN source_currency scur on scur.source_currency_id = COALESCE(hd.pnl_currency_id,sdp.settlement_currency_id,fs1.func_cur_value_id)				
			 WHERE 1=1 
			AND ((ISNULL(sdht.internal_deal_type_value_id,-1) IN(19,20,21) AND sdp.source_deal_header_id IS NOT NULL) OR ISNULL(sdht.internal_deal_type_value_id,-1) NOT IN(19,20,21)) 
			 ' +@Sql_WhereB+
		
			   ' AND convert(varchar(7),COALESCE(hd.pnl_term,sdp.term_start,sdp1.term_start),120)+   ''-01'' <= convert(varchar(7),'''+@as_of_date+''',120)+   ''-01'''
			 +' GROUP BY sdh.source_deal_header_id, sdh.deal_id,sdd.leg, sdp.settlement_date,sdp.term_start,sdp1.term_start,ISNULL(sdp.term_end,sdd.term_end),spcd.curve_name,hd.pnl_term,hd.pnl_term,invoice_due_date'
			 
			 +' UNION '+
			 
			 @sql_select+
				'ISNULL(sdp.term_end,sdd.term_end) Expiration,MAX(sdp.pnl_as_of_date) [PNLDate],
				 sum(CASE WHEN CONVERT(varchar(7),sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120) AND '''+@summary_option+'''=''21'' THEN COALESCE(hd.a_und_pnl,sdp.und_pnl_set,0) ELSE COALESCE('+CASE WHEN @discount_option = 'u' THEN 'hd.a_und_pnl' ELSE 'hd.a_dis_pnl' END+',und_pnl_set, 0) '+CASE WHEN @summary_option<>'21' THEN '+ISNULL(premium,0)' ELSE '' END+' END) Settlement,MAX(pnl_as_of_date) pnl_as_of_date,
				 SUM(COALESCE(hd.deal_volume,sdp.deal_volume,sdd.deal_volume)*CASE WHEN sdd.buy_sell_flag=''s'' THEN -1 ELSE 1 END) Volume,MAX(sdp.price) [price],
				 MAX(CASE WHEN hd.pnl_term IS NOT NULL THEN sdd.term_start ELSE NULL END),
				 SUM(CASE WHEN CONVERT(varchar(7),sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120) AND '''+@summary_option+'''=''21'' THEN COALESCE(hd.a_und_pnl,sdp.und_pnl, 0) ELSE COALESCE(hd.a_und_pnl,sdp.und_pnl, 0) '+CASE WHEN @summary_option<>'21' THEN '+ISNULL(premium,0)' ELSE '' END+' END ) mtm,
				 SUM(CASE WHEN CONVERT(varchar(7),sdp.term_start, 120) = CONVERT(varchar(7), '''+@as_of_date+''', 120) AND '''+@summary_option+'''=''21'' THEN COALESCE(hd.a_dis_pnl,sdp.dis_pnl, 0) ELSE COALESCE(hd.a_dis_pnl,sdp.dis_pnl, 0) '+CASE WHEN @summary_option<>'21' THEN '+ISNULL(premium,0)' ELSE '' END+' END ) dis_mtm,
				 SUM(COALESCE(hd.market_value_pnl,sdp.market_value, 0)) market_value,
				 SUM(COALESCE(hd.dis_market_value_pnl,sdp.dis_market_value, 0)) dis_market_value,
				 SUM(COALESCE(hd.contract_value_pnl,sdp.contract_value, 0)) contract_value,
				 SUM(COALESCE(hd.dis_contract_value_pnl,sdp.dis_contract_value,0)) dis_contract_value,
				 ''Commodity''+CASE WHEN hd.pnl_term IS NOT NULL THEN '' -Released'' ELSE '''' END AS charge_type,CASE WHEN hd.pnl_term IS NOT NULL THEN 1 ELSE 2 END AS charge_type_id,
				 MAX(smj.location_name),SUM(sdd.deal_volume*CASE WHEN sdd.buy_sell_flag=''s'' THEN -1 ELSE 1 END),MAX(su2.uom_name),
				 '+@time_map+'[cashflow_date],'+@time_map+'[pnl_date],MAX(sdv_cat.code),
				 SUM(COALESCE(hd.deal_volume,sdp.deal_volume,sdd.deal_volume)*CASE WHEN sdd.buy_sell_flag=''s'' THEN -1 ELSE 1 END)*MAX(ISNULL(uc.conversion_factor,1)) MwhEquivalentVol,MAX(sdh.source_deal_type_id),MAX(sdh.contract_id),MAX(sdh.product_id),MAX(sdh.counterparty_id),'+@time_map+' term_start,MAX(sub.entity_id)
				FROM	
					source_deal_header sdh 
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id						
					LEFT JOIN source_deal_pnl_detail sdp ON sdh.source_deal_header_id=sdp.source_deal_header_id 
						AND sdp.term_start=sdd.term_start
						AND sdp.pnl_as_of_date = '''+@as_of_date+'''
						AND sdd.leg = sdp.leg and sdp.pnl_source_value_id =' +CAST(@curve_source_id as varchar)
					+@sql_from+'
					LEFT OUTER JOIN #hedge_deferral2 hd ON hd.source_deal_header_id = sdd.source_deal_header_id 
						AND hd.cash_flow_term = sdd.term_start
						AND hd.as_Of_date='''+@as_of_date+'''
					LEFT JOIN source_currency scur on scur.source_currency_id = COALESCE(hd.pnl_currency_id,sdp.pnl_currency_id,fs1.func_cur_value_id)'
				+CASE WHEN @summary_option <> '21' THEN 
					'LEFT JOIN #premium ifb  ON ifb.source_deal_header_id =  sdh.source_deal_header_id 
						AND ifb.term_start = sdd.term_start						
						AND ifb.leg = sdd.leg		
						AND ifb.fs_type=''f'''
					ELSE '' END+'
			 WHERE 1=1  ' +@Sql_WhereB+
	 		--+' AND sdh.source_deal_header_id IN(47250,1667,120824,49257,34169,46319,45137,113340,47253,49736,50136,45438,114334,3857,3856,45438)'+
			 ' AND ISNULL(hd.as_of_date,sdp.pnl_as_of_date) = '''+@as_of_date+'''
			  AND convert(varchar(10),ISNULL(hd.pnl_term,sdp.term_start),120) > convert(varchar(10),'''+@as_of_date+''',120)
			  GROUP BY sdh.source_deal_header_id, sdh.deal_id,sdd.leg, sdp.term_start,ISNULL(sdp.term_end,sdd.term_end),spcd.curve_name,hd.pnl_term,hd.pnl_term,invoice_due_date'
		END
			 
	--END	
	ELSE
		
	BEGIN
		--SELECT '--MTM--MMMMMMMMMMMMMMMMMMMMMMMMTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTMMMMMMMMMMMMMMMMMM'
		SET @Sql ='
		insert into #deal_pnl1 ([Sub],[Strategy],[Book],[Counterparty],[DealNumber],[DealRefNumber],[DealDate],[PNLDate],
			[Type],[Phy/Fin] ,[Expiration],[CumulativeFV],[term_start],[source_deal_header_id],[pnl_as_of_date],
			buy_sell_flag, ContractValue, MarketValue, Volume, sbm1, sbm2, sbm3, sbm4, Trader, Currency,[term_start_orig],[mtm],[dis_mtm],[dis_market_value],[dis_contract_value],category,product_id,sub_id
		select max(sub.entity_name) Sub, max(stra.entity_name) Strategy, max(book.entity_name) Book,
					max(sc.counterparty_name+CASE WHEN hd.pnl_term IS NOT NULL THEN '' -Released'' ELSE '''' END) Counterparty,
					--dbo.FNAHyperLink(10131024,(cast(sdh.source_deal_header_id as varchar) + '' ('' + sdh.deal_id + '')''),sdh.source_deal_header_id, ''' + @disable_hyperlink + ''') DealNumber, 	 
					''<span style=cursor:hand onClick=openHyperLink(10131024,''+CAST(sdh.source_deal_header_id AS VARCHAR)+'')><font color=#0000ff><u>''+cast(sdh.source_deal_header_id as varchar)+''</u></font></span>'',
					sdh.deal_id DealRefNumber, 
					(max(sdh.deal_date)) [DealDate],
					(max(sdp.pnl_as_of_date)) [PNLDate],
					max(case when (ssbm.fas_deal_type_value_id IS NULL) then ''Unmapped'' when (ssbm.fas_deal_type_value_id = 400) then ''Der'' else '' Item'' end) [Type], 
					max(case when (sdh.physical_financial_flag = ''p'') then ''Phy'' else ''Fin'' end) [Phy/Fin], ' +
					@time_map + ' Expiration, ' +		
					CASE WHEN @report_type = 'm' THEN --MTM
						CASE WHEN @discount_option = 'u' THEN  ' sum(isnull(und_pnl, 0)'+CASE WHEN @summary_option='21' THEN '-ISNULL(premium,0)' ELSE '' END+') ' ELSE ' sum(isnull(dis_pnl, 0)'+CASE WHEN @summary_option='21' THEN '-ISNULL(premium,0)' ELSE '' END+') ' END + ' CumulativeFV, ' 
						WHEN @report_type = 'c' THEN --CASH FLOW
							CASE WHEN @discount_option = 'u' THEN  ' sum(isnull(und_pnl_set, 0)'+CASE WHEN @summary_option='21' THEN '-ISNULL(premium,0)' ELSE '' END+') ' ELSE ' sum(isnull(und_pnl_set, 0)'+CASE WHEN @summary_option='21' THEN '-ISNULL(premium,0)' ELSE '' END+') ' END + ' CumulativeFV, ' 
						ELSE	
							CASE WHEN @discount_option = 'u' THEN  ' sum(coalesce(hd.a_und_pnl, und_pnl_set, 0)'+CASE WHEN @summary_option='21' THEN '-ISNULL(premium,0)' ELSE '' END+') ' ELSE ' sum(coalesce(hd.a_dis_pnl, und_pnl_set, 0)'+CASE WHEN @summary_option='21' THEN '-ISNULL(premium,0)' ELSE '' END+') ' END + ' CumulativeFV, ' 
					END +						
					@time_map + ' term_start, ' +					
					'sdh.source_deal_header_id, max(pnl_as_of_date) pnl_as_of_date,
					max(sdh.header_buy_sell_flag) header_buy_sell_flag, ' + 
					'CASE WHEN (''' + isnull(@report_type, 'm') + ''' = ''p'') THEN 0 ELSE ' + 
					CASE WHEN @discount_option = 'u' THEN  ' sum(COALESCE(hd.contract_value,sdp.contract_value, 0)) ' ELSE ' sum(COALESCE(hd.dis_contract_value,sdp.dis_contract_value, 0)) ' END + ' END * max(isnull(hd.per_alloc, 1)) ContractValue, ' + 
					'CASE WHEN (''' + isnull(@report_type, 'm') + ''' = ''p'') THEN 0 ELSE ' + 
					CASE WHEN @discount_option = 'u' THEN  ' sum(COALESCE(hd.market_value,sdp.market_value, 0)) ' ELSE ' sum(COALESCE(hd.dis_market_value,sdp.dis_market_value, 0)) ' END + ' END * max(isnull(hd.per_alloc, 1)) MarketValue, ' + 
					'sum(COALESCE(hd.deal_volume,sdp.deal_volume)*CASE WHEN sdd.buy_sell_flag=''s'' THEN -1 ELSE 1 END) Volume ' + 	
					',max(sb1.source_book_name) sbm1, max(sb2.source_book_name) sbm2, max(sb3.source_book_name) sbm3, max(sb4.source_book_name) sbm4,
					max(st.trader_name) Trader, max(scur.currency_name) Currency,
					(CASE WHEN hd.pnl_term IS NOT NULL THEN sdd.term_start ELSE NULL END),
					 SUM(COALESCE(hd.a_und_pnl,sdp.und_pnl, 0)) mtm,
					 SUM(COALESCE(hd.a_dis_pnl,sdp.dis_pnl, 0)) dis_mtm,
					 SUM(COALESCE(hd.dis_market_value,sdp.dis_market_value, 0)) dis_market_value,
					 SUM(COALESCE(hd.dis_contract_value,sdp.dis_contract_value,0)) dis_contract_value,
					 MAX(sdv_cat.code),MAX(sdh.product_id),MAX(sub.entity_id)
					'+CASE WHEN @summary_option='21' THEN ',MAX(ssbm.book_deal_type_map_id),MAX(sdh.broker_id),MAX(sdh.internal_desk_id),MAX(sdh.source_deal_type_id),
									MAX(sdh.trader_id) ,MAX(sdh.contract_id) ,MAX(sdh.internal_portfolio_id) ,MAX(sdh.template_id) ,MAX(sdh.deal_status) ,MAX(sdh.counterparty_id) ,
									MAX(ISNULL(spcd.block_define_id,sdh.block_define_id)),sdd.curve_id,sdd.pv_party ,sdd.location_id,MAX(COALESCE(hd.pnl_currency_id,sdp.pnl_currency_id,fs1.func_cur_value_id)),MAX(sdd.physical_financial_flag),
									''Commodity''+CASE WHEN hd.pnl_term IS NOT NULL THEN '' -Released'' ELSE '''' END AS charge_type,CASE WHEN hd.pnl_term IS NOT NULL THEN 1 ELSE 2 END AS charge_type_id,
									'+@time_map+'[cashflow_date],'+@time_map+'[pnl_date] ,MAX(sdd.category),''f''' 
					ELSE '' END+ 				
		' from		source_deal_header sdh 
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=sdh.source_deal_header_id
					'+ CASE WHEN @summary_option='21' THEN '
					LEFT JOIN ' +	
					dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl_detail' ) + ' 
							sdp on sdh.source_deal_header_id=sdp.source_deal_header_id 
							AND sdp.term_start=sdd.term_start
							AND sdp.pnl_as_of_date= ''' + @as_of_date + '''
							AND sdp.leg=sdd.leg and sdp.pnl_source_value_id =' +CAST(@curve_source_id as varchar)					
					ELSE
					'AND sdd.leg=1
					LEFT JOIN ' +	
					dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl' ) + ' 
							sdp on sdh.source_deal_header_id=sdp.source_deal_header_id 
							AND sdp.term_start=sdd.term_start
							AND sdp.pnl_as_of_date= ''' + @as_of_date + ''' '
					END +		
					' INNER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id 
					INNER JOIN source_traders st on st.source_trader_id = sdh.trader_id '+
					CASE WHEN (@mapped = 'm' AND (@deal_id_from IS NULL AND @deal_id IS NULL)) THEN ' INNER JOIN #books bk ON 
							bk.source_system_book_id1 = sdh.source_system_book_id1 AND
							bk.source_system_book_id2 = sdh.source_system_book_id2 AND
							bk.source_system_book_id3 = sdh.source_system_book_id3 AND
							bk.source_system_book_id4 = sdh.source_system_book_id4 '
					ELSE '' END + 
					
					'			
					LEFT OUTER JOIN
					source_book sb1 ON sb1.source_book_id = sdh.source_system_book_id1 LEFT OUTER JOIN
					source_book sb2 ON sb2.source_book_id = sdh.source_system_book_id2 LEFT OUTER JOIN
					source_book sb3 ON sb3.source_book_id = sdh.source_system_book_id3 LEFT OUTER JOIN
					source_book sb4 ON sb4.source_book_id = sdh.source_system_book_id4 LEFT OUTER JOIN
					source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
													sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND 
													sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
													sdh.source_system_book_id4 = ssbm.source_system_book_id4 LEFT OUTER JOIN
					portfolio_hierarchy book on book.entity_id = ssbm.fas_book_id LEFT OUTER JOIN
					portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id LEFT OUTER JOIN
					portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id LEFT OUTER JOIN
					fas_strategy fs on fs.fas_strategy_id = stra.entity_id
					LEFT JOIN fas_subsidiaries fs1 On fs1.fas_subsidiary_id = sub.entity_id
					LEFT JOIN #hedge_deferral1 hd ON hd.source_deal_header_id = sdd.source_deal_header_id AND
										   hd.cash_flow_term = sdd.term_start 	 
										   AND hd.as_of_date= ''' + @as_of_date + '''
					LEFT JOIN source_currency scur on scur.source_currency_id = COALESCE(hd.pnl_currency_id,sdp.pnl_currency_id,fs1.func_cur_value_id)
					LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
					LEFT JOIN
					contract_group cg on cg.contract_id = sdh.contract_id    
					LEFT JOIN static_data_value sdv_cat ON sdv_cat.value_id = sdd.category					 
					'+CASE WHEN @summary_option='21' THEN 
					'LEFT JOIN #premium ifb  ON ifb.source_deal_header_id =  sdh.source_deal_header_id 
						AND ifb.term_start = sdd.term_start						
						AND ifb.leg = sdd.leg		
						AND ifb.fs_type=''f'''
					ELSE '' END
				    + CASE WHEN  (@deal_status IS NULL AND @deal_id_from IS NULL AND @deal_id IS NULL) THEN 'INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status' ELSE '' END +
		' WHERE 1=1 AND ISNULL(hd.as_of_date,pnl_as_of_date) = ''' + @as_of_date + ''''
		
	
		IF @deal_sub_type_id IS NOT NULL
			SET @sql= @sql + ' AND sdh.deal_sub_type_type_id IN( ' + CAST(@deal_sub_type_id AS VARCHAR(100)) + ')' --Added to add deal sub type filter
		
		IF @contract_ids IS NOT NULL 
			SET @sql = @sql + ' AND cg.contract_id IN (' + @contract_ids + ')'
		--+' AND sdh.source_deal_header_id IN(47250,1667,120824,49257,34169,46319,45137,113340,47253,49736,50136,45438,114334,3857,3856,45438)'
		
		SET @sql=@sql+@sql_WhereB
				+' GROUP BY sdh.source_deal_header_id, sdh.deal_id, sdp.settlement_date,sdd.term_start,sdd.term_end,spcd.curve_name'
	END		
	
	
	--PRINT(@Sql)
	EXEC(@Sql)

	--IF @summary_option <> '21'
	--BEGIN
	--- Insert the Original Deffered value
		INSERT INTO #deal_pnl1 ([Sub],[Strategy],[Book],[Counterparty],[DealNumber],[DealRefNumber],[DealDate],[PNLDate],
				[Type],[Phy/Fin] ,[Expiration],[CumulativeFV],[term_start],[source_deal_header_id],[pnl_as_of_date],
				buy_sell_flag, ContractValue, MarketValue, Volume, sbm1, sbm2, sbm3, sbm4, Trader, Currency,[term_end],[price_uom],[Location]
				,[volume_uom],MwhEquivalentVol,DealPriceCurrency,ContractName,pricing ,DealStatus,[IndexName],
				Leg,DealTermStart,DealTermEnd ,TemplateName,[Profile],Commodity,BlockDefinition,Reference,
				Description1,Description2,Description3,CreatedBy ,CreatedDate,UpdateBy,UpdateDate,[price],[Parent Counterparty],charge_type,charge_type_id,cashflow_date,
				pnl_date,category_id,category,book_deal_type_map_id,broker_id,internal_desk_id,source_deal_type_id,
				trader_id,contract_id,internal_portfolio_id,template_id,deal_status,counterparty_id,
				block_define_id,curve_id,pv_party,location_id,pnl_currency_id,physical_financial_flag,mtm,dis_mtm,dis_market_value,dis_contract_value,forward_actual_flag,sub_id)
		SELECT 
			[Sub],[Strategy],[Book],REPLACE([Counterparty],' -Released',''),[DealNumber],[DealRefNumber],[DealDate],[PNLDate],
			[Type],[Phy/Fin] ,[term_start_orig],SUM([CumulativeFV]),[term_start_orig],[source_deal_header_id],[pnl_as_of_date],
			buy_sell_flag,SUM(ContractValue),SUM(MarketValue),SUM(Volume),MAX(sbm1),MAX(sbm2),MAX(sbm3),MAX(sbm4),Trader,Currency,
			MAX([term_end]),MAX([price_uom]),MAX([Location])
			,MAX([volume_uom]),MAX(MwhEquivalentVol),MAX(DealPriceCurrency),MAX(ContractName),MAX(pricing) ,MAX(DealStatus),MAX([IndexName]),
			MAX(Leg),MAX(DealTermStart),MAX(DealTermEnd) ,MAX(TemplateName),MAX([Profile]),MAX(Commodity),MAX(BlockDefinition),MAX(Reference),
			MAX(Description1),MAX(Description2),MAX(Description3),MAX(CreatedBy) ,MAX(CreatedDate),MAX(UpdateBy),MAX(UpdateDate),
			MAX([price]),MAX([Parent Counterparty]),MAX(REPLACE([charge_type],' -Released','')),2,[term_start_orig] cashflow_date,[term_start_orig] pnl_date,MAX(category_id),MAX(category),
			MAX(book_deal_type_map_id),MAX(broker_id),MAX(internal_desk_id),MAX(source_deal_type_id),MAX(trader_id),MAX(contract_id),MAX(internal_portfolio_id),
			MAX(template_id),MAX(deal_status),MAX(counterparty_id),	MAX(block_define_id),MAX(curve_id),MAX(pv_party),MAX(location_id),MAX(pnl_currency_id),
			MAX(physical_financial_flag),SUM(mtm),SUM(dis_mtm),SUM(dis_market_value),SUM(dis_contract_value),
			CASE WHEN DATEADD(m,1,[term_start_orig])-1>@as_of_date THEN 'f' ELSE 'a' END forward_actual_flag,MAX(sub_id)
	FROM
			#deal_pnl1
		WHERE
			term_start_orig IS NOT NULL
			--AND pnl_date IS NOT NULL
		GROUP BY 
			[Sub],[Strategy],[Book],[Counterparty],[DealNumber],[DealRefNumber],[DealDate],[PNLDate],buy_sell_flag,
			[Type],[Phy/Fin] ,[term_start_orig],Trader,Currency,[source_deal_header_id],[pnl_as_of_date]			

		UNION 
		
		SELECT 
			[Sub],[Strategy],[Book],REPLACE([Counterparty],'-Released','-Deferred'),[DealNumber],[DealRefNumber],[DealDate],[PNLDate],
			[Type],[Phy/Fin] ,[term_start_orig],SUM([CumulativeFV])*-1,[term_start_orig],[source_deal_header_id],[pnl_as_of_date],
			buy_sell_flag,SUM(ContractValue)*-1,SUM(MarketValue)*-1,SUM(Volume)*-1,MAX(sbm1),MAX(sbm2),MAX(sbm3),MAX(sbm4),Trader,Currency,
			MAX([term_end]),MAX([price_uom]),MAX([Location])
			,MAX([volume_uom]),MAX(MwhEquivalentVol),MAX(DealPriceCurrency),MAX(ContractName),MAX(pricing) ,MAX(DealStatus),MAX([IndexName]),
			MAX(Leg),MAX(DealTermStart),MAX(DealTermEnd) ,MAX(TemplateName),MAX([Profile]),MAX(Commodity),MAX(BlockDefinition),MAX(Reference),
			MAX(Description1),MAX(Description2),MAX(Description3),MAX(CreatedBy) ,MAX(CreatedDate),MAX(UpdateBy),MAX(UpdateDate),
			MAX([price]),MAX([Parent Counterparty]),MAX(REPLACE([charge_type],'-Released','-Deferred')),3,[term_start_orig] cashflow_date,[term_start_orig] pnl_date,MAX(category_id),MAX(category),
			MAX(book_deal_type_map_id),MAX(broker_id),MAX(internal_desk_id),MAX(source_deal_type_id),MAX(trader_id),MAX(contract_id),MAX(internal_portfolio_id),
			MAX(template_id),MAX(deal_status),MAX(counterparty_id),	MAX(block_define_id),MAX(curve_id),MAX(pv_party),MAX(location_id),MAX(pnl_currency_id),
			MAX(physical_financial_flag),SUM(mtm)*-1,SUM(dis_mtm)*-1,SUM(dis_market_value)*-1,SUM(dis_contract_value)*-1,
			CASE WHEN DATEADD(m,1,[term_start_orig])-1>@as_of_date THEN 'f' ELSE 'a' END,MAX(sub_id)
		FROM
			#deal_pnl1
			
		WHERE
			term_start_orig IS NOT NULL
			--AND pnl_date IS NOT NULL
		GROUP BY 
			[Sub],[Strategy],[Book],[Counterparty],[DealNumber],[DealRefNumber],[DealDate],[PNLDate],buy_sell_flag,
			[Type],[Phy/Fin] ,[term_start_orig],Trader,Currency,[source_deal_header_id],[pnl_as_of_date]	
	--END	
	-- save for later use for periodic mtm logic


	SET @save_sql = @Sql
	
	DECLARE @temp_pnl_table VARCHAR(50)

	SET @temp_pnl_table = '#deal_pnl1'

	--now populate prior values if period mtm required
	IF @period_report = 'y' AND @previous_as_of_date IS NOT NULL
	BEGIN

--print @Sql 


	SET @Sql = REPLACE(@Sql, '#deal_pnl1', '#deal_pnl0')
	SET @Sql = REPLACE(@Sql, '#hedge_deferral1', '#hedge_deferral0')
	SET @Sql = REPLACE(@Sql, '''' + @as_of_date + '''', '''' + @previous_as_of_date + '''')

	 
	EXEC (@Sql)
	

END




---##### Insert The Settlement Contract values calculated at charge Type Level	
	IF(@settlement_only = 'y' AND (@detail_option IN('c','s','p') OR @summary_option IN('21')))
	BEGIN
	
		CREATE TABLE #temp_deal_detail
		(
			sub                    VARCHAR(100) ,
			strategy               VARCHAR(100) ,
			book                   VARCHAR(100) ,
			sbm1                   VARCHAR(100) ,
			sbm2                   VARCHAR(100) ,
			sbm3                   VARCHAR(100) ,
			sbm4                   VARCHAR(100) ,
			broker_id              INT,
			internal_desk_id       INT,
			source_deal_type_id    INT,
			trader_id              INT,
			contract_id            INT,
			internal_portfolio_id  INT,
			template_id            INT,
			deal_status            INT,
			counterparty_id        INT,
			source_deal_header_id  INT,
			counterparty           VARCHAR(100) ,
			ContractName           VARCHAR(100) ,
			dealrefnumber          VARCHAR(100) ,
			Trader                 VARCHAR(100) ,
			DealDate               DATETIME,
			TemplateName           VARCHAR(100) ,
			[Profile]              VARCHAR(100) ,
			Reference              VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			Description1           VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			Description2           VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			Description3           VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			CreatedBy              VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			CreatedDate            VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			UpdateBy               VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			UpdateDate             VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			DealStatus             VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			Pricing                VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			[type]                 VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			DealTermStart          DATETIME,
			DealTermEnd            DATETIME,
			block_define_id        INT,
			book_deal_type_map_id  INT,
			product_id             INT,
			sub_id                 INT
		)
				
		INSERT INTO #temp_deal_detail
		SELECT MAX(sub),MAX(strategy),MAX(book),MAX(sbm1),MAX(sbm2),MAX(sbm3),MAX(sbm4),MAX(broker_id),MAX(internal_desk_id),MAX(source_deal_type_id),MAX(trader_id),
			   MAX(contract_id),MAX(internal_portfolio_id),MAX(template_id),MAX(deal_status),MAX(counterparty_id),source_deal_header_id,MAX(counterparty),
			   MAX(ContractName),MAX(dealrefnumber),MAX(Trader),MAX(DealDate),MAX(TemplateName),MAX([Profile]),MAX(Reference),MAX(Description1),MAX(Description2),
			   MAX(Description3),MAX(CreatedBy ),MAX(CreatedDate),MAX(UpdateBy),MAX(UpdateDate),MAX(DealStatus),MAX(Pricing),MAX([type]),MAX(DealTermStart),MAX(DealTermEnd),MAX(block_define_id),MAX(book_deal_type_map_id),MAX(product_id),MAX(sub_id)
		FROM
			#deal_pnl1
		GROUP BY 
			source_deal_header_id

		DECLARE @sql_group VARCHAR(MAX)
		SET @sql='
			INSERT INTO #deal_pnl1(sub,strategy,book,sbm1,sbm2,sbm3,sbm4,term_start,term_end,broker_id,internal_desk_id,source_deal_type_id,trader_id,contract_id,internal_portfolio_id,template_id,deal_status,counterparty_id,
				curve_id,location_id,pnl_currency_id,physical_financial_flag,buy_sell_flag,mtm,dis_mtm,	marketvalue,dis_market_value,contractvalue,dis_contract_value,source_deal_header_id,charge_type,charge_type_id,cashflow_date,
				pnl_date,category_id,volume,counterparty,ContractName,dealrefnumber,CumulativeFV,Price,[IndexName],Location,Trader,DealDate,
				DealPriceCurrency,volume_uom,Currency,location_group,Country,Grid,[type],leg,MwhEquivalentVol,TemplateName,[Profile],Commodity,
				BlockDefinition,Reference,Description1,Description2,Description3,CreatedBy ,CreatedDate,UpdateBy,UpdateDate,DealStatus,Pricing,DealTermStart,DealTermEnd,Expiration,[phy/fin],Category,forward_actual_flag,sub_id,book_deal_type_map_id)	
				SELECT
					ISNULL(sdh.sub,ph.entity_name),sdh.strategy,sdh.book,sdh.sbm1,sdh.sbm2,sdh.sbm3,sdh.sbm4,
					civv1.prod_date,DATEADD(m,1,civv1.prod_date)-1,MAX(sdh.broker_id)broker_id,
					MAX(sdh.internal_desk_id),MAX(ISNULL(sdh.source_deal_type_id,cgd.deal_type)),MAX(sdh.trader_id),cg.contract_id contract_id,MAX(sdh.internal_portfolio_id),
					MAX(sdh.template_id),MAX(sdh.deal_status),civv1.counterparty_id,MAX(ISNULL(sdd.curve_id,sdd1.curve_id)),
					MAX(ISNULL(sdd.location_id,sdd1.location_id)),MAX(COALESCE(sdd.settlement_currency,sdd.fixed_price_currency_id,sdd1.settlement_currency,sdd1.fixed_price_currency_id)),
					''p'',''s'',SUM(cfv.value),SUM(cfv.value),NULL,NULL,SUM(cfv.value),SUM(cfv.value),sdh.source_deal_header_id,sdv.code AS charge_type,sdv.value_id,MAX(CASE WHEN (cg.invoice_due_date IS NOT NULL) THEN cast(ISNULL(civv1.prod_date, cg.invoice_due_date) as datetime) 
						  ELSE civv1.prod_date END) , 
					MAX(CASE WHEN (cg.pnl_date IS NOT NULL) THEN cast(ISNULL(civv1.prod_date, cg.pnl_date) as datetime) 
						  ELSE civv1.prod_date END),
					NULL category,SUM(cfv.volume),ISNULL(sdh.counterparty,sc.counterparty_name),cg.contract_name ContractName,MAX(sdh.dealrefnumber),SUM(cfv.value),SUM(cfv.value)/ISNULL(NULLIF(SUM(cfv.volume),0),1),
					MAX(spcd.curve_name),MAX(sml.location_name),MAX(sdh.Trader),MAX(sdh.DealDate),MAX(cur1.currency_name),	MAX(su.uom_name),MAX(cur.currency_name),
					MAX(smj.location_name),MAX(sdv_c.code)Country,MAX(sdv_g.code)Grid,MAX(ISNULL(sdh.TYPE,sdt.source_deal_type_name)),ISNULL(sdd.leg,sdd1.leg),SUM(cfv.volume*ISNULL(conv.conversion_factor,10)),MAX(sdh.TemplateName),
					MAX(sdh.[Profile])[Profile],MAX(com.commodity_name)Commodity,MAX(sdv3.code)BlockDefinition,MAX(sdh.reference)Reference,MAX(sdh.description1)Description1,MAX(sdh.description2)Description2,MAX(sdh.description3)Description3,
					MAX(sdh.CreatedBy)CreatedBy ,MAX(sdh.CreatedDate)CreatedDate,MAX(sdh.UpdateBy)UpdateBy,MAX(sdh.UpdateDate)UpdateDate,MAX(sdh.DealStatus)DealStatus,MAX(sdh.Pricing)Pricing,max(sdh.DealTermStart) DealTermStart,max(sdh.DealTermEnd) DealTermEnd,DATEADD(m,1,civv1.prod_date)-1,
					MAX(CASE WHEN ISNULL(sdd.physical_financial_flag,sdd1.physical_financial_flag)=''p'' THEN ''Phy'' ELSE ''Fin'' END)
					,MAX(sdv_cat.code)
					,''a''
					,MAX(ISNULL(sdh.sub_id,cg.sub_id)) sub_id
					,MAX(ISNULL(sdh.book_deal_type_map_id,ssbm.book_deal_type_map_id)) book_deal_type_map_id
				FROM
					contract_group cg
					INNER JOIN (SELECT DISTINCT sub_id FROM #books) sub ON sub.sub_id=cg.sub_id
					CROSS APPLY(SELECT MAX(book_deal_type_map_id) book_deal_type_map_id FROM portfolio_hierarchy ph INNER JOIN portfolio_hierarchy ph1 ON ph.entity_id=ph1.parent_entity_id INNER JOIN portfolio_hierarchy ph2 ON ph1.entity_id=ph2.parent_entity_id INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id=ph2.entity_id WHERE ph.entity_id=cg.sub_id) ssbm
					INNER JOIN contract_group_detail cgd ON cg.contract_id=cgd.contract_id
						AND ISNULL(include_charges,''n'')=''y''
					INNER JOIN (SELECT MAX(as_of_date)as_of_date,prod_date,counterparty_id,contract_id FROM calc_invoice_volume_variance GROUP BY prod_date,counterparty_id,contract_id) civv 
						ON civv.contract_id=cg.contract_id
					INNER JOIN calc_invoice_volume_variance civv1 ON civv1.counterparty_id=civv.counterparty_id
						AND civv1.contract_id=civv.contract_id
						AND civv1.as_of_date=civv.as_of_date
						AND civv1.prod_date=civv.prod_date	
						AND convert(varchar(7),civv1.prod_date,120)+   ''-01'' <= convert(varchar(7),'''+@as_of_date+''',120)+   ''-01''					
					INNER JOIN calc_formula_value cfv ON civv1.calc_id=cfv.calc_id
						AND cfv.is_final_result=''y''
						AND cfv.invoice_line_item_id=cgd.invoice_line_item_id
					INNER JOIN static_data_value sdv ON sdv.value_id=cfv.invoice_line_item_id
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id=cfv.deal_id AND cfv.deal_id IS NOT NULL
					INNER JOIN #temp_deal_detail sdh On sdh.source_deal_header_id=ISNULL(cfv.source_deal_header_id,sdd.source_deal_header_id)
					LEFT JOIN source_deal_detail sdd1 ON sdd1.source_deal_header_id=sdh.source_deal_header_id AND cfv.deal_id IS NULL
						AND sdd1.term_start=CONVERT(VARCHAR(8),civv1.prod_date,120)+''01''
						AND sdd1.leg=1					
					LEFT JOIN source_price_curve_def spcd On spcd.source_curve_def_id=ISNULL(sdd.curve_id,sdd1.curve_id)
					LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=ISNULL(sdd.location_id,sdd1.location_id)
					LEFT JOIN source_currency cur On cur.source_currency_id=cg.currency
					LEFT JOIN source_uom su ON su.source_uom_id=civv1.UOM
					LEFT JOIN holiday_group hgc ON hgc.hol_group_value_id = cg.payment_calendar and 
							convert(varchar(7), hgc.hol_date, 120) = convert(varchar(7), civv1.prod_date, 120)
					LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.pnl_calendar and
							convert(varchar(7), hgp.hol_date, 120) = convert(varchar(7), civv1.prod_date, 120)	
					LEFT JOIN source_major_location smj ON smj.source_major_location_ID=sml.source_major_location_ID
					LEFT JOIN static_data_value sdv_c ON sdv_c.value_id=sml.country
					LEFT JOIN static_data_value sdv_g ON sdv_g.value_id=sml.grid_value_id
					LEFT JOIN source_currency cur1 On cur1.source_currency_id=ISNULL(sdd.fixed_price_currency_id,sdd1.fixed_price_currency_id)
					LEFT JOIN rec_volume_unit_conversion conv on conv.from_source_uom_id=civv1.UOM AND conv.to_source_uom_id='+CAST(@convert_uom AS VARCHAR) +'										   
					LEFT JOIN static_data_value sdv3 on sdv3.value_id=coalesce(spcd.block_define_id,sdh.block_define_id)
					LEFT JOIN source_commodity com on com.source_commodity_id=spcd.commodity_id 
					LEFT JOIN static_data_value sdv_cat ON sdv_cat.value_id = sdd.category
					LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = civv.counterparty_id
					LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = cg.sub_id
					LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = cgd.deal_type
			WHERE 1=1 ' +
				CASE WHEN @source_deal_header_list IS NOT NULL  THEN ' AND sdh.source_deal_header_id IN (SELECT deal_id FROM #temp) ' ELSE '' END +
				CASE WHEN (@source_deal_header_list IS NULL AND @deal_id IS NULL) THEN 
					CASE WHEN (@deal_id_from IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR) +' AND ' + CAST(@deal_id_to AS VARCHAR) ELSE '' END +
					CASE WHEN (@deal_id_from IS NOT NULL AND @match_id = 'y') THEN ' AND cast(sdh.source_deal_header_id as varchar) LIKE cast(' + CAST(@deal_id_from AS VARCHAR) + ' as varchar) + ''%''' ELSE '' END +
					CASE WHEN (@deal_id IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.deal_id = ''' + @deal_id + '''' ELSE  '' END +
					CASE WHEN (@deal_id IS NOT NULL AND @match_id = 'y') THEN ' AND sdh.deal_id LIKE ''' + @deal_id + '%''' ELSE  '' END +
					CASE WHEN (@deal_id_from IS NULL AND @deal_id IS NULL) THEN
						CASE WHEN (@trader_id IS NOT NULL) THEN ' AND sdh.trader_id = ' + CAST(@trader_id AS VARCHAR) ELSE  '' END +
						CASE WHEN (@deal_type_id IS NOT NULL) THEN ' AND sdh.source_deal_type_id = ' + CAST(@deal_type_id AS VARCHAR) ELSE  '' END +
						--CASE WHEN (@deal_sub_type_id IS NOT NULL) THEN ' AND sdh.deal_sub_type_type_id = ' + CAST(@deal_sub_type_id AS VARCHAR) ELSE  '' END +
						CASE WHEN (@counterparty_id IS NOT NULL) THEN ' AND (civv.counterparty_id IN (' + @counterparty_id + ')) ' ELSE  '' END +
						CASE WHEN (@deal_date_from IS NOT NULL) THEN ' AND sdh.DealDate  BETWEEN ''' + @deal_date_from + ''' AND ''' +  @deal_date_to + ''' ' ELSE  '' END +
						CASE WHEN (@term_start IS NOT NULL) THEN ' AND cfv.prod_date BETWEEN ''' + @term_start + ''' AND ''' +  @term_end + ''' ' ELSE  '' END +
						CASE WHEN (@phy_fin<>'b') THEN ' AND sdd.physical_financial_flag = ''' + @phy_fin + ''' ' ELSE  '' END +
						CASE WHEN (@commodity_id IS NOT NULL) THEN ' AND sdh.commodity_id = ' + CAST(@commodity_id AS VARCHAR) ELSE  '' END  +
						CASE WHEN @deal_status IS NOT NULL THEN ' AND sdh.deal_status IN('+@deal_status+')' ELSE '' END+
						CASE WHEN (@counterparty<>'a') THEN ' AND sc.int_ext_flag = ''' + @counterparty + '''' ELSE  '' END 
					ELSE '' END
				ELSE '' END					
		SET @sql_group = ' GROUP BY	ISNULL(sdh.sub,ph.entity_name),sdh.strategy,sdh.book,sdh.sbm1,sdh.sbm2,sdh.sbm3,sdh.sbm4,civv1.prod_date,cg.contract_id,civv1.counterparty_id,
							sdh.source_deal_header_id,ISNULL(sdd.leg,sdd1.leg),sdv.code,sdv.value_id,ISNULL(sdh.counterparty,sc.counterparty_name),cg.contract_name '
		--PRINT(@sql + @sql_group)
		EXEC(@sql + @sql_group)
		
		--### Insert Fees in the table
		--IF @summary_option IN('21')
			BEGIN
			SET @sql='
				INSERT INTO #deal_pnl1(
						sub,strategy,book,sbm1,sbm2,sbm3,sbm4,term_start,term_end,
						book_deal_type_map_id,broker_id,internal_desk_id,source_deal_type_id,trader_id,contract_id,internal_portfolio_id,template_id,deal_status,counterparty_id,
						block_define_id,curve_id,pv_party,location_id,pnl_currency_id,physical_financial_flag,buy_sell_flag,mtm,dis_mtm,
						marketvalue,dis_market_value,contractvalue,dis_contract_value,source_deal_header_id,charge_type,charge_type_id,cashflow_date,
						pnl_date,category_id,counterparty,ContractName,dealrefnumber,[IndexName],Location,Trader,DealDate,Currency,location_group,Country,Grid,
						TemplateName,[Profile],Commodity,BlockDefinition,Reference,Description1,Description2,Description3,CreatedBy ,
						CreatedDate,UpdateBy,UpdateDate,DealStatus,Pricing,DealTermStart,DealTermEnd,CumulativeFV,
						forward_actual_flag,sub_id)	 
					SELECT
						sdh.sub,sdh.strategy,sdh.book,sdh.sbm1,sdh.sbm2,sdh.sbm3,sdh.sbm4,
						sdp.term_start,sdp.term_end,
						sdh.book_deal_type_map_id book_deal_type_map_id,
						sdh.broker_id broker_id,
						sdh.internal_desk_id internal_desk_id,
						sdh.source_deal_type_id source_deal_type_id,
						sdh.trader_id trader_id,
						sdh.contract_id contract_id,
						sdh.internal_portfolio_id internal_portfolio_id,
						sdh.template_id template_id,
						sdh.deal_status deal_status,
						sdh.counterparty_id counterparty_id,
						ISNULL(spcd.block_define_id,sdh.block_define_id) block_define_id,
						sdd.curve_id curve_id,
						sdd.pv_party pv_party,
						NULLIF(sdd.location_id,-1) location_id,
						sdp.fee_currency_id pnl_currency_id,
						sdd.physical_financial_flag,
						sdd.buy_sell_flag,
						sdp.value,
						sdp.value,
						CASE WHEN ISNULL(sdh.product_id,4101)=4100 THEN sdp.value ELSE NULL END,
						CASE WHEN ISNULL(sdh.product_id,4101)=4100 THEN sdp.value ELSE NULL END,
						CASE WHEN ISNULL(sdh.product_id,4101)=4101 THEN sdp.value ELSE NULL END,
						CASE WHEN ISNULL(sdh.product_id,4101)=4101 THEN sdp.value ELSE NULL END,
						sdh.source_deal_header_id,
						sdp.field_name AS charge_type,
						sdp.field_id,
						CASE WHEN (cg.invoice_due_date IS NOT NULL) THEN cast(ISNULL(sdp.term_start, cg.invoice_due_date) as datetime) 
							 WHEN (hgc.exp_date IS NOT NULL) THEN hgc.exp_date
							 ELSE sdp.term_start END , 
						CASE WHEN (cg.pnl_date IS NOT NULL) THEN cast(ISNULL(sdp.term_start, cg.pnl_date) as datetime) 
							 WHEN (hgp.exp_date IS NOT NULL) THEN hgp.exp_date
							 ELSE sdp.term_start END,
						sdd.category,
						sdh.counterparty,sdh.ContractName,sdh.dealrefnumber,
						spcd.curve_name[IndexName],sml.location_name,sdh.Trader,sdh.DealDate,
						cur.currency_name Currency,smj.location_name location_group,sdv_c.code Country,sdv_g.code Grid,
						sdh.TemplateName,sdh.[Profile],com.commodity_name Commodity,sdv3.code,sdh.Reference,sdh.Description1,sdh.Description2,sdh.Description3,sdh.CreatedBy ,
						sdh.CreatedDate,sdh.UpdateBy,sdh.UpdateDate,sdh.DealStatus,sdh.Pricing,sdh.DealTermStart,sdh.DealTermEnd,sdp.value,					
						''a'' forward_actual_flag,
						sdh.sub_id
					FROM
						#temp_deal_detail sdh 
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=sdh.source_deal_header_id
						INNER JOIN index_fees_breakdown_settlement
								sdp on sdh.source_deal_header_id=sdp.source_deal_header_id 
								AND sdp.term_start=sdd.term_start
								AND sdp.leg=sdd.Leg
								AND ((sdp.set_type = ''f'' AND sdp.as_of_date = '''+@as_of_date+''') OR (sdp.set_type = ''s''  AND '''+@as_of_date+'''>=sdp.term_end))
						'+CASE WHEN @summary_option <>'21' THEN	' INNER JOIN static_data_value s ON s.value_id = sdp.field_id AND ISNULL(s.category_id,-1) <> '+CAST(@premium_id AS VARCHAR) ELSE '' END+'										
						LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id	
						LEFT JOIN contract_group cg on cg.contract_id = sdh.contract_id   
						LEFT JOIN holiday_group hgc ON hgc.hol_group_value_id = cg.payment_calendar and 
								convert(varchar(7), hgc.hol_date, 120) = convert(varchar(7), sdd.term_start, 120)
						LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.pnl_calendar and
								convert(varchar(7), hgp.hol_date, 120) = convert(varchar(7), sdd.term_start, 120)		
						LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id
						LEFT JOIN source_currency cur On cur.source_currency_id=sdp.currency_id													   
						LEFT JOIN source_major_location smj ON smj.source_major_location_ID=sml.source_major_location_ID
						LEFT JOIN static_data_value sdv_c ON sdv_c.value_id=sml.country
						LEFT JOIN static_data_value sdv_g ON sdv_g.value_id=sml.grid_value_id	
						LEFT JOIN source_commodity com on com.source_commodity_id=spcd.commodity_id 
						LEFT JOIN static_data_value sdv3 on sdv3.value_id=coalesce(spcd.block_define_id,sdh.block_define_id)						
					
				WHERE 1=1
					 AND sdp.internal_type <> -1 	
					 AND sdp.term_start <= '''+@as_of_date+''''
					
			EXEC(@sql)	
	
			END



		IF @detail_option IN('c','p') OR @summary_option IN('21')
			BEGIN

			SELECT ifb.* INTO #index_fees_breakdown FROM index_fees_breakdown ifb INNER JOIN #temp_deal_detail tdd ON tdd.source_deal_header_id = ifb.source_deal_header_id  WHERE ifb.as_of_date=@as_of_date
			CREATE INDEX temp_IDX_1 ON #index_fees_breakdown(as_of_date, source_deal_header_id, term_start, field_id, leg)


			SET @sql='
				INSERT INTO #deal_pnl1(
						sub,strategy,book,sbm1,sbm2,sbm3,sbm4,term_start,term_end,
						book_deal_type_map_id,broker_id,internal_desk_id,source_deal_type_id,trader_id,contract_id,internal_portfolio_id,template_id,deal_status,counterparty_id,
						block_define_id,curve_id,pv_party,location_id,pnl_currency_id,physical_financial_flag,buy_sell_flag,mtm,dis_mtm,
						marketvalue,dis_market_value,contractvalue,dis_contract_value,source_deal_header_id,charge_type,charge_type_id,cashflow_date,
						pnl_date,category_id,counterparty,ContractName,dealrefnumber,[IndexName],Location,Trader,DealDate,Currency,location_group,Country,Grid,
						TemplateName,[Profile],Commodity,BlockDefinition,Reference,Description1,Description2,Description3,CreatedBy ,
						CreatedDate,UpdateBy,UpdateDate,DealStatus,Pricing,DealTermStart,DealTermEnd,CumulativeFV,
						forward_actual_flag,sub_id)	 
					SELECT
						sdh.sub,sdh.strategy,sdh.book,sdh.sbm1,sdh.sbm2,sdh.sbm3,sdh.sbm4,
						sdp.term_start,sdp.term_end,
						sdh.book_deal_type_map_id book_deal_type_map_id,
						sdh.broker_id broker_id,
						sdh.internal_desk_id internal_desk_id,
						sdh.source_deal_type_id source_deal_type_id,
						sdh.trader_id trader_id,
						sdh.contract_id contract_id,
						sdh.internal_portfolio_id internal_portfolio_id,
						sdh.template_id template_id,
						sdh.deal_status deal_status,
						sdh.counterparty_id counterparty_id,
						ISNULL(spcd.block_define_id,sdh.block_define_id) block_define_id,
						sdd.curve_id curve_id,
						sdd.pv_party pv_party,
						NULLIF(sdd.location_id,-1) location_id,
						sdp.fee_currency_id pnl_currency_id,
						sdd.physical_financial_flag,
						sdd.buy_sell_flag,
						sdp.value,
						sdp.value,
						CASE WHEN ISNULL(sdh.product_id,4101)=4100 THEN sdp.value ELSE NULL END,
						CASE WHEN ISNULL(sdh.product_id,4101)=4100 THEN sdp.value ELSE NULL END,
						CASE WHEN ISNULL(sdh.product_id,4101)=4101 THEN sdp.value ELSE NULL END,
						CASE WHEN ISNULL(sdh.product_id,4101)=4101 THEN sdp.value ELSE NULL END,
						sdh.source_deal_header_id,
						sdp.field_name AS charge_type,
						sdp.field_id,
						CASE WHEN (cg.invoice_due_date IS NOT NULL) THEN cast(ISNULL(sdp.term_start, cg.invoice_due_date) as datetime) 
							 WHEN (hgc.exp_date IS NOT NULL) THEN hgc.exp_date
							 ELSE sdp.term_start END , 
						CASE WHEN (cg.pnl_date IS NOT NULL) THEN cast(ISNULL(sdp.term_start, cg.pnl_date) as datetime) 
							 WHEN (hgp.exp_date IS NOT NULL) THEN hgp.exp_date
							 ELSE sdp.term_start END,
						sdd.category,
						sdh.counterparty,sdh.ContractName,sdh.dealrefnumber,
						spcd.curve_name[IndexName],sml.location_name,sdh.Trader,sdh.DealDate,
						cur.currency_name Currency,smj.location_name location_group,sdv_c.code Country,sdv_g.code Grid,
						sdh.TemplateName,sdh.[Profile],com.commodity_name Commodity,sdv3.code,sdh.Reference,sdh.Description1,sdh.Description2,sdh.Description3,sdh.CreatedBy ,
						sdh.CreatedDate,sdh.UpdateBy,sdh.UpdateDate,sdh.DealStatus,sdh.Pricing,sdh.DealTermStart,sdh.DealTermEnd,sdp.value,					
						''f'' forward_actual_flag,
						sdh.sub_id
					FROM
						#temp_deal_detail sdh 
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=sdh.source_deal_header_id
						INNER JOIN #index_fees_breakdown
								sdp on sdh.source_deal_header_id=sdp.source_deal_header_id 
								AND sdp.term_start=sdd.term_start
								AND sdp.as_of_date= '''+@as_of_date+'''
								AND sdp.leg=sdd.Leg
						'+CASE WHEN @summary_option <>'21' THEN	' INNER JOIN static_data_value s ON s.value_id = sdp.field_id AND ISNULL(s.category_id,-1) <> '+CAST(@premium_id AS VARCHAR) ELSE '' END+'		
						LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id	
						LEFT JOIN contract_group cg on cg.contract_id = sdh.contract_id   
						LEFT JOIN holiday_group hgc ON hgc.hol_group_value_id = cg.payment_calendar and 
								convert(varchar(7), hgc.hol_date, 120) = convert(varchar(7), sdd.term_start, 120)
						LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.pnl_calendar and
								convert(varchar(7), hgp.hol_date, 120) = convert(varchar(7), sdd.term_start, 120)		
						LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id
						LEFT JOIN source_currency cur On cur.source_currency_id=sdp.currency_id													   
						LEFT JOIN source_major_location smj ON smj.source_major_location_ID=sml.source_major_location_ID
						LEFT JOIN static_data_value sdv_c ON sdv_c.value_id=sml.country
						LEFT JOIN static_data_value sdv_g ON sdv_g.value_id=sml.grid_value_id	
						LEFT JOIN source_commodity com on com.source_commodity_id=spcd.commodity_id 
						LEFT JOIN static_data_value sdv3 on sdv3.value_id=coalesce(spcd.block_define_id,sdh.block_define_id)						
					
				WHERE 1=1
					 AND sdp.internal_type <> -1 	
					 AND sdp.as_of_date = '''+@as_of_date+''''  
					
				EXEC(@sql)				
			END
	
	END


	IF(@settlement_only = 'y' AND (@detail_option IN('c','s','p') OR @summary_option IN('21')))
	BEGIN
	SET @Sql='
			INSERT INTO #payment_calendar
			SELECT DISTINCT
				a.contract_id,
				a.term_start,
				MAX(ISNULL(cast(dbo.FNAInvoiceDueDate(a.term_start, cg.invoice_due_date, NULL,cg.payment_days) as datetime),hgc.exp_date)) payment_calendar,
				MAX(ISNULL(cast(dbo.FNAInvoiceDueDate(a.term_start, cg.pnl_date, NULL,cg.payment_days) as datetime),hgp.exp_date)) pnl_calendar
			FROM		
				(SELECT contract_id,term_start FROM '+ @temp_pnl_table+' GROUP BY contract_id,term_start) a
				LEFT JOIN contract_group cg ON cg.contract_id = a.contract_id 
				LEFT JOIN holiday_group hgc ON hgc.hol_group_value_id = cg.payment_calendar and 
						 convert(varchar(7), hgc.hol_date, 120) = convert(varchar(7), a.term_start, 120) 
				LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.pnl_calendar and
						 convert(varchar(7), hgp.hol_date, 120) = convert(varchar(7), a.term_start, 120)
			GROUP BY a.contract_id,	a.term_start '
				
		EXEC(@sql)	
	END	
 

	SET @Sql='
		SELECT 
			max(p.sub) [Subsidiary],
			max(p.strategy) [Strategy],
			max(p.book) [Book],
			max(p.sbm1) [Source Book ID 1],
			p.source_deal_header_id  [Deal ID],
			max(p.dealrefnumber) [Reference ID], 
			max(p.Counterparty) Counterparty,
			max(p.[Parent Counterparty]) [Parent Counterparty],
			ISNULL(p.[Type]+'' - '','''')+p.charge_type [PNL Type],
			max(p.Leg) Leg,
			max(p.Location_group) [Location Group],
			MAX(p.category) [Category],
			(p.[IndexName]) [Index],
			max(p.trader) Trader,
			dbo.FNADateFormat(max(p.dealdate)) [Deal Date],
			CASE max(p.buy_sell_flag) WHEN ''b'' THEN ''Buy'' ELSE ''Sell'' END [Buy Sell],
			dbo.FNADateFormat(max(p.term_start)) [Term Start],
			dbo.FNADateFormat(max(ISNULL(p.term_end,DATEADD(m,1,p.term_start)-1))) [Term End],
			dbo.FNADateFormat(max(p.DealTermStart)) [Deal Term Start],
			dbo.FNADateFormat(max(p.DealTermEnd)) [Deal Term End],
			dbo.FNADateFormat(max(NULLIF(ISNULL(CASE WHEN p.charge_type LIKE ''%-Released%'' THEN ''1900-01-01'' WHEN p.charge_type LIKE ''%-Deferred%'' THEN ''1900-01-01'' ELSE pc.payment_calendar END,p.term_start),''1900-01-01''))) [Expiration Date],
			ROUND(max(ABS(p.price)),'+@round_value+') Price,
			max(p.DealPriceCurrency) Currency,
			ROUND(sum(p.volume),'+@round_value+') Volume,
			max(p.[volume_uom]) [Volume UOM],
			max(p.DealStatus) [Deal Status],
			ROUND(sum(p.CumulativeFV),'+@round_value+') [Settlement],
			max(p.currency) [Settlement Currency],
			max(p.[Type]) [Type],
			max(p.TemplateName) [Template Name],
			max(p.[Phy/Fin]) [Physical/Financial],
			p.ContractName [Contract Name],
			max(p.[Profile]) [Profile],
			max(p.Commodity) Commodity,
			max(p.BlockDefinition) [Block Definition],
			max(p.Reference) Reference,
			max(p.Pricing) Pricing,
			max(p.Description1) [Description 1],
			max(p.Description2) [Description 2],
			max(p.Description3) [Description 3],
			max(p.CreatedBy) [Created By],
			[dbo].[FNADateTimeFormat](max(p.CreatedDate),2) [Created Date],
			max(p.UpdateBy) [Update By],
			[dbo].[FNADateTimeFormat](max(p.UpdateDate),2) [Update Date],		 	
			ROUND(sum(CASE WHEN p.[Type]+'' - ''+p.charge_type=''Physical - Commodity'' OR (sdt.deal_type_id = ''Virtual Storage'') THEN p.MwhEquivalentVol ELSE NULL END),'+@round_value+')  [PNL Volume],
			ROUND(sum(p.CumulativeFV),'+@round_value+')  [PNL Value],
			ROUND(sum(p.CumulativeFV)/ISNULL(NULLIF(sum(p.MwhEquivalentVol),0),1),'+@round_value+') [PNL Price],
			MAX(gl_code) AS [SAPGL]	,
			MAX(cat1) AS [CAT1],
			MAX(cat2) AS [CAT2],
			MAX(cat3) AS [CAT3],
			MAX(YEAR([pnl_date])) AS [PNL Year],
			''Q-''+MAX(DATENAME(q,pnl_date)) AS [PNL Quarter],
			MAX(LEFT(DATENAME(m,pnl_date),3)) AS [PNL Month],
			MAX(LEFT(DATENAME(m,NULLIF(ISNULL(CASE WHEN p.charge_type LIKE ''%-Released%'' THEN ''1900-01-01'' WHEN p.charge_type LIKE ''%-Deferred%'' THEN ''1900-01-01'' ELSE pc.payment_calendar END,p.term_start),''1900-01-01'')),3)) AS [Expiration Month],
			MAX(YEAR(NULLIF(ISNULL(CASE WHEN p.charge_type LIKE ''%-Released%'' THEN ''1900-01-01'' WHEN p.charge_type LIKE ''%-Deferred%'' THEN ''1900-01-01'' ELSE pc.payment_calendar END,p.term_start),''1900-01-01''))) AS [Expiration Year],
			MAX(p.Country) Country,
			MAX(Grid) Grid
		FROM '+ @temp_pnl_table+' p 
		LEFT JOIN source_deal_type sdt ON p.source_deal_type_id = sdt.source_deal_type_id
		LEFT JOIN #payment_calendar pc ON  pc.contract_id = p.contract_id
			AND pc.term_start = p.term_start
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = p.counterparty_id	
		LEFT JOIN pnl_categories_mapping pcm ON pcm.counterparty_id = p.counterparty_id
			AND pcm.contract_id = p.contract_id
			AND pcm.buy_sell_flag = p.buy_sell_flag
			AND ISNULL(pcm.source_deal_type_id,'''') = ISNULL(p.source_deal_type_id,'''')
			AND pcm.charge_type_id = p.charge_type_id	
			AND pcm.sub_id = p.sub_id	
			AND sc.counterparty_name+ISNULL('' -''+pcm.deferral,'''') = p.Counterparty
		WHERE 1=1 '+
		CASE WHEN (@deal_id_from IS NULL AND @deal_id IS NULL) AND (@term_start IS NOT NULL) THEN ' AND p.term_start BETWEEN ''' + @term_start + ''' AND ''' +  @term_end + ''' ' ELSE  '' END +
		+' GROUP BY  
			p.Counterparty,
			p.source_deal_header_id,
			p.[IndexName],
			ISNULL(p.[Type]+'' - '','''')+p.charge_type,
			p.Leg,'+
			CASE WHEN ISNULL(@show_by,'t')='m' THEN 'convert(varchar(7),p.term_start,120)' ELSE 'p.term_start' END+',
			p.ContractName
		ORDER BY [Deal ID],p.[IndexName],p.Counterparty,ISNULL(p.[Type]+'' - '','''')+p.charge_type,p.leg,'+CASE WHEN ISNULL(@show_by,'t')='m' THEN 'convert(varchar(7),p.term_start,120)' ELSE 'p.term_start' END

EXEC(@Sql)
