

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_trade_ticket_report]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_trade_ticket_report]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_trade_ticket_report]
	@flag VARCHAR(2),
    @source_deal_header_id VARCHAR(1000) = NULL,
	@deal_id_from INT = NULL,
	@deal_id_to INT = NULL  	
AS 
SET NOCOUNT ON

DECLARE @vol_frequency_table  VARCHAR(500)
DECLARE @process_id           VARCHAR(50)
DECLARE @user_login_id        VARCHAR(50)
DECLARE @sql_Select           VARCHAR(MAX)
DECLARE @sql_Select2          VARCHAR(MAX)
DECLARE @sql                  VARCHAR(MAX)
DECLARE @default_date         DATETIME

SET @default_date = GETDATE()

CREATE TABLE #sourceDealheader(source_deal_header_id INT)

IF @source_deal_header_id IS NOT NULL
BEGIN
	SET @sql_Select = 'INSERT INTO #sourceDealheader 
						SELECT Item from dbo.SplitCommaSeperatedValues('''+@source_deal_header_id+''')'
	--PRINT @sql_Select
	EXEC (@sql_Select)
END
ELSE 
BEGIN
	SET @sql = 'INSERT INTO #sourceDealheader 
				SELECT source_deal_header_id FROM source_deal_header WHERE 1=1'
            
	IF @deal_id_from IS NULL AND @deal_id_to IS NULL 
		SET @sql = @sql + ' AND dbo.FNAGetSQLStandardDate(update_ts)=dbo.FNAGetSQLStandardDate(''' + CAST(@default_date AS VARCHAR(20)) + ''') '
	
	IF @deal_id_from IS NOT NULL 
		SET @sql = @sql + ' AND source_deal_header_id >= ' + CAST(@deal_id_from AS VARCHAR) 
		
	IF @deal_id_to IS NOT NULL 
		SET @sql = @sql + ' AND source_deal_header_id <= ' + CAST(@deal_id_to AS VARCHAR) 		
	
	--PRINT @sql
	EXEC (@sql)
END

DECLARE @leg1                  INT,
        @buy_sell_flag1        CHAR(1),
        @fixed_price1          NUMERIC(38, 20),
        @option_strike_price1  FLOAT,
        @curve_id1             VARCHAR(100),
        @fixed_cost1           NUMERIC(38, 20),
        @price_adder1          NUMERIC(38, 20),
        @price_multiplier1     FLOAT,
        @deal_volume1          NUMERIC(38, 20),
        @sum_deal_volume1      NUMERIC(38, 20),
        @currency1             VARCHAR(50),
        @frequency1            VARCHAR(50),
        @uom1                  VARCHAR(50)

DECLARE @leg2                  INT,
        @buy_sell_flag2        CHAR(1),
        @fixed_price2          NUMERIC(38, 20),
        @option_strike_price2  FLOAT,
        @curve_id2             VARCHAR(100),
        @fixed_cost2           NUMERIC(38, 20),
        @price_adder2          NUMERIC(38, 20),
        @price_multiplier2     FLOAT,
        @deal_volume2          FLOAT,
        @sum_deal_volume2      NUMERIC(38, 20),
        @currency2             VARCHAR(50),
        @frequency2            VARCHAR(50),
        @uom2                  VARCHAR(50)


--- ######################GET the volume by frequency	
SET @user_login_id = dbo.FNADBUser()
SET @process_id = REPLACE(NEWID(), '-', '_')	
SET @vol_frequency_table = dbo.FNAProcessTableName('deal_volume_frequency_mult',@user_login_id, @process_id)
SET @sql_Select = 'SELECT DISTINCT 
                          sdd.term_start,
                          sdd.term_end,
                          sdd.deal_volume_frequency AS deal_volume_frequency,
                          ISNULL(spcd.block_type, sdh.block_type) block_type,
                          ISNULL(spcd.block_define_id, sdh.block_define_id) 
                          block_definition_id
					INTO ' + @vol_frequency_table + '
					FROM source_deal_header sdh 
					INNER JOIN #sourceDealheader sd ON sd.source_deal_header_id = sdh.source_deal_header_id	
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
					LEFT JOIN source_deal_detail sdd1 ON sdh.source_deal_header_id = sdd1.source_deal_header_id
						AND sdd.term_start = sdd1.term_start AND sdd1.leg = 1
					LEFT JOIN source_price_curve_def spcd ON sdd1.curve_id = spcd.source_curve_def_id'	
EXEC ( @sql_Select)

EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table
--PRINT @vol_frequency_table

CREATE TABLE #vol_frequency_table
(
	term_start             DATETIME,
	term_end               DATETIME,
	deal_volume_frequency  CHAR(1) COLLATE DATABASE_DEFAULT ,
	block_type             INT,
	block_definition_id    INT,
	Volume_Mult            NUMERIC(38, 20)
)
SET @sql_Select = 'INSERT INTO #vol_frequency_table
                   SELECT term_start,
                          term_end,
                          deal_volume_frequency,
                          block_type,
                          block_definition_id,
                          Volume_Mult
                   FROM   ' + @vol_frequency_table

EXEC (@sql_Select)

--Leg 1 Buy/Sell flag:
--Leg 1 Fixed price:
--Leg 1 Strike price:
--Leg 1 Index:
--Leg 1 Fixed Cost:
--Leg 1 Price Adder:
--Leg 1 Multiplier:
--Leg 1 Quantity: 
--Leg 1 Total Quantity: 


CREATE TABLE #leg1
(
	source_deal_header_id  INT,
	leg                    INT,
	buy_sell_flag          CHAR(1) COLLATE DATABASE_DEFAULT ,
	fixed_price            NUMERIC(38, 20),
	option_strike_price    FLOAT,
	curve_id               VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	fixed_cost             NUMERIC(38, 20),
	price_adder            NUMERIC(38, 20),
	price_multiplier       FLOAT,
	deal_volume            FLOAT,
	sum_deal_volume        NUMERIC(38, 20),
	currency               VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	frequency              VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	uom                    VARCHAR(200) COLLATE DATABASE_DEFAULT 
)

CREATE TABLE #leg2
(
	source_deal_header_id  INT,
	leg                    INT,
	buy_sell_flag          CHAR(1) COLLATE DATABASE_DEFAULT ,
	fixed_price            NUMERIC(38, 20),
	option_strike_price    FLOAT,
	curve_id               VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	fixed_cost             NUMERIC(38, 20),
	price_adder            NUMERIC(38, 20),
	price_multiplier       FLOAT,
	deal_volume            FLOAT,
	sum_deal_volume        NUMERIC(38, 20),
	currency               VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	frequency              VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	uom                    VARCHAR(200) COLLATE DATABASE_DEFAULT 
)


INSERT INTO #leg1
SELECT  
		sdh.source_deal_header_id,
		MAX(sdd.leg),
        MAX(sdd.buy_sell_flag),
        MAX(sdd.fixed_price),
        MAX(sdd.option_strike_price),
        MAX(spcd.curve_id),
        MAX(sdd.fixed_cost),		
        MAX(sdd.price_adder),
        MAX(sdd.multiplier),
        [dbo].[FNARemoveTrailingZeroes](MAX(sdd.deal_volume)),
        [dbo].[FNARemoveTrailingZeroes](SUM(sdd.deal_volume * ISNULL(vft.Volume_Mult,1))*MAX(ISNULL(sdd.price_multiplier,1))),        
        MAX(sc.currency_id),
        MAX(sdd.deal_volume_frequency),
		max(uom.uom_id)
FROM    source_deal_header sdh
		INNER JOIN #sourceDealheader sd ON sd.source_deal_header_id=sdh.source_deal_header_id	
        INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN source_currency sc on sc.source_currency_id = sdd.fixed_price_currency_id
		LEFT JOIN source_uom uom on uom.source_uom_id = sdd.deal_volume_uom_id
        LEFT JOIN #vol_frequency_table vft ON vft.term_start = sdd.term_start
           AND vft.term_end = sdd.term_end
           AND ISNULL(vft.block_definition_id,-1) = COALESCE(spcd.block_define_id,sdh.block_define_id, -1)
           AND ISNULL(vft.block_type, -1) = COALESCE(spcd.block_type,sdh.block_type, -1)
WHERE   sdd.leg = 1
GROUP BY sdh.source_deal_header_id


INSERT INTO #leg2
SELECT  
		sdh.source_deal_header_id,
		MAX(sdd.leg),
        MAX(sdd.buy_sell_flag),
        MAX(sdd.fixed_price),
        MAX(sdd.option_strike_price),
        MAX(spcd.curve_id),
        MAX(sdd.fixed_cost),
		
        MAX(sdd.price_adder),
        MAX(sdd.multiplier),
        [dbo].[FNARemoveTrailingZeroes](MAX(sdd.deal_volume)),
        [dbo].[FNARemoveTrailingZeroes](SUM(sdd.deal_volume * ISNULL(vft.Volume_Mult,1))*MAX(ISNULL(sdd.price_multiplier,1))),
        
        MAX(sc.currency_id),
        MAX(sdd.deal_volume_frequency),
		max(uom.uom_id)
FROM    source_deal_header sdh
		INNER JOIN #sourceDealheader sd ON sd.source_deal_header_id=sdh.source_deal_header_id	
        INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN source_currency sc on sc.source_currency_id = sdd.fixed_price_currency_id
		LEFT JOIN source_uom uom on uom.source_uom_id = sdd.deal_volume_uom_id
		LEFT JOIN source_deal_detail sdd1 on sdh.source_deal_header_id=sdd1.source_deal_header_id
			AND sdd.term_start=sdd1.term_start and sdd1.leg=1
		LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id
        LEFT JOIN #vol_frequency_table vft ON vft.term_start = sdd.term_start
           AND vft.term_end = sdd.term_end
           AND ISNULL(vft.block_definition_id,-1) = COALESCE(spcd1.block_define_id,sdh.block_define_id, -1)
           AND ISNULL(vft.block_type, -1) = COALESCE(spcd1.block_type,sdh.block_type, -1)
WHERE   sdd.leg = 2
GROUP BY sdh.source_deal_header_id

SELECT ISNULL(l1.source_deal_header_id,l2.source_deal_header_id) [deal_id],
	   l1.leg [leg1],
	   l1.buy_sell_flag [buy_sell_flag1],
	   l1.fixed_price fixed_price1,
	   l1.option_strike_price option_strike_price1,
	   l1.curve_id curve_id1,
	   l1.fixed_cost fixed_cost1,
	   l1.price_adder price_adder1,
	   l1.price_multiplier price_multiplier1,
	   l1.deal_volume deal_volume1,
	   l1.sum_deal_volume sum_deal_volume1,
	   l1.currency currency1,
	   l1.frequency frequency1,
	   l1.uom uom1,
	   l2.leg leg2,
	   l2.buy_sell_flag buy_sell_flag2,
	   l2.fixed_price fixed_price2,
	   l2.option_strike_price option_strike_price2,
	   l2.curve_id curve_id2,
	   l2.fixed_cost fixed_cost2,
	   l2.price_adder price_adder2,
	   l2.price_multiplier price_multiplier2,
	   l2.deal_volume deal_volume2,
	   l2.sum_deal_volume sum_deal_volume2,
	   l2.currency currency2,
	   l2.frequency frequency2,
	   l2.uom uom2 
INTO #deals
FROM #leg1 l1
FULL JOIN #leg2 l2 ON l1.source_deal_header_id = l2.source_deal_header_id

IF @flag = 'a'
BEGIN

	SET @sql_Select = '
		SELECT 
			dbo.FNAConvertTZAwareDateFormat(GETDATE(),0)[Date],
			st.trader_name Trader,
			dbo.FNADateFormat(sdh.deal_date) [Trade Date],
			sdt.source_deal_type_name [Trade Type],				
			MAX(sc.commodity_name) [Commodity], 
			dbo.FNADateFormat(MIN(sdd.term_start)) [Start Date], 
			dbo.FNADateFormat(MAX(sdd.term_end)) [End Date],
			CAST(MAX(dbo.[FNARemoveTrailingZeroes](ROUND(sdd.deal_volume, 4))) AS VARCHAR)+'' '' + MAX(su.uom_name)+'' per ''+ 
			CASE MAX(sdd.deal_volume_frequency)
				WHEN ''h'' THEN ''HOUR''
				WHEN ''d'' THEN ''DAY''
				WHEN ''w'' THEN ''WEEK''
				WHEN ''m'' THEN ''MONTH''
				WHEN ''q'' THEN ''Quarter''
				WHEN ''s'' THEN ''Semi-annual''
				WHEN ''a'' THEN ''Annual''
			END [Quantity],
			CAST(CAST(SUM(sdd.deal_volume*
				CASE WHEN vft.Volume_Mult IS NOT NULL THEN vft.Volume_Mult 
					ELSE
					CASE  sdd.deal_volume_frequency
						WHEN ''h'' THEN  
							CASE  sdht.term_frequency_type
								WHEN ''h'' THEN  1
								WHEN ''d'' THEN 24
								WHEN ''w'' THEN 24*7
								WHEN ''m'' THEN 24*30
								WHEN ''q'' THEN 24*30*3
								WHEN ''s'' THEN 24*30*6
								WHEN ''a'' THEN 24*30*12
							END 
						WHEN ''d'' THEN 
							CASE sdht.term_frequency_type
								WHEN ''d'' THEN 1
								WHEN ''w'' THEN 7
								WHEN ''m'' THEN 30
								WHEN ''q'' THEN 30*3
								WHEN ''s'' THEN 30*6
								WHEN ''a'' THEN 30*12
							END 
						WHEN ''w'' THEN
							CASE  sdht.term_frequency_type
								WHEN ''d'' THEN 1/7
								WHEN ''w'' THEN 1
								WHEN ''m'' THEN 30/7
								WHEN ''q'' THEN (30*3)/7
								WHEN ''s'' THEN (30*6)/7
								WHEN ''a'' THEN (30*12)/7
							END 
						WHEN ''m'' THEN 
							CASE  sdht.term_frequency_type
								WHEN ''d'' THEN 1/30
								WHEN ''w'' THEN 7/30
								WHEN ''m'' THEN 1
								WHEN ''q'' THEN 3
								WHEN ''s'' THEN 6
								WHEN ''a'' THEN 12
							END 
						WHEN ''q'' THEN 
							CASE  sdht.term_frequency_type
								WHEN ''d'' THEN 1/90
								WHEN ''w'' THEN 7/90
								WHEN ''m'' THEN 30/90
								WHEN ''q'' THEN 1
								WHEN ''s'' THEN 2
								WHEN ''a'' THEN 4
							END 
						WHEN ''s'' THEN 
							CASE sdht.term_frequency_type
								WHEN ''d'' THEN 1/180
								WHEN ''w'' THEN 7/180
								WHEN ''m'' THEN 30/180
								WHEN ''q'' THEN (30*3)/180
								WHEN ''s'' THEN 1
								WHEN ''a'' THEN 2
							END 
						WHEN ''a'' THEN 
							CASE  sdht.term_frequency_type
								WHEN ''d'' THEN 1/365
								WHEN ''w'' THEN 7/365
								WHEN ''m'' THEN 30/365
								WHEN ''q'' THEN (30*3)/365
								WHEN ''s'' THEN (30*6)/365
								WHEN ''a'' THEN 1
							END 
					END
			END) AS NUMERIC(16,4)) AS VARCHAR) + '' ''+ MAX(su.uom_name) [Total Quantity],
			ISNULL(MAX(spcd.curve_name),MAX(risk_spcd.curve_name)) AS [Price Index],
			CAST(MAX(dbo.[FNARemoveTrailingZeroes](sdd.fixed_price)) AS VARCHAR) +'' ''+MAX(scu.currency_name) + '' / ''+ MAX(su.uom_name) [Fixed Price],
			MAX(sdh.deal_id) [External Trade ID],
			MAX(ph.entity_name) [Book],
			MAX(sdd.deal_detail_description) [Comments],
			ISNULL(MAX(scp.counterparty_name),'''') counterparty_name,
			MAX(au.user_off_tel) [TraderPhone],
			MAX(au.user_fax_tel) [TraderFax],
			MAX(au.user_emal_add) [TraderEmail],
			MAX(sdh.source_deal_header_id) [System Trade ID],
			MAX(sdh.create_user) [Input By],
			dbo.FNADateFormat(MAX(sdh.option_settlement_date)) [Premium Settlement DATE],
			CAST(MAX(sdd.option_strike_price) AS NUMERIC(20,2)) [Strike Price],
			CAST(ROUND(CAST(AVG((( ISNULL(sdd.fixed_price, 0) + ISNULL(sdd.price_adder, 0)) * ISNULL(sdd.price_multiplier, 1)))AS NUMERIC(20,2)),3) AS VARCHAR)+'' ''  [Premium],
			CAST(ROUND((SUM(((ISNULL(sdd.fixed_price, 0) +  ISNULL(sdd.price_adder, 0)) * ISNULL(sdd.price_multiplier, 1))* ISNULL(vft.Volume_Mult,1)*sdd.deal_volume)),3) AS VARCHAR)+'' ''+MAX(scu.currency_name) [TotalPremium],
			dbo.FNADateFormat(MAX(sdh.create_ts)) [Input Date],
			au2.user_l_name + '', '' + au2.user_f_name + '' '' + ISNULL(au2.user_m_name,'''')   [Verified By Name],
			sdh.verified_date [Verified Date],
			au3.user_l_name + '', '' + au3.user_f_name + '' '' + ISNULL(au3.user_m_name,'''')   [Risk Sign Off By Name],
			sdh.risk_sign_off_date [Risk Sign Off Date],
			au4.user_l_name + '', '' + au4.user_f_name + '' '' + ISNULL(au4.user_m_name,'''')   [Back Office Sign Off By Name],
			sdh.back_office_sign_off_date [Back Office Sign Off Date],
			CASE MAX(d.buy_sell_flag1) WHEN ''b'' THEN ''Buy'' WHEN ''s'' THEN ''Sell'' END  [Buy Sell Flag 1],
			dbo.FNARemoveTrailingZeroes(MAX(d.fixed_price1)) [Fixed Price 1],
			dbo.FNARemoveTrailingZeroes(MAX(d.option_strike_price1)) [Option Strike Price 1],
			MAX(d.curve_id1) [Index 1],
			dbo.FNARemoveTrailingZeroes(MAX(d.fixed_cost1)) [Fixed Cost 1],
			dbo.FNARemoveTrailingZeroes(ROUND(MAX(d.price_adder1),4)) [Adder 1],
			dbo.FNARemoveTrailingZeroes(CAST(MAX(d.price_multiplier1) AS VARCHAR)) [Multiplier 1],
			CAST(ROUND(MAX(d.deal_volume1), 4) AS VARCHAR) [Volume 1],
			dbo.FNARemoveTrailingZeroes(ROUND(MAX(d.sum_deal_volume1), 4)) [Total Volume 1],
			MAX(d.currency1) [Currency 1],
			MAX(d.frequency1) [Frequency 1],
			MAX(d.uom1) [UOM 1],			
			CASE MAX(d.buy_sell_flag2) WHEN ''b'' THEN ''Buy'' WHEN ''s'' THEN ''Sell'' END  [Buy Sell Flag 2],
			dbo.FNARemoveTrailingZeroes(MAX(d.fixed_price2)) [Fixed Price 2],
			dbo.FNARemoveTrailingZeroes(MAX(d.option_strike_price2)) [Option Strike Price 2],
			MAX(d.curve_id2) [Index 2],
			dbo.FNARemoveTrailingZeroes(MAX(d.fixed_cost2)) [Fixed Cost 2],
			dbo.FNARemoveTrailingZeroes(ROUND(MAX(d.price_adder2),4)) [Adder 2],
			dbo.FNARemoveTrailingZeroes(CAST(MAX(d.price_multiplier2) AS VARCHAR)) [Multiplier 2],
			CAST(ROUND(MAX(d.deal_volume2),4) AS VARCHAR) [Volume 2],
			dbo.FNARemoveTrailingZeroes(CAST(ROUND(CAST(MAX(d.sum_deal_volume2) AS NUMERIC(38,20)), 4) AS VARCHAR)) [Total Volume 2],
			MAX(d.currency2) [Currency 2],
			MAX(d.frequency2) [Frequency 2],
			MAX(d.uom2) [UOM 2],
			ISNULL(scp1.counterparty_name, '''') [Broker],
			CASE sdh.header_buy_sell_flag WHEN ''b'' THEN ''Buy'' WHEN ''s'' THEN ''Sell'' END  [Buy Sell Flag Header],
			CASE WHEN MAX(sdh.physical_financial_flag) = ''p'' THEN ''Physical''
				ELSE ''Financial'' END [Phy/Fin Header]
			' 
        		
        	SET @sql_Select2 = ' FROM 
		source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
		INNER JOIN #deals d ON d.deal_id = sdh.source_deal_header_id
		INNER JOIN source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3 
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
		INNER JOIN dbo.portfolio_hierarchy ph ON ph.entity_id=ssbm.fas_book_id
		LEFT JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id 			
		LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id=spcd.risk_bucket_id 
		LEFT JOIN dbo.source_counterparty  scp ON sdh.counterparty_id = scp.source_counterparty_id
		LEFT JOIN dbo.source_counterparty  scp1 ON sdh.broker_id = scp1.source_counterparty_id
		LEFT JOIN dbo.source_traders st ON st.source_trader_id=sdh.trader_id
		LEFT JOIN dbo.source_deal_type sdt ON sdt.source_deal_type_id=sdh.source_deal_type_id
		LEFT JOIN source_commodity sc ON sc.source_commodity_id=ISNULL(spcd.commodity_id,risk_spcd.commodity_id)
		LEFT JOIN source_deal_header_template sdht ON sdh.template_id=sdht.template_id
		LEFT JOIN source_currency scu ON scu.source_currency_id=sdd.fixed_price_currency_id
		LEFT JOIN dbo.source_uom su ON su.source_uom_id=sdd.deal_volume_uom_id
		LEFT JOIN dbo.static_data_value sdv ON sdv.value_id=sdh.block_define_id
		LEFT JOIN (SELECT DISTINCT block_value_id,holiday_value_id FROM dbo.hourly_block) hb ON hb.block_value_id =sdh.block_define_id
		LEFT JOIN dbo.static_data_value sdv1 ON sdv1.value_id =hb.holiday_value_id
		--LEFT JOIN confirm_status_recent csr ON csr.source_deal_header_id=sdh.source_deal_header_id
		LEFT JOIN application_users au ON au.user_f_name+'' ''+au.user_l_name=st.trader_name
		LEFT JOIN application_users au2 ON au2.user_login_id = sdh.verified_by
		LEFT JOIN application_users au3 ON au3.user_login_id = sdh.risk_sign_off_by
		LEFT JOIN application_users au4 ON au4.user_login_id = sdh.back_office_sign_off_by
		LEFT JOIN source_deal_detail sdd1 ON sdh.source_deal_header_id=sdd1.source_deal_header_id
			AND sdd.term_start=sdd1.term_start AND sdd1.leg=1
		LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id
		LEFT JOIN ' + @vol_frequency_table + ' vft ON vft.term_start=sdd.term_start
			AND vft.term_end=sdd.term_end
			AND ISNULL(vft.block_definition_id,-1)=COALESCE(spcd1.block_define_id,sdh.block_define_id,-1)
			AND ISNULL(vft.block_type,-1)=COALESCE(spcd1.block_type,sdh.block_type, -1)					
		GROUP BY st.trader_name ,sdh.deal_date,sdt.source_deal_type_name, sdh.header_buy_sell_flag,sdh.source_deal_type_id,sdh.option_type,
				sdh.verified_by,sdh.verified_date,sdh.risk_sign_off_date,sdh.back_office_sign_off_date,
				au2.user_f_name, au2.user_m_name, au2.user_l_name, 
				au3.user_f_name, au3.user_m_name, au3.user_l_name, 
				au4.user_f_name, au4.user_m_name, au4.user_l_name, 
				st.user_login_id, sdh.source_deal_header_id, scp1.counterparty_name'

	--PRINT @sql_select
	--PRINT @sql_select2
	EXEC (@sql_select + @sql_select2)
END
ELSE IF @flag = 't' OR @flag ='l'
BEGIN
	SET @sql_Select = '
		SELECT 			
			sdd.leg [Leg],
			CASE MAX(sdd.buy_sell_flag) WHEN ''b'' THEN ''Buy'' WHEN ''s'' THEN ''Sell'' END  [Buy Sell Flag],
			CASE WHEN MAX(sdd.physical_financial_flag) = ''p'' THEN ''Physical''
				ELSE ''Financial'' END [Phy/Fin],
			CAST(dbo.FNARemoveTrailingZeroes(AVG(sdd.fixed_price)) AS NUMERIC(32,4)) [Fixed Price],
			dbo.FNARemoveTrailingZeroes(MAX(sdd.option_strike_price)) [Option Strike Price],
			CASE WHEN max(sml.Location_Name) IS NULL THEN MAX(spcd.curve_id)
				WHEN  MAX(spcd.curve_id) IS NULL THEN max(sml.Location_Name)
				ELSE max(sml.Location_Name)+ '' / '' + MAX(spcd.curve_id) END [Location Name/Index],
			dbo.FNARemoveTrailingZeroes(MAX(sdd.fixed_cost)) [Fixed Cost],
			dbo.FNARemoveTrailingZeroes(ROUND(AVG(sdd.price_adder),4)) [Adder],
			MAX(sdd.price_multiplier) [Multiplier],
			CAST([dbo].[FNARemoveTrailingZeroes](AVG(sdd.deal_volume)) AS NUMERIC(32,2)) [Volume],
			CAST(CAST([dbo].[FNARemoveTrailingZeroes](SUM(sdd.total_volume)) AS MONEY) AS NUMERIC(32,2)) [Total Volume],			
			MAX(scu.currency_id) [Currency],
			MAX(sdd.deal_volume_frequency) [Frequency],
			MAX(uom.uom_id) [UOM],
			CASE WHEN MAX(sdd.formula_id) IS NOT NULL THEN ''Formula'' ELSE '''' END [Formula],
			CAST (dbo.FNADATEFORMAT(MIN(sdd.term_start)) AS VARCHAR(20)) + '' - '' + CAST (dbo.FNADATEFORMAT(MAX(sdd.term_end)) AS VARCHAR(20))[Term],
			MAX(spcd2.curve_name) [Indexed On],
           CAST(dbo.FNARemoveTrailingZeroes(AVG(sdd.fixed_price)) * CAST([dbo].[FNARemoveTrailingZeroes](SUM(sdd.total_volume)) AS MONEY) AS NUMERIC(32,2)) [Notional Value]
			' 
SET @sql_Select2 = ' FROM 
		source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
		INNER JOIN #sourceDealheader sd ON sd.source_deal_header_id=sdh.source_deal_header_id	
		--INNER JOIN #deals d ON d.deal_id = sdh.source_deal_header_id
		INNER JOIN source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3 
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
		LEFT JOIN dbo.portfolio_hierarchy ph ON ph.entity_id=ssbm.fas_book_id
		LEFT JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id 			
		LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id=spcd.risk_bucket_id 
		LEFT JOIN dbo.source_counterparty  scp ON sdh.counterparty_id = scp.source_counterparty_id
		LEFT JOIN dbo.source_counterparty  scp1 ON sdh.broker_id = scp1.source_counterparty_id
		LEFT JOIN dbo.source_traders st ON st.source_trader_id=sdh.trader_id
		LEFT JOIN dbo.source_deal_type sdt ON sdt.source_deal_type_id=sdh.source_deal_type_id
		LEFT JOIN source_commodity sc ON sc.source_commodity_id=ISNULL(spcd.commodity_id,risk_spcd.commodity_id)
		LEFT JOIN source_deal_header_template sdht ON sdh.template_id=sdht.template_id
		LEFT JOIN source_currency scu ON scu.source_currency_id=sdd.fixed_price_currency_id
		LEFT JOIN dbo.source_uom su ON su.source_uom_id=sdd.deal_volume_uom_id
		LEFT JOIN dbo.static_data_value sdv ON sdv.value_id=sdh.block_define_id
		LEFT JOIN (SELECT DISTINCT block_value_id,holiday_value_id FROM dbo.hourly_block) hb ON hb.block_value_id =sdh.block_define_id
		LEFT JOIN dbo.static_data_value sdv1 ON sdv1.value_id =hb.holiday_value_id
		--LEFT JOIN confirm_status_recent csr ON csr.source_deal_header_id=sdh.source_deal_header_id
		LEFT JOIN (SELECT DISTINCT source_deal_header_id, type, comment1 from confirm_status_recent) csr on csr.source_deal_header_id = sdh.source_deal_header_id and csr.type = sdh.confirm_status_type -- Added from SNWA
		LEFT JOIN application_users au ON au.user_f_name+'' ''+au.user_l_name=st.trader_name
		LEFT JOIN application_users au2 ON au2.user_login_id = sdh.verified_by
		LEFT JOIN application_users au3 ON au3.user_login_id = sdh.risk_sign_off_by
		LEFT JOIN application_users au4 ON au4.user_login_id = sdh.back_office_sign_off_by
		LEFT JOIN source_deal_detail sdd1 ON sdh.source_deal_header_id=sdd1.source_deal_header_id
			AND sdd.term_start=sdd1.term_start AND sdd1.leg=1
		LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id
		LEFT JOIN ' + @vol_frequency_table + ' vft ON vft.term_start=sdd.term_start
			AND vft.term_end=sdd.term_end
			AND ISNULL(vft.block_definition_id,-1)=COALESCE(spcd1.block_define_id,sdh.block_define_id,-1)
			AND ISNULL(vft.block_type,-1)=COALESCE(spcd1.block_type,sdh.block_type, -1)
		left join source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
		LEFT JOIN source_uom uom on uom.source_uom_id = sdd.deal_volume_uom_id
		LEFT JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id = sdd.formula_curve_id'
		
        IF @flag = 't' 	
		    SET @sql_Select2 += ' GROUP BY sdd.leg, sdh.source_deal_header_id,sdd.term_start ORDER BY sdd.leg asc'
		ELSE
            SET @sql_Select2 += ' GROUP BY sdd.leg, sdh.source_deal_header_id ORDER BY sdd.leg asc'

--	EXEC spa_print @sql_select
--	EXEC spa_print @sql_select2
	EXEC (@sql_select + @sql_select2)
END 

ELSE IF @flag = 'c'
BEGIN
	SELECT sdh.source_deal_header_id [source_deal_header_id],
	CASE WHEN MAX(crt.[filename]) IS NULL THEN (SELECT [filename] FROM Contract_report_template WHERE template_type = 33 AND template_category = 42019 AND [default] = 1 ANd [document_type] = 'r')
		ELSE REPLACE(MAX(crt.[filename]), '.rdl', '') END [template_filename]
	FROM source_deal_header sdh
	INNER JOIN #sourceDealheader sd ON sd.source_deal_header_id=sdh.source_deal_header_id
	LEFT JOIN source_deal_header_template sdht ON sdh.template_id=sdht.template_id
	LEFT JOIN Contract_report_template crt ON crt.template_id = sdht.trade_ticket_template_id
	GROUP BY sdh.source_deal_header_id
	ORDER BY  sdh.source_deal_header_id DESC
	
END	
----LADWP Trade Ticket Specific
IF @flag = 'b'
BEGIN
	SET @sql_Select = '
		SELECT 
			dbo.FNAConvertTZAwareDateFormat(GETDATE(),0)[Date],
			st.trader_name Trader,
			dbo.FNADateFormat(sdh.deal_date) [Trade Date],
			sdt.source_deal_type_name [Trade Type],				
			MAX(sc.commodity_name) [Commodity], 
			dbo.FNADateFormat(MIN(sdd.term_start)) [Start Date], 
			dbo.FNADateFormat(MAX(sdd.term_end)) [End Date],
			CAST(MAX(dbo.[FNAAddThousandSeparator](ROUND(sdd.deal_volume, 4))) AS VARCHAR)+'' '' + MAX(su.uom_name) + '' per ''+ 
			CASE MAX(sdd.deal_volume_frequency)
				WHEN ''h'' THEN ''HOUR''
				WHEN ''d'' THEN ''DAY''
				WHEN ''w'' THEN ''WEEK''
				WHEN ''m'' THEN ''MONTH''
				WHEN ''q'' THEN ''Quarter''
				WHEN ''s'' THEN ''Semi-annual''
				WHEN ''a'' THEN ''Annual''
			END [Quantity],
			dbo.[FNAAddThousandSeparator](SUM(sdd.deal_volume*
				CASE WHEN vft.Volume_Mult IS NOT NULL THEN vft.Volume_Mult 
					ELSE
					CASE  sdd.deal_volume_frequency
						WHEN ''h'' THEN  
							CASE  sdht.term_frequency_type
								WHEN ''h'' THEN  1
								WHEN ''d'' THEN 24
								WHEN ''w'' THEN 24*7
								WHEN ''m'' THEN 24*30
								WHEN ''q'' THEN 24*30*3
								WHEN ''s'' THEN 24*30*6
								WHEN ''a'' THEN 24*30*12
							END 
						WHEN ''d'' THEN 
							CASE sdht.term_frequency_type
								WHEN ''d'' THEN 1
								WHEN ''w'' THEN 7
								WHEN ''m'' THEN 30
								WHEN ''q'' THEN 30*3
								WHEN ''s'' THEN 30*6
								WHEN ''a'' THEN 30*12
							END 
						WHEN ''w'' THEN
							CASE  sdht.term_frequency_type
								WHEN ''d'' THEN 1/7
								WHEN ''w'' THEN 1
								WHEN ''m'' THEN 30/7
								WHEN ''q'' THEN (30*3)/7
								WHEN ''s'' THEN (30*6)/7
								WHEN ''a'' THEN (30*12)/7
							END 
						WHEN ''m'' THEN 
							CASE  sdht.term_frequency_type
								WHEN ''d'' THEN 1/30
								WHEN ''w'' THEN 7/30
								WHEN ''m'' THEN 1
								WHEN ''q'' THEN 3
								WHEN ''s'' THEN 6
								WHEN ''a'' THEN 12
							END 
						WHEN ''q'' THEN 
							CASE  sdht.term_frequency_type
								WHEN ''d'' THEN 1/90
								WHEN ''w'' THEN 7/90
								WHEN ''m'' THEN 30/90
								WHEN ''q'' THEN 1
								WHEN ''s'' THEN 2
								WHEN ''a'' THEN 4
							END 
						WHEN ''s'' THEN 
							CASE sdht.term_frequency_type
								WHEN ''d'' THEN 1/180
								WHEN ''w'' THEN 7/180
								WHEN ''m'' THEN 30/180
								WHEN ''q'' THEN (30*3)/180
								WHEN ''s'' THEN 1
								WHEN ''a'' THEN 2
							END 
						WHEN ''a'' THEN 
							CASE  sdht.term_frequency_type
								WHEN ''d'' THEN 1/365
								WHEN ''w'' THEN 7/365
								WHEN ''m'' THEN 30/365
								WHEN ''q'' THEN (30*3)/365
								WHEN ''s'' THEN (30*6)/365
								WHEN ''a'' THEN 1
							END 
					END
			END)) + '' ''+ MAX(su.uom_name) [Total Quantity],
			ISNULL(MAX(spcd.curve_name),MAX(risk_spcd.curve_name)) AS [Price Index],
			CAST(MAX(dbo.[FNARemoveTrailingZeroes](sdd.fixed_price)) AS VARCHAR) +'' ''+MAX(scu.currency_name) + '' / ''+ MAX(su.uom_name) [Fixed Price],
			MAX(sdh.deal_id) [External Trade ID],
			MAX(ph.entity_name) [Book],
			MAX(sdd.deal_detail_description) [Comments],
			ISNULL(MAX(scp.counterparty_name),'''') counterparty_name,
			MAX(cc.telephone) [TraderPhone],
			MAX(cc.fax) [TraderFax],
			MAX(cc.email) [TraderEmail],
			MAX(sdh.source_deal_header_id) [System Trade ID],
			CAST(MAX(ISNULL(au1.user_f_name,'''') + '' '' + ISNULL(au1.user_l_name, '''')) AS VARCHAR) [Input By],
			dbo.FNADateFormat(MAX(sdh.option_settlement_date)) [Premium Settlement DATE],
			CAST(MAX(sdd.option_strike_price) AS NUMERIC(20,2)) [Strike Price],
			CASE WHEN sdh.source_deal_type_id=3 then CAST(ROUND(CAST(AVG((( ISNULL(sdd.fixed_price, 0) + ISNULL(sdd.price_adder, 0)) * ISNULL(sdd.price_multiplier, 1)))AS NUMERIC(20,2)),3) AS VARCHAR)+'' '' else '''' end [Premium],
			CASE WHEN sdh.source_deal_type_id=3 then dbo.FNAAddThousandSeparator(ROUND((SUM(((ISNULL(sdd.fixed_price, 0) +  ISNULL(sdd.price_adder, 0)) * ISNULL(sdd.price_multiplier, 1))* ISNULL(vft.Volume_Mult,1)*sdd.deal_volume)),3))+'' ''+MAX(scu.currency_name) else '''' end [TotalPremium],
			dbo.FNADateFormat(MAX(sdh.create_ts)) [Input Date],
			au2.user_l_name + '', '' + au2.user_f_name + '' '' + ISNULL(au2.user_m_name,'''')   [Verified By Name],
			sdh.verified_date [Verified Date],
			au3.user_l_name + '', '' + au3.user_f_name + '' '' + ISNULL(au3.user_m_name,'''')   [Risk Sign Off By Name],
			sdh.risk_sign_off_date [Risk Sign Off Date],
			au4.user_l_name + '', '' + au4.user_f_name + '' '' + ISNULL(au4.user_m_name,'''')   [Back Office Sign Off By Name],
			sdh.back_office_sign_off_date [Back Office Sign Off Date],
			CASE MAX(d.buy_sell_flag1) WHEN ''b'' THEN ''Buy'' WHEN ''s'' THEN ''Sell'' END  [Buy Sell Flag 1],
			dbo.FNARemoveTrailingZeroes(MAX(d.fixed_price1)) [Fixed Price 1],
			dbo.FNARemoveTrailingZeroes(MAX(d.option_strike_price1)) [Option Strike Price 1],
			MAX(d.curve_id1) [Index 1],
			dbo.FNARemoveTrailingZeroes(MAX(d.fixed_cost1)) [Fixed Cost 1],
			dbo.FNARemoveTrailingZeroes(ROUND(MAX(d.price_adder1),4)) [Adder 1],
			dbo.FNARemoveTrailingZeroes(CAST(MAX(d.price_multiplier1) AS VARCHAR)) [Multiplier 1],
			CAST(ROUND(MAX(d.deal_volume1), 4) AS VARCHAR) [Volume 1],
			dbo.FNARemoveTrailingZeroes(ROUND(MAX(d.sum_deal_volume1), 4)) [Total Volume 1],
			MAX(d.currency1) [Currency 1],
			MAX(d.frequency1) [Frequency 1],
			MAX(d.uom1) [UOM 1],			
			CASE MAX(d.buy_sell_flag2) WHEN ''b'' THEN ''Buy'' WHEN ''s'' THEN ''Sell'' END  [Buy Sell Flag 2],
			dbo.FNARemoveTrailingZeroes(MAX(d.fixed_price2)) [Fixed Price 2],
			dbo.FNARemoveTrailingZeroes(MAX(d.option_strike_price2)) [Option Strike Price 2],
			MAX(d.curve_id2) [Index 2],
			dbo.FNARemoveTrailingZeroes(MAX(d.fixed_cost2)) [Fixed Cost 2],
			dbo.FNARemoveTrailingZeroes(ROUND(MAX(d.price_adder2),4)) [Adder 2],
			dbo.FNARemoveTrailingZeroes(CAST(MAX(d.price_multiplier2) AS VARCHAR)) [Multiplier 2],
			CAST(ROUND(MAX(d.deal_volume2),4) AS VARCHAR) [Volume 2],
			dbo.FNARemoveTrailingZeroes(CAST(ROUND(CAST(MAX(d.sum_deal_volume2) AS NUMERIC(38,20)), 4) AS VARCHAR)) [Total Volume 2],
			MAX(d.currency2) [Currency 2],
			MAX(d.frequency2) [Frequency 2],
			MAX(d.uom2) [UOM 2],
			ISNULL(scp1.counterparty_name, '''') [Broker]
			,CASE WHEN MAX(sdh.header_buy_sell_flag) = ''b'' THEN ''Buy'' ELSE ''Sell'' end [header_buy_sell_flag] 
        	, ''1st day of the month'' [Pricing Dates]	
        	, CASE  MAX(sdht.term_frequency_type)
				WHEN ''d'' then ''Daily''
				WHEN ''w'' then ''Weekly''
				WHEN ''m'' then ''Monthly''
				WHEN ''q'' then ''Quarterly''
				WHEN ''s'' then ''Semi-Annualy''
				WHEN ''a'' then ''Annualy''
				END [Payment Frequency]
			, CASE WHEN sdt.source_deal_type_name=''Fixed Physical Forward'' THEN ''T+25'' ELSE ''T+5'' END [Settle Rules]
			, ISNULL(MAX(sdv1.code),MAX(sdv.code)) [Holiday Calendar]
			'
SET @sql_Select2 = ' FROM 
		source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
		INNER JOIN #deals d ON d.deal_id = sdh.source_deal_header_id
		INNER JOIN source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3 
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
		INNER JOIN dbo.portfolio_hierarchy ph ON ph.entity_id=ssbm.fas_book_id
		LEFT JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id 			
		LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id=spcd.risk_bucket_id 
		LEFT JOIN dbo.source_counterparty  scp ON sdh.counterparty_id = scp.source_counterparty_id
		LEFT JOIN dbo.source_counterparty  scp1 ON sdh.broker_id = scp1.source_counterparty_id
		LEFT JOIN dbo.counterparty_contacts cc ON cc.counterparty_id = scp.source_counterparty_id and cc.contact_type = -32200
		LEFT JOIN dbo.source_traders st ON st.source_trader_id=sdh.trader_id
		LEFT JOIN dbo.source_deal_type sdt ON sdt.source_deal_type_id=sdh.source_deal_type_id
		LEFT JOIN source_commodity sc ON sc.source_commodity_id=ISNULL(spcd.commodity_id,risk_spcd.commodity_id)
		LEFT JOIN source_deal_header_template sdht ON sdh.template_id=sdht.template_id
		LEFT JOIN source_currency scu ON scu.source_currency_id=sdd.fixed_price_currency_id
		LEFT JOIN dbo.source_uom su ON su.source_uom_id=sdd.deal_volume_uom_id
		LEFT JOIN dbo.static_data_value sdv ON sdv.value_id=sdh.block_define_id
		LEFT JOIN (SELECT DISTINCT block_value_id,holiday_value_id FROM dbo.hourly_block) hb ON hb.block_value_id =sdh.block_define_id
		LEFT JOIN dbo.static_data_value sdv1 ON sdv1.value_id =hb.holiday_value_id
		--LEFT JOIN confirm_status_recent csr ON csr.source_deal_header_id=sdh.source_deal_header_id
		LEFT JOIN application_users au ON au.user_f_name+'' ''+au.user_l_name=st.trader_name
		LEFT JOIN application_users au1 ON au1.user_login_id = sdh.create_user
		LEFT JOIN application_users au2 ON au2.user_login_id = sdh.verified_by
		LEFT JOIN application_users au3 ON au3.user_login_id = sdh.risk_sign_off_by
		LEFT JOIN application_users au4 ON au4.user_login_id = sdh.back_office_sign_off_by
		LEFT JOIN source_deal_detail sdd1 ON sdh.source_deal_header_id=sdd1.source_deal_header_id
			AND sdd.term_start=sdd1.term_start AND sdd1.leg=1
		LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id
		LEFT JOIN ' + @vol_frequency_table + ' vft ON vft.term_start=sdd.term_start
			AND vft.term_end=sdd.term_end
			AND ISNULL(vft.block_definition_id,-1)=COALESCE(spcd1.block_define_id,sdh.block_define_id,-1)
			AND ISNULL(vft.block_type,-1)=COALESCE(spcd1.block_type,sdh.block_type, -1)	
		WHERE sdd.leg = 1				
		GROUP BY st.trader_name ,sdh.deal_date,sdt.source_deal_type_name, sdh.header_buy_sell_flag,sdh.source_deal_type_id,sdh.option_type,
				sdh.verified_by,sdh.verified_date,sdh.risk_sign_off_date,sdh.back_office_sign_off_date,
				au2.user_f_name, au2.user_m_name, au2.user_l_name, 
				au3.user_f_name, au3.user_m_name, au3.user_l_name, 
				au4.user_f_name, au4.user_m_name, au4.user_l_name, 
				st.user_login_id, sdh.source_deal_header_id, scp1.counterparty_name'

	--PRINT @sql_select
	--PRINT @sql_select2
	EXEC (@sql_select + @sql_select2)
END
	




	



