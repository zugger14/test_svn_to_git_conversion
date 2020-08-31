
/****** Object:  StoredProcedure [dbo].[spa_Create_Options_Report]    Script Date: 10/08/2009 13:37:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Create_Options_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_Options_Report]
/****** Object:  StoredProcedure [dbo].[spa_Create_Options_Report]    Script Date: 10/08/2009 13:37:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----===========================================================================================
-- exec spa_Create_Options_Report 'e', 'd', '2009-01-31', '193', '200', '216', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,1, '50000000000', NULL, '2', 'i',4500 
CREATE PROC [dbo].[spa_Create_Options_Report]
    @report_type CHAR(1),  --Show options expiration 'e' and Show options Greeks 'g'
    @summary_option VARCHAR(1) = 's',
    @as_of_date VARCHAR(50),
    @sub_entity_id VARCHAR(100) = NULL,
    @strategy_entity_id VARCHAR(100) = NULL,
    @book_entity_id VARCHAR(100) = NULL,
    @counterparty_id NVARCHAR(1000) = NULL,
    @tenor_from VARCHAR(50) = NULL,
    @tenor_to VARCHAR(50) = NULL,
    @trader_id INT = NULL,
    @source_system_book_id1 INT = NULL,
    @source_system_book_id2 INT = NULL,
    @source_system_book_id3 INT = NULL,
    @source_system_book_id4 INT = NULL,
    @deal_id_from VARCHAR(100) = NULL,
    @deal_id_to VARCHAR(100) = NULL,
    @deal_list_table VARCHAR(100) = NULL,
    @round INT = 4,
    @option_status VARCHAR(1) = NULL, -- 'i' In-the-money, 'o' Out-of-the-money, 'a' At-the-money, 'l' for all
    @curve_source_value_id INT = 4500,
    @transaction_type VARCHAR(100) = NULL,
    @batch_process_id VARCHAR(50) = NULL,
    @batch_report_param VARCHAR(1000) = NULL
AS ---------------------------------------------------------------
SET NOCOUNT ON 
---exec spa_Create_Options_Report 'g', 's', '2012-09-03', '311', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, '158184', '2', 'l',4500,NULL
/*
DECLARE	@report_type CHAR(1)='g',  --Show options expiration 'e' and Show options Greeks 'g'
    @summary_option VARCHAR(1) = 's',
    @as_of_date VARCHAR(50)='2012-09-03',
    @sub_entity_id VARCHAR(100) = '311',
    @strategy_entity_id VARCHAR(100) = NULL,
    @book_entity_id VARCHAR(100) = '275',
    @counterparty_id VARCHAR(500) = NULL,
    @tenor_from VARCHAR(50) = NULL,
    @tenor_to VARCHAR(50) = NULL,
    @trader_id INT = NULL,
    @source_system_book_id1 INT = NULL,
    @source_system_book_id2 INT = NULL,
    @source_system_book_id3 INT = NULL,
    @source_system_book_id4 INT = NULL,
    @deal_id_from VARCHAR(100) = NULL,
    @deal_id_to VARCHAR(100) = NULL,
    @deal_id VARCHAR(100) = '158184',
    @round INT = 4,
    @option_status VARCHAR(1) = 'l', -- 'i' In-the-money, 'o' Out-of-the-money, 'a' At-the-money, 'l' for all
    @curve_source_value_id INT = 4500,
    @transaction_type VARCHAR(100) = NULL,
        @batch_process_id VARCHAR(50) = NULL,
    @batch_report_param VARCHAR(1000) = NULL

    --exec spa_Create_Options_Report 'g', 'd', '2012-06-22', '264', NULL, '275', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, '2', 'l',4500,NULL
--SET @report_type = 'e'
--set @sub_entity_id = '5'
--SET @as_of_date = '2008-10-31'
--SET @round = 4
--SET @summary_option = 's'
--SET @option_status = null --'i'
--SET @curve_source_value_id = 4500
--
drop table #books
drop table #temp
drop table #deal
--*/
---------------------------------------------------------------

    DECLARE @Sql VARCHAR(8000)
    DECLARE @SqlG VARCHAR(500)
    DECLARE @SqlW VARCHAR(500)
    DECLARE @str_batch_table VARCHAR(max)
    SET @SqlW = ''
    DECLARE @Sql_SelectB VARCHAR(5000)        
    DECLARE @Sql_WhereB VARCHAR(5000)        
    DECLARE @assignment_type INT   
    DECLARE @round_s VARCHAR(10)     
    DECLARE @source_price_curve VARCHAR(100)
	DECLARE @process_id VARCHAR(50)
	DECLARE @user_login_id VARCHAR(50)

	CREATE TABLE #source_deal_header_id (source_deal_header_id INT)
	SET @str_batch_table=''        
	IF @batch_process_id is not null  
	BEGIN      
		SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)   
	END

	If OBJECT_ID(@deal_list_table) is not null
	BEGIN
		EXEC('INSERT INTO #source_deal_header_id  SELECT DISTINCT source_deal_header_id FROM '+@deal_list_table)
	END

	SET @user_login_id=dbo.FNADBUser()
	SET @process_id=REPLACE(newid(),'-','_')	


    IF @option_status = 'l' 
        SET @option_status = NULL

    SET @source_price_curve = dbo.FNAGetProcessTableName(@as_of_date,
                                                         'source_price_curve')
    SET @round_s = CAST(@round AS VARCHAR)

    SET @Sql_WhereB = ''        

    CREATE TABLE #books ( fas_book_id INT ) 

    SET @Sql_SelectB = '
		INSERT INTO  #books
		SELECT distinct book.entity_id fas_book_id FROM portfolio_hierarchy book (nolock) INNER JOIN
				Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
				source_system_book_map ssbm ON ssbm.fas_deal_type_value_id = book.entity_id         
		WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 
