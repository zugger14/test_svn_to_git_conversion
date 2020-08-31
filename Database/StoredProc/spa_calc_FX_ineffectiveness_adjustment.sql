

--/*
IF OBJECT_ID(N'[dbo].[spa_calc_FX_ineffectiveness_adjustment]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_calc_FX_ineffectiveness_adjustment]
GO

CREATE PROC [dbo].[spa_calc_FX_ineffectiveness_adjustment]          
	@flag CHAR(1),	--i for insert s for select
	@as_of_date VARCHAR(10) = '2012-12-31',
	@sub_entity_id VARCHAR(100) = NULL,
	@strategy_entity_id VARCHAR(100) = NULL,
	@book_entity_id VARCHAR(100) = NULL, 
	@deal_from INT = NULL ,
	@deal_to INT = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL
	
AS

/* test case start */

/*
--spa_calc_FX_ineffectiveness_adjustment 's', '2013-3-22', NULL, NULL, NULL, -1,-1   
--spa_calc_FX_ineffectiveness_adjustment 'd', '2013-3-22', NULL, NULL, NULL, -1,-1
--spa_calc_FX_ineffectiveness_adjustment 'm', '2013-3-22', NULL, NULL, NULL, -1,-1

DECLARE @flag CHAR(1),	--i for insert s for select
		@as_of_date VARCHAR(10) ,
		@sub_entity_id VARCHAR(100),
		@strategy_entity_id VARCHAR(100),
		@book_entity_id VARCHAR(100), 
		@deal_from INT,
		@deal_to INT
		
SET @flag = 'i'
SET @as_of_date = '2013-3-31'
SET @deal_from = 1354212
SET @deal_to = 1354212		

IF OBJECT_ID('tempdb..#books') IS NOT NULL
    DROP TABLE #books

IF OBJECT_ID('tempdb..#sdh_leg_1') IS NOT NULL
    DROP TABLE #sdh_leg_1

IF OBJECT_ID('tempdb..#sdh_leg_2') IS NOT NULL
    DROP TABLE #sdh_leg_2
    */
/* test case end */ 

CREATE TABLE #sdh_leg_1(link_id INT,
						term_start DATETIME,
						hedge_or_item CHAR(1) COLLATE DATABASE_DEFAULT  ,
						deal_volume NUMERIC(38, 10), 
						fixed_price NUMERIC(38, 10),
						leg INT,
						fixed_price_currency_id INT,
						func_currency_id INT,
						effective_date DATETIME, 
						link_effective_date DATETIME,
						percentage_used FLOAT,
						deal_volume_uom_id INT, 
						term_end DATETIME,
						source_deal_header_id INT,
						buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT  )


CREATE TABLE #sdh_leg_2(link_id INT,
						term_start DATETIME,
						hedge_or_item CHAR(1) COLLATE DATABASE_DEFAULT  ,
						deal_volume NUMERIC(38, 10), 
						fixed_price NUMERIC(38, 10),
						leg INT,
						fixed_price_currency_id INT,
						func_currency_id INT,
						effective_date DATETIME, 
						link_effective_date DATETIME,
						buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT  )
								

--Step # 1 - COLLECT BOOKS TO PROCESS


DECLARE @link_deal_term_used_per VARCHAR(250)
DECLARE @user_login_id VARCHAR(30) = dbo.FNAdbuser()
DECLARE @process_id VARCHAR(250) = dbo.FNAGetNewID()
DECLARE @sql VARCHAR(MAX) 
DECLARE @Sql_SelectB VARCHAR(MAX)        
DECLARE @Sql_WhereB VARCHAR(5000)        
DECLARE @assignment_type INT  

EXEC spa_print 'Step1 - COLLECT BOOKS TO PROCESS'
CREATE TABLE #books (fas_book_id INT, func_currency_id INT)

