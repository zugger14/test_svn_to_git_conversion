
/****** Object:  StoredProcedure [dbo].[spa_Create_MTM_Period_Report_TRM_wrapper]******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_Create_MTM_Period_Report_TRM_wrapper]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_MTM_Period_Report_TRM_wrapper]
GO
/****** Object:  StoredProcedure [dbo].[spa_Create_MTM_Period_Report_TRM_wrapper]
--========================--
--Created by: Shushil Bohara
--Created dt: 3-Feb-2013
--========================-- 
*  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_Create_MTM_Period_Report_TRM_wrapper] 
	@as_of_date DATETIME,
	@sub_entity_id VARCHAR(500), 
	@strategy_entity_id VARCHAR(100) = NULL, 
	@book_entity_id VARCHAR(100) = NULL, 
	@discount_option CHAR(1), 
	@settlement_option CHAR(1), 
	@report_type CHAR(1), 
	@summary_option CHAR(2),
	@counterparty_id NVARCHAR(1000)= NULL, 
	@tenor_from VARCHAR(50)= NULL,
	@tenor_to VARCHAR(50) = NULL,
	@previous_as_of_date VARCHAR(50) = NULL,
	@trader_id INT = NULL,
	@include_item CHAR(1)='n', -- to include item in cash flow hedge
	@source_system_book_id1 INT = NULL, 
	@source_system_book_id2 INT = NULL, 
	@source_system_book_id3 INT = NULL, 
	@source_system_book_id4 INT = NULL, 
	@show_firstday_gain_loss CHAR(1)='n', -- To Show First Day Gain/Loss
	@transaction_type VARCHAR(500) = NULL,
	@deal_id_from INT = NULL,
	@deal_id_to INT = NULL,
	@deal_id VARCHAR(100) = NULL,
	@threshold_values FLOAT = NULL,
	@show_prior_processed_values CHAR(1) = 'n',
	@exceed_threshold_value CHAR(1) = 'n',   -- For First Day gain Loss Treatment selection
	@show_only_for_deal_date CHAR(1) = 'y',
	@use_create_date CHAR(1) = 'n',
	@round_value CHAR(1) = '0',
	@counterparty CHAR(1) = 'a', --i means only internal AND e means only external, a means all
	@mapped CHAR(1) = 'm', --m means mapped only, n means non-mapped only,
	@match_id CHAR(1) = 'n', --'y' means use like for deal ids AND 'n' means use 
	@cpty_type_id INT = NULL,  
	@curve_source_id INT=4500,
	@deal_sub_type CHAR(4)='t',
	@deal_date_from VARCHAR(20) = NULL,
	@deal_date_to VARCHAR(20) = NULL,
	@phy_fin VARCHAR(1) = 'b',
	@deal_type_id INT = NULL,
	@period_report VARCHAR(1) = 'n',
	@term_start VARCHAR(20) = NULL,
	@term_end VARCHAR(20) = NULL,
	@settlement_date_from VARCHAR(20) = NULL,
	@settlement_date_to VARCHAR(20) = NULL,
	@settlement_only CHAR(1)='n',
	@drill1 VARCHAR(100) = NULL,
	@drill2 VARCHAR(100) = NULL,
	@drill3 VARCHAR(100) = NULL,
	@drill4 VARCHAR(100) = NULL,
	@drill5 VARCHAR(100) = NULL,
	@drill6 VARCHAR(100) = NULL,
	--Add Parameters Here
	@risk_bucket_header_id INT = NULL,
	@risk_bucket_detail_id INT = NULL,
	@commodity_id INT = NULL, 
	@deal_status VARCHAR(500) = NULL,
	@convert_uom INT = NULL,	
	@show_by VARCHAR(1) = 't',
	@parent_counterparty INT = NULL,
	@graph CHAR(1) = NULL,
	@source_deal_header_list VARCHAR(500) = NULL,
	@run_date DATETIME,	
	@process_table VARCHAR(200),
	@detail_option CHAR(1) = NULL,
	@calc_type CHAR(1) = 'r',
	@call_to CHAR(1) = 'o',
	@criteria_id INT = NULL, --it comes from whatif only
	--END
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(1000) = NULL,
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
	
AS
DECLARE @user_name VARCHAR(50)
	SET @user_name = dbo.fnadbuser()

IF @batch_process_id IS NULL
	SET @batch_process_id = REPLACE(NEWID(), '-', '_')

DECLARE @as_of_date_point_process_table VARCHAR(200), @hypo_deal_detail VARCHAR(250), @hypo_deal_header VARCHAR(250)
	SET @as_of_date_point_process_table = dbo.FNAProcessTableName('as_of_date_point', @user_name, @batch_process_id)
	SET @hypo_deal_detail = dbo.FNAProcessTableName('hypo_deal_detail', @user_name, @batch_process_id)
	SET @hypo_deal_header = dbo.FNAProcessTableName('hypo_deal_header', @user_name, @batch_process_id)	
--Declaration and Initialization of variables
DECLARE @sql VARCHAR(MAX), @sql_second VARCHAR(MAX), @sql_and VARCHAR(500)
--DROP TABLE #books
--DROP TABLE #hedge_deferral1
--DROP TABLE #deal_pnl1
--DROP TABLE #deal_pnl_detail
DECLARE @revaluation CHAR(1)
SELECT @revaluation = ISNULL(revaluation, 'n') FROM maintain_whatif_criteria WHERE criteria_id = @criteria_id

SET @sql_and = ''
IF @tenor_from IS NOT NULL 
	SET @sql_and = @sql_and + ' AND sdd.term_start >= '''	+ @tenor_from + ''''
IF @tenor_to IS NOT NULL 
	SET @sql_and = @sql_and + ' AND sdd.term_end <= ''' + @tenor_to + ''''

CREATE TABLE #books(fas_book_id INT,source_system_book_id1 INT, source_system_book_id2 INT, source_system_book_id3 INT, source_system_book_id4 INT,	fas_deal_type_value_id INT, book_deal_type_map_id INT, sub_id INT) 
CREATE TABLE #hedge_deferral1(as_of_date DATETIME,source_deal_header_id INT, cash_flow_term DATETIME, pnl_term DATETIME, a_und_pnl FLOAT, a_dis_pnl FLOAT, per_alloc FLOAT,deal_volume FLOAT,pnl_currency_id INT,market_value FLOAT,contract_value FLOAT,dis_market_value FLOAT,dis_contract_value FLOAT,market_value_pnl FLOAT,contract_value_pnl FLOAT,dis_market_value_pnl FLOAT,dis_contract_value_pnl FLOAT)

	SET @sql=        
	'INSERT INTO #books(
		fas_book_id, 
		source_system_book_id1, 
		source_system_book_id2, 
		source_system_book_id3, 
		source_system_book_id4, 
		fas_deal_type_value_id, 
		book_deal_type_map_id, 
		sub_id) 
	 SELECT DISTINCT 
		book.entity_id fas_book_id,
		source_system_book_id1,
		source_system_book_id2,
		source_system_book_id3,
		source_system_book_id4,	
		fas_deal_type_value_id,
		ssbm.book_deal_type_map_id,
		stra.parent_entity_id
	 FROM portfolio_hierarchy book (NOLOCK) 
		 INNER JOIN Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
		 INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id'   
	       
	IF @sub_entity_id IS NOT NULL        
		SET @sql = @sql + ' AND stra.parent_entity_id IN(' + @sub_entity_id + ') '         
	IF @strategy_entity_id IS NOT NULL        
		SET @sql = @sql + ' AND stra.entity_id IN(' + @strategy_entity_id + ' )'        
	IF @book_entity_id IS NOT NULL        
		SET @sql = @sql + ' AND book.entity_id IN(' + @book_entity_id + ') '        
	      
	exec spa_print @sql         
	EXEC (@sql)


	SET @sql= '
	INSERT INTO #hedge_deferral1
	SELECT h.as_of_date,
		h.source_deal_header_id, 
		cash_flow_term, 
		pnl_term, 
		SUM(und_pnl) a_und_pnl, 
		SUM(dis_pnl) a_dis_pnl, 
		MAX(per_alloc) per_alloc,
		SUM(deal_volume) deal_volume,
		MAX(pnl_currency_id) pnl_currency_id,
		SUM(market_value),
		SUM(contract_value),
		SUM(dis_market_value),
		SUM(dis_contract_value),
		SUM(market_value_pnl),
		SUM(contract_value_pnl),
		SUM(dis_market_value_pnl),
		SUM(dis_contract_value_pnl)
	FROM hedge_deferral_values h
		INNER JOIN source_deal_header sdh ON h.source_deal_header_id=sdh.source_deal_header_id
		INNER JOIN ' + @source_deal_header_list + ' tt ON sdh.source_deal_header_id = tt.source_deal_header_id
		INNER JOIN #books bk ON bk.source_system_book_id1 = sdh.source_system_book_id1 
			AND bk.source_system_book_id2 = sdh.source_system_book_id2 
			AND bk.source_system_book_id3 = sdh.source_system_book_id3 
			AND bk.source_system_book_id4 = sdh.source_system_book_id4
	WHERE h.set_type = h.set_type
		AND h.as_of_date = CASE WHEN (h.set_type = ''f'') THEN ''' + CAST(@as_of_date AS VARCHAR) + ''' ELSE h.as_of_date END			   
		AND ((''' + @settlement_only + ''' <> ''y'' 
		AND pnl_term >= ''' + CAST(@as_of_date AS VARCHAR) + ''') OR (''' + @settlement_only + ''' = ''y''))
	GROUP BY h.source_deal_header_id, cash_flow_term, pnl_term, h.as_of_date'
	
	exec spa_print @sql
	EXEC(@sql)
	
	CREATE INDEX [IDX_hd2] ON #hedge_deferral1(source_deal_header_id, cash_flow_term, pnl_term)
	
	-- For the Deal sub type filter
	CREATE TABLE [#deal_pnl1](
	[Sub] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
	[Strategy] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
	[Book] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
	[Counterparty] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
	[Parent Counterparty] VARCHAR (100) COLLATE DATABASE_DEFAULT  NULL,
	[DealNumber] VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
	[DealRefNumber] VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
	[DealDate] DATETIME NULL,
	[PNLDate] DATETIME NULL,
	[TYPE] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
	[Phy/Fin] VARCHAR(3) COLLATE DATABASE_DEFAULT  NULL,
	[Expiration] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL,
	[CumulativeFV] FLOAT NULL,
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
	DealTermEND DATETIME,
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
	[dis_contract_value] FLOAT, 
	[dis_market_value] FLOAT,
	[book_deal_type_map_id] INT ,
	[broker_id] INT ,
	[internal_desk_id] INT ,
	[source_deal_type_id] INT ,
	[trader_id] INT ,
	[contract_id] INT ,
	[internal_portfolio_id] INT ,
	[template_id] INT ,
	[deal_status] INT ,
	[counterparty_id] INT ,
	[block_define_id] INT ,
	[curve_id] INT ,
	[pv_party] INT ,
	[location_id] INT ,
	[pnl_currency_id] INT ,
	physical_financial_flag CHAR(10) COLLATE DATABASE_DEFAULT ,
	[und_pnl] FLOAT ,
	[dis_pnl] FLOAT ,
	[market_value] FLOAT ,
	[charge_type] VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
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
	forward_actual_flag CHAR(1) COLLATE DATABASE_DEFAULT 	,
	product_id INT,
	sub_id INT				
	)
	
	SET @sql ='
	INSERT INTO #deal_pnl1([Sub],[Strategy],[Book],[Counterparty],[DealNumber],[DealRefNumber],[DealDate],[PNLDate],[Type],[Phy/Fin],[Expiration],
		[CumulativeFV],[term_start],[source_deal_header_id],[pnl_as_of_date], buy_sell_flag, ContractValue, MarketValue, Volume, sbm1, sbm2, 
		sbm3, sbm4, Trader, Currency,[term_start_orig],[mtm],[dis_mtm],[dis_market_value],[dis_contract_value],category,product_id, sub_id) 
	SELECT 
		MAX(sub.entity_name) Sub, 
		MAX(stra.entity_name) Strategy, 
		MAX(book.entity_name) Book,
		MAX(sc.counterparty_name + CASE WHEN hd.pnl_term IS NOT NULL THEN '' -Released'' ELSE '''' END) Counterparty,
		''<span style=cursor:hand onClick=openHyperLink(10131024,'' + CAST(sdh.source_deal_header_id AS VARCHAR) + '')><font color=#0000ff><u>'' + CAST(sdh.source_deal_header_id AS VARCHAR) + ''</u></font></span>'',
		sdh.deal_id DealRefNumber, 
		sdh.deal_date [DealDate],
		vsd.' + CASE WHEN @call_to = 'n' THEN 'as_of_date' ELSE 'pnl_as_of_date' END + ' [PNLDate],
		MAX(CASE WHEN (ssbm.fas_deal_type_value_id IS NULL) THEN ''Unmapped'' WHEN (ssbm.fas_deal_type_value_id = 400) THEN ''Der'' ELSE '' Item'' END) [Type], 
		MAX(CASE WHEN (sdh.physical_financial_flag = ''p'') THEN ''Phy'' ELSE ''Fin'' END) [Phy/Fin], 
		vsd.term_start Expiration, ' +		
		CASE WHEN @report_type = 'c' THEN --CASH FLOW
			CASE WHEN @discount_option = 'u' THEN  ' SUM(ISNULL(' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ', 0)) ' ELSE ' SUM(ISNULL(' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ', 0)) ' END + ' CumulativeFV, ' 
		ELSE	
			CASE WHEN @discount_option = 'u' THEN  ' SUM(COALESCE(hd.a_und_pnl, ' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ', 0)) ' ELSE ' SUM(COALESCE(hd.a_dis_pnl, ' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ', 0)) ' END + ' CumulativeFV, ' 
		END + '						
		vsd.term_start term_start, 					
		sdh.source_deal_header_id, 
		MAX(vsd.' + CASE WHEN @call_to = 'n' THEN 'as_of_date' ELSE 'pnl_as_of_date' END + ') pnl_as_of_date,
		MAX(sdh.header_buy_sell_flag) header_buy_sell_flag, ' + ' 
		CASE WHEN (''' + ISNULL(@report_type, 'm') + ''' = ''p'') THEN 0 ELSE ' + 
		CASE WHEN @discount_option = 'u' THEN  ' SUM(COALESCE(hd.contract_value, vsd.' + CASE WHEN @call_to = 'n' THEN 'contract_value_delta' ELSE 'contract_value' END + ', 0)) ' ELSE ' SUM(COALESCE(hd.dis_contract_value, vsd.' + CASE WHEN @call_to = 'n' THEN 'contract_value_delta' ELSE 'dis_contract_value' END + ', 0)) ' END + ' END * MAX(ISNULL(hd.per_alloc, 1)) ContractValue, ' + ' 
		CASE WHEN (''' + ISNULL(@report_type, 'm') + ''' = ''p'') THEN 0 ELSE ' + 
		CASE WHEN @discount_option = 'u' THEN  ' SUM(COALESCE(hd.market_value, vsd.' + CASE WHEN @call_to = 'n' THEN 'market_value_delta' ELSE 'market_value' END + ', 0)) ' ELSE ' SUM(COALESCE(hd.dis_market_value, vsd.' + CASE WHEN @call_to = 'n' THEN 'market_value_delta' ELSE 'market_value' END + ', 0)) ' END + ' END * MAX(ISNULL(hd.per_alloc, 1)) MarketValue, ' + ' 
		SUM(COALESCE(hd.deal_volume, vsd.' + CASE WHEN @call_to = 'n' THEN 'position' ELSE 'deal_volume' END + ') * CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END) Volume ' + ',
		MAX(sb1.source_book_name) sbm1, 
		MAX(sb2.source_book_name) sbm2, 
		MAX(sb3.source_book_name) sbm3, 
		MAX(sb4.source_book_name) sbm4,
		MAX(st.trader_name) Trader, 
		MAX(scur.currency_name) Currency,
		(CASE WHEN hd.pnl_term IS NOT NULL THEN sdd.term_start ELSE NULL END),
		SUM(COALESCE(hd.a_und_pnl, vsd.' + CASE WHEN @call_to = 'n' THEN 'delta_value' ELSE 'und_pnl' END + ', 0)) mtm,
		SUM(COALESCE(hd.a_dis_pnl, vsd.' + CASE WHEN @call_to = 'n' THEN 'delta_value' ELSE 'dis_pnl' END + ', 0)) dis_mtm,
		SUM(COALESCE(hd.dis_market_value, vsd.' + CASE WHEN @call_to = 'n' THEN 'market_value_delta' ELSE 'dis_market_value' END + ', 0)) dis_market_value,
		SUM(COALESCE(hd.dis_contract_value, vsd.' + CASE WHEN @call_to = 'n' THEN 'contract_value_delta' ELSE 'dis_contract_value' END + ', 0)) dis_contract_value,
		MAX(sdv_cat.code),
		MAX(sdh.product_id),
		MAX(sub.entity_id)
	FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
		INNER JOIN ' + @source_deal_header_list + ' tt ON sdh.source_deal_header_id = tt.source_deal_header_id 
			AND sdd.leg = 1
		INNER JOIN ' + CASE WHEN @call_to = 'n' THEN 'source_deal_delta_value'+ CASE WHEN @revaluation ='y' THEN '_whatif' ELSE '' END ELSE 'var_simulation_data' END + ' vsd ON sdh.source_deal_header_id = vsd.source_deal_header_id 
			AND vsd.term_start = sdd.term_start
			' + @sql_and + '
			AND vsd.run_date = ''' + CAST(@run_date AS VARCHAR) + '''' + 
			CASE WHEN @revaluation ='y' THEN ' AND vsd.criteria_id = ' + CAST(@criteria_id AS VARCHAR) + '' ELSE '' END + ' 
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id 
		INNER JOIN source_traders st ON st.source_trader_id = sdh.trader_id
		INNER JOIN #books bk ON bk.source_system_book_id1 = sdh.source_system_book_id1 
			AND	bk.source_system_book_id2 = sdh.source_system_book_id2 
			AND bk.source_system_book_id3 = sdh.source_system_book_id3 
			AND bk.source_system_book_id4 = sdh.source_system_book_id4
		LEFT OUTER JOIN source_book sb1 ON sb1.source_book_id = sdh.source_system_book_id1 
		LEFT OUTER JOIN source_book sb2 ON sb2.source_book_id = sdh.source_system_book_id2 
		LEFT OUTER JOIN source_book sb3 ON sb3.source_book_id = sdh.source_system_book_id3 
		LEFT OUTER JOIN source_book sb4 ON sb4.source_book_id = sdh.source_system_book_id4 
		LEFT OUTER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2 
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4 
		LEFT OUTER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id 
		LEFT OUTER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
		LEFT OUTER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
		LEFT OUTER JOIN fas_strategy fs ON fs.fas_strategy_id = stra.entity_id
		LEFT JOIN fas_subsidiaries fs1 ON fs1.fas_subsidiary_id = sub.entity_id
		LEFT JOIN #hedge_deferral1 hd ON hd.source_deal_header_id = sdd.source_deal_header_id
			AND hd.cash_flow_term = sdd.term_start 	 
			AND hd.as_of_date= ''' + CAST(@as_of_date AS VARCHAR) + '''
		LEFT JOIN source_currency scur ON scur.source_currency_id = COALESCE(hd.pnl_currency_id, vsd.' + CASE WHEN @call_to = 'n' THEN 'currency_id' ELSE 'pnl_currency_id' END + ', fs1.func_cur_value_id)
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id    
		LEFT JOIN static_data_value sdv_cat ON sdv_cat.value_id = sdd.category 
		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status 
	WHERE 1 = 1 
		AND ISNULL(NULLIF(vsd.pnl_source_value_id, 775), 4505) = ' + CAST(@curve_source_id AS VARCHAR) + '
		AND ssbm.fas_deal_type_value_id IN(' + CAST(@transaction_type AS VARCHAR(500)) + ')   
	GROUP BY vsd.' + CASE WHEN @call_to = 'n' THEN 'as_of_date' ELSE 'pnl_as_of_date' END + ',sdh.deal_date, sdh.source_deal_header_id, sdh.deal_id,
		vsd.term_start,(CASE WHEN hd.pnl_term IS NOT NULL THEN sdd.term_start ELSE NULL END)'				
	
	
	exec spa_print @sql
	EXEC(@sql)

	CREATE TABLE #deal_pnl_detail(
		[Sub] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		[Strategy] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		[Book] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		[DealID] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		[REF ID] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		[Trade TYPE] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		[Counterparty] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		[Trader] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		[Deal DATE] DATETIME,
		[PNLDate] DATETIME,
		[Term] DATETIME,
		[Leg] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
		[Buy/Sell] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
		[INDEX] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		[Market Price] FLOAT,
		[Fixed Cost] FLOAT,
		[Formula Price] FLOAT,
		[Deal Fixed Price] FLOAT,
		[Price Adder] FLOAT,
		[Deal Price] FLOAT,
		[Net Price] FLOAT,
		[Multiplier] FLOAT,
		[Volume] FLOAT,
		[UOM] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
		[Discount Factor] FLOAT,
		[MTM] FLOAT,
		[Discounted MTM] FLOAT,
		deal_volume FLOAT,      
		block_type INT,
		block_define_id INT,
		deal_volume_frequency CHAR(1) COLLATE DATABASE_DEFAULT ,
		term_start DATETIME,
		term_end DATETIME,
		physical_financial_flag CHAR(1) COLLATE DATABASE_DEFAULT ,
		pnl_currency_id INT,
		curve_id INT
	)                    

	SELECT  @sql = '
		INSERT INTO #deal_pnl_detail 
		SELECT DISTINCT    
		Sub.entity_name Sub,
		stra.entity_name Strategy,
		Book.entity_name Book,
		sdh.source_deal_header_id [DealID],
		dbo.FNAHyperLink(10131024,(CAST(sdh.source_deal_header_id AS VARCHAR) + '' ('' + sdh.deal_id +  '')''),sdh.source_deal_header_id,''' + ISNULL(@batch_process_id,'-1') + ''') AS [Ref ID], 
		sdt.deal_type_id [Trade Type],
		sc.Counterparty_name Counterparty ,
		st.Trader_name Trader,
		(sdh.deal_date) [Deal Date],
		(vsd.' + CASE WHEN @call_to = 'n' THEN 'as_of_date' ELSE 'pnl_as_of_date' END + ') [PNLDate],' +
		CASE WHEN @report_type = 'c' THEN --CASH FLOW
			'CASE WHEN (cg.invoice_due_date IS NOT NULL) THEN cast(dbo.FNAInvoiceDueDate(vsd.term_start, cg.invoice_due_date, NULL, NULL) as datetime) 
				  WHEN (hgc.exp_date IS NOT NULL) THEN hgc.exp_date
			 ELSE vsd.term_start END Term,' 
		ELSE -- EARNING
			'CASE	WHEN (hd.pnl_term IS NOT NULL) THEN hd.pnl_term 
					WHEN (cg.pnl_date IS NOT NULL) THEN cast(dbo.FNAInvoiceDueDate(vsd.term_start, cg.pnl_date, NULL, NULL) as datetime) 
					WHEN (hgp.exp_date IS NOT NULL) THEN hgp.exp_date
			ELSE vsd.term_start END Term,' 
		END + ' 
		' + CASE WHEN @call_to = 'n' THEN 'sdd.leg' ELSE 'vsd.leg' END + ' [Leg],
		''b'' [Buy/Sell],
		spcd.curve_name [INDEX],
		0 [Market Price],
		0 [Fixed Cost],
		0 [Formula Price],
		0 [Deal Fixed Price],
		0 [Price Adder],
		0 [Deal Price],
		0 [Net Price],
		0 [Multiplier],
		ROUND(vsd.' + CASE WHEN @call_to = 'n' THEN 'position' ELSE 'deal_volume' END + ',' + CAST(@round_value AS VARCHAR) + ')  [Volume],
		su.uom_name [UOM], 
		''1'' AS [Discount Factor],'+
		CASE WHEN (@report_type = 'c') THEN 'ROUND(vsd.' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ',' + CAST(@round_value AS VARCHAR) + ') [MTM]' 
			 ELSE 'ROUND(COALESCE(hd.a_dis_pnl, vsd.' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ',' + CAST(@round_value AS VARCHAR) + ', 0),' + CAST(@round_value AS VARCHAR) + ') [MTM]' 
		END + ',' +
		CASE WHEN (@report_type='c') THEN 'round(vsd.' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ',' + CAST(@round_value AS VARCHAR) + ' '
			 ELSE 'ROUND(COALESCE(hd.a_dis_pnl, vsd.' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ',' + CAST(@round_value AS VARCHAR) + ', 0) '
		END + ',' + CAST(@round_value AS VARCHAR) + ') [Discounted MTM],
		vsd.' + CASE WHEN @call_to = 'n' THEN 'position' ELSE 'deal_volume' END + ',
		ISNULL(spcd1.block_type,sdh.block_type) block_type,
		ISNULL(spcd1.block_define_id,sdh.block_define_id)block_define_id,
		sdd.deal_volume_frequency,
		sdd.term_start,
		sdd.term_end,
		sdh.physical_financial_flag,
		' + CASE WHEN @call_to = 'n' THEN 'vsd.currency_id, vsd.curve_id' ELSE 'vsd.pnl_currency_id, NULL' END + '  
	FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN ' + @source_deal_header_list + ' tt ON sdd.source_deal_header_id = tt.source_deal_header_id
		INNER JOIN ' + CASE WHEN @call_to = 'n' THEN 'source_deal_delta_value'+ CASE WHEN @revaluation ='y' THEN '_whatif' ELSE '' END ELSE 'var_simulation_data' END + ' vsd ON sdd.source_deal_header_id = vsd.source_deal_header_id
			' + @sql_and + ' 
			AND sdd.term_start = vsd.term_start 
			AND sdd.term_end = vsd.term_end
			AND sdd.leg = ' + CASE WHEN @call_to = 'n' THEN 'sdd.leg' ELSE 'vsd.leg' END + ' 
			AND vsd.pnl_source_value_id = ' + CAST(@curve_source_id AS VARCHAR) + '
			AND run_date = ''' + CAST(@run_date AS VARCHAR) + '''' +
			CASE WHEN @revaluation ='y' THEN ' AND vsd.criteria_id = ' + CAST(@criteria_id AS VARCHAR) + '' ELSE '' END + '
		INNER JOIN ' + @as_of_date_point_process_table + ' aodp ON vsd.' + CASE WHEN @call_to = 'n' THEN 'as_of_date' ELSE 'pnl_as_of_date' END + ' = aodp.as_of_date	 
		INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
			AND	ssbm.source_system_book_id3 = sdh.source_system_book_id3 
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
		INNER JOIN #books b ON b.fas_book_id = ssbm.fas_book_id
		INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
		INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
		INNER JOIN fas_strategy fs ON fs.fas_strategy_id = stra.entity_id 
		LEFT JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id 
		LEFT JOIN source_uom su ON su.source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)    --sdd.deal_volume_uom_id
		LEFT JOIN dbo.source_traders st ON sdh.trader_id = st.source_trader_id
		LEFT JOIN dbo.source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
		--LEFT JOIN source_deal_pnl_detail_options sdpdo ON sdpdo.source_deal_header_id = vsd.source_deal_header_id 
		--	AND sdpdo.as_of_date = vsd.pnl_as_of_date 
		--	AND sdpdo.term_start = vsd.term_start
		--LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = sdd.curve_id 
		--	AND spc.as_of_date = CASE WHEN(sdd.contract_expiration_date > vsd.pnl_as_of_date) THEN 
		--							vsd.pnl_as_of_date 
		--						ELSE sdd.contract_expiration_date END  
		--	AND spc.maturity_date = vsd.term_start 
		LEFT OUTER JOIN #hedge_deferral1 hd ON hd.source_deal_header_id = vsd.source_deal_header_id 
			AND hd.cash_flow_term = vsd.term_start 	 
		LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id    
		LEFT JOIN holiday_group hgc ON hgc.hol_group_value_id = cg.payment_calENDar 
			AND CONVERT(VARCHAR(7), hgc.hol_date, 120) = CONVERT(VARCHAR(7), vsd.term_start, 120) 
		LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.pnl_calENDar 
			AND CONVERT(VARCHAR(7), hgp.hol_date, 120) = CONVERT(VARCHAR(7), vsd.term_start, 120)
		LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
		LEFT JOIN source_deal_detail sdd1 ON sdh.source_deal_header_id = sdd1.source_deal_header_id
			AND sdd.term_start = sdd1.term_start 
			AND sdd1.leg = 1
		LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id
	WHERE 1 = 1 
		AND ssbm.fas_deal_type_value_id IN(401,402,400)'
	
	SET	@sql_second = '
	UNION ALL
	SELECT DISTINCT    
		Sub.entity_name Sub,
		stra.entity_name Strategy,
		Book.entity_name Book,
		sdh.source_deal_header_id [DealID],
		dbo.FNAHyperLink(10131024,(CAST(sdh.source_deal_header_id AS VARCHAR) + '' ('' + sdh.deal_id +  '')''),sdh.source_deal_header_id,''' + ISNULL(@batch_process_id,'-1') + ''') AS [Ref ID], 
		sdt.deal_type_id [Trade Type],
		sc.Counterparty_name Counterparty ,
		st.Trader_name Trader,
		(sdh.deal_date) [Deal Date],
		(sdpd.pnl_as_of_date) [PNLDate],' +
		CASE WHEN @report_type = 'c' THEN --CASH FLOW
			'CASE WHEN (cg.invoice_due_date IS NOT NULL) THEN cast(dbo.FNAInvoiceDueDate(sdpd.term_start, cg.invoice_due_date, NULL, NULL) as datetime) 
				  WHEN (hgc.exp_date IS NOT NULL) THEN hgc.exp_date
			 ELSE sdpd.term_start END Term,' 
		ELSE -- EARNING
			'CASE	WHEN (hd.pnl_term IS NOT NULL) THEN hd.pnl_term 
					WHEN (cg.pnl_date IS NOT NULL) THEN cast(dbo.FNAInvoiceDueDate(sdpd.term_start, cg.pnl_date, NULL, NULL) as datetime) 
					WHEN (hgp.exp_date IS NOT NULL) THEN hgp.exp_date
			ELSE sdpd.term_start END Term,' 
		END + ' 
		sdpd.leg [Leg],
		''b'' [Buy/Sell],
		spcd.curve_name [INDEX],
		0 [Market Price],
		0 [Fixed Cost],
		0 [Formula Price],
		0 [Deal Fixed Price],
		0 [Price Adder],
		0 [Deal Price],
		0 [Net Price],
		0 [Multiplier],
		ROUND(sdpd.deal_volume,' + CAST(@round_value AS VARCHAR) + ')  [Volume],
		su.uom_name [UOM], 
		''1'' AS [Discount Factor],'+
		CASE WHEN (@report_type = 'c') THEN 'ROUND(sdpd.und_pnl_set,' + CAST(@round_value AS VARCHAR) + ') [MTM]' 
			 ELSE 'ROUND(COALESCE(hd.a_dis_pnl, sdpd.und_pnl_set, 0),' + CAST(@round_value AS VARCHAR) + ') [MTM]' 
		END + ',' +
		CASE WHEN (@report_type='c') THEN 'round(sdpd.und_pnl_set '
			 ELSE 'ROUND(COALESCE(hd.a_dis_pnl, sdpd.und_pnl_set, 0) '
		END + ',' + CAST(@round_value AS VARCHAR) + ') [Discounted MTM],
		sdpd.deal_volume,
		ISNULL(spcd1.block_type,sdh.block_type) block_type,
		ISNULL(spcd1.block_define_id,sdh.block_define_id)block_define_id,
		sdd.deal_volume_frequency,
		sdd.term_start,
		sdd.term_end,
		sdh.physical_financial_flag,
		sdpd.pnl_currency_id,
		sdpd.curve_id
	FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		' + CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdd.term_start >= ''' + CAST(@tenor_from AS VARCHAR) + '''' ELSE '' END + '
		' + CASE WHEN @tenor_to IS NOT NULL THEN ' AND sdd.term_end <= ''' + CAST(@tenor_to AS VARCHAR) + '''' ELSE '' END + '
		INNER JOIN ' + @source_deal_header_list + ' tt ON sdd.source_deal_header_id = tt.source_deal_header_id  
		INNER JOIN source_deal_pnl_detail' + CASE WHEN @calc_type = 'w' THEN '_whatif' ELSE '' END + ' sdpd ON sdd.source_deal_header_id = sdpd.source_deal_header_id
			' + CASE WHEN @calc_type = 'w' THEN ' AND criteria_id = ' + CAST(@criteria_id AS VARCHAR) + ' ' ELSE '' END + '
			AND sdd.term_start = sdpd.term_start 
			AND sdd.term_end = sdpd.term_end
			AND sdd.leg = sdpd.leg 
			AND sdpd.pnl_source_value_id = ''4500''
			AND pnl_as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''' 
		INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
			AND	ssbm.source_system_book_id3 = sdh.source_system_book_id3 
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
		INNER JOIN #books b ON b.fas_book_id = ssbm.fas_book_id
		INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
		INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
		INNER JOIN fas_strategy fs ON fs.fas_strategy_id = stra.entity_id 
		LEFT JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id 
		LEFT JOIN source_uom su ON su.source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)    --sdd.deal_volume_uom_id
		LEFT JOIN dbo.source_traders st ON sdh.trader_id = st.source_trader_id
		LEFT JOIN dbo.source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
		--LEFT JOIN source_deal_pnl_detail_options sdpdo ON sdpdo.source_deal_header_id = sdpd.source_deal_header_id 
		--	AND sdpdo.as_of_date = sdpd.pnl_as_of_date 
		--	AND sdpdo.term_start = sdpd.term_start
		--LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = sdd.curve_id 
		--	AND spc.as_of_date = CASE WHEN(sdd.contract_expiration_date > sdpd.pnl_as_of_date) THEN 
		--							sdpd.pnl_as_of_date 
		--						ELSE sdd.contract_expiration_date END  
		--	AND spc.maturity_date = sdpd.term_start 
		LEFT OUTER JOIN #hedge_deferral1 hd ON hd.source_deal_header_id = sdpd.source_deal_header_id 
			AND hd.cash_flow_term = sdpd.term_start 	 
		LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id    
		LEFT JOIN holiday_group hgc ON hgc.hol_group_value_id = cg.payment_calENDar 
			AND CONVERT(VARCHAR(7), hgc.hol_date, 120) = CONVERT(VARCHAR(7), sdpd.term_start, 120) 
		LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.pnl_calENDar 
			AND CONVERT(VARCHAR(7), hgp.hol_date, 120) = CONVERT(VARCHAR(7), sdpd.term_start, 120)
		LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
		LEFT JOIN source_deal_detail sdd1 ON sdh.source_deal_header_id = sdd1.source_deal_header_id
			AND sdd.term_start = sdd1.term_start 
			AND sdd1.leg = 1
		LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id
	WHERE 1 = 1 
		AND ssbm.fas_deal_type_value_id IN(401,402,400)' 
	
	SET @sql = @sql + @sql_second         
	exec spa_print @sql, @sql_second
	EXEC(@sql)
	
	IF @calc_type = 'w'
	BEGIN
		SET	@sql = 'INSERT INTO #deal_pnl_detail
		SELECT DISTINCT    
			Sub.entity_name Sub,
			stra.entity_name Strategy,
			Book.entity_name Book,
			sdh.source_deal_header_id [DealID],
			dbo.FNAHyperLink(10131024,(CAST(sdh.source_deal_header_id AS VARCHAR) + '' ('' + sdh.deal_id +  '')''),sdh.source_deal_header_id,''' + ISNULL(@batch_process_id,'-1') + ''') AS [Ref ID], 
			sdt.deal_type_id [Trade Type],
			sc.Counterparty_name Counterparty ,
			st.Trader_name Trader,
			(sdh.deal_date) [Deal Date],
			(vsd.' + CASE WHEN @call_to = 'n' THEN 'as_of_date' ELSE 'pnl_as_of_date' END + ') [PNLDate],' +
			CASE WHEN @report_type = 'c' THEN --CASH FLOW
				'CASE WHEN (cg.invoice_due_date IS NOT NULL) THEN cast(dbo.FNAInvoiceDueDate(vsd.term_start, cg.invoice_due_date, NULL, NULL) as datetime) 
					  WHEN (hgc.exp_date IS NOT NULL) THEN hgc.exp_date
				 ELSE vsd.term_start END Term,' 
			ELSE -- EARNING
				'CASE	WHEN (hd.pnl_term IS NOT NULL) THEN hd.pnl_term 
						WHEN (cg.pnl_date IS NOT NULL) THEN cast(dbo.FNAInvoiceDueDate(vsd.term_start, cg.pnl_date, NULL, NULL) as datetime) 
						WHEN (hgp.exp_date IS NOT NULL) THEN hgp.exp_date
				ELSE vsd.term_start END Term,' 
			END + ' 
			' + CASE WHEN @call_to = 'n' THEN 'sdd.leg' ELSE 'vsd.leg' END + ' [Leg],
			''b'' [Buy/Sell],
			spcd.curve_name [INDEX],
			0 [Market Price],
			0 [Fixed Cost],
			0 [Formula Price],
			0 [Deal Fixed Price],
			0 [Price Adder],
			0 [Deal Price],
			0 [Net Price],
			0 [Multiplier],
			ROUND(vsd.' + CASE WHEN @call_to = 'n' THEN 'position' ELSE 'deal_volume' END + ',' + CAST(@round_value AS VARCHAR) + ')  [Volume],
			su.uom_name [UOM], 
			''1'' AS [Discount Factor],'+
			CASE WHEN (@report_type = 'c') THEN 'ROUND(vsd.' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ',' + CAST(@round_value AS VARCHAR) + ') [MTM]' 
				 ELSE 'ROUND(COALESCE(hd.a_dis_pnl, vsd.' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ', 0),' + CAST(@round_value AS VARCHAR) + ') [MTM]' 
			END + ',' +
			CASE WHEN (@report_type='c') THEN 'round(vsd.' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ' '
				 ELSE 'ROUND(COALESCE(hd.a_dis_pnl, vsd.' + CASE WHEN @call_to = 'n' THEN 'avg_delta_value' ELSE 'und_pnl_set' END + ', 0) '
			END + ',' + CAST(@round_value AS VARCHAR) + ') [Discounted MTM],
			vsd.' + CASE WHEN @call_to = 'n' THEN 'position' ELSE 'deal_volume' END + ',
			ISNULL(spcd1.block_type,sdh.block_type) block_type,
			ISNULL(spcd1.block_define_id,sdh.block_define_id)block_define_id,
			sdd.deal_volume_frequency,
			sdd.term_start,
			sdd.term_end,
			sdh.physical_financial_flag,
			' + CASE WHEN @call_to = 'n' THEN 'vsd.currency_id, vsd.curve_id' ELSE 'vsd.pnl_currency_id, NULL' END + ' 
		FROM ' + @hypo_deal_header + ' sdh
			INNER JOIN ' + @hypo_deal_detail + ' sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN ' + @source_deal_header_list + ' tt ON sdd.source_deal_header_id = tt.source_deal_header_id
			INNER JOIN ' + CASE WHEN @call_to = 'n' THEN 'source_deal_delta_value'+ CASE WHEN @revaluation ='y' THEN '_whatif' ELSE '' END ELSE 'var_simulation_data' END + ' vsd ON sdd.source_deal_header_id = vsd.source_deal_header_id
				' + @sql_and + ' 
				AND sdd.term_start = vsd.term_start 
				AND sdd.term_end = vsd.term_end
				AND sdd.leg = ' + CASE WHEN @call_to = 'n' THEN 'sdd.leg' ELSE 'vsd.leg' END + ' 
				AND vsd.pnl_source_value_id = ' + CAST(@curve_source_id AS VARCHAR) + '
				AND run_date = ''' + CAST(@run_date AS VARCHAR) + ''''+
				CASE WHEN @revaluation ='y' THEN ' AND vsd.criteria_id = ' + CAST(@criteria_id AS VARCHAR) + '' ELSE '' END + '
			INNER JOIN ' + @as_of_date_point_process_table + ' aodp ON vsd.' + CASE WHEN @call_to = 'n' THEN 'as_of_date' ELSE 'pnl_as_of_date' END + ' = aodp.as_of_date	 
			INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
				AND	ssbm.source_system_book_id3 = sdh.source_system_book_id3 
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
			INNER JOIN #books b ON b.fas_book_id = ssbm.fas_book_id
			INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
			INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
			INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
			INNER JOIN fas_strategy fs ON fs.fas_strategy_id = stra.entity_id 
			LEFT JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id 
			LEFT JOIN source_uom su ON su.source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)    --sdd.deal_volume_uom_id
			LEFT JOIN dbo.source_traders st ON sdh.trader_id = st.source_trader_id
			LEFT JOIN dbo.source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
			--LEFT JOIN source_deal_pnl_detail_options sdpdo ON sdpdo.source_deal_header_id = vsd.source_deal_header_id 
			--	AND sdpdo.as_of_date = vsd.pnl_as_of_date 
			--	AND sdpdo.term_start = vsd.term_start
			--LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = sdd.curve_id 
			--	AND spc.as_of_date = CASE WHEN(sdd.contract_expiration_date > vsd.pnl_as_of_date) THEN 
			--							vsd.pnl_as_of_date 
			--						ELSE sdd.contract_expiration_date END  
			--	AND spc.maturity_date = vsd.term_start 
			LEFT OUTER JOIN #hedge_deferral1 hd ON hd.source_deal_header_id = vsd.source_deal_header_id 
				AND hd.cash_flow_term = vsd.term_start 	 
			LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id    
			LEFT JOIN holiday_group hgc ON hgc.hol_group_value_id = cg.payment_calENDar 
				AND CONVERT(VARCHAR(7), hgc.hol_date, 120) = CONVERT(VARCHAR(7), vsd.term_start, 120) 
			LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.pnl_calENDar 
				AND CONVERT(VARCHAR(7), hgp.hol_date, 120) = CONVERT(VARCHAR(7), vsd.term_start, 120)
			LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
			LEFT JOIN source_deal_detail sdd1 ON sdh.source_deal_header_id = sdd1.source_deal_header_id
				AND sdd.term_start = sdd1.term_start 
				AND sdd1.leg = 1
			LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id
		WHERE 1 = 1 
			AND ssbm.fas_deal_type_value_id IN(401,402,400)'
		SET	@sql_second = '
		UNION ALL
		SELECT DISTINCT    
			Sub.entity_name Sub,
			stra.entity_name Strategy,
			Book.entity_name Book,
			sdh.source_deal_header_id [DealID],
			dbo.FNAHyperLink(10131024,(CAST(sdh.source_deal_header_id AS VARCHAR) + '' ('' + sdh.deal_id +  '')''),sdh.source_deal_header_id,''' + ISNULL(@batch_process_id,'-1') + ''') AS [Ref ID], 
			sdt.deal_type_id [Trade Type],
			sc.Counterparty_name Counterparty ,
			st.Trader_name Trader,
			(sdh.deal_date) [Deal Date],
			(sdpd.pnl_as_of_date) [PNLDate],' +
			CASE WHEN @report_type = 'c' THEN --CASH FLOW
				'CASE WHEN (cg.invoice_due_date IS NOT NULL) THEN cast(dbo.FNAInvoiceDueDate(sdpd.term_start, cg.invoice_due_date, NULL, NULL) as datetime) 
					  WHEN (hgc.exp_date IS NOT NULL) THEN hgc.exp_date
				 ELSE sdpd.term_start END Term,' 
			ELSE -- EARNING
				'CASE	WHEN (hd.pnl_term IS NOT NULL) THEN hd.pnl_term 
						WHEN (cg.pnl_date IS NOT NULL) THEN cast(dbo.FNAInvoiceDueDate(sdpd.term_start, cg.pnl_date, NULL, NULL) as datetime) 
						WHEN (hgp.exp_date IS NOT NULL) THEN hgp.exp_date
				ELSE sdpd.term_start END Term,' 
			END + ' 
			sdpd.leg [Leg],
			''b'' [Buy/Sell],
			spcd.curve_name [INDEX],
			0 [Market Price],
			0 [Fixed Cost],
			0 [Formula Price],
			0 [Deal Fixed Price],
			0 [Price Adder],
			0 [Deal Price],
			0 [Net Price],
			0 [Multiplier],
			ROUND(sdpd.deal_volume,' + CAST(@round_value AS VARCHAR) + ')  [Volume],
			su.uom_name [UOM], 
			''1'' AS [Discount Factor],'+
			CASE WHEN (@report_type = 'c') THEN 'ROUND(sdpd.und_pnl_set,' + CAST(@round_value AS VARCHAR) + ') [MTM]' 
				 ELSE 'ROUND(COALESCE(hd.a_dis_pnl, sdpd.und_pnl_set, 0),' + CAST(@round_value AS VARCHAR) + ') [MTM]' 
			END + ',' +
			CASE WHEN (@report_type='c') THEN 'round(sdpd.und_pnl_set '
				 ELSE 'ROUND(COALESCE(hd.a_dis_pnl, sdpd.und_pnl_set, 0) '
			END + ',' + CAST(@round_value AS VARCHAR) + ') [Discounted MTM],
			sdpd.deal_volume,
			ISNULL(spcd1.block_type,sdh.block_type) block_type,
			ISNULL(spcd1.block_define_id,sdh.block_define_id)block_define_id,
			sdd.deal_volume_frequency,
			sdd.term_start,
			sdd.term_end,
			sdh.physical_financial_flag,
			sdpd.pnl_currency_id,
			sdpd.curve_id
		FROM ' + @hypo_deal_header + ' sdh
			INNER JOIN ' + @hypo_deal_detail + ' sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			' + CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdd.term_start >= ''' + CAST(@tenor_from AS VARCHAR) + '''' ELSE '' END + '
			' + CASE WHEN @tenor_to IS NOT NULL THEN ' AND sdd.term_end <= ''' + CAST(@tenor_to AS VARCHAR) + '''' ELSE '' END + '
			INNER JOIN ' + @source_deal_header_list + ' tt ON sdd.source_deal_header_id = tt.source_deal_header_id  
			INNER JOIN source_deal_pnl_detail_whatif sdpd ON sdd.source_deal_header_id = sdpd.source_deal_header_id 
				AND sdd.term_start = sdpd.term_start 
				AND sdd.term_end = sdpd.term_end
				AND sdd.leg = sdpd.leg 
				AND sdpd.pnl_source_value_id = ''4500''
				AND pnl_as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''' 
			INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
				AND	ssbm.source_system_book_id3 = sdh.source_system_book_id3 
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
			INNER JOIN #books b ON b.fas_book_id = ssbm.fas_book_id
			INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
			INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
			INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
			INNER JOIN fas_strategy fs ON fs.fas_strategy_id = stra.entity_id 
			LEFT JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id 
			LEFT JOIN source_uom su ON su.source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)    --sdd.deal_volume_uom_id
			LEFT JOIN dbo.source_traders st ON sdh.trader_id = st.source_trader_id
			LEFT JOIN dbo.source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
			--LEFT JOIN source_deal_pnl_detail_options sdpdo ON sdpdo.source_deal_header_id = sdpd.source_deal_header_id 
			--	AND sdpdo.as_of_date = sdpd.pnl_as_of_date 
			--	AND sdpdo.term_start = sdpd.term_start
			--LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = sdd.curve_id 
			--	AND spc.as_of_date = CASE WHEN(sdd.contract_expiration_date > sdpd.pnl_as_of_date) THEN 
			--							sdpd.pnl_as_of_date 
			--						ELSE sdd.contract_expiration_date END  
			--	AND spc.maturity_date = sdpd.term_start 
			LEFT OUTER JOIN #hedge_deferral1 hd ON hd.source_deal_header_id = sdpd.source_deal_header_id 
				AND hd.cash_flow_term = sdpd.term_start 	 
			LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id    
			LEFT JOIN holiday_group hgc ON hgc.hol_group_value_id = cg.payment_calENDar 
				AND CONVERT(VARCHAR(7), hgc.hol_date, 120) = CONVERT(VARCHAR(7), sdpd.term_start, 120) 
			LEFT JOIN holiday_group hgp ON hgp.hol_group_value_id = cg.pnl_calENDar 
				AND CONVERT(VARCHAR(7), hgp.hol_date, 120) = CONVERT(VARCHAR(7), sdpd.term_start, 120)
			LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
			LEFT JOIN source_deal_detail sdd1 ON sdh.source_deal_header_id = sdd1.source_deal_header_id
				AND sdd.term_start = sdd1.term_start 
				AND sdd1.leg = 1
			LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id
		WHERE 1 = 1 
			AND ssbm.fas_deal_type_value_id IN(401,402,400)'	
			
		
		EXEC spa_print '/********************test/**********************/'
		SET @sql = @sql + @sql_second         
		exec spa_print @sql, @sql_second
		EXEC(@sql)
	END	
	
	SET @sql = 'SELECT 
		[PNLDate] pnl_as_of_date,
		[DealID] source_deal_header_id,
		term_start,
		term_end,
		Leg leg,
		MTM und_pnl,
		deal_volume,
		pnl_currency_id,
		curve_id
		INTO ' + @process_table + '
	FROM
		#deal_pnl_detail dpd
	ORDER BY [sub],[Strategy],[book],[DealID],dbo.FNAStdDate([Term]),leg'
	
	exec spa_print @sql
	EXEC(@sql)
	
	RETURN