'   


    IF @deal_id_from IS NOT NULL
        OR @deal_id_to IS NOT NULL
        BEGIN
            SET @sub_entity_id = NULL
            SET @strategy_entity_id = NULL
            SET @book_entity_id = NULL
        END 
              
    IF @sub_entity_id IS NOT NULL 
        SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( '
            + @sub_entity_id + ') '         
    IF @strategy_entity_id IS NOT NULL 
        SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN('
            + @strategy_entity_id + ' ))'        
    IF @book_entity_id IS NOT NULL 
        SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN('
            + @book_entity_id + ')) '        

    SET @Sql_SelectB = @Sql_SelectB + @Sql_WhereB        
     
    EXEC spa_print @Sql_SelectB 
    EXEC ( @Sql_SelectB
        )

    IF @report_type = 'e'
        AND @summary_option = 'd' 
        SET @report_type = 'g'


    CREATE TABLE #deal
        (
          Sub VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Strategy VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Book VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Book1 VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Book2 VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Book3 VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Book4 VARCHAR(100) COLLATE DATABASE_DEFAULT,
          source_deal_header_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
          deal_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
          term_start DATETIME,
          expiration DATETIME,
          expiry_status VARCHAR(20) COLLATE DATABASE_DEFAULT,
          counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
          option_type VARCHAR(10) COLLATE DATABASE_DEFAULT,
          excercise_type VARCHAR(10) COLLATE DATABASE_DEFAULT,
          underlying_index VARCHAR(50) COLLATE DATABASE_DEFAULT,
          deal_volume FLOAT,
          deal_volume_frequency VARCHAR(50) COLLATE DATABASE_DEFAULT,
          uom_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
          strike_price FLOAT,
          curve_id INT,
          currency VARCHAR(50) COLLATE DATABASE_DEFAULT,
          curve_source_value_id INT,
          option_price FLOAT,
		  term_end DATETIME,
		  volume_frequency CHAR(1) COLLATE DATABASE_DEFAULT,
		  block_type INT NULL,
		  block_definition_id INT NULL,
		            deal_volume2 FLOAT
			,pay_opposite char(1) COLLATE DATABASE_DEFAULT,internal_deal_subtype_value_id int
        )


--select option_type,* from source_deal_header
--select top 1 * from source_Deal_detail
--select top 1 * from source_Deal_header where option_flag = 'y'
    SET @Sql = '
		INSERT INTO #deal
		select	max(fs.entity_name) Sub, max(st.entity_name) Strategy, max(bk.entity_name) Book,
				max(sb1.source_book_name) Book1, max(sb2.source_book_name) Book2, 
				max(sb3.source_book_name) Book3, max(sb4.source_book_name) Book4,
				sdh.source_deal_header_id, max(sdh.deal_id) deal_id, sdd.term_start, 
				max(sdd.contract_expiration_date) expiration,
				max(case when (''' + @as_of_date
				+ ''' >= sdd.contract_expiration_date) then ''Expired'' else ''Outstanding'' end) expiry_status,
				max(sc.counterparty_name) counterparty_name,  	
				max(case when (sdh.option_type = ''c'') then ''Call'' else ''Put'' end) option_type,  
				max(case when (sdh.option_excercise_type = ''e'') then ''European'' else ''American'' end) excercise_type, 
				max(spcd.curve_des) [underlying_index], 
				sum(case when (sdd.buy_sell_flag = ''s'') then -1 else 1 end *case when sdd.leg=1 then sdd.total_volume else 0 end ) deal_volume,
				--max(sdd.deal_volume) deal_volume, 
				case  max(sdh.term_frequency) when ''d'' then ''Daily'' when ''m'' then ''Monthly'' 	 when ''q'' then ''Quartely'' 
				 when ''y'' then ''Yearly'' 				 when ''w'' then ''Weekly'' end deal_volume_frequency, 
				max(su.uom_name) volume_uom,
				max(round(sdd.option_strike_price, ' + @round_s
				+ ')) strike_price, max(sdd.curve_id) curve_id,
				max(scur.currency_name) currency_name,
		max(' + CAST(@curve_source_value_id AS VARCHAR)
				+ ') curve_source_value_id,
				sum(case when (sdd.buy_sell_flag = ''s'') then -1 else 1 end * fixed_price) option_price,
				sdd.term_end,
				MAX(sdd.deal_volume_frequency) volume_frequency,
				MAX(sdh.block_type) block_type,
				MAX(sdh.block_define_id) block_definition_id	
				,sum(case when (sdd.buy_sell_flag = ''s'') then -1 else 1 end *case when sdd.leg=2 then sdd.total_volume else null end ) deal_volume2
				,max('+case when @summary_option='s' then 'case when sdd.leg=2 then null else sdd.pay_opposite end ' else '''n''' end +') pay_opposite
				,max(sdh.internal_deal_subtype_value_id	) internal_deal_subtype_value_id						
		from	#books b INNER JOIN
				source_system_book_map ssbm ON ssbm.fas_book_id = b.fas_book_id INNER JOIN
				source_deal_header sdh on sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
					sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND 
					sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
					sdh.source_system_book_id4 = ssbm.source_system_book_id4 INNER JOIN
				source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id INNER JOIN
				source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id INNER JOIN
				portfolio_hierarchy bk on bk.entity_id = ssbm.fas_book_id INNER JOIN 
				portfolio_hierarchy st on st.entity_id = bk.parent_entity_id INNER JOIN 
				portfolio_hierarchy fs on fs.entity_id = st.parent_entity_id LEFT OUTER JOIN
				source_book sb1 ON sb1.source_book_id = sdh.source_system_book_id1 LEFT OUTER JOIN
				source_book sb2 ON sb2.source_book_id = sdh.source_system_book_id2 LEFT OUTER JOIN
				source_book sb3 ON sb3.source_book_id = sdh.source_system_book_id3 LEFT OUTER JOIN
				source_book sb4 ON sb4.source_book_id = sdh.source_system_book_id4 LEFT OUTER JOIN
				source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id and sdd.leg=1 LEFT OUTER JOIN
				source_uom su ON su.source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id)  LEFT OUTER JOIN
				source_currency scur ON scur.source_currency_id = sdd.fixed_price_currency_id 
				' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #source_deal_header_id t ON sdh.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + '
		WHERE  sdh.option_flag = ''y'' AND sdd.term_start > ''' + @as_of_date + ''''
--select * from source_deal_pnl_detail_options
    IF @deal_id_from IS NOT NULL
        OR @deal_id_to IS NOT NULL
        BEGIN
	--If @deal_id_from IS NOT NULL OR @deal_id_to IS NULL 
            IF @deal_id_from IS NOT NULL
                AND @deal_id_to IS NULL 
                SET @deal_id_to = @deal_id_from 
--	If @deal_id_to IS NOT NULL OR  @deal_id_from IS NULL 
            IF @deal_id_to IS NOT NULL
                AND @deal_id_from IS NULL 
                SET @deal_id_from = @deal_id_to 

            IF @deal_id_from IS NOT NULL 
                SET @Sql = @Sql + ' AND sdh.source_deal_header_id  BETWEEN '
                    + @deal_id_from + ' AND ' + @deal_id_to
  --          IF @deal_list_table IS NOT NULL 
  ---- 	SET @Sql = @Sql + ' AND sdh.deal_id  = ''' + @deal_id_from + '''' 
  --              SET @Sql = @Sql + ' AND sdh.source_deal_header_id IN('
  --                  + @deal_list_table + ')' 
        END
    ELSE 
        BEGIN

            SET @Sql = @Sql + ' AND sdh.deal_date <= ''' + @as_of_date + ''''
            IF @trader_id IS NOT NULL 
                SET @Sql = @Sql + ' AND sdh.trader_id = '
                    + CAST(@trader_id AS VARCHAR)
            IF @counterparty_id IS NOT NULL 
                SET @Sql = @Sql + +' AND (sdh.counterparty_id IN ('
                    + @counterparty_id + ')) '
            IF @source_system_book_id1 IS NOT NULL 
                SET @Sql = @Sql + ' AND (sdh.source_system_book_id1 IN ('
                    + CAST(@source_system_book_id1 AS VARCHAR) + ')) '
            IF @source_system_book_id2 IS NOT NULL 
                SET @Sql = @Sql + ' AND (sdh.source_system_book_id2 IN ('
                    + CAST(@source_system_book_id2 AS VARCHAR) + ')) '
            IF @source_system_book_id3 IS NOT NULL 
                SET @Sql = @Sql + ' AND (sdh.source_system_book_id3 IN ('
                    + CAST(@source_system_book_id3 AS VARCHAR) + ')) '
            IF @source_system_book_id4 IS NOT NULL 
                SET @Sql = @Sql + ' AND (sdh.source_system_book_id4 IN ('
                    + CAST(@source_system_book_id4 AS VARCHAR) + ')) '

            IF ( @tenor_from IS NOT NULL ) 
                SET @Sql = @Sql
                    + ' AND convert(varchar(10),sdd.term_start,120)>='''
                    + CONVERT(VARCHAR(10), @tenor_from, 120) + ''''

            IF ( @tenor_to IS NOT NULL ) 
                SET @Sql = @Sql
                    + ' AND convert(varchar(10),sdd.term_start,120) <='''
                    + CONVERT(VARCHAR(10), @tenor_to, 120) + ''''

           
            IF ( @transaction_type IS NOT NULL ) 
                SET @Sql = @Sql + ' AND ssbm.fas_deal_type_value_id ='
                    + CAST(@transaction_type AS VARCHAR)

        END
    SET @Sql = @Sql + ' GROUP BY sdh.source_deal_header_id, sdd.term_start,sdd.term_end '

    EXEC spa_print @Sql
    EXEC ( @Sql  )
    
    

--####################################################
--Create a temporary table to SP "spa_get_dealvolume_mult_byfrequency". This SP will return volume multiplier based on frequency
--select * from #deal
DECLARE @vol_frequency_table VARCHAR(128)
SET @vol_frequency_table=dbo.FNAProcessTableName('deal_volume_frequency_mult', @user_login_id, @process_id)

	set @Sql='SELECT DISTINCT 
						term_start, 
						term_end,
						volume_frequency AS deal_volume_frequency,
						block_type,
						block_definition_id
				INTO '+@vol_frequency_table+'
				FROM
					#deal	
				WHERE 
					volume_frequency IN(''d'',''h'')'
	EXEC(@Sql)

	EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table


-----##################################################

    CREATE TABLE #temp
        (
          Sub VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Strategy VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Book VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Book1 VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Book2 VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Book3 VARCHAR(100) COLLATE DATABASE_DEFAULT,
          Book4 VARCHAR(100) COLLATE DATABASE_DEFAULT,
          source_deal_header_id INT,
          deal_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
          term_start DATETIME,
          expiration DATETIME,
          expiry_status VARCHAR(20) COLLATE DATABASE_DEFAULT,
          counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
          option_type VARCHAR(10) COLLATE DATABASE_DEFAULT,
          excercise_type VARCHAR(10) COLLATE DATABASE_DEFAULT,
          underlying_index VARCHAR(50) COLLATE DATABASE_DEFAULT,
          deal_volume FLOAT,
          deal_volume_frequency VARCHAR(50) COLLATE DATABASE_DEFAULT,
          uom_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
		  options_premium FLOAT,	
          strike_price FLOAT,
          curve_id INT,
          currency_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
          curve_source_value_id INT,
          option_price FLOAT,
          expiry_year FLOAT,
          annual_intrate FLOAT,
          annual_vol FLOAT,
          annual_vol_implied FLOAT,
          current_price FLOAT,
          option_status VARCHAR(50) COLLATE DATABASE_DEFAULT,
          premium FLOAT,
          --premium_actual FLOAT,
          delta FLOAT,
          --delta_actual FLOAT,
          delta2 FLOAT,
          --delta2_actual FLOAT,
          gamma FLOAT,
          --gamma_actual FLOAT,
          gamma2 FLOAT,
          --gamma2_actual FLOAT,
          vega FLOAT,
          --vega_actual FLOAT,
          vega2 FLOAT,
          --vega2_actual FLOAT,
          theta FLOAT,
          --theta_actual FLOAT,
          theta2 FLOAT,
          --theta2_actual FLOAT,
          rho FLOAT,
          --rho_actual FLOAT,
          rho2 FLOAT,
          --rho2_actual FLOAT,
		  deal_volume2 FLOAT

        )

    SET @Sql = '
		INSERT INTO #temp
		select	
			   sdh.Sub ,
			   sdh.Strategy ,
			   sdh.Book ,
			   sdh.Book1 ,
			   sdh.Book2 ,
			   sdh.Book3 ,
			   sdh.Book4 ,
			   sdh.source_deal_header_id,
			   sdh.deal_id,
			   sdh.term_start,
			   sdh.expiration ,
			   sdh.expiry_status ,
			   sdh.counterparty_name ,
			   sdh.option_type ,
			   sdh.excercise_type ,
			   sdh.underlying_index ,
			   -- sdh.deal_volume*ISNULL(vft.Volume_Mult,1) ,

			   sdh.deal_volume,
			   sdh.deal_volume_frequency ,
			   sdh.uom_name ,
			   round(sdo.option_premium, ' + @round_s + ')  [Options Premium],
			   round(sdo.strike_price, ' + @round_s + ') strike_price,
			   sdh.curve_id ,
			   sdh.currency ,
			   sdh.curve_source_value_id ,
			   sdh.option_price ,
				round(sdo.days_expiry, ' + @round_s + ') expiry_year, 
				round(sdo.discount_rate, ' + @round_s + ') annual_intrate, 
				round(sdo.volatility_1, ' + @round_s + ') annual_vol, 
				round(cvi.value, ' + @round_s + ') annual_vol_implied,
				sdo.spot_price_1 current_price, 
				case when (sp.curve_value is null) then ''Not Available'' 
					 when (round(sp.curve_value, ' + @round_s
				+ ') = round(sdh.strike_price, ' + @round_s
				+ ')) then ''At-the-money''
					 when (round(sp.curve_value, ' + @round_s
				+ ') > round(sdh.strike_price, ' + @round_s
				+ ')) then ''In-the-money''	
					 else ''Out-of-the-money''	
				end option_status,
				--round(sdo.premium, ' + @round_s + ')  Premium,
				sdo.premium Premium,
			  --round(sdo.delta ,' + @round_s + ') delta,
			  sdo.delta delta,
			  --round(sdo.delta2 ,' + @round_s + ') delta2,
			  sdo.delta2 delta2,
			  --round(sdo.gamma ,' + @round_s + ') gamma,
			  sdo.gamma gamma,
			  --round(sdo.gamma2 ,' + @round_s + ') gamma2,
			  sdo.gamma2 gamma2,
			  --round(sdo.vega ,' + @round_s + ') vega,
			  sdo.vega vega,
			  --round(sdo.vega2 ,' + @round_s + ') vega2,
			  sdo.vega2 vega2,
			  --round(sdo.theta ,' + @round_s + ') theta,
			  sdo.theta theta,
			  --round(sdo.theta2 ,' + @round_s + ')  theta2,
			  sdo.theta2 theta2,
			  --round(sdo.rho ,' + @round_s + ') rho,
			  sdo.rho rho,
			  --round(sdo.rho2 ,' + @round_s + ') rho2,
			  sdo.rho2 rho2,
			case when isnull(sdh.pay_opposite,''n'')=''y'' then -1 else 1 end* COALESCE (sdh_leg2.deal_volume2, sdh.deal_volume2, sdh.deal_volume) 
		from	(select * from #deal where not ( isnull(internal_deal_subtype_value_id,1)=101 and isnull(deal_volume2,0)<>0)) sdh -- all records except leg=2 of calendar spread
		
		 LEFT OUTER JOIN
				' + @source_price_curve
				+ ' sp on  sp.source_curve_def_id = sdh.curve_id and
								  sp.maturity_date = sdh.term_start and
								  sp.curve_source_value_id = sdh.curve_source_value_id AND
								  sp.as_of_date = '''+ @as_of_date	+ ''' 	LEFT OUTER JOIN	
				source_deal_pnl_detail_options sdo ON sdo.source_deal_header_id = sdh.source_deal_header_id AND
								sdo.pnl_source_value_id = sdh.curve_source_value_id  AND
								sdo.as_of_date = '''+ @as_of_date	+ ''' AND
								sdo.term_start = case when sdh.internal_deal_subtype_value_id=101 then sdo.term_start else sdh.term_start end
					LEFT OUTER JOIN	curve_volatility_imp cvi on cvi.curve_id = sdh.curve_id AND 
					cvi.as_of_date =''' + @as_of_date	+ ''' AND
					cvi.curve_source_value_id = sdh.curve_source_value_id AND cvi.term = sdh.term_start 
				LEFT OUTER JOIN  '+@vol_frequency_table+' vft ON
					vft.term_start=sdh.term_start AND
					vft.term_end=sdh.term_end AND
					vft.deal_volume_frequency=sdh.volume_frequency AND
					ISNULL(vft.block_type,-1)=ISNULL(sdh.block_type,-1) AND
					ISNULL(vft.block_definition_id,-1)=ISNULL(sdh.block_definition_id,-1)
	left join (select * from #deal where  (  isnull(internal_deal_subtype_value_id,1)=101 and isnull(deal_volume2,0)<>0)) sdh_leg2 -- all records of leg=2 of calendar spread only
	on sdh.source_deal_header_id=sdh_leg2.source_deal_header_id
		WHERE  (sdo.as_of_date IS NULL OR sdo.as_of_date = ''' + @as_of_date + ''') 
		' 
		+CASE WHEN @curve_source_value_id IS NOT NULL  THEN ' AND sdo.pnl_source_value_id ='+ CONVERT(VARCHAR, @curve_source_value_id) ELSE '' END

--select * from source_deal_pnl_detail_options
--print 'oooooooooooooooooooooooooooooooooooo'

    --print ( @Sql   )
    


    EXEC ( @Sql    )
--return
--select * from #temp




--@option_status
    IF @report_type = 'e' 
        BEGIN
			SET @Sql = '
            SELECT  Sub,
                    Strategy,
                    Book,
                    dbo.FNAHyperLinkText(10131010,
                                         CAST(source_deal_header_id AS VARCHAR),
                                         source_deal_header_id) DealID,
                    deal_id RefDealID,
                    dbo.FNADateFormat(term_start) Term,
                    dbo.FNADateFormat(expiration) Expiration,
                    expiry_status [Expiration Status],
                    counterparty_name Counterparty,
                    option_type [Option Type],
                    excercise_type [Excercise Type],
                    underlying_index [Underlying Index],
                    ROUND(deal_volume, ' + @round_s + ') Volume,
                    deal_volume_frequency Frequency,
                    uom_name UOM,
					ROUND(options_premium, ' + @round_s + ') [Options Premium],
                    ROUND(strike_price, ' + @round_s + ') Strike,
                    ROUND(current_price, ' + @round_s + ') [Current Price],
                    currency_name Currency,
                    option_status [Status]
                    '+  @str_batch_table +'
            FROM    #temp
            WHERE   SUBSTRING(option_status, 1, 1) = '+ CASE WHEN ( @option_status IS NULL )
                                                          THEN ' SUBSTRING(option_status, 1, 1) '
                                                          ELSE ''''+ @option_status +''''
                                                     END
                                                     +'
            ORDER BY Sub,
                    Strategy,
                    Book,
                    source_deal_header_id,
                    term_start
                    
			'
			--PRINT @Sql
			EXEC(@Sql) 
            --RETURN
        END

    IF @report_type = 'g' 
        BEGIN

	--########### Group Label
            DECLARE @group1 VARCHAR(100),
                @group2 VARCHAR(100),
                @group3 VARCHAR(100),
                @group4 VARCHAR(100)
            IF EXISTS ( SELECT  group1,
                                group2,
                                group3,
                                group4
                        FROM    source_book_mapping_clm ) 
                BEGIN	
                    SELECT  @group1 = group1,
                            @group2 = group2,
                            @group3 = group3,
                            @group4 = group4
                    FROM    source_book_mapping_clm
                    
                END
            ELSE 
                BEGIN
                    SET @group1 = 'Book1'
                    SET @group2 = 'Book2'
                    SET @group3 = 'Book3'
                    SET @group4 = 'Book4'
                    
                END
                
	--######## End






	--For summary multiple greeks by volume and add historical and implied vol
	--For detail add historical and implied vol
            IF @summary_option = 's' 
                BEGIN
--select * from #temp

					SET @sql = '
                    SELECT  Sub,
                            Strategy,
                            Book,
                            underlying_index [Underlying Index],
                            dbo.FNADateFormat(term_start) [Term],
                            dbo.FNADateFormat(expiration) Expiration,
                            ROUND(strike_price, ' + @round_s + ') Strike,
                            ROUND(MAX(annual_vol), ' + @round_s + ') [Annual Vol],
                            ROUND(MAX(annual_vol_implied), ' + @round_s + ') [Annual Imp Vol],
                            ROUND(SUM(deal_volume), ' + @round_s + ') Volume,
                            deal_volume_frequency Fequency,
                            uom_name UOM,
                            option_status [Status],
                            ROUND(MAX(option_price), ' + @round_s + ') [Premium Per Unit],
                            currency_name Currency,
                            ROUND(SUM(deal_volume * premium), ' + @round_s + ') [Premium Calc],
                     	  ROUND(sum(deal_volume * (delta)), ' + @round_s + ') Delta,
						  ROUND(sum(-1 * deal_volume2 * (delta2)), ' + @round_s + ') Delta2,
						  ROUND(sum(deal_volume * (gamma) ), ' + @round_s + ') Gamma,
						  ROUND(sum(-1 * deal_volume2 * (gamma2)), ' + @round_s + ') Gamma2,
						  ROUND(sum(deal_volume * (vega)), ' + @round_s + ') Vega,
						--sum(deal_volume2 * (vega2)) Vega2,
						  ROUND(sum(deal_volume * (theta)), ' + @round_s + ') Theta,
						  ROUND(sum(deal_volume * (rho)), ' + @round_s + ') Rho
                '+  @str_batch_table +'
                    FROM    #temp
                    WHERE   SUBSTRING(option_status, 1, 1) = ' + CASE WHEN ( @option_status IS NULL ) THEN ' SUBSTRING(option_status, 1, 1) '
                                                                  ELSE ''''+ @option_status + ''''     END        + '
                    GROUP BY Sub,
                            Strategy,
                            Book,
                            underlying_index,
                            term_start,
                            expiration,
                            strike_price,
                            deal_volume_frequency,
                            uom_name,
                            option_status,
                            currency_name
                    ORDER BY Sub,
                            Strategy,
                            Book,
                            underlying_index,
                            term_start,
                            expiration,
                            strike_price,
                            deal_volume_frequency,
                            uom_name,
                            option_status
                     '
             --       EXEC spa_print @Sql
					EXEC(@Sql)        
                END
            ELSE 
                IF @summary_option = 'd' 
                    BEGIN

                        SET @Sql = '
		select	Sub, Strategy, t.Book [Book],			 
			Book1 AS [' + @group1 + '], 
			Book2 AS [' + @group2 + '], 
			Book3 AS [' + @group3 + '], 
			Book4 AS [' + @group4 + '], 
			dbo.FNAHyperLinkText(10131010, cast(source_deal_header_id as varchar), source_deal_header_id) DealID,
			deal_id RefDealID, dbo.FNADateFormat(term_start) Term, dbo.FNADateFormat(expiration) Expiration,
			expiry_status [Expiration Status], counterparty_name Counterparty, option_type [Option Type],
			excercise_type [Excercise Type], underlying_index [Underlying Index], 
			ROUND(deal_volume, ' + @round_s + ') Volume,
			deal_volume_frequency Frequency, uom_name UOM, 
			ROUND(options_premium, ' + @round_s + ') [Options Premium],
			ROUND(strike_price, ' + @round_s + ') Strike, 
			ROUND(expiry_year, ' + @round_s + ') [Expiry in Year], 
			ROUND(annual_intrate, ' + @round_s + ') [Annual Int Rate],
			ROUND(annual_vol, ' + @round_s + ') [Annual Vol], 
			ROUND(annual_vol_implied, ' + @round_s + ') [Annual Imp Vol], 
			ROUND(current_price, ' + @round_s + ') [Current Price],  currency_name Currency,
			option_status [Status], 
			ROUND(premium, ' + @round_s + ') Premium,
			ROUND(delta, ' + @round_s + ') Delta, 
			ROUND(delta2, ' + @round_s + ') Delta2, 
			ROUND(gamma, ' + @round_s + ') Gamma,
			ROUND(gamma2, ' + @round_s + ') Gamma2,
			ROUND(vega, ' + @round_s + ') Vega,--vega2  Vega2,
			ROUND(theta, ' + @round_s + ') Theta,
			ROUND(rho, ' + @round_s + ') Rho		
			'+  @str_batch_table +'
		from  #temp t' 
			+ CASE WHEN ( @option_status IS NULL ) THEN '' ELSE ' WHERE substring(option_status,1 ,1) = ''' + @option_status + '''' END
		+ ' order by Sub, Strategy, t.Book, source_deal_header_id '
		
     --   EXEC spa_print @sql
        
        EXEC (@Sql)

                    END
                ELSE 
                    BEGIN
                        SET @Sql = '
								select	dbo.FNAHyperLinkText(10131010, cast(source_deal_header_id as varchar), source_deal_header_id) DealID,
										deal_id RefDealID, dbo.FNADateFormat(term_start) Term, dbo.FNADateFormat(expiration) Expiration,
										option_type [Option Type], 	excercise_type [Excercise Type], underlying_index [Underlying Index], 
										deal_volume Volume, deal_volume_frequency Frequency, uom_name UOM, strike_price Strike, 
										current_price [Current Price], currency_name Currency, 
										option_status [Status], premium Premium, 
										delta Delta,delta2 Delta2,gamma  Gamma,gamma2  Gamma2,vega Vega,--vega2  Vega2,
										theta  Theta,theta2   Theta2,rho  Rho,rho2  Rho2			
										'+  @str_batch_table +'
								from #temp ' + CASE WHEN ( @option_status IS NULL ) THEN ''
														ELSE ' WHERE substring(option_status,1 ,1) = '''
															 + @option_status + ''''
												   END
													+ ' order by Sub, Strategy, Book, source_deal_header_id '
													
					--		 exec spa_print  @sql               						
                        EXEC ( @sql               )
                    END

            --RETURN

        END

---------==============================

--*****************FOR BATCH PROCESSING**********************************    
     
    IF @batch_process_id IS NOT NULL 
        BEGIN        
            SELECT  @str_batch_table = dbo.FNABatchProcess('u',
                                                           @batch_process_id,
                                                           @batch_report_param,
                                                           GETDATE(), NULL,
                                                           NULL)         
            EXEC (@str_batch_table)        
            DECLARE @report_name VARCHAR(100)        

           	If @report_type='g'
				SET @report_name = 'Run Options Greeks Report'
			else
				SET @report_name = 'Run Options Report'        
			        
            SELECT  @str_batch_table = dbo.FNABatchProcess('c',
                                                           @batch_process_id,
                                                           @batch_report_param,
                                                           GETDATE(),
                                                           'spa_Create_Options_Report',
            
                                                           @report_name)         
            EXEC ( @str_batch_table
                )        
			        
        END        
--********************************************************************   