SET @Sql_SelectB = 'INSERT INTO  #books
					SELECT distinct book.entity_id fas_book_id, ISNULL(fb.fun_cur_value_id, fs.func_cur_value_id) func_currency_id  
					FROM portfolio_hierarchy book (nolock) 
					INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id  
					INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id 
					INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = stra.parent_entity_id 
					LEFT OUTER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
					WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) '   

SET @Sql_WhereB = ''
     
IF @sub_entity_id IS NOT NULL        
	SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '         

IF @strategy_entity_id IS NOT NULL        
	SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        

IF @book_entity_id IS NOT NULL        
	SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN(' + @book_entity_id + ')) '        
  
SET @Sql_SelectB = @Sql_SelectB + @Sql_WhereB        
   
EXEC (@Sql_SelectB)   

--end of step #1

--Step #2 - COLLECT DICING DEALS

SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)
EXEC spa_print 'Process table'
EXEC spa_print @link_deal_term_used_per 
   
IF OBJECT_ID(@link_deal_term_used_per) IS NOT NULL
	EXEC('DROP TABLE ' + @link_deal_term_used_per)
      
EXEC dbo.spa_get_link_deal_term_used_per @as_of_date = @as_of_date
	, @link_ids = NULL
	, @header_deal_id =NULL
	, @term_start = NULL
    , @no_include_link_id = NULL
    , @output_type = 1
    , @include_gen_tranactions  = 'b'
    , @process_table = @link_deal_term_used_per

--end of step #2
/* collect links start*/
SET @sql = 'INSERT INTO #sdh_leg_1 (link_id,
										term_start,
										hedge_or_item,
										deal_volume, 
										fixed_price,
										leg,
										fixed_price_currency_id,
										func_currency_id,
										effective_date, 
										link_effective_date,
										percentage_used,
										deal_volume_uom_id, 
										term_end,
										source_deal_header_id,
										buy_sell_flag)
				SELECT fld.link_id,
					   sdd.term_start,
					   fld.hedge_or_item,
					   sdd.deal_volume, 
					   sdd.fixed_price,
					   sdd.leg,
					   sdd.fixed_price_currency_id,
					   b.func_currency_id,
					   fld.effective_date, 
					   flh.link_effective_date,
					   per.percentage_used,
					   sdd.deal_volume_uom_id,
					   sdd.term_end,
					   sdd.source_deal_header_id,
					   sdd.buy_sell_flag
				FROM   fas_link_header flh
				INNER JOIN #books b ON  b.fas_book_id = flh.fas_book_id
				INNER JOIN fas_link_detail fld ON  fld.link_id = flh.link_id
				INNER JOIN source_deal_detail sdd ON  sdd.source_deal_header_id = fld.source_deal_header_id
				INNER JOIN ' +  @link_deal_term_used_per + ' per ON  fld.link_id = per.link_id 
					AND fld.source_deal_header_id = per.source_deal_header_id
					AND per.term_start = sdd.term_start
					AND sdd.leg = 1 '
	
exec spa_print @sql
EXEC (@sql)

SET @sql = '
			INSERT INTO #sdh_leg_2 (link_id,
									term_start,
									hedge_or_item,
									deal_volume, 
									fixed_price,
									leg,
									fixed_price_currency_id,
									func_currency_id,
									effective_date, 
									link_effective_date,
									buy_sell_flag)
			SELECT fld.link_id,
						   sdd.term_start,
						   fld.hedge_or_item,
						   sdd.deal_volume, 
						   sdd.fixed_price,
						   sdd.leg,
						   sdd.fixed_price_currency_id,
						   b.func_currency_id,
						   fld.effective_date, 
						   flh.link_effective_date,
						   sdd.buy_sell_flag
					FROM   fas_link_header flh
					INNER JOIN #books b ON  b.fas_book_id = flh.fas_book_id
					INNER JOIN fas_link_detail fld ON  fld.link_id = flh.link_id
					INNER JOIN source_deal_detail sdd ON  sdd.source_deal_header_id = fld.source_deal_header_id
					INNER JOIN ' +  @link_deal_term_used_per + ' per ON  fld.link_id = per.link_id 
						AND fld.source_deal_header_id = per.source_deal_header_id
						AND per.term_start = sdd.term_start
						AND sdd.leg = 2 '

exec spa_print @sql
EXEC (@sql)
/* collect link end */	

IF ISNULL(@flag, 'i') = 'i'
EXEC spa_print @flag

IF @flag = 'i' OR @flag = 's'
BEGIN
	EXEC spa_print 'flag passed is '
	EXEC spa_print @flag
	--Step #3 - COLLECT DEALS AND LINKS THAT REQUIRE FX INEFFECTIVENESS CALCULATIONS
	
	
	IF @flag = 'i'
	SET @Sql_SelectB = '
						DELETE [dbo].[fx_correction_values] WHERE [as_of_date] = ''' + @as_of_date + '''

						INSERT INTO [dbo].[fx_correction_values]([as_of_date], [cor_link_id], [cor_term_start]
																, [cor_hedge_item], [u_correction_value], [d_correction_value] )
						
						SELECT	''' + @as_of_date + ''',
								sdhl1.link_id,
								sdhl1.term_start,
								sdhl1.hedge_or_item,
								SUM(CASE  WHEN (spc1c.curve_value IS NOT NULL AND spc1i.curve_value IS NOT NULL) 
									THEN (spc1c.curve_value - spc1i.curve_value) * 
										(CASE WHEN sdhl1.buy_sell_flag = ''s'' THEN -1 * sdhl1.deal_volume ELSE sdhl1.deal_volume END) 
										* (CASE WHEN sdhl2.fixed_price IS NOT NULL THEN sdhl2.fixed_price ELSE sdhl1.fixed_price END)
									ELSE (1 / NULLIF(spc1c.curve_value, 0) - 1 / NULLIF(spc1i.curve_value, 0)) * 
										(CASE WHEN sdhl1.buy_sell_flag = ''s'' THEN -1 * sdhl1.deal_volume else sdhl1.deal_volume END) 
										* (CASE WHEN sdhl2.fixed_price IS NOT NULL THEN sdhl2.fixed_price ELSE sdhl1.fixed_price END)
									END * ISNULL(sdhl1.percentage_used, 0)) u_correction_value,
								SUM(CASE  WHEN (spc1c.curve_value IS NOT NULL AND spc1i.curve_value IS NOT NULL) 
									THEN (spc1c.curve_value - spc1i.curve_value) * 
										(CASE WHEN sdhl1.buy_sell_flag = ''s'' THEN -1 * sdhl1.deal_volume ELSE sdhl1.deal_volume END) 
										* (CASE WHEN sdhl2.fixed_price IS NOT NULL THEN sdhl2.fixed_price ELSE sdhl1.fixed_price END)
									ELSE (1 / NULLIF(spc1c.curve_value, 0) - 1 / NULLIF(spc1i.curve_value, 0)) * 
										(CASE WHEN sdhl1.buy_sell_flag = ''s'' THEN -1 * sdhl1.deal_volume else sdhl1.deal_volume END) 
										* (CASE WHEN sdhl2.fixed_price IS NOT NULL THEN sdhl2.fixed_price ELSE sdhl1.fixed_price END)
									END * ISNULL(sdhl1.percentage_used, 0)) d_correction_value
									'	
	ELSE IF @flag = 's'
		SET @Sql_SelectB = '
						SELECT	(sdhl1.link_id) [Link ID]
								, sdhl1.hedge_or_item
								, sdhl1.source_deal_header_id
								, sdhl1.term_start
								, sdhl1.term_end
								, sdhl1.deal_volume
								, sdhl1.deal_volume_uom_id
								, sdhl1.fixed_price  
								, sdhl1.fixed_price_currency_id
								, ISNULL(sdhl1.effective_date, sdhl1.link_effective_date)  effective_date
								, (CASE  WHEN (spc1c.curve_value IS NOT NULL AND spc1i.curve_value IS NOT NULL) THEN (spc1c.curve_value - spc1i.curve_value) * sdhl1.deal_volume * (CASE WHEN sdhl2.fixed_price IS NOT NULL THEN sdhl2.fixed_price ELSE sdhl1.fixed_price END) * (CASE WHEN sdhl2.buy_sell_flag = ''s'' THEN -1 ELSE 1 END)
									ELSE (1 / NULLIF(spc1c.curve_value, 0) - 1 / NULLIF(spc1i.curve_value, 0)) 
									* sdhl1.deal_volume * (CASE WHEN sdhl2.fixed_price IS NOT NULL THEN sdhl2.fixed_price ELSE sdhl1.fixed_price END) 
									END * ISNULL(sdhl1.percentage_used, 0)) fx_ineff_adj_values
								, ISNULL(sdhl1.percentage_used ,0) percentage_used
								'	

	SET	@Sql_SelectB = @Sql_SelectB + ' 
						FROM #sdh_leg_1 sdhl1
						LEFT JOIN #sdh_leg_2 sdhl2 ON sdhl2.link_id = sdhl1.link_id
							AND sdhl2.term_start = sdhl1.term_start
							AND sdhl2.hedge_or_item = sdhl1.hedge_or_item 
						LEFT JOIN source_price_curve_def spcd ON spcd.source_currency_id = sdhl1.fixed_price_currency_id 
							AND spcd.source_currency_to_ID = sdhl1.func_currency_id 
							AND spcd.Granularity = 980 
						LEFT JOIN source_price_curve_def spcd2 ON spcd2.source_system_id = sdhl1.func_currency_id  
							AND spcd2.source_currency_id = sdhl1.func_currency_id 
							AND spcd2.source_currency_to_ID = sdhl1.fixed_price_currency_id	
							AND spcd2.Granularity = 980	
						LEFT JOIN
						--Get inception FX prices
						--***If prices archived this logic needs to get from archival table or we need to save this info somewhere
						' + dbo.FNAGetProcessTableName(@as_of_date,'source_price_curve') + ' spc1i ON spc1i.source_curve_def_id = spcd.source_curve_def_id 
							AND spc1i.as_of_date = ISNULL(sdhl1.effective_date, sdhl1.link_effective_date) 
							AND spc1i.maturity_date = sdhl1.term_start  	
						LEFT JOIN ' + dbo.FNAGetProcessTableName(@as_of_date,'source_price_curve') +' spc2i ON spc2i.source_curve_def_id = spcd2.source_curve_def_id 
							AND spc2i.as_of_date = ISNULL(sdhl1.effective_date, sdhl1.link_effective_date) 
							AND spc2i.maturity_date = sdhl1.term_start  
						LEFT JOIN
						--Get currentFX prices
						' + dbo.FNAGetProcessTableName(@as_of_date,'source_price_curve') + ' spc1c ON spc1c.source_curve_def_id = spcd.source_curve_def_id 
							AND spc1c.as_of_date = ''' + @as_of_date + ''' 
							AND spc1c.maturity_date = sdhl1.term_start  	
						LEFT JOIN ' + dbo.FNAGetProcessTableName(@as_of_date,'source_price_curve') + ' spc2c ON spc2c.source_curve_def_id = spcd2.source_curve_def_id 
							AND spc2c.as_of_date = ''' + @as_of_date + ''' 
							AND spc2c.maturity_date = sdhl1.term_start 				
						WHERE	1 = 1
							AND ISNULL(sdhl1.effective_date, sdhl1.link_effective_date) <= ''' + @as_of_date + ''' --only for effective dates
							--AND sdhl1.Leg = 1 
							AND sdhl1.term_start > ''' + @as_of_date + ''' --only for 1st leg and forward months
							AND sdhl1.fixed_price_currency_id <> sdhl1.func_currency_id -- only if deal price is not same as functional currency
							'
							
	IF @deal_from <> -1 AND @deal_to <> -1 
	BEGIN
		SET	@Sql_SelectB = @Sql_SelectB +	' AND sdhl1.source_deal_header_id BETWEEN ''' + CAST(@deal_from AS VARCHAR) + ''' AND ''' + CAST(@deal_to AS VARCHAR) + ''''
	END	
		
	SET	@Sql_SelectB = @Sql_SelectB + CASE WHEN ISNULL(@flag, 'i') = 'i' 
						THEN ' GROUP BY sdhl1.link_id, sdhl1.hedge_or_item,  sdhl1.term_start' 
						ELSE ' ORDER BY sdhl1.link_id, sdhl1.hedge_or_item, sdhl1.source_deal_header_id, sdhl1.term_start ' END

	exec spa_print @Sql_SelectB	
	EXEC(@Sql_SelectB)

	IF ISNULL(@flag,'i') = 'i'
		UPDATE [dbo].[fx_correction_values] SET [d_correction_value] = [u_correction_value] 
		WHERE [as_of_date] = @as_of_date 
			AND [d_correction_value] IS NULL
	--end of step #3	
END
	
--start flag 'd' for detialed FX Report
IF @flag='d' 
BEGIN
	EXEC spa_print 'Detailed FX Report'
	
    SET @Sql_SelectB = '
						SELECT	fxcv.as_of_date [As of Date], 
								sdhl1.link_id [Link ID],
								--sdh.deal_id [Ref ID],
								sdhl1.source_deal_header_id [Deal ID],  
								sdhl1.hedge_or_item [Hedge/Item], 
								sdhl1.term_start [Term Start],
								CASE WHEN sdhl2.leg = 2 THEN sdhl2.fixed_price ELSE  sdhl1.fixed_price END [Deal Price], 
								sdhl1.fixed_price_currency_id [Deal Currency], 
								sdhl1.deal_volume [Deal Volume], 
								spc1i.curve_value [FX Inception Price], 
								spc1c.curve_value [FX Current Price],				
								fxcv.u_correction_value [FX Ineff Adj Amount] '	

	SET	@Sql_SelectB = @Sql_SelectB +	
						'FROM #sdh_leg_1 sdhl1
						LEFT JOIN #sdh_leg_2 sdhl2 ON sdhl2.link_id = sdhl1.link_id
							AND sdhl2.term_start = sdhl1.term_start
							AND sdhl2.hedge_or_item = sdhl1.hedge_or_item 
						LEFT JOIN source_price_curve_def spcd ON spcd.source_currency_id = sdhl1.fixed_price_currency_id 
							AND spcd.source_currency_to_ID = sdhl1.func_currency_id 
							AND spcd.Granularity = 980 
						LEFT JOIN source_price_curve_def spcd2 ON spcd2.source_system_id = sdhl1.func_currency_id  
							AND spcd2.source_currency_id = sdhl1.func_currency_id 
							AND spcd2.source_currency_to_ID = sdhl1.fixed_price_currency_id	
							AND spcd2.Granularity = 980	
						LEFT JOIN
						--Get inception FX prices
						--***If prices archived this logic needs to get from archival table or we need to save this info somewhere
						' + dbo.FNAGetProcessTableName(@as_of_date,'source_price_curve') + ' spc1i ON spc1i.source_curve_def_id = spcd.source_curve_def_id 
							AND spc1i.as_of_date = ISNULL(sdhl1.effective_date, sdhl1.link_effective_date) 
							AND spc1i.maturity_date = sdhl1.term_start  	
						LEFT JOIN ' + dbo.FNAGetProcessTableName(@as_of_date,'source_price_curve') +' spc2i ON spc2i.source_curve_def_id = spcd2.source_curve_def_id 
							AND spc2i.as_of_date = ISNULL(sdhl1.effective_date, sdhl1.link_effective_date) 
							AND spc2i.maturity_date = sdhl1.term_start  
						LEFT JOIN
						--Get currentFX prices
						' + dbo.FNAGetProcessTableName(@as_of_date,'source_price_curve') + ' spc1c ON spc1c.source_curve_def_id = spcd.source_curve_def_id 
							AND spc1c.as_of_date = ''' + @as_of_date + ''' 
							AND spc1c.maturity_date = sdhl1.term_start  	
						LEFT JOIN ' + dbo.FNAGetProcessTableName(@as_of_date,'source_price_curve') + ' spc2c ON spc2c.source_curve_def_id = spcd2.source_curve_def_id 
							AND spc2c.as_of_date = ''' + @as_of_date + ''' 
							AND spc2c.maturity_date = sdhl1.term_start 
						INNER JOIN fx_correction_values fxcv on fxcv.cor_link_id = sdhl1.link_id 
							AND fxcv.cor_hedge_item=sdhl1.hedge_or_item 
							AND fxcv.cor_term_start=sdhl1.term_start
						WHERE	1 = 1 AND fxcv.as_of_date = ''' + @as_of_date + ''' '

	IF @deal_from <> -1 AND @deal_to <> -1 
	BEGIN
		SET	@Sql_SelectB = @Sql_SelectB +	' AND sdhl1.source_deal_header_id BETWEEN ''' + CAST(@deal_from AS VARCHAR) + ''' AND ''' + CAST(@deal_to AS VARCHAR) + ''''
	END
	IF @deal_from <> -1 AND @deal_to = -1 
	BEGIN
		SET	@Sql_SelectB = @Sql_SelectB +	' AND sdhl1.source_deal_header_id = ''' + CAST(@deal_from AS VARCHAR) + ''''
	END
	IF @deal_from = -1 AND @deal_to <> -1 
	BEGIN
		SET	@Sql_SelectB = @Sql_SelectB +	' AND sdhl1.source_deal_header_id = ''' + CAST(@deal_to AS VARCHAR) + ''''
	END
				
	SET	@Sql_SelectB = @Sql_SelectB + ' 
					AND ISNULL(sdhl1.effective_date, sdhl1.link_effective_date) <= ''' + @as_of_date + ''' --only for effective dates
				 --  --AND sdd.Leg = 1
					AND sdhl1.term_start > '''+ @as_of_date+''' --only for 1st leg and forward months
					AND sdhl1.fixed_price_currency_id <> sdhl1.func_currency_id -- only if deal price is not same as functional currency			
					ORDER BY fxcv.as_of_date,sdhl1.link_id, sdhl1.hedge_or_item, sdhl1.source_deal_header_id, sdhl1.term_start '

	exec spa_print @Sql_SelectB
	EXEC(@Sql_SelectB)       	
END
--end of flag 'd'

--start flag 'm' for summary FX Report
IF @flag = 'm' 
BEGIN
	EXEC spa_print 'Detail FX Report'
	EXEC spa_print '-----------------------------------------'
	
	SET @Sql_SelectB = ' SELECT	fxcv.as_of_date [As of Date], 
									fxcv.cor_link_id [Link ID], 
									fxcv.cor_hedge_item [Hedge/Item], 
									fxcv.cor_term_start [Term Start],
									fxcv.u_correction_value [FX Ineff Adj Amount] 			
						FROM	fas_link_header flh 
						INNER JOIN #books b ON b.fas_book_id = flh.fas_book_id 
						INNER JOIN fas_link_detail fld ON fld.link_id = flh.link_id 
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = fld.source_deal_header_id and sdd.leg=1 
						INNER JOIN	' + @link_deal_term_used_per + ' per on fld.link_id = per.link_id 
							AND fld.source_deal_header_id = per.source_deal_header_id 
							AND per.term_start = sdd.term_start
						INNER JOIN fx_correction_values fxcv on fxcv.cor_link_id=fld.link_id 
							AND fxcv.cor_hedge_item = fld.hedge_or_item 
							AND fxcv.cor_term_start = sdd.term_start									 				
                        WHERE 1 = 1 AND fxcv.as_of_date = ''' + @as_of_date + ''''

	IF @deal_from <> -1 AND @deal_to <> -1 
	BEGIN
		SET	@Sql_SelectB = @Sql_SelectB + ' AND sdd.source_deal_header_id between ''' + CAST(@deal_from AS VARCHAR) + ''' AND ''' + CAST(@deal_to AS VARCHAR) + ''''
	END
	IF @deal_from <> -1 AND @deal_to = -1 
	BEGIN
		SET	@Sql_SelectB = @Sql_SelectB +	' AND sdd.source_deal_header_id = ''' + CAST(@deal_from AS VARCHAR) + ''''
	END
	IF @deal_from = -1 AND @deal_to <> -1 
	BEGIN
		SET	@Sql_SelectB = @Sql_SelectB +	' AND sdd.source_deal_header_id = ''' + CAST(@deal_to AS VARCHAR) + ''''
	END 	
			
	SET	@Sql_SelectB = @Sql_SelectB + ' AND ISNULL(fld.effective_date, flh.link_effective_date) <= ''' + @as_of_date + ''' --only for effective dates
				   --AND sdd.Leg = 1 
					AND sdd.term_start > ''' + @as_of_date + ''' --only for 1st leg and forward months
					AND sdd.fixed_price_currency_id <> b.func_currency_id -- only if deal price is not same as functional currency			
					ORDER BY fxcv.as_of_date,fld.link_id, fld.hedge_or_item, sdd.term_start '
	exec spa_print @Sql_SelectB
	EXEC(@Sql_SelectB)       	
END

DECLARE @desc VARCHAR(MAX)

IF @flag NOT IN ('d', 'm')
BEGIN 
	SET @desc = 'FX Calculation has been completed for As of Date: ' + CAST(dbo.FNAUserDateFormat(@as_of_date,@user_login_id) AS VARCHAR(100)) + '.'
	EXEC spa_message_board 'i', @user_login_id,  NULL, 'FX Calculation', @desc, '', '', '',  '', NULL, @process_id, '', '', '', 'y'
END
GO

/*
SELECT	
sdhl1.effective_date, sdhl1.link_effective_date, spc1c.*, spc1i.*
--'2013-3-31',
--		sdhl1.link_id,
--		sdhl1.term_start,
--		sdhl1.hedge_or_item,
--		SUM(CASE  WHEN (spc1c.curve_value IS NOT NULL AND spc1i.curve_value IS NOT NULL) 
--			THEN (spc1c.curve_value - spc1i.curve_value) * 
--				(CASE WHEN sdhl1.buy_sell_flag = 's' THEN -1 * sdhl1.deal_volume ELSE sdhl1.deal_volume END) 
--				* (CASE WHEN sdhl2.fixed_price IS NOT NULL THEN sdhl2.fixed_price ELSE sdhl1.fixed_price END)
--			ELSE (1 / NULLIF(spc1c.curve_value, 0) - 1 / NULLIF(spc1i.curve_value, 0)) * 
--				(CASE WHEN sdhl1.buy_sell_flag = 's' THEN -1 * sdhl1.deal_volume else sdhl1.deal_volume END) 
--				* (CASE WHEN sdhl2.fixed_price IS NOT NULL THEN sdhl2.fixed_price ELSE sdhl1.fixed_price END)
--			END * ISNULL(sdhl1.percentage_used, 0)) u_correction_value,
--		SUM(CASE  WHEN (spc1c.curve_value IS NOT NULL AND spc1i.curve_value IS NOT NULL) 
--			THEN (spc1c.curve_value - spc1i.curve_value) * 
--				(CASE WHEN sdhl1.buy_sell_flag = 's' THEN -1 * sdhl1.deal_volume ELSE sdhl1.deal_volume END) 
--				* (CASE WHEN sdhl2.fixed_price IS NOT NULL THEN sdhl2.fixed_price ELSE sdhl1.fixed_price END)
--			ELSE (1 / NULLIF(spc1c.curve_value, 0) - 1 / NULLIF(spc1i.curve_value, 0)) * 
--				(CASE WHEN sdhl1.buy_sell_flag = 's' THEN -1 * sdhl1.deal_volume else sdhl1.deal_volume END) 
--				* (CASE WHEN sdhl2.fixed_price IS NOT NULL THEN sdhl2.fixed_price ELSE sdhl1.fixed_price END)
--			END * ISNULL(sdhl1.percentage_used, 0)) d_correction_value
			 
FROM #sdh_leg_1 sdhl1
LEFT JOIN #sdh_leg_2 sdhl2 ON sdhl2.link_id = sdhl1.link_id
	AND sdhl2.term_start = sdhl1.term_start
	AND sdhl2.hedge_or_item = sdhl1.hedge_or_item 
LEFT JOIN source_price_curve_def spcd ON spcd.source_currency_id = sdhl1.fixed_price_currency_id 
	AND spcd.source_currency_to_ID = sdhl1.func_currency_id 
	AND spcd.Granularity = 980 
LEFT JOIN source_price_curve_def spcd2 ON spcd2.source_system_id = sdhl1.func_currency_id  
	AND spcd2.source_currency_id = sdhl1.func_currency_id 
	AND spcd2.source_currency_to_ID = sdhl1.fixed_price_currency_id	
	AND spcd2.Granularity = 980	

LEFT JOIN
--Get inception FX prices
--***If prices archived this logic needs to get from archival table or we need to save this info somewhere
source_price_curve spc1i ON spc1i.source_curve_def_id = spcd.source_curve_def_id 
	AND spc1i.as_of_date = ISNULL(sdhl1.effective_date, sdhl1.link_effective_date) 
	AND spc1i.maturity_date = sdhl1.term_start  
		

	
LEFT JOIN
--Get currentFX prices
source_price_curve spc1c ON spc1c.source_curve_def_id = spcd.source_curve_def_id 
	AND spc1c.as_of_date = '2013-3-31' 
	AND spc1c.maturity_date = sdhl1.term_start  
		
LEFT JOIN source_price_curve spc2c ON spc2c.source_curve_def_id = spcd2.source_curve_def_id 
	AND spc2c.as_of_date = '2013-3-31' 
	AND spc2c.maturity_date = sdhl1.term_start 				
WHERE	1 = 1
	AND ISNULL(sdhl1.effective_date, sdhl1.link_effective_date) <= '2013-3-31' --only for effective dates
	--AND sdhl1.Leg = 1 
	AND sdhl1.term_start > '2013-3-31' --only for 1st leg and forward months
	AND sdhl1.fixed_price_currency_id <> sdhl1.func_currency_id -- only if deal price is not same as functional currency
	 AND sdhl1.source_deal_header_id BETWEEN '1354212' AND '1354212' 

--GROUP BY sdhl1.link_id, sdhl1.hedge_or_item,  sdhl1.term_start
 
SELECT  spc1i.as_of_date , sdhl1.effective_date,  
spc1i.maturity_date , sdhl1.term_start 
,  spc1i.*
 FROM  #sdh_leg_1 sdhl1 
LEFT JOIN source_price_curve_def spcd ON spcd.source_currency_id = sdhl1.fixed_price_currency_id 
	AND spcd.source_currency_to_ID = sdhl1.func_currency_id 
	AND spcd.Granularity = 980 
 LEFT JOIN
--Get inception FX prices
--***If prices archived this logic needs to get from archival table or we need to save this info somewhere
source_price_curve spc1i ON spc1i.source_curve_def_id = spcd.source_curve_def_id 
	--AND spc1i.as_of_date = ISNULL(sdhl1.effective_date, sdhl1.link_effective_date) 
	AND spc1i.maturity_date = sdhl1.term_start 
	 where sdhl1.source_deal_header_id BETWEEN '1354212' AND '1354212' 
	 
	 
SELECT * FROM   #sdh_leg_1 sdhl1 where sdhl1.source_deal_header_id BETWEEN '1354212' AND '1354212' 

* */
