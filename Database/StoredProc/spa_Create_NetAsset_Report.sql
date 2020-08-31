IF OBJECT_ID(N'spa_Create_NetAsset_Report', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Create_NetAsset_Report]
 GO 

--create PROC spa_Create_NetAsset_Report 
--exec spa_Create_NetAsset_Report '2007-09-07', '30,1', '215', '218', 'd', 'b', 's', 3
create PROC [dbo].[spa_Create_NetAsset_Report] @as_of_date varchar(50), @sub_entity_id varchar(100), 
 	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, @discount_option char(1), 
	@report_type char(1), 
	@summary_option char(1),
	@prior_months int = NULL
 AS
--
-- SET NOCOUNT ON


--drop table #temp_cash_flowb
--drop table #temp_fair_valueb1
--drop table #temp_mtmbb1
--drop table #temp_cash_flowb1
--drop table #temp_opts
--drop table #temp_table
--drop table #temp_t2
--drop table #temp_table1
--drop table #temp_fair_valueb
--drop table #temp_mtmbb
--drop table #temp_cash_flowb
--drop table #max_date

--Declare @as_of_date varchar(50)
--Declare @sub_entity_id varchar(100)
--Declare	@strategy_entity_id varchar(100)
--Declare	@book_entity_id varchar(100)
--Declare @discount_option char(1)
--Declare	@report_type char(1)
--Declare	@summary_option char(1)
--Declare	@prior_months int
--exec spa_Create_NetAsset_Report '2004-09-30', '20,1,30,71', NULL, NULL, 'd', 'a', 's', 1


--set @as_of_date='2004-09-30'
--set @sub_entity_id='20,1,30,71'
--set @discount_option='d'
--set @report_type='b'
--set @summary_option='s'
--set @prior_months=1


Declare @Sql_Select varchar(8000)
Declare @Sql_From varchar(8000)
Declare @Sql_Where varchar(8000)
Declare @Sql_GpBy varchar(8000)
Declare @Sql1 varchar(8000)
Declare @Sql2 varchar(8000)
Declare @Sql3 varchar(8000)
Declare @Sql4 varchar(8000)
Declare @Sql5 varchar(8000)
Declare @Sql6 varchar(8000)
Declare @Sql7 varchar(8000)
Declare @Sql8 varchar(8000)
Declare @Sql9 varchar(8000)
Declare @Sql10 varchar(8000)
Declare @beginning_date varchar(50)
Declare @temptable_name varchar(100)
		declare @st varchar(8000)
		declare @st1 varchar(8000)

if @prior_months is null
	set @prior_months = 1


if @beginning_date is null
begin
--		create table #max_date (as_of_date datetime)
--		declare @st_where varchar(100)
--		set @st_where ='as_of_date<='''+convert(varchar(10),dbo.FNALastDayInDate(dateadd(mm, -1 * @prior_months, @as_of_date)),120)+''''
--		insert into #max_date (as_of_date) exec  spa_get_Script_ProcessTableFunc 'max','as_of_date','report_measurement_values',@st_where
--		select @beginning_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from #max_date
--		select @beginning_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from 
--		report_measurement_values where as_of_date <= dbo.FNALastDayInDate(dateadd(mm, -1*@prior_months, @as_of_date))


		select @beginning_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from 
		measurement_run_dates where as_of_date <= dbo.FNALastDayInDate(dateadd(mm, -1*@prior_months, @as_of_date))

		IF @beginning_date IS NULL --OR @prior_months = 0
		SET @beginning_date= '1900-01-01'

end

IF @report_type='a'
	Begin
/*---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------FAIR VALUE------------------------------------------------------------
*/
	SET @Sql_Select = 'SELECT 1 AS NO,'  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id , ' END +
			'''Beginning net positions at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] , ' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'link_id , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'link_deal_flag , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'term_month , ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' ),0) AS [Hedge Value],'+
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' ),0) AS [Item Value],'+
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  rmv '
					
		SET @Sql_Where = ' WHERE   hedge_type_value_id = 151 AND (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.term_month >   CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
				
		SET @Sql1 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		----------------------------------
		SET @Sql_Select = 'SELECT 2 AS NO,'  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id , ' END +
			'''Settlements of position included in the opening balance:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'link_id , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'link_deal_flag , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'term_month , ' END +
			CASE WHEN (@summary_option = 's') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.'  END  + case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' ),0) AS [Hedge Value],' +
			CASE WHEN (@summary_option = 's') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.'  END  + case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' ),0) AS [Item Value],' +
			CASE WHEN (@summary_option = 's') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.'  END  + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff] ' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  RMV '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND   (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND  
						(RMV.term_month > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND
						(RMV.term_month <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		
		SET @Sql2 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-------------------------------
		
		SET @Sql_Select = 'SELECT  3 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id , ' END +
			'''New positions added during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' ),0) AS [Hedge Value],' +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' ),0) AS [Item Value],' +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 

		SET @Sql_From = ' FROM  '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
					INNER JOIN 
						(SELECT link_id, link_type, max(link_effective_date) link_effective_date,
						CASE 	--WHEN (link_type = ''deal'') THEN ''d'' 
							WHEN (link_type = ''book'') THEN ''b'' 
							WHEN (link_type = ''dlink'') THEN ''o'' 
							ELSE ''l'' 
						END AS link_deal_flag 
						FROM '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + ' calcprocess_deals 
						WHERE calc_type  = ''m'' and  as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102) and link_type <> ''deal'' and hedge_type_value_id = 151
						GROUP BY link_id, link_type) sdh 
						 
						ON sdh.link_id = rmv.link_id AND sdh.link_deal_flag = rmv.link_deal_flag'


		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND     (rmv.link_deal_flag <> ''d'') AND
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND 
						(sdh.link_effective_date > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		SET @Sql3 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		-----------------------------------
			
		SET @Sql_Select = 'SELECT 4 AS NO,'  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id , ' END +
			'''Changes in value of existing positions during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'now.link_id , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'now.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'now.term_month , ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM( ISNULL(now.hedge_mtm,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.hedge_mtm,0) -ISNULL(beginning.' END+ case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ',0)),0) AS [Hedge Value],'+
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM( ISNULL(now.item_mtm,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.item_mtm,0) -ISNULL(beginning.' END + case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ',0)),0) AS [Item Value] ,'+
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM( ISNULL(now.total_pnl,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.total_pnl,0) -ISNULL(beginning.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ',0)),0) AS [PNL Ineff] ' 
						
		SET @Sql_From = ' FROM     	(
						SELECT   as_of_date, rmv.link_id, term_month, rmv.link_deal_flag,' 
						+ case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' as hedge_mtm,'
						+ case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' as item_mtm,'
						+ case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' as total_pnl
						from '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
						INNER JOIN
						(select link_id, link_type, max(link_effective_date) link_effective_date ,
						CASE 	--WHEN (link_type = ''deal'') THEN ''d'' 
							WHEN (link_type = ''book'') THEN ''b'' 
							WHEN (link_type = ''dlink'') THEN ''o'' 
							ELSE ''l'' 
						END AS link_deal_flag
							FROM '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + ' calcprocess_deals 
							WHERE calc_type  = ''m'' and  as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102) and link_type <> ''deal'' and hedge_type_value_id = 151
							GROUP BY link_id, link_type) sdh 
							on sdh.link_id = rmv.link_id AND sdh.link_deal_flag = rmv.link_deal_flag'
						
					
								
		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)
						AND  (sdh.link_effective_date <= CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		

		SET @Sql_Where = @Sql_Where + ')AS now
						LEFT OUTER JOIN '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  beginning
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
							AND now.link_Deal_flag = beginning.link_deal_flag
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 151  '
						
		
	
		SET @Sql4 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		

		----------------------------------------
		SET @Sql_Select = 'SELECT 5 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id , ' END +
			'''Ending net positions  at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' ),0) AS [Hedge Value],' +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' ),0) AS [Item Value],' +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 

		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv '
		
		SET @Sql_Where = ' WHERE  hedge_type_value_id = 151 AND (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND  
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
			
		SET @Sql5 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy


	 	--print  (@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5)
		--EXEC (@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 )


	--------================================================---------------PNL MTM----------------------======================================-----
		SET @Sql_Select = 'SELECT 1 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id , ' END +
			'''Beginning net positions at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] , ' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  rmv '
					
		SET @Sql_Where = ' WHERE   hedge_type_value_id = 151 AND (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.term_month >   CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
				
		SET @Sql6 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		----------------------------------
		SET @Sql_Select = 'SELECT 2 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id , ' END +
			'''Settlements of position included in the opening balance:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 's') THEN	'-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM] ' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  RMV '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND   (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND  
						(RMV.term_month > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND
						(RMV.term_month <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		
		SET @Sql7 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-------------------------------

		
		SET @Sql_Select = 'SELECT  3 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id , ' END +
			'''New positions added during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 

		SET @Sql_From = ' FROM  '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
					INNER JOIN 
						source_deal_header sdh 
						 
						ON sdh.source_deal_header_id = rmv.link_id'


		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND     (link_deal_flag = ''d'') AND
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND 
						(sdh.deal_date > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '

		
		SET @Sql8 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-----------------------------------
			
		SET @Sql_Select = 'SELECT 4 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id , ' END +
			'''Changes in value of existing positions during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE ' now.link_id , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'now.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'now.term_month , ' END +
			CASE WHEN (@summary_option = 's') THEN 	'ISNULL(SUM( ISNULL(now.total_pnl,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.total_pnl,0) -ISNULL(beginning.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ',0)),0) AS [PNL MTM] ' 
						
		SET @Sql_From = ' FROM     	(
						SELECT   as_of_date, rmv.link_id, term_month, rmv.link_deal_flag,  ' 
						+ case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' as hedge_mtm,'
						+ case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' as item_mtm,'
						+ case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' as total_pnl
						from '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
						INNER JOIN
						source_deal_header sdh 
							on sdh.source_deal_header_id = rmv.link_id'
						
					
								
		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and link_deal_flag = ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)
						AND  (sdh.deal_date <= CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		

		SET @Sql_Where = @Sql_Where + ')AS now
						LEFT OUTER JOIN '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  beginning
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag = ''d'' AND beginning.hedge_type_value_id = 151  '
						
		
	
		SET @Sql9 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		

		----------------------------------------
		SET @Sql_Select = 'SELECT 5 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id , ' END +
			'''Ending net positions at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 

		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv '
		
		SET @Sql_Where = ' WHERE  hedge_type_value_id = 151 AND (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND  
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
			
		SET @Sql10 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy


		--print  (@sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10 )
		--EXEC (@sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10 )
	
	
		--PUT all columns together
		IF @summary_option = 's'
			Begin
			set @temptable_name='#temp_fair_value'
			create table #temp_fair_value([NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
			
			EXEC('Insert into '+@temptable_name+' SELECT A.NO, A.Items,
			0,[PNL INeff],[PNL MTM],ISNULL([PNL Ineff],0)+ ISNULL([PNL MTM],0) As [Total PNL]
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A INNER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO ')
		
		
		End
		
		
		Else IF @summary_option='a'
			Begin
			set @temptable_name='#temp_fair_value1'
			create table #temp_fair_value1([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,
			[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
	 		
			EXEC('Insert into '+@temptable_name+' Select s.entity_name AS Sub,r.NO,r.Items,
				SUM(r.[AOCI]) as [AOCI],SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as [Total PNL]  
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.Items, B.Items) AS Items,
				0 as [AOCI],[PNL INeff],[PNL MTM],ISNULL([PNL Ineff],0)+ ISNULL([PNL MTM],0) As [Total PNL]
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION '+ @sql5+') A FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
			) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				GROUP BY s.entity_name,r.NO,r.Items
				ORDER BY s.entity_name,r.NO')
		
			
			End

		Else IF @summary_option='b'
			Begin	
		 
			set @temptable_name='#temp_fair_value2'
			create table #temp_fair_value2([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
			EXEC('Insert into '+@temptable_name+' Select s.entity_name AS Sub,st.entity_name as Str,r.NO,	r.Items, 
			SUM(r.[AOCI]) as [AOCI],SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as [Total PNL]  
					FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
					COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
					COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
					COALESCE(A.book_entity_id, B.book_entity_id) AS Book,
					COALESCE(A.Items, B.Items) AS Items,
						0 as [AOCI],[PNL INeff],[PNL MTM],ISNULL([PNL Ineff],0)+ ISNULL([PNL MTM],0) As [Total PNL]
				FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A FULL OUTER JOIN
				(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
					ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
					 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
					 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
					GROUP BY s.entity_name,st.entity_name,r.NO,r.Items
					ORDER BY s.entity_name,r.NO')
				

			End	
		Else IF @summary_option='c'
			Begin	

			set @temptable_name='#temp_fair_value3'
			create table #temp_fair_value3([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
 
			EXEC('Insert into '+@temptable_name+' Select s.entity_name AS Sub,st.entity_name as Str,b.entity_name as Book,r.NO,	r.Items, 
				SUM(r.[AOCI]) as [AOCI],SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as [Total PNL]  
					FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
					COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
					COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
					COALESCE(A.book_entity_id, B.book_entity_id) AS Book,
					COALESCE(A.Items, B.Items) AS Items,
					0 as [AOCI],[PNL INeff],[PNL MTM],ISNULL([PNL Ineff],0)+ ISNULL([PNL MTM],0) As [Total PNL]
				FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A FULL OUTER JOIN
				(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
					ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
					 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
					 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
					 LEFT OUTER JOIN portfolio_hierarchy b ON b.entity_id = r.Book
					GROUP BY s.entity_name,st.entity_name,b.entity_name,r.NO,r.Items
					ORDER BY s.entity_name,r.NO')
			End			
		Else IF @summary_option = 'd'
			Begin
			set @temptable_name='#temp_fair_value4'
			create table #temp_fair_value4([NO] int,[Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,items varchar(100) COLLATE DATABASE_DEFAULT,
			[ID] int,[Group] varchar(100) COLLATE DATABASE_DEFAULT,[Term] Varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
 
			EXEC('Insert into '+@temptable_name+' Select r.NO, s.entity_name AS Sub, st.entity_name AS Str, b.entity_name AS Book,
				r.Items, r.ID, r.[Group], r.[Term],
				r.[AOCI] as [AOCI],r.[PNL Ineff] as [PNL Ineff],r.[PNL MTM] as [PNL MTM],r.[Total PNL] as [Total PNL]  
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
				COALESCE(A.book_entity_id, B.book_entity_id) AS Book,
				COALESCE(A.Items, B.Items) AS Items,
				COALESCE(A.link_id, B.link_id) AS ID,
				CASE 	WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''d'') THEN ''Deal'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''b'') THEN ''Book'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''l'') THEN ''Link'' 
					ELSE COALESCE(A.link_deal_flag, B.link_deal_flag) END AS [Group],
				dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],
				0 as [AOCI],0 as [PNL Ineff],ISNULL([Hedge Value],0) as [PNL MTM],ISNULL([Hedge Value],0)+ISNULL([PNL Ineff],0)+ ISNULL([PNL MTM],0) As [Total PNL]
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
			) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
				 LEFT OUTER JOIN portfolio_hierarchy b ON b.entity_id = r.Book
				ORDER BY r.NO')	

			End





/*----------------------------------------------- END FAIR VALUE-----------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
*/
/*------------------------------------------------------------ -----------------------------------------------------
--------------------------------------------------CASH FLOW-------------------------------------------------------
*/


SET @Sql_Select = 'SELECT 1 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id, ' END +
			'''Beginning net positions at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ),0) AS [AOCI],'+
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  rmv '
					
		SET @Sql_Where = ' WHERE   hedge_type_value_id = 150 AND (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.term_month >   CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
				
		SET @Sql1 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		----------------------------------
		SET @Sql_Select = 'SELECT 2 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id, ' END +
			'''Settlements of position included in the opening balance:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 's') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ),0) AS [AOCI],' +
			CASE WHEN (@summary_option = 's') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff] ' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  RMV '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND  
						(RMV.term_month > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND
						(RMV.term_month <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		
		SET @Sql2 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		
		-------------------------------

		
		SET @Sql_Select = 'SELECT  3 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id, ' END +
			'''New positions added during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ),0) AS [AOCI],' +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 

		SET @Sql_From = ' FROM  '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
					LEFT OUTER JOIN 
						(SELECT link_id, link_type, max(link_effective_date) link_effective_date ,
						CASE 	--WHEN (link_type = ''deal'') THEN ''d'' 
							WHEN (link_type = ''book'') THEN ''b'' 
							WHEN (link_type = ''dlink'') THEN ''o'' 

							ELSE ''l'' 
						END AS link_deal_flag
						FROM '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + ' calcprocess_deals 
						WHERE calc_type  = ''m'' and  as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102) and link_type <> ''deal'' and hedge_type_value_id = 150
						GROUP BY link_id, link_type) sdh 
						 
						ON sdh.link_id = rmv.link_id AND sdh.link_deal_flag = rmv.link_deal_flag'


		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND     (rmv.link_deal_flag <> ''d'') AND
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND 
						(sdh.link_effective_date > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		SET @Sql3 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-----------------------------------
			
		SET @Sql_Select = 'SELECT 4 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id, ' END +
			'''Changes in value of existing positions during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE ' now.link_id, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'now.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'now.term_month, ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM( ISNULL(now.total_aoci,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.total_aoci,0) -ISNULL(beginning.' END + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ',0)),0) AS [AOCI],' +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM( ISNULL(now.total_pnl,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.total_pnl,0) -ISNULL(beginning.' END  + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ',0)),0) AS [PNL Ineff] ' 
						
		SET @Sql_From = ' FROM     	(
						SELECT   as_of_date, rmv.link_id, term_month, rmv.link_deal_flag, ' 
						+ case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' as total_aoci,'
						+ case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' as total_pnl
						from '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
						INNER JOIN
						(select link_id, link_type, max(link_effective_date) link_effective_date ,
							CASE 	--WHEN (link_type = ''deal'') THEN ''d'' 
							WHEN (link_type = ''book'') THEN ''b'' 
							WHEN (link_type = ''dlink'') THEN ''o'' 
							ELSE ''l'' 
						END AS link_deal_flag
							FROM '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + ' calcprocess_deals 
							WHERE calc_type  = ''m'' and  as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102) and link_type <> ''deal'' and hedge_type_value_id = 150
							GROUP BY link_id, link_type) sdh 
							on sdh.link_id = rmv.link_id  AND sdh.link_deal_flag = rmv.link_deal_flag'
						
					
								
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)
						AND  (sdh.link_effective_date <= CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '

		

		SET @Sql_Where = @Sql_Where + ')AS now
						LEFT OUTER JOIN '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  beginning
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
							AND now.link_deal_flag = beginning.link_deal_flag
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 150  '
						
		
	
		SET @Sql4 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		

		----------------------------------------
		SET @Sql_Select = 'SELECT 5 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id, ' END +
			'''Ending net positions at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END +  case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ),0) AS [AOCI],' +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END  + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 

		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv '
		
		SET @Sql_Where = ' WHERE  hedge_type_value_id = 150 AND (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND  
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
			
		SET @Sql5 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy


	 	--print  (@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5)
		--EXEC (@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 )
	

	--------================================================---------------PNL MTM----------------------======================================-----
		SET @Sql_Select = 'SELECT 1 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id, ' END +
			'''Beginning net positions at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  rmv '
					
		SET @Sql_Where = ' WHERE   hedge_type_value_id = 150 AND (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.term_month >   CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
				
		SET @Sql6 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		----------------------------------
		SET @Sql_Select = 'SELECT 2 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id, ' END +
			'''Settlements of position included in the opening balance:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 's') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM] ' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  RMV '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND  
						(RMV.term_month > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND
						(RMV.term_month <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		
		SET @Sql7 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		
		-------------------------------

		
		SET @Sql_Select = 'SELECT  3 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id, ' END +
			'''New positions added during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END  + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 

		SET @Sql_From = ' FROM  '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
					INNER JOIN 
						source_deal_header sdh 
						 
						ON sdh.source_deal_header_id = rmv.link_id'


		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND     (link_deal_flag = ''d'') AND
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND 
						(sdh.deal_date > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
			SET @Sql8 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-----------------------------------
			
		SET @Sql_Select = 'SELECT 4 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id, ' END +
			'''Changes in value of existing positions during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE ' now.link_id, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'now.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'now.term_month, ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM( ISNULL(now.total_pnl,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.total_pnl,0) -ISNULL(beginning.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ',0)),0) AS [PNL MTM] ' 
						
		SET @Sql_From = ' FROM     	(
						SELECT   as_of_date, rmv.link_id, term_month, rmv.link_deal_flag, ' 
						+ case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' as hedge_mtm,'
						+ case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' as item_mtm,'
						+ case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' as total_pnl
						from '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
						INNER JOIN

						source_deal_header sdh 
							on sdh.source_deal_header_id = rmv.link_id'
						
					
								
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and link_deal_flag = ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)
						AND  (sdh.deal_date <= CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		

		SET @Sql_Where = @Sql_Where + ')AS now
						LEFT OUTER JOIN '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  beginning
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag = ''d'' AND beginning.hedge_type_value_id = 150  '
						
		
	
		SET @Sql9 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		

		----------------------------------------
		SET @Sql_Select = 'SELECT 5 AS NO, '  +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'book_entity_id, ' END +
			'''Ending net positions at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 's') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 's') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 

		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv '
		
		SET @Sql_Where = ' WHERE  hedge_type_value_id = 150 AND (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND  
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
			
		SET @Sql10 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy



		--print  (@sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10 )
		--EXEC (@sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10 )
	
	
		--PUT all columns together
	
	IF @summary_option = 's' 
		Begin	
			set @temptable_name='#temp_cash_flow'
			create table #temp_cash_flow([NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
			

			EXEC('Insert into '+@temptable_name+' SELECT A.NO, A.Items, [AOCI], [PNL Ineff],0,
					ISNULL([AOCI],0)+ISNULL([PNL Ineff],0)+ISNULL([PNL MTM],0) As [Total PNL]
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A INNER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO ')
		

		End
	ELSE IF @summary_option = 'a' 
			Begin
				set @temptable_name='#temp_cash_flow1'
				create table #temp_cash_flow1([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
				,[Total MTM] float)
	
				EXEC('Insert into '+@temptable_name+'  Select s.entity_name AS Sub,r.NO,  
				r.Items,SUM(r.[AOCI]) as [AOCI],
				SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as  [Total PNL]
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.Items, B.Items) AS Items,
				[AOCI], [PNL Ineff],0 as [PNL MTM],
				ISNULL([AOCI],0)+ISNULL([PNL Ineff],0)+ISNULL([PNL MTM],0) As [Total PNL]
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A 
			FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				GROUP BY r.NO,s.entity_name,r.Items
				ORDER BY r.NO, s.entity_name 
				')
		End
	
	ELSE IF @summary_option='b'
		Begin
			set @temptable_name='#temp_cash_flow2'
			create table #temp_cash_flow2([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)

			EXEC('Insert into '+@temptable_name+'  Select s.entity_name AS Sub,st.entity_name AS Str,r.NO,  
				r.Items, SUM(r.[AOCI]) as [AOCI],
				SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as  [Total PNL]
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
				COALESCE(A.Items, B.Items) AS Items,
				[AOCI], [PNL Ineff],0 as [PNL MTM],
				ISNULL([AOCI],0)+ISNULL([PNL Ineff],0)+ISNULL([PNL MTM],0) As [Total PNL]
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A 
			FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month

				) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
				GROUP BY r.NO,s.entity_name,st.entity_name,r.Items
				ORDER BY r.NO, s.entity_name 
				')
		
		End
	ELSE IF @summary_option = 'c'
		Begin
			
			set @temptable_name='#temp_cash_flow3'
			create table #temp_cash_flow3([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
			EXEC('Insert into '+@temptable_name+'  Select s.entity_name AS Sub, st.entity_name AS Str,b.entity_name as Book,r.NO,  
				r.Items,SUM(r.[AOCI]) as [AOCI]
				,SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as [Total PNL]
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
				COALESCE(A.book_entity_id, B.book_entity_id) AS Book,
				COALESCE(A.Items, B.Items) AS Items,
				[AOCI], [PNL Ineff],0 as [PNL MTM],
				ISNULL([AOCI],0)+ISNULL([PNL Ineff],0)+ISNULL([PNL MTM],0) As [Total PNL]
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A 
			FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
				 LEFT OUTER JOIN portfolio_hierarchy b ON b.entity_id = r.Book
				GROUP BY s.entity_name,st.entity_name,b.entity_name,r.NO, r.items
				ORDER BY s.entity_name, st.entity_name, b.entity_name,r.NO 
				')
		End

	ELSE IF @summary_option = 'd'
		Begin
			set @temptable_name='#temp_cash_flow4'
			create table #temp_cash_flow4([NO] int,[Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,items varchar(100) COLLATE DATABASE_DEFAULT,
			[ID] int,[Group] varchar(100) COLLATE DATABASE_DEFAULT,[Term] Varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)

			EXEC('Insert into '+@temptable_name+'  Select r.NO, s.entity_name AS Sub, st.entity_name AS Str, b.entity_name AS Book,
				r.Items, r.ID, r.[Group], r.[Term], r.[AOCI], r.[PNL Ineff], r.[PNL MTM], r.[Total PNL]  
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
				COALESCE(A.book_entity_id, B.book_entity_id) AS Book,
				COALESCE(A.Items, B.Items) AS Items,
				COALESCE(A.link_id, B.link_id) AS ID,
				CASE 	WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''d'') THEN ''Deal'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''b'') THEN ''Book'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''l'') THEN ''Link'' 
					ELSE COALESCE(A.link_deal_flag, B.link_deal_flag) END AS [Group],
				dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],
			[AOCI], [PNL Ineff],0 as [PNL MTM],
				ISNULL([AOCI],0)+ISNULL([PNL Ineff],0)+ISNULL([PNL MTM],0) As [Total PNL]
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A 
			FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
				 LEFT OUTER JOIN portfolio_hierarchy b ON b.entity_id = r.Book
				ORDER BY r.NO, s.entity_name, st.entity_name, b.entity_name, r.[Group], r.ID, CAST((r.Term + ''-01'') as datetime) 
				')

		End

/*----------------------------------------------- END CASH FLOW-----------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
*/
/*------------------------------------------------------------ -----------------------------------------------------
-------------------------------------------------- MTM-----------------------------------------------------------
*/


		If (@summary_option = 's')
			SET @Sql_Select = 'SELECT 1 AS NO, ''Beginning net MtM balance at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] , ISNULL(SUM(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' ),0) AS [TotalAmount]' 

		Else
			SET @Sql_Select = 'SELECT 1 AS NO, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Beginning net MtM balance at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] ,' +
					'link_id ID, ''Deal'' [Group], dbo.FNADateFormat(term_month) Term, ISNULL(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ', 0) AS [TotalAmount]'  
		
		
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  rmv '
		If (@summary_option <> 's')
			SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '
			
					
		SET @Sql_Where = ' WHERE   (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.term_month >   CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
				
		SET @Sql1 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		
		----------------------------------
		If (@summary_option = 's')
			SET @Sql_Select = 'SELECT 2 AS NO, ''Settlements of position included in the opening balance:'' AS [Items] ,-1 * ISNULL(SUM(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' ),0) AS [TotalAmount] ' 
		Else 
			SET @Sql_Select = 'SELECT 2 AS NO, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Settlements of position included in the opening balance:'' AS [Items],' +
					'link_id ID, ''Deal'' [Group], dbo.FNADateFormat(term_month) Term, -1 * ISNULL(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ', 0 ) AS [TotalAmount]'  

				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  RMV '
		If (@summary_option <> 's')
			SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '
		
		SET @Sql_Where = ' WHERE   (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND  
						(RMV.term_month > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND
						(RMV.term_month <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		
		SET @Sql2 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-------------------------------
		If (@summary_option = 's')
			SET @Sql_Select = 'SELECT  3 AS NO, ''New positions added during the period:'' AS [Items] ,ISNULL(SUM(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' ),0) AS [TotalAmount] ' 
		Else 
			SET @Sql_Select = 'SELECT 3 AS NO, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''New positions added during the period:'' AS [Items] ,' +
					'link_id ID, ''Deal'' [Group], dbo.FNADateFormat(term_month) Term, ISNULL(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ', 0) AS [TotalAmount] '  
		
		SET @Sql_From = ' FROM  '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv INNER JOIN source_deal_header sdh 
						ON sdh.source_deal_header_id = rmv.link_id'
		If (@summary_option <> 's')
			SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '

		SET @Sql_Where = ' WHERE   (link_deal_flag = ''d'') AND
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND 
						(sdh.deal_date > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		SET @Sql3 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-----------------------------------
			
		If (@summary_option = 's')
			SET @Sql_Select = 'SELECT 4 AS NO, ''Changes in value of existing positions during the period:'' AS [Items] , SUM( ISNULL(now.d_pnl_mtm,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ',0)) AS [TotalAmount] ' 
		Else 
			SET @Sql_Select = 'SELECT 4 AS NO, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Changes in value of existing positions during the period:'' AS [Items] ,' +
					'now.link_id ID, ''Deal''  [Group], dbo.FNADateFormat(now.term_month) Term, (ISNULL(now.d_pnl_mtm,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ',0)) AS [TotalAmount] '  

					
		SET @Sql_From = ' FROM     	(
						SELECT   ' +
				case when (@summary_option <> 's') then 'sub_entity_id, strategy_entity_id, book_entity_id, ' else '' end +
						' as_of_date, link_id, term_month, ' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' as d_pnl_mtm 
						from '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv INNER JOIN source_deal_header sdh 
						ON sdh.source_deal_header_id = rmv.link_id '
						
					
								
		SET @Sql_Where = ' WHERE as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and link_deal_flag = ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)
						AND 
						(sdh.deal_date <= CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND   
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		

		SET @Sql_Where = @Sql_Where + ')AS now ' +
		case when (@summary_option <> 's') then
			' INNER JOIN portfolio_hierarchy s ON s.entity_id = now.sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = now.strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = now.book_entity_id '	
			else '' end +
						' LEFT OUTER JOIN '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  beginning
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
							AND beginning.link_deal_flag = ''d'' '
						
		
	
		SET @Sql4 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		--print @Sql4

		----------------------------------------
		If (@summary_option = 's')
			SET @Sql_Select = 'SELECT 5 AS NO, ''Ending net MtM balance at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,ISNULL(SUM(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' ),0)  AS [TotalAmount]' 
		Else 
			SET @Sql_Select = 'SELECT 5 AS NO, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Ending net MtM balance at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,' +
					'link_id ID, ''Deal'' [Group], dbo.FNADateFormat(term_month) Term, ISNULL(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' ,0)  AS [TotalAmount]'  



		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv '
		If (@summary_option <> 's')
			SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '
		
		SET @Sql_Where = ' WHERE   (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND  
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
			
		SET @Sql5 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

-- 	END
	
	IF @summary_option='s'
		Begin
		set @temptable_name='#temp_mtm'
		create table #temp_mtm([NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
		,[Total MTM] float)
		Exec('Insert into '+@temptable_name+' select A.NO,A.items,0,0,A.[TotalAmount],A.[TotalAmount] from 
		( '+@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5+' ) A') 
		End	
	
				
	
	if @summary_option='a'
		Begin
		set @temptable_name='#temp_mtm1'
		create table #temp_mtm1([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
		items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
		,[Total MTM] float)

		EXEC('Insert into '+@temptable_name+' select ISNULL(r.SUB,0) as Sub,ISNULL(r.NO,0)
		,ISNULL(r.items,0),SUM(0),SUM(0),SUM(r.[TotalAmount]),SUM(r.[TotalAmount]) as [TotalAmount] from ('+@sql1 + 
		' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5+') r 
		group by r.SUB,r.NO,r.items order by r.SUB,r.NO') 

		End

	Else if @summary_option='b'
		Begin
		set @temptable_name='#temp_mtm2'
		create table #temp_mtm2([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
		items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
		,[Total MTM] float)
		EXEC ('Insert into '+@temptable_name+' select r.SUB as Sub,r.str Str,r.NO,r.items,0,0,SUM(r.[TotalAmount]),SUM(r.[TotalAmount]) from(
		'+@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5+') r
		group by r.SUB,r.str,r.NO,r.items order by r.SUB,r.str,r.NO' )
		
		End

	Else if @summary_option='c'
		Begin
		set @temptable_name='#temp_mtm3'
		create table #temp_mtm3([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
		,[Total MTM] float)
		EXEC ('Insert into '+@temptable_name+' select r.SUB as Sub,r.str Str, r.book As Book,r.NO,r.items,SUM(0),SUM(0),SUM(r.[TotalAmount]),SUM(r.[TotalAmount]) from(
		'+@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5+') r
		group by r.SUB,r.str,r.book,r.NO,r.items order by r.SUB,r.str,r.book,r.NO' )
		End

	Else	if @summary_option='d'
		Begin
		
		set @temptable_name='#temp_mtm4'
		create table #temp_mtm4([NO] int,[Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,
		items varchar(100) COLLATE DATABASE_DEFAULT,[ID] int,[Group] varchar(100) COLLATE DATABASE_DEFAULT,[Term] varchar(100) COLLATE DATABASE_DEFAULT,[Total MTM] float)
		Exec('Insert into '+@temptable_name+' select A.NO,A.sub,A.Str,A.Book,A.items,A.ID,A.[group],A.term,A.[TotalAmount] from 
		 ( '+@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5+' ) A') 
		
		
		End	

		

/*------------------------------------------------------------ -----------------------------------------------------
-------------------------------------------------- END MTM-----------------------------------------------------------
*/



declare @counts int,@i int,@subname varchar(100),@item_name varchar(100),@strname varchar(100),@bookname varchar(100)



	create table #temp_op(sub varchar(100) COLLATE DATABASE_DEFAULT,strategy varchar(100) COLLATE DATABASE_DEFAULT,book varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
	items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
	,[Total MTM] float)

	set @temptable_name='#temp_op'
	set @sql_select=' insert into '+@temptable_name+' select s.entity_name as sub,st.entity_name,b.entity_name,
	6 as [NO],''asda'' as items,0,0,0,a.option_premium from
	(select distinct  fas_subsidiary_id ,fas_strategy_id  ,fas_book_id,
	deal_date,  sum(option_premium) as option_premium from '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + ' calcprocess_deals
	where calc_type = ''m'' and option_flag = ''y'' and as_of_date ='''+ @as_of_date +''' and 
	deal_date between '''+@beginning_date+''' and '''+@as_of_date +'''  
	group by  fas_subsidiary_id,fas_strategy_id,fas_book_id,deal_date) a 
	INNER JOIN portfolio_hierarchy s ON s.entity_id =fas_subsidiary_id 
	INNER JOIN portfolio_hierarchy st ON st.entity_id =fas_strategy_id 
	INNER JOIN portfolio_hierarchy b ON b.entity_id =fas_book_id '  
	
	set @Sql_Where=' where  fas_subsidiary_id in ('+@sub_entity_id +') '

	IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' and fas_strategy_id IN(' + @strategy_entity_id + ' )'
	IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' and fas_book_id IN(' + @book_entity_id + ') '
	EXEC(@sql_select+@Sql_Where)


if @summary_option='s'
	Begin

		create table #temp_t1([No] int,items varchar(100) COLLATE DATABASE_DEFAULT,[Total Amount] float)
		set @temptable_name='#temp_t1'

		
		--(select a.[NO],a.items,
		--ISNULL(a.[AOCI  (Effective)],0)+ISNULL(a.[PNL Ineff],0)+ISNULL(b.[PNL MTM],0)+ISNULL(c.[Total MTM],0) as [Total MTM]
		--from #temp_cash_flow a Left Outer join #temp_fair_value b on a.no=b.no   Left Outer join #temp_mtm c
		--on b.no=c.no)
		--UNION
		insert into #temp_t1 select [NO],[Items],ISNULL([Total Amount],0) as [Total Amount] from(	
		(select 1 as [NO],'Total MTM Energy Contract Net Assets at ('+ dbo.FNADateFormat(@beginning_date)+')' as [items],
		ISNULL(a.[AOCI  (Effective)],0)+ISNULL(a.[PNL Ineff],0)+ISNULL(b.[PNL MTM],0)+ISNULL(c.[Total MTM],0) as [Total Amount]
		from #temp_cash_flow a Left Outer join #temp_fair_value b on a.no=b.no   Left Outer join #temp_mtm c
		on b.no=c.no where a.no=1)
		UNION
		(select 2 as [NO],'Total Change in Fair Value Excluding Reclassification to Realized at Settlement of Contracts' as [Items]
		,ISNULL(b.[PNL MTM],0)+ISNULL(c.[Total MTM],0) as [TotAL Values]
		from #temp_cash_flow a Left Outer join #temp_fair_value b on a.no=b.no   Left Outer join #temp_mtm c
		on b.no=c.no where a.no=4)
		UNION	
		(select 3 as [NO],'Reclassification to Realized at Settlement of Contracts' as [Items],
		ISNULL(a.[AOCI  (Effective)],0)+ISNULL(a.[PNL Ineff],0)+ISNULL(b.[PNL MTM],0)+ISNULL(c.[Total MTM],0) as [Total Values]
		from #temp_cash_flow a Left Outer join #temp_fair_value b on a.no=b.no   Left Outer join #temp_mtm c
		on b.no=c.no where a.no=2)
		UNION
		(select 4 as [NO],'Effective Portion of Changes in Fair Value  (Recorded in OCI)' as [Items],
		ISNULL(a.[AOCI  (Effective)],0)+ISNULL(b.[AOCI  (Effective)],0) as [Total Values] 
		from #temp_cash_flow a, #temp_cash_flow b where	a.no=4 and  b.no=3)	
		UNION
		(select 5 as [NO],'Ineffective Portion of Changes in Fair Value (Recorded in Earnings)' as [Items],
		ISNULL(a.[PNL Ineff],0)+ISNULL(b.[PNL Ineff],0) as [Total Values] 
		from #temp_cash_flow a, #temp_cash_flow b where	a.no=4 and  b.no=3)	
		UNION		
		select 6 as [NO],'Net Option Premium Payments' as [Items],ISNULL(SUM(e.[Total MTM]),0) as [Total Amount] from
		(select [Total MTM] from #temp_op) e
		UNION
		(select 7 as [NO],'Purchase/Sale of Existing Contracts or Portfolios Subject to MTM' as [Items],
		ISNULL(a.[PNL Ineff],0)+ISNULL(b.[Total MTM],0) as [Total MTM]
		from #temp_fair_value a , #temp_mtm b,#temp_cash_flow c  where a.no=3 and c.no=3 and b.no=3)
		) x order by x.no
	
		select  Items,[Total Amount] from(
		select [no],items,[total amount] from #temp_t1 UNION 
		select 8 as [No],'Total MTM Energy Contract Net Assets at ('+ dbo.FNADateFormat(@as_of_date) + ')' as [Items],
		SUM(ISNULL([TOTAL Amount],0))  as [Total Amount] from #temp_t1 
		) a order by a.[NO]
	
	End
Else IF @summary_option='a'	
	Begin
	create table #temp_sub([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
	items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
	,[Total MTM] float)


	
		DECLARE a_cursor CURSOR FOR
		select distinct   sub from (select sub from #temp_cash_flow1 UNION select sub 
		from #temp_fair_value1 UNION select sub from #temp_mtm1) a 
		 order by sub
		
		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @subname
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			--set @i=8
			set @i=7	
			while @i<>0
				Begin
					if @i=1
					set @item_name='Total MTM Energy Contract Net Assets at ('+ dbo.FNADateFormat(@beginning_date)+')'
					else if @i=2
					set @item_name='Total Change in Fair Value Excluding Reclassification to Realized at Settlement of Contracts'
					else if @i=3
					set @item_name='Reclassification to Realized at Settlement of Contracts'
					else if @i=4
					set @item_name='Effective Portion of Changes in Fair Value - Recorded in OCI'
					else if @i=5
					set @item_name='Ineffective Portion of Changes in Fair Value - Recorded in Earnings'
					else if @i=6
					set @item_name='Net Option Premium Payments' 
					else if @i=7
					set @item_name='Purchase/Sale of Existing Contracts or Portfolios Subject to MTM'
					else if @i=8
					set @item_name='Total MTM Energy Contract Net Assets at (' + dbo.FNADateFormat(@as_of_date) + ')'  

					insert into #temp_sub values(@subname,@i,@item_name,0,0,0,0)					
					set @i=@i-1
				End
			
			FETCH NEXT FROM a_cursor INTO  @subname
		END 
		CLOSE a_cursor
		DEALLOCATE  a_cursor		
	
	--select * from #temp_sub
	--return

	create table #temp_t2([No] int,sub varchar(100) COLLATE DATABASE_DEFAULT,items varchar(100) COLLATE DATABASE_DEFAULT,[Total Amount] float)
	set @temptable_name='#temp_t2'

 	insert into  #temp_t2 select z.[No],z.[Sub] as [Subsidiary],
	z.[Items],round(ISNULL(x.[Total Amount],0),0) as [Total Amount] from(
	select 1 as [NO],a.sub,'Total MTM Energy Contract Net Assets at('+ dbo.FNADateFormat(@beginning_date)+')' as [Items],SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow1 where NO=1) Union
	(select sub,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_value1 where NO=1)Union
	(select sub,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtm1 where NO=1)) a
	group by a.sub 
	UNION
	select 2 as [NO],a.sub,'Total Change in Fair Value Excluding Reclassification to Realized at Settlement of Contracts' as [Items],
	SUM(Isnull(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_value1 where NO=4)Union
	(select sub,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtm1 where NO=4)) a
	group by a.sub 
	UNION
	select 3 as [NO],a.sub,'Reclassification to Realized at Settlement of Contracts' as [Items],SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow1 where NO=2) Union
	(select sub,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_value1 where NO=2)Union
	(select sub,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtm1 where NO=2)) a
	group by a.sub	
	UNION
	select 4 as [NO],a.sub,'Effective Portion of Changes in Fair Value - Recorded in OCI' as [Items],
	SUM(ISNULL(a.[AOCI  (Effective)],0)) as [Total Amount] from (
	(select sub,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow1 where NO=3)UNION
	(select sub,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow1 where NO=4)

	) a
	group by a.sub	 
	UNION
	select 5 as [NO],a.sub,'Ineffective Portion of Changes in Fair Value - Recorded in Earnings' as [Items],
	SUM(ISNULL(a.[PNL Ineff],0)) as [Total Amount] from (
	(select sub,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow1 where NO=3)UNION
	(select sub,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow1 where NO=4)
	) a
	group by a.sub	
	UNION
	select 6 as [NO],a.sub,'Net Option Premium Payments' as [Items],SUM(a.[Total MTM]) as [Total Amount] from
	(select  sub,[Total MTM] from #temp_op) a
	group by a.sub	 
	UNION
	select 7 as [NO],a.sub,'Purchase/Sale of Existing Contracts or Portfolios Subject to MTM' as [Items],
	SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[Total MTM],0)) as [Total Amount] from(
	(select sub,[NO],0 AS [AOCI  (Effective)],0 AS [PNL Ineff], [PNL Ineff] as [PNL MTM] ,0 as [Total MTM] from #temp_fair_value1 where NO=3)UNION
	(select sub,[NO],0 AS [AOCI  (Effective)],0 AS [PNL Ineff],0 as [PNL MTM] ,ISNULL([Total MTM],0) as [Total MTM] from #temp_mtm1 where NO=3) UNION
	(select sub,[NO],ISNULL([AOCI  (Effective)],0) AS [AOCI  (Effective)],ISNULL([PNL Ineff],0) AS [PNL Ineff],0 as [PNL MTM] ,0 as [Total MTM] from #temp_cash_flow1 where NO=3)
	) a
	group by a.sub	 
	 ) x  RIGHT OUTER JOIN #temp_sub z
	on x.no=z.no and x.sub=z.sub order by z.sub,z.no
		
	
	--select * from #temp_t2
	--return
	select  Sub,Items,[Total Amount] from(
	select [no],sub,items,[total amount] from #temp_t2  
	UNION	
	select 8 as [NO],sub,'Total MTM Energy Contract Net Assets at ('	 + dbo.FNADateFormat(@as_of_date) + ')' as [Items],
	SUM(ISNULL([TOTAL Amount],0))  as [Total Amount] from #temp_t2 group by sub) a
	order by a.sub,a.no
	
	
	
	End
	
Else IF @summary_option='b'
	Begin

	create table #temp_sub1([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
	items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
	,[Total MTM] float)


	
		DECLARE a_cursor CURSOR FOR
		select distinct   sub,str from (select sub,str from #temp_cash_flow2 UNION select sub,str
		from #temp_fair_value2 UNION select sub,str from #temp_mtm2) a
		 order by sub
		
		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @subname,@strname
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			set @i=7
			while @i<>0
				Begin
					if @i=1
					set @item_name='Total MTM Energy Contract Net Assets at ('+ dbo.FNADateFormat(@beginning_date)+')'
					else if @i=2
					set @item_name='Total Change in Fair Value Excluding Reclassification to Realized at Settlement of Contracts'
					else if @i=3
					set @item_name='Reclassification to Realized at Settlement of Contracts'
					else if @i=4
					set @item_name='Effective Portion of Changes in Fair Value - Recorded in OCI'
					else if @i=5
					set @item_name='Ineffective Portion of Changes in Fair Value - Recorded in Earnings'
					else if @i=6
					set @item_name='Net Option Premium Payments' 
					else if @i=7
					set @item_name='Purchase/Sale of Existing Contracts or Portfolios Subject to MTM'
					else if @i=8
					set @item_name='Total MTM Energy Contract Net Assets at (' + dbo.FNADateFormat(@as_of_date) + ')'  

					insert into #temp_sub1 values(@subname,@strname,@i,@item_name,0,0,0,0)					
					set @i=@i-1
				End
			
			FETCH NEXT FROM a_cursor INTO  @subname,@strname
		END 
		CLOSE a_cursor
		DEALLOCATE  a_cursor		
	--select * from #temp_sub1
	--return
	create table #temp_t3([No] int,sub varchar(100) COLLATE DATABASE_DEFAULT,str varchar(100) COLLATE DATABASE_DEFAULT,items varchar(100) COLLATE DATABASE_DEFAULT,[Total Amount] float)
	set @temptable_name='#temp_t3'
  	
	insert into  #temp_t3 select z.[No],z.[Sub] as [Subsidiary],z.str as [Strategy],
	z.[Items],round(ISNULL(x.[Total Amount],0),0) as [Total Amount] from(
	select 1 as [NO],a.sub,a.str,'Total MTM Energy Contract Net Assets at('+ dbo.FNADateFormat(@beginning_date)+')' as [Items],SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow2 where NO=1) Union
	(select sub,str,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_value2 where NO=1)Union
	(select sub,str,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtm2 where NO=1)) a
	group by a.sub,a.str
	UNION
	select 2 as [NO],a.sub,a.str,'Total Change in Fair Value Excluding Reclassification to Realized at Settlement of Contracts' as [Items],
	SUM(Isnull(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_value2 where NO=4)Union
	(select sub,str,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtm2 where NO=4)) a
	group by a.sub ,a.str
	UNION
	select 3 as [NO],a.sub,a.str,'Reclassification to Realized at Settlement of Contracts' as [Items],SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow2 where NO=2) Union
	(select sub,str,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_value2 where NO=2)Union
	(select sub,str,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtm2 where NO=2)) a
	group by a.sub	,a.str
	UNION
	select 4 as [NO],a.sub,a.str,'Effective Portion of Changes in Fair Value - Recorded in OCI' as [Items],
	SUM(ISNULL(a.[AOCI  (Effective)],0)) as [Total Amount] from (
	(select sub,str,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow2 where NO=3)UNION
	(select sub,str,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow2 where NO=4)
	) a
	group by a.sub	 ,a.str
	UNION
	select 5 as [NO],a.sub,a.str,'Ineffective Portion of Changes in Fair Value - Recorded in Earnings' as [Items],
	SUM(ISNULL(a.[PNL Ineff],0)) as [Total Amount] from (
	(select sub,str,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow2 where NO=3)UNION
		(select sub,str,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow2 where NO=4)
	) a
	group by a.sub	,a.str
	UNION
	select 6 as [NO],a.sub,a.strategy,'Net Option Premium Payments' as [Items],SUM(a.[Total MTM]) as [Total Amount] from
	(select  sub,strategy,[Total MTM] from #temp_op) a
	group by a.sub	 ,a.strategy
	UNION
	select 7 as [NO],a.sub,a.str,'Purchase/Sale of Existing Contracts or Portfolios Subject to MTM' as [Items],
	SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[Total MTM],0)) as [Total Amount] from(
	(select sub,str,[NO],0 AS [AOCI  (Effective)],0 AS [PNL Ineff], [PNL Ineff] as [PNL MTM] ,0 as [Total MTM] from #temp_fair_value2 where NO=3)UNION
	(select sub,str,[NO],0 AS [AOCI  (Effective)],0 AS [PNL Ineff],0 as [PNL MTM] ,ISNULL([Total MTM],0) as [Total MTM] from #temp_mtm2 where NO=3) UNION
	(select sub,str,[NO],ISNULL([AOCI  (Effective)],0) AS [AOCI  (Effective)],ISNULL([PNL Ineff],0) AS [PNL Ineff],0 as [PNL MTM] ,0 as [Total MTM] from #temp_cash_flow2 where NO=3)
	) a
	group by a.sub	 ,a.str
	) x  RIGHT OUTER JOIN #temp_sub1 z on
	x.no=z.no and x.sub=z.sub and x.str=z.str order by z.sub,z.str,z.no
	
	select  Sub,str as Strategy,Items,[Total Amount] from(
	select [no],sub,str,items,[total amount] from #temp_t3  
	UNION	
	select 8 as [NO],sub,str,'Total MTM Energy Contract Net Assets at ('	 + dbo.FNADateFormat(@as_of_date) + ')' as [Items],
	SUM(ISNULL([TOTAL Amount],0))  as [Total Amount] from #temp_t3 group by sub,str) a
	order by a.sub,a.str,a.no	
	
	End

Else IF @summary_option='c'
Begin


	create table #temp_sub2([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
	items varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
	,[Total MTM] float)


	
		DECLARE a_cursor CURSOR FOR
		select distinct   sub,str,book from (select sub,str,book from #temp_cash_flow3  UNION select sub,str,book
		from #temp_fair_value3 UNION select sub,str,book from #temp_mtm3) a
		 order by sub
		
		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @subname,@strname,@bookname
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			set @i=7
			while @i<>0
				Begin
					if @i=1
					set @item_name='Total MTM Energy Contract Net Assets at ('+ dbo.FNADateFormat(@beginning_date)+')'
					else if @i=2
					set @item_name='Total Change in Fair Value Excluding Reclassification to Realized at Settlement of Contracts'
					else if @i=3
					set @item_name='Reclassification to Realized at Settlement of Contracts'
					else if @i=4
					set @item_name='Effective Portion of Changes in Fair Value - Recorded in OCI'
					else if @i=5
					set @item_name='Ineffective Portion of Changes in Fair Value - Recorded in Earnings'
					else if @i=6
					set @item_name='Net Option Premium Payments' 
					else if @i=7
					set @item_name='Purchase/Sale of Existing Contracts or Portfolios Subject to MTM'
					else if @i=8
					set @item_name='Total MTM Energy Contract Net Assets at (' + dbo.FNADateFormat(@as_of_date) + ')'  

					insert into #temp_sub2 values(@subname,@strname,@bookname,@i,@item_name,0,0,0,0)					
					set @i=@i-1
				End
			
			FETCH NEXT FROM a_cursor INTO  @subname,@strname,@bookname
		END 
		CLOSE a_cursor
		DEALLOCATE  a_cursor		
	--select * from #temp_sub2
	--return
	create table #temp_t4([No] int,sub varchar(100) COLLATE DATABASE_DEFAULT,str varchar(100) COLLATE DATABASE_DEFAULT,book varchar(100) COLLATE DATABASE_DEFAULT,items varchar(100) COLLATE DATABASE_DEFAULT,[Total Amount] float)
	set @temptable_name='#temp_t4'
  	
	insert into  #temp_t4 select z.[No],z.[Sub] as [Subsidiary],z.str as [Strategy],z.book as [Book],
	z.[Items],round(ISNULL(x.[Total Amount],0),0) as [Total Amount] from(
	select 1 as [NO],a.sub,a.str,a.book,'Total MTM Energy Contract Net Assets at('+ dbo.FNADateFormat(@beginning_date)+')' as [Items],SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,book,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow3 where NO=1) Union
	(select sub,str,book,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_value3 where NO=1)Union
	(select sub,str,book,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtm3 where NO=1)) a
	group by a.sub,a.str,a.book
	UNION
	select 2 as [NO],a.sub,a.str,a.book,'Total Change in Fair Value Excluding Reclassification to Realized at Settlement of Contracts' as [Items],
	SUM(Isnull(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,book,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_value3 where NO=4)Union
	(select sub,str,book,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtm3 where NO=4)) a
	group by a.sub ,a.str,a.book
	UNION
	select 3 as [NO],a.sub,a.str,a.book,'Reclassification to Realized at Settlement of Contracts' as [Items],SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,book,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow3 where NO=2) Union
	(select sub,str,book,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_value3 where NO=2)Union
	(select sub,str,book,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtm3 where NO=2)) a
	group by a.sub	,a.str,a.book
	UNION
	select 4 as [NO],a.sub,a.str,a.book,'Effective Portion of Changes in Fair Value - Recorded in OCI' as [Items],
	SUM(ISNULL(a.[AOCI  (Effective)],0)) as [Total Amount] from (
	(select sub,str,book,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow3 where NO=3)UNION
	(select sub,str,book,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow3 where NO=4)
	) a
	group by a.sub	 ,a.str,a.book
	UNION
	select 5 as [NO],a.sub,a.str,a.book,'Ineffective Portion of Changes in Fair Value - Recorded in Earnings' as [Items],
	SUM(ISNULL(a.[PNL Ineff],0)) as [Total Amount] from (
	(select sub,str,book,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow3 where NO=3)UNION
	(select sub,str,book,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flow3 where NO=4)
	) a
	group by a.sub	,a.str,a.book
	UNION
	select 6 as [NO],a.sub,a.strategy,a.book,'Net Option Premium Payments' as [Items],SUM(a.[Total MTM]) as [Total Amount] from
	(select  sub,strategy,book,[Total MTM] from #temp_op) a
	group by a.sub	 ,a.strategy,a.book
	UNION

	select 7 as [NO],a.sub,a.str,a.book,'Purchase/Sale of Existing Contracts or Portfolios Subject to MTM' as [Items],
	SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[Total MTM],0)) as [Total Amount] from(
	(select sub,str,book,[NO],0 AS [AOCI  (Effective)],0 AS [PNL Ineff], [PNL Ineff] as [PNL MTM] ,0 as [Total MTM] from #temp_fair_value3 where NO=3)UNION
	(select sub,str,book,[NO],0 AS [AOCI  (Effective)],0 AS [PNL Ineff],0 as [PNL MTM] ,ISNULL([Total MTM],0) as [Total MTM] from #temp_mtm3 where NO=3) UNION
	(select sub,str,book,[NO],ISNULL([AOCI  (Effective)],0) AS [AOCI  (Effective)],ISNULL([PNL Ineff],0) AS [PNL Ineff],0 as [PNL MTM] ,0 as [Total MTM] from #temp_cash_flow3 where NO=3)
	) a
	group by a.sub	 ,a.str,a.book
	) x RIGHT OUTER JOIN #temp_sub2 z on
	x.no=z.no and x.sub=z.sub and x.str=z.str and x.book=z.book order by z.sub,z.str,z.book,z.no
		
	select  Sub,str as Strategy,book as Book,Items,[Total Amount] from(
	select [no],sub,str,book,items,[total amount] from #temp_t4  
	UNION	
	select 8 as [NO],sub,str,book,'Total MTM Energy Contract Net Assets at (' + dbo.FNADateFormat(@as_of_date) + ')' as [Items],
	SUM(ISNULL([TOTAL Amount],0))  as [Total Amount] from #temp_t4 group by sub,str,book) a
	order by a.sub,a.str,a.book,a.no	
	
	End


End

/*-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
*/

IF @report_type='b'
	Begin
/*---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------FAIR VALUE------------------------------------------------------------
*/
		
	
	SET @Sql_Select = 'SELECT 1 AS NO,'  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id , ' END +
			'''Beginning net positions at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] , ' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'link_id , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'link_deal_flag , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'term_month , ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' ),0) AS [Hedge Value],'+
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' ),0) AS [Item Value],'+
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  rmv '
					
		SET @Sql_Where = ' WHERE   hedge_type_value_id = 151 AND (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.term_month >   CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
				
		SET @Sql1 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
	EXEC spa_print @Sql1
	EXEC spa_print'	-----------------------------------'

		----------------------------------
		SET @Sql_Select = 'SELECT 2 AS NO,'  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id , ' END +
			'''Settlements of position included in the opening balance:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'link_id , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'link_deal_flag , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'term_month , ' END +
			CASE WHEN (@summary_option = 't') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.'  END  + case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' ),0) AS [Hedge Value],' +
			CASE WHEN (@summary_option = 't') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.'  END  + case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' ),0) AS [Item Value],' +
			CASE WHEN (@summary_option = 't') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.'  END  + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff] ' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  RMV '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND   (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND  
						(RMV.term_month > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND
						(RMV.term_month <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
					
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
	
		SET @Sql2 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
	EXEC spa_print'	-----------------------------------'
	EXEC spa_print @Sql2
	EXEC spa_print'	-----------------------------------'

		-------------------------------

		
		SET @Sql_Select = 'SELECT  3 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id , ' END +
			'''New positions added during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' ),0) AS [Hedge Value],' +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' ),0) AS [Item Value],' +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 

		SET @Sql_From = ' FROM  '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
					INNER JOIN 
						(SELECT link_id, link_type, max(link_effective_date) link_effective_date,
						CASE 	--WHEN (link_type = ''deal'') THEN ''d'' 
							WHEN (link_type = ''book'') THEN ''b'' 
							WHEN (link_type = ''dlink'') THEN ''o'' 
							ELSE ''l'' 
						END AS link_deal_flag 
						FROM '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + ' calcprocess_deals 
						WHERE calc_type  = ''m'' and  as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102) and link_type <> ''deal'' and hedge_type_value_id = 151
						GROUP BY link_id, link_type) sdh 
						 
						ON sdh.link_id = rmv.link_id AND sdh.link_deal_flag = rmv.link_deal_flag'


		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND     (rmv.link_deal_flag <> ''d'') AND
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND 
						(sdh.link_effective_date > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		SET @Sql3 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

	EXEC spa_print @Sql3
	EXEC spa_print'	-----------------------------------'
			
		SET @Sql_Select = 'SELECT 4 AS NO,'  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id , ' END +
			'''Changes in value of existing positions during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'now.link_id , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'now.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'now.term_month , ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM( ISNULL(now.hedge_mtm,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.hedge_mtm,0) -ISNULL(beginning.' END+ case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ',0)),0) AS [Hedge Value],'+
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM( ISNULL(now.item_mtm,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.item_mtm,0) -ISNULL(beginning.' END + case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ',0)),0) AS [Item Value] ,'+
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM( ISNULL(now.total_pnl,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.total_pnl,0) -ISNULL(beginning.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ',0)),0) AS [PNL Ineff] ' 
						
		SET @Sql_From = ' FROM     	(
						SELECT   as_of_date, rmv.link_id, term_month, rmv.link_deal_flag,' 
						+ case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' as hedge_mtm,'
						+ case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' as item_mtm,'
						+ case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' as total_pnl
						from '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
						INNER JOIN
						(select link_id, link_type, max(link_effective_date) link_effective_date ,
						CASE 	--WHEN (link_type = ''deal'') THEN ''d'' 
							WHEN (link_type = ''book'') THEN ''b'' 
							WHEN (link_type = ''dlink'') THEN ''o'' 
							ELSE ''l'' 
						END AS link_deal_flag
							FROM '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + ' calcprocess_deals 
							WHERE calc_type  = ''m'' and  as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102) and link_type <> ''deal'' and hedge_type_value_id = 151
							GROUP BY link_id, link_type) sdh 
							on sdh.link_id = rmv.link_id AND sdh.link_deal_flag = rmv.link_deal_flag'
						
					
								
		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)
						AND  (sdh.link_effective_date <= CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		

		SET @Sql_Where = @Sql_Where + ')AS now
						LEFT OUTER JOIN '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  beginning
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
							AND now.link_Deal_flag = beginning.link_deal_flag
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 151  '
						
		
	
		SET @Sql4 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

	EXEC spa_print'	-----------------------------------'
	EXEC spa_print @Sql4
	EXEC spa_print'	-----------------------------------'


		----------------------------------------
		SET @Sql_Select = 'SELECT 5 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id , ' END +
			'''Ending net positions  at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' ),0) AS [Hedge Value],' +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' ),0) AS [Item Value],' +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 

		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv '
		
		SET @Sql_Where = ' WHERE  hedge_type_value_id = 151 AND (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND  
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
			
		SET @Sql5 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

	EXEC spa_print'	-----------------------------------'
	EXEC spa_print @Sql5
	EXEC spa_print'	-----------------------------------'


	 	--print  (@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5)
		--EXEC (@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 )


	--------================================================---------------PNL MTM----------------------======================================-----
		SET @Sql_Select = 'SELECT 1 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id , ' END +
			'''Beginning net positions at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] , ' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  rmv '
					
		SET @Sql_Where = ' WHERE   hedge_type_value_id = 151 AND (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.term_month >   CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
				
		SET @Sql6 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
	EXEC spa_print'	-----------------------------------'
	EXEC spa_print @Sql6
	EXEC spa_print'	-----------------------------------'


		----------------------------------
		SET @Sql_Select = 'SELECT 2 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id , ' END +
			'''Settlements of position included in the opening balance:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 't') THEN	'-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM] ' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  RMV '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND   (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND  
						(RMV.term_month > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND
						(RMV.term_month <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		
		SET @Sql7 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
	EXEC spa_print'	-----------------------------------'
	EXEC spa_print @Sql7
	EXEC spa_print'	-----------------------------------'


		-------------------------------

		
		SET @Sql_Select = 'SELECT  3 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id , ' END +
			'''New positions added during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 

		SET @Sql_From = ' FROM  '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
					INNER JOIN 
						source_deal_header sdh 
						 
						ON sdh.source_deal_header_id = rmv.link_id'


		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND     (link_deal_flag = ''d'') AND
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND 
						(sdh.deal_date > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		SET @Sql8 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
	EXEC spa_print'	-----------------------------------'
	EXEC spa_print @Sql8
	EXEC spa_print'	-----------------------------------'


		-----------------------------------
			
		SET @Sql_Select = 'SELECT 4 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id , ' END +
			'''Changes in value of existing positions during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE ' now.link_id , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'now.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'now.term_month , ' END +
			CASE WHEN (@summary_option = 't') THEN 	'ISNULL(SUM( ISNULL(now.total_pnl,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.total_pnl,0) -ISNULL(beginning.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ',0)),0) AS [PNL MTM] ' 
						
		SET @Sql_From = ' FROM     	(
						SELECT   as_of_date, rmv.link_id, term_month, rmv.link_deal_flag,  ' 
						+ case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' as hedge_mtm,'
						+ case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' as item_mtm,'
						+ case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' as total_pnl
						from '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
						INNER JOIN
						source_deal_header sdh 
							on sdh.source_deal_header_id = rmv.link_id'
						
					
								
		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and link_deal_flag = ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)
						AND  (sdh.deal_date <= CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		

		SET @Sql_Where = @Sql_Where + ')AS now
						LEFT OUTER JOIN '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  beginning
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag = ''d'' AND beginning.hedge_type_value_id = 151  '
						
		
	
		SET @Sql9 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

			EXEC spa_print'	-----------------------------------'
	EXEC spa_print @Sql9
	EXEC spa_print'	-----------------------------------'



		----------------------------------------
		SET @Sql_Select = 'SELECT 5 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id ,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id ,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id , ' END +
			'''Ending net positions at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag , ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month , ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 

		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv '
		
		SET @Sql_Where = ' WHERE  hedge_type_value_id = 151 AND (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND  
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
			
		SET @Sql10 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
	EXEC spa_print'	-----------------------------------'
	EXEC spa_print @Sql10
	EXEC spa_print'	-----------------------------------'



		--print  (@sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10 )
		--EXEC (@sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10 )
	
	
		--PUT all columns together
			
		declare @st3 varchar(8000),@st4 varchar(8000)
		IF @summary_option = 's'
			Begin
			declare @st2 varchar(8000)
			set @temptable_name='#temp_fair_valueb'
			create table #temp_fair_valueb([NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,
			[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
			
		set @st='
				Insert into '+@temptable_name+' Select  r.no,r.items,r.term,
		SUM(r.[AOCI]) as [AOCI],SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as [Total PNL]  	
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.Items, B.Items) AS Items,
				COALESCE(A.link_id, B.link_id) AS ID,
				CASE 	WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''d'') THEN ''Deal'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''b'') THEN ''Book'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''l'') THEN ''Link'' 
					ELSE COALESCE(A.link_deal_flag, B.link_deal_flag) END AS [Group],
				dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],
			0 as [AOCI],[PNL INeff],[PNL MTM],ISNULL([PNL Ineff],0)+ ISNULL([PNL MTM],0) As [Total PNL]
			'
		set @st1='
		FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 
		set @st2= ' UNION ' + @sql4  +' UNION ' + @sql5  + ') A 
					FULL OUTER JOIN '
		set @st3='
					(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  
		set @st4 =' UNION ' + @sql10  + ') B 
						ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
						) r
						group by r.no,r.items,r.term
						 ORDER BY r.NO, CAST((r.Term + ''-01'') as datetime) '
EXEC spa_print ')))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))'
EXEC spa_print @st
EXEC spa_print @st1
EXEC spa_print @st2
EXEC spa_print @st3
EXEC spa_print @st4
		exec (@st+@st1+@st2+@st3+@st4)
	End
			
		Else IF @summary_option='a'
			Begin
			set @temptable_name='#temp_fair_valueb1'
			create table #temp_fair_valueb1([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,
			[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
	 		
			set @st='Insert into '+@temptable_name+' Select s.entity_name AS Sub,r.NO,r.Items,term, 
				SUM(r.[AOCI]) as [AOCI],SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as [Total PNL]  
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.Items, B.Items) AS Items,
				dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],	
				0 as [AOCI],[PNL INeff],[PNL MTM],ISNULL([PNL Ineff],0)+ ISNULL([PNL MTM],0) As [Total PNL]
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3  
		set @st1=' UNION ' + @sql4  + ' UNION '+ @sql5+') A FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
			) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				GROUP BY s.entity_name,r.NO,r.Items,r.term
				ORDER BY s.entity_name,r.NO'
			exec (@st+@st)
			End

		Else IF @summary_option='b'
			Begin	
		 
			set @temptable_name='#temp_fair_valueb2'
			create table #temp_fair_valueb2([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
			items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
			set @st='Insert into '+@temptable_name+' Select s.entity_name AS Sub,st.entity_name as Str,r.NO,	r.Items,term, 
			SUM(r.[AOCI]) as [AOCI],SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as [Total PNL]  
					FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
					COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
					COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
					COALESCE(A.book_entity_id, B.book_entity_id) AS Book,
					COALESCE(A.Items, B.Items) AS Items,
					dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],	
				0 as [AOCI],[PNL INeff],[PNL MTM],ISNULL([PNL Ineff],0)+ ISNULL([PNL MTM],0) As [Total PNL]
			'
		set @st1='
				FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A FULL OUTER JOIN
				(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
					ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
					 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
					 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
					GROUP BY s.entity_name,st.entity_name,r.NO,r.Items,r.term
					ORDER BY s.entity_name,r.NO'
				exec(@st+@st1)


			End	
		Else IF @summary_option='c'
			Begin	

			set @temptable_name='#temp_fair_valueb3'
			create table #temp_fair_valueb3([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,
			[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
 
			set @st='Insert into '+@temptable_name+' Select s.entity_name AS Sub,st.entity_name as Str,b.entity_name as Book,r.NO,r.Items,term, 
				SUM(r.[AOCI]) as [AOCI],SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as [Total PNL]  
					FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
					COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
					COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
					COALESCE(A.book_entity_id, B.book_entity_id) AS Book,
					COALESCE(A.Items, B.Items) AS Items,
				dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],
					0 as [AOCI],[PNL INeff],[PNL MTM],ISNULL([PNL Ineff],0)+ ISNULL([PNL MTM],0) As [Total PNL]'
			set @st1='
				FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A FULL OUTER JOIN
				(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
					ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
					 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
					 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
					 LEFT OUTER JOIN portfolio_hierarchy b ON b.entity_id = r.Book
					GROUP BY s.entity_name,st.entity_name,b.entity_name,r.NO,r.Items,r.term
					ORDER BY s.entity_name,r.NO'
					exec(@st+@st1)

			End			
		Else IF @summary_option = 'd'
			Begin
			set @temptable_name='#temp_fair_valueb4'
			create table #temp_fair_valueb4([NO] int,[Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,items varchar(100) COLLATE DATABASE_DEFAULT,
			[ID] int,[Group] varchar(100) COLLATE DATABASE_DEFAULT,[Term] Varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
 
			set @st='Insert into '+@temptable_name+' Select r.NO, s.entity_name AS Sub, st.entity_name AS Str, b.entity_name AS Book,
				r.Items, r.ID, r.[Group], r.[Term],
				r.[AOCI] as [AOCI],r.[PNL Ineff] as [PNL Ineff],r.[PNL MTM] as [PNL MTM],r.[Total PNL] as [Total PNL]  
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
				COALESCE(A.book_entity_id, B.book_entity_id) AS Book,
				COALESCE(A.Items, B.Items) AS Items,
				COALESCE(A.link_id, B.link_id) AS ID,
				CASE 	WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''d'') THEN ''Deal'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''b'') THEN ''Book'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''l'') THEN ''Link'' 
					ELSE COALESCE(A.link_deal_flag, B.link_deal_flag) END AS [Group],
				dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],
				0 as [AOCI],0 as [PNL Ineff],ISNULL([Hedge Value],0) as [PNL MTM],ISNULL([Hedge Value],0)+ISNULL([PNL Ineff],0)+ ISNULL([PNL MTM],0) As [Total PNL]
'
		set @st1='
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
			) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
				 LEFT OUTER JOIN portfolio_hierarchy b ON b.entity_id = r.Book
				ORDER BY r.NO'
			exec(@st+@st1)

			End




/*----------------------------------------------- END FAIR VALUE-----------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
*/
/*------------------------------------------------------------ -----------------------------------------------------
--------------------------------------------------CASH FLOW-------------------------------------------------------
*/

SET @Sql_Select = 'SELECT 1 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id, ' END +
			'''Beginning net positions at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ),0) AS [AOCI],'+
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  rmv '
					
		SET @Sql_Where = ' WHERE   hedge_type_value_id = 150 AND (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.term_month >   CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
				
		SET @Sql1 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		----------------------------------
		SET @Sql_Select = 'SELECT 2 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id, ' END +
			'''Settlements of position included in the opening balance:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 't') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ),0) AS [AOCI],' +
			CASE WHEN (@summary_option = 't') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff] ' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  RMV '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND  
						(RMV.term_month > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND
						(RMV.term_month <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		
		SET @Sql2 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		
		-------------------------------

		
		SET @Sql_Select = 'SELECT  3 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id, ' END +
			'''New positions added during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ),0) AS [AOCI],' +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 

		SET @Sql_From = ' FROM  '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
					LEFT OUTER JOIN 
						(SELECT link_id, link_type, max(link_effective_date) link_effective_date ,
						CASE 	--WHEN (link_type = ''deal'') THEN ''d'' 
							WHEN (link_type = ''book'') THEN ''b'' 
							WHEN (link_type = ''dlink'') THEN ''o'' 

							ELSE ''l'' 
						END AS link_deal_flag
						FROM '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + ' calcprocess_deals 
						WHERE calc_type  = ''m'' and  as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102) and link_type <> ''deal'' and hedge_type_value_id = 150
						GROUP BY link_id, link_type) sdh 
						 
						ON sdh.link_id = rmv.link_id AND sdh.link_deal_flag = rmv.link_deal_flag'


		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND     (rmv.link_deal_flag <> ''d'') AND
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND 
						(sdh.link_effective_date > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		SET @Sql3 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-----------------------------------
			
		SET @Sql_Select = 'SELECT 4 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id, ' END +
			'''Changes in value of existing positions during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE ' now.link_id, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'now.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'now.term_month, ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM( ISNULL(now.total_aoci,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.total_aoci,0) -ISNULL(beginning.' END + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ',0)),0) AS [AOCI],' +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM( ISNULL(now.total_pnl,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.total_pnl,0) -ISNULL(beginning.' END  + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ',0)),0) AS [PNL Ineff] ' 
						
		SET @Sql_From = ' FROM     	(
						SELECT   as_of_date, rmv.link_id, term_month, rmv.link_deal_flag, ' 
						+ case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' as total_aoci,'
						+ case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' as total_pnl
						from '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
						INNER JOIN
						(select link_id, link_type, max(link_effective_date) link_effective_date ,
							CASE 	--WHEN (link_type = ''deal'') THEN ''d'' 
							WHEN (link_type = ''book'') THEN ''b'' 
							WHEN (link_type = ''dlink'') THEN ''o'' 
							ELSE ''l'' 
						END AS link_deal_flag
							FROM '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + ' calcprocess_deals 
							WHERE calc_type  = ''m'' and  as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102) and link_type <> ''deal'' and hedge_type_value_id = 150
							GROUP BY link_id, link_type) sdh 
							on sdh.link_id = rmv.link_id  AND sdh.link_deal_flag = rmv.link_deal_flag'
						
					
								
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)
						AND  (sdh.link_effective_date <= CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '

		

		SET @Sql_Where = @Sql_Where + ')AS now
						LEFT OUTER JOIN '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  beginning
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
							AND now.link_deal_flag = beginning.link_deal_flag
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 150  '
						
		
	
		SET @Sql4 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		

		----------------------------------------
		SET @Sql_Select = 'SELECT 5 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id, ' END +
			'''Ending net positions at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END +  case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ),0) AS [AOCI],' +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END  + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL Ineff]' 

		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv '
		
		SET @Sql_Where = ' WHERE  hedge_type_value_id = 150 AND (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND  
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
			
		SET @Sql5 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy


	 	--print  (@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5)
		--EXEC (@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 )
	

	--------================================================---------------PNL MTM----------------------======================================-----
		SET @Sql_Select = 'SELECT 1 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id, ' END +
			'''Beginning net positions at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  rmv '
					
		SET @Sql_Where = ' WHERE   hedge_type_value_id = 150 AND (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.term_month >   CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
				
		SET @Sql6 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		----------------------------------
		SET @Sql_Select = 'SELECT 2 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id, ' END +
			'''Settlements of position included in the opening balance:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 't') THEN '-1 * ISNULL(SUM(RMV.' ELSE '-1 * ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM] ' 
				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  RMV '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND  
						(RMV.term_month > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND
						(RMV.term_month <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		
		SET @Sql7 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		
		-------------------------------

		
		SET @Sql_Select = 'SELECT  3 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id, ' END +
			'''New positions added during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END  + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 

		SET @Sql_From = ' FROM  '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
					INNER JOIN 
						source_deal_header sdh 
						 
						ON sdh.source_deal_header_id = rmv.link_id'


		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND     (link_deal_flag = ''d'') AND
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND 
						(sdh.deal_date > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
			SET @Sql8 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-----------------------------------
			
		SET @Sql_Select = 'SELECT 4 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id, ' END +
			'''Changes in value of existing positions during the period:'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE ' now.link_id, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'now.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'now.term_month, ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM( ISNULL(now.total_pnl,0) -ISNULL(beginning.' ELSE 'ISNULL(( ISNULL(now.total_pnl,0) -ISNULL(beginning.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ',0)),0) AS [PNL MTM] ' 
						
		SET @Sql_From = ' FROM     	(
						SELECT   as_of_date, rmv.link_id, term_month, rmv.link_deal_flag, ' 
						+ case when (@discount_option = 'd') then 'd_hedge_mtm' else 'u_hedge_mtm' end + ' as hedge_mtm,'
						+ case when (@discount_option = 'd') then 'd_item_mtm' else 'u_item_mtm' end + ' as item_mtm,'
						+ case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' as total_pnl
						from '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
						INNER JOIN

						source_deal_header sdh 
							on sdh.source_deal_header_id = rmv.link_id'
						
					
								
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and link_deal_flag = ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)
						AND  (sdh.deal_date <= CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		

		SET @Sql_Where = @Sql_Where + ')AS now
						LEFT OUTER JOIN '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  beginning
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag = ''d'' AND beginning.hedge_type_value_id = 150  '
						
		
	
		SET @Sql9 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy


		----------------------------------------
		SET @Sql_Select = 'SELECT 5 AS NO, '  +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'sub_entity_id,' END + 
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'strategy_entity_id,' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'book_entity_id, ' END +
			'''Ending net positions at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,' +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_id, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.link_deal_flag, ' END +
			CASE WHEN (@summary_option = 't') THEN '' ELSE 'rmv.term_month, ' END +
			CASE WHEN (@summary_option = 't') THEN 'ISNULL(SUM(RMV.' ELSE 'ISNULL((RMV.' END + case when (@discount_option = 'd') then 'd_total_pnl' else 'u_total_pnl' end + ' ),0) AS [PNL MTM]' 

		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv '
		
		SET @Sql_Where = ' WHERE  hedge_type_value_id = 150 AND (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND  
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
			
		SET @Sql10 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy


		--print  (@sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10 )
		--EXEC (@sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10 )
	
	
		--PUT all columns together
	
	IF @summary_option = 's' 
		Begin	
			set @temptable_name='#temp_cash_flowb'

			create table #temp_cash_flowb([NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,
			[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
			

			--EXEC('Insert into '+@temptable_name+' SELECT  distinct A.NO, A.Items,dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term], [AOCI], [PNL Ineff],0,
			--		ISNULL([AOCI],0)+ISNULL([PNL Ineff],0)+ISNULL([PNL MTM],0) As [Total PNL]
			--FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A FULL OUTER JOIN
			--(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
			--	ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month ')

		
			set @st='  Insert into '+@temptable_name+' Select  distinct r.no,r.items,r.term, SUM(r.[AOCI]) as [AOCI],
				SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as  [Total PNL]  
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.Items, B.Items) AS Items,
				COALESCE(A.link_id, B.link_id) AS ID,
				CASE 	WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''d'') THEN ''Deal'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''b'') THEN ''Book'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''l'') THEN ''Link'' 
					ELSE COALESCE(A.link_deal_flag, B.link_deal_flag) END AS [Group],
				dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],
			[AOCI], [PNL Ineff],[PNL MTM],
			ISNULL([AOCI],0)+ISNULL([PNL Ineff],0)+ISNULL([PNL MTM],0) As [Total PNL]
			'
		set @st1='
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  +' UNION ' + @sql5  + ') A 
			FULL OUTER JOIN '
		set @st2='
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  +' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
				group by r.no,r.term,r.items
				 ORDER BY r.NO, r.[Total PNL] '  
		EXEC spa_print 'vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv'		
		EXEC spa_print @st
		EXEC spa_print @st1
		EXEC spa_print @st2
		exec(@st+@st1+@st2)
		End
	ELSE IF @summary_option = 'a' 
			Begin
				set @temptable_name='#temp_cash_flowb1'
				create table #temp_cash_flowb1([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,
				[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
				,[Total MTM] float)
	
			set @st='Insert into '+@temptable_name+'  Select s.entity_name AS Sub,r.NO,  
				r.Items,term,SUM(r.[AOCI]) as [AOCI],
				SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as  [Total PNL]
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.Items, B.Items) AS Items,
				dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],
				[AOCI], [PNL Ineff],0 as [PNL MTM],
				ISNULL([AOCI],0)+ISNULL([PNL Ineff],0)+ISNULL([PNL MTM],0) As [Total PNL]
			'
			set @st1=' FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A 
			FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				GROUP BY r.NO,s.entity_name,r.Items,r.term
				ORDER BY r.NO, s.entity_name 
				'
					exec(@st+@st1)

		End
	
	ELSE IF @summary_option='b'
		Begin
			set @temptable_name='#temp_cash_flowb2'
			create table #temp_cash_flowb2([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)

		set @st='Insert into '+@temptable_name+'  Select s.entity_name AS Sub,st.entity_name AS Str,r.NO,  
				r.Items,term, SUM(r.[AOCI]) as [AOCI],
				SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as  [Total PNL]
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
				COALESCE(A.Items, B.Items) AS Items,
				dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],
				[AOCI], [PNL Ineff],0 as [PNL MTM],
				ISNULL([AOCI],0)+ISNULL([PNL Ineff],0)+ISNULL([PNL MTM],0) As [Total PNL]
		'
			set @st1='
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A 
			FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
				GROUP BY r.NO,s.entity_name,st.entity_name,r.Items,r.term
				ORDER BY r.NO, s.entity_name 
				'
		exec(@st+@st1)

		
		End
	ELSE IF @summary_option = 'c'
		Begin
			
			set @temptable_name='#temp_cash_flowb3'
			create table #temp_cash_flowb3([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,
			[Book] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)
			set @st='Insert into '+@temptable_name+'  Select s.entity_name AS Sub, st.entity_name AS Str,b.entity_name as Book,r.NO,  
				r.Items,term,SUM(r.[AOCI]) as [AOCI]
				,SUM(r.[PNL Ineff]) as [PNL Ineff],SUM(r.[PNL MTM]) as [PNL MTM],SUM(r.[Total PNL]) as [Total PNL]
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
				COALESCE(A.book_entity_id, B.book_entity_id) AS Book,
				COALESCE(A.Items, B.Items) AS Items,
				dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],
				[AOCI], [PNL Ineff],0 as [PNL MTM],
				ISNULL([AOCI],0)+ISNULL([PNL Ineff],0)+ISNULL([PNL MTM],0) As [Total PNL]
		'
	set @st1='
	FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A 
			FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
				 LEFT OUTER JOIN portfolio_hierarchy b ON b.entity_id = r.Book
				GROUP BY s.entity_name,st.entity_name,b.entity_name,r.NO, r.items,r.term
				ORDER BY s.entity_name, st.entity_name, b.entity_name,r.NO 
				'
		exec(@st+@st1)

		End

	ELSE IF @summary_option = 'd'
		Begin
			set @temptable_name='#temp_cash_flowb4'
			create table #temp_cash_flowb4([NO] int,[Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,items varchar(100) COLLATE DATABASE_DEFAULT,
			[ID] int,[Group] varchar(100) COLLATE DATABASE_DEFAULT,[Term] Varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
			,[Total MTM] float)

			set @st='Insert into '+@temptable_name+'  Select r.NO, s.entity_name AS Sub, st.entity_name AS Str, b.entity_name AS Book,
				r.Items, r.ID, r.[Group], r.[Term], r.[AOCI], r.[PNL Ineff], r.[PNL MTM], r.[Total PNL]  
				FROM (SELECT COALESCE(A.NO, B.NO) AS NO, 
				COALESCE(A.sub_entity_id, B.sub_entity_id) AS Sub,
				COALESCE(A.strategy_entity_id, B.strategy_entity_id) AS Str,
				COALESCE(A.book_entity_id, B.book_entity_id) AS Book,
				COALESCE(A.Items, B.Items) AS Items,
				COALESCE(A.link_id, B.link_id) AS ID,
				CASE 	WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''d'') THEN ''Deal'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''b'') THEN ''Book'' 
					WHEN (COALESCE(A.link_deal_flag, B.link_deal_flag) = ''l'') THEN ''Link'' 
					ELSE COALESCE(A.link_deal_flag, B.link_deal_flag) END AS [Group],
				dbo.FNAContractMonthFormat(COALESCE(A.term_month, B.term_month)) AS [Term],
			[AOCI], [PNL Ineff],0 as [PNL MTM],
				ISNULL([AOCI],0)+ISNULL([PNL Ineff],0)+ISNULL([PNL MTM],0) As [Total PNL]
			'
			set @st1='
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ') A 
			FULL OUTER JOIN
			(' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 + ' UNION ' + @sql9  + ' UNION ' + @sql10  + ') B 
				ON A.NO = B.NO AND A.link_deal_flag = B.link_deal_flag AND A.term_month = B.term_month
				) r
				 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.Sub
				 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
				 LEFT OUTER JOIN portfolio_hierarchy b ON b.entity_id = r.Book
				ORDER BY r.NO, s.entity_name, st.entity_name, b.entity_name, r.[Group], r.ID, CAST((r.Term + ''-01'') as datetime) 
				'
		exec(@st+@st1)


		End

/*----------------------------------------------- END CASH FLOW-----------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
*/
/*------------------------------------------------------------ -----------------------------------------------------
-------------------------------------------------- MTM-----------------------------------------------------------
*/


		If (@summary_option = 't')
			SET @Sql_Select = 'SELECT 1 AS NO, ''Beginning net MtM balance at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] , ISNULL(SUM(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' ),0) AS [TotalAmount]' 

		Else
			SET @Sql_Select = 'SELECT 1 AS NO, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Beginning net MtM balance at beginning date (' + dbo.FNADateFormat(@beginning_date) + ') :'' AS [Items] ,' +
					'link_id ID, ''Deal'' [Group], dbo.FNADateFormat(term_month) Term, ISNULL(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ', 0) AS [TotalAmount]'  
		
		
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  rmv '
		If (@summary_option <> 't')
			SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '
			
					
		SET @Sql_Where = ' WHERE   (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
						(RMV.term_month >   CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
				
		SET @Sql1 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		
		----------------------------------
		If (@summary_option = 't')
			SET @Sql_Select = 'SELECT 2 AS NO, ''Settlements of position included in the opening balance:'' AS [Items] ,-1 * ISNULL(SUM(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' ),0) AS [TotalAmount] ' 
		Else 
			SET @Sql_Select = 'SELECT 2 AS NO, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Settlements of position included in the opening balance:'' AS [Items],' +
					'link_id ID, ''Deal'' [Group], dbo.FNADateFormat(term_month) Term, -1 * ISNULL(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ', 0 ) AS [TotalAmount]'  

				
		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  RMV '
		If (@summary_option <> 't')
			SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '
		
		SET @Sql_Where = ' WHERE   (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND  
						(RMV.term_month > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) AND
						(RMV.term_month <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
							                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		
		SET @Sql2 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-------------------------------
		If (@summary_option = 't')
			SET @Sql_Select = 'SELECT  3 AS NO, ''New positions added during the period:'' AS [Items] ,ISNULL(SUM(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' ),0) AS [TotalAmount] ' 
		Else 
			SET @Sql_Select = 'SELECT 3 AS NO, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''New positions added during the period:'' AS [Items] ,' +
					'link_id ID, ''Deal'' [Group], dbo.FNADateFormat(term_month) Term, ISNULL(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ', 0) AS [TotalAmount] '  
		
		SET @Sql_From = ' FROM  '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv INNER JOIN source_deal_header sdh 
						ON sdh.source_deal_header_id = rmv.link_id'
		If (@summary_option <> 't')
			SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '

		SET @Sql_Where = ' WHERE   (link_deal_flag = ''d'') AND
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND 
						(sdh.deal_date > CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND 
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		SET @Sql3 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-----------------------------------
			
		If (@summary_option = 't')
			SET @Sql_Select = 'SELECT 4 AS NO, ''Changes in value of existing positions during the period:'' AS [Items] , SUM( ISNULL(now.d_pnl_mtm,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ',0)) AS [TotalAmount] ' 
		Else 
			SET @Sql_Select = 'SELECT 4 AS NO, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Changes in value of existing positions during the period:'' AS [Items] ,' +
					'now.link_id ID, ''Deal''  [Group], dbo.FNADateFormat(now.term_month) Term, (ISNULL(now.d_pnl_mtm,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ',0)) AS [TotalAmount] '  

					
		SET @Sql_From = ' FROM     	(
						SELECT   ' +
				case when (@summary_option <> 't') then 'sub_entity_id, strategy_entity_id, book_entity_id, ' else '' end +
						' as_of_date, link_id, term_month, ' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' as d_pnl_mtm 
						from '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv INNER JOIN source_deal_header sdh 
						ON sdh.source_deal_header_id = rmv.link_id '
						
					
								
		SET @Sql_Where = ' WHERE as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and link_deal_flag = ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)
						AND 
						(sdh.deal_date <= CONVERT(DATETIME, ''' + @beginning_date  +''', 102)) 
						AND   
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		

		SET @Sql_Where = @Sql_Where + ')AS now ' +
		case when (@summary_option <> 't') then
			' INNER JOIN portfolio_hierarchy s ON s.entity_id = now.sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = now.strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = now.book_entity_id '	
			else '' end +
						' LEFT OUTER JOIN '+ dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + '  beginning
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
							AND beginning.link_deal_flag = ''d'' '
						
		
	
		SET @Sql4 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		--print @Sql4

		----------------------------------------
		If (@summary_option = 't')
			SET @Sql_Select = 'SELECT 5 AS NO, ''Ending net MtM balance at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,ISNULL(SUM(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' ),0)  AS [TotalAmount]' 
		Else 
			SET @Sql_Select = 'SELECT 5 AS NO, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Ending net MtM balance at end date (' + dbo.FNADateFormat(@as_of_date) + ') :'' AS [Items] ,' +
					'link_id ID, ''Deal'' [Group], dbo.FNADateFormat(term_month) Term, ISNULL(RMV.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' ,0)  AS [TotalAmount]'  



		SET @Sql_From = ' FROM     '+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv '
		If (@summary_option <> 't')
			SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '
		
		SET @Sql_Where = ' WHERE   (link_deal_flag = ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND 
						(RMV.term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND  
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
			
		SET @Sql5 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

-- 	END

	IF @summary_option='s'
		Begin

		set @temptable_name='#temp_mtmbb'
		create table #temp_mtmbb([NO] int,items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,
		[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
		,[Total MTM] float)
	
	--Exec('Insert into '+@temptable_name+' select A.NO,A.items,dbo.FNAContractMonthFormat(A.term) AS [Term],
		--0,0,A.[TotalAmount],A.[TotalAmount] from 
		--( '+@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5+' ) A') 
	
		EXEC('  Insert into '+@temptable_name+' Select  r.no,r.items,r.term, 
		SUM(0),SUM(0),SUM(r.[Total PNL]),SUM(r.[Total PNL]) as [TotalAmount]
				FROM (SELECT A.NO AS NO, 
				A.Items Items,
				dbo.FNAContractMonthFormat(A.term) AS [Term],
			ISNULL([TotalAmount],0) As [Total PNL]
			FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  +' UNION ' + @sql5  + ') A 
				) r
				group by r.no,r.term,r.items
				 ORDER BY r.NO   
				')		
		End	

	if @summary_option='a'
		Begin
		set @temptable_name='#temp_mtmbb1'
		create table #temp_mtmbb1([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
		items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
		,[Total MTM] float)

		EXEC('Insert into '+@temptable_name+' select ISNULL(r.SUB,0) as Sub,ISNULL(r.NO,0)
		,ISNULL(r.items,0),dbo.FNAContractMonthFormat(r.term) AS [Term],
		SUM(0),SUM(0),SUM(r.[TotalAmount]),SUM(r.[TotalAmount]) as [TotalAmount] from ('+@sql1 + 
		' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5+') r 
		group by r.SUB,r.NO,r.items,dbo.FNAContractMonthFormat(r.term) order by r.SUB,r.NO') 


		End

	Else if @summary_option='b'
		Begin
		set @temptable_name='#temp_mtmbb2'
		create table #temp_mtmbb2([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
		items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
		,[Total MTM] float)
		EXEC ('Insert into '+@temptable_name+' select r.SUB as Sub,r.str Str,r.NO,r.items,
		dbo.FNAContractMonthFormat(r.term) AS [Term],0,0,SUM(r.[TotalAmount]),SUM(r.[TotalAmount]) from(
		'+@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5+') r
		group by r.SUB,r.str,r.NO,r.items,dbo.FNAContractMonthFormat(r.term)  order by r.SUB,r.str,r.NO' )
		
		End

	Else if @summary_option='c'
		Begin
		set @temptable_name='#temp_mtmbb3'
		create table #temp_mtmbb3([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
		items varchar(100) COLLATE DATABASE_DEFAULT,term_month varchar(100) COLLATE DATABASE_DEFAULT,[AOCI  (Effective)] float,[PNL Ineff] float, [PNL MTM] float
		,[Total MTM] float)
		EXEC ('Insert into '+@temptable_name+' select r.SUB as Sub,r.str Str, r.book As Book,r.NO,
		r.items,dbo.FNAContractMonthFormat(r.term) AS [Term],SUM(0),SUM(0),SUM(r.[TotalAmount]),SUM(r.[TotalAmount]) from(
		'+@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5+') r
		group by r.SUB,r.str,r.book,r.NO,r.items,dbo.FNAContractMonthFormat(r.term) order by r.SUB,r.str,r.book,r.NO' )
		End

	Else	if @summary_option='d'
		Begin
		
		set @temptable_name='#temp_mtmbb4'
		create table #temp_mtmbb4([NO] int,[Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,
		items varchar(100) COLLATE DATABASE_DEFAULT,[ID] int,[Group] varchar(100) COLLATE DATABASE_DEFAULT,[Term] varchar(100) COLLATE DATABASE_DEFAULT,[Total MTM] float)
		Exec('Insert into '+@temptable_name+' select A.NO,A.sub,A.Str,A.Book,A.items,A.ID,A.[group],A.term,A.[TotalAmount] from 
		 ( '+@sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5+' ) A') 
		
		
		End	


/*------------------------------------------------------------ -----------------------------------------------------
-------------------------------------------------- END MTM-----------------------------------------------------------
*/

--declare @subname varchar(100),@item_name varchar(100),@strname varchar(100),@bookname varchar(100)

	create table #temp_opts(sub varchar(100) COLLATE DATABASE_DEFAULT,str varchar(100) COLLATE DATABASE_DEFAULT,book varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
	deal_date varchar(100) COLLATE DATABASE_DEFAULT,option_premium float)

	set @temptable_name='#temp_opts'
	set @sql_select=' insert into '+@temptable_name+' select s.entity_name as sub,st.entity_name,b.entity_name,6 as [NO],
	dbo.FNAContractMonthFormat(a.deal_date),a.option_premium from
	(select distinct  fas_subsidiary_id,fas_strategy_id,fas_book_id,
	deal_date,  sum(option_premium) as option_premium from '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + '  calcprocess_deals
	where calc_type = ''m'' and option_flag = ''y'' and as_of_date ='''+ @as_of_date +''' and 
	deal_date between '''+@beginning_date+''' and '''+@as_of_date +'''  
	group by  fas_subsidiary_id,fas_strategy_id,fas_book_id,deal_date) a 
	INNER JOIN portfolio_hierarchy s ON s.entity_id =fas_subsidiary_id 
	INNER JOIN portfolio_hierarchy st ON st.entity_id =fas_strategy_id 
	INNER JOIN portfolio_hierarchy b ON b.entity_id =fas_book_id '  
	
	set @Sql_Where=' where  fas_subsidiary_id in ('+@sub_entity_id +') '

	IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' and fas_strategy_id IN(' + @strategy_entity_id + ' )'
	IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' and fas_book_id IN(' + @book_entity_id + ') '
	EXEC(@sql_select+@Sql_Where)


if @summary_option='s'
	Begin
		set @temptable_name='#temp_table'
		create table #temp_table([Term] varchar(100) COLLATE DATABASE_DEFAULT,[Total MTM] float)
	insert into  #temp_table select term_month as Term,ISNULL(x.[Total Amount],0) as [Total Amount] from(
	select 1 as [NO],'Total MTM Energy Contract Net Assets at('+ dbo.FNADateFormat(@beginning_date)+')' as [Items],a.term_month,SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select [NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb where NO=1) Union
	(select [NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb where NO=1)Union
	(select [NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb where NO=1)) a
	group by a.term_month 
	UNION
	select 2 as [NO],'Total Change in Fair Value Excluding Reclassification to Realized at Settlement of Contracts' as [Items],a.term_month,
	SUM(Isnull(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select [NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb where NO=4)Union
	(select [NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb where NO=4)) a
	group by a.term_month  
	UNION
	select 3 as [NO],'Reclassification to Realized at Settlement of Contracts' as [Items],a.term_month,SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select [NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb where NO=2) Union
	(select [NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb where NO=2)Union
	(select [NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb where NO=2)) a
	group by a.term_month 	
	UNION
	select 4 as [NO],'Effective Portion of Changes in Fair Value - Recorded in OCI' as [Items],a.term_month,
	SUM(ISNULL(a.[AOCI  (Effective)],0)) as [Total Amount] from (
	(select [NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb where NO=3)UNION
	(select [NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb where NO=4)

	) a
	group by a.term_month 	 
	UNION
	select 5 as [NO],'Ineffective Portion of Changes in Fair Value - Recorded in Earnings' as [Items],a.term_month,
	SUM(ISNULL(a.[PNL Ineff],0)) as [Total Amount] from (
	(select [NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb where NO=3)UNION
	(select [NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb where NO=4)
	) a
	group by a.term_month 	
	--UNION
	--select 6 as [NO],a.sub,'Net Option Premium Payments' as [Items],SUM(a.[Total MTM]) as [Total Amount] from
	--(select  sub,[Total MTM] from #temp_op) a
	--group by a.sub,a.term_month 	 
	UNION
	select 7 as [NO],'Purchase/Sale of Existing Contracts or Portfolios Subject to MTM' as [Items],a.term_month,
	SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[Total MTM],0)) as [Total Amount] from(
	(select [NO],term_month,0 AS [AOCI  (Effective)],0 AS [PNL Ineff],[PNL Ineff] as [PNL MTM] ,0 as [Total MTM] from #temp_fair_valueb where NO=3)UNION
	(select [NO],term_month,0 AS [AOCI  (Effective)],0 AS [PNL Ineff],0 as [PNL MTM] ,ISNULL([Total MTM],0) as [Total MTM] from #temp_mtmbb where NO=3) UNION
	(select [NO],term_month,ISNULL([AOCI  (Effective)],0) AS [AOCI  (Effective)],ISNULL([PNL Ineff],0) AS [PNL Ineff],0 as [PNL MTM] ,0 as [Total MTM] from #temp_cash_flowb where NO=3)
	) a
	group by a.term_month 	 
	 ) x 
		

	End

if @summary_option='a'
	Begin

	create table #temp_table1(sub varchar(100) COLLATE DATABASE_DEFAULT,term varchar(100) COLLATE DATABASE_DEFAULT,[Total MTM] float)
	set @temptable_name='#temp_table1'
 	
	insert into  #temp_table1 select x.[Sub] as [Subsidiary],
	term_month,ISNULL(x.[Total Amount],0) as [Total Amount] from(
	select 1 as [NO],a.sub,'Total MTM Energy Contract Net Assets at('+ dbo.FNADateFormat(@beginning_date)+')' as [Items],a.term_month,SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,[NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb1 where NO=1) Union
	(select sub,[NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb1 where NO=1)Union
	(select sub,[NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb1 where NO=1)) a
	group by a.sub,a.term_month 
	UNION
	select 2 as [NO],a.sub,'Total Change in Fair Value Excluding Reclassification to Realized at Settlement of Contracts' as [Items],a.term_month,
	SUM(Isnull(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,[NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb1 where NO=4)Union
	(select sub,[NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb1 where NO=4)) a
	group by a.sub,a.term_month  
	UNION
	select 3 as [NO],a.sub,'Reclassification to Realized at Settlement of Contracts' as [Items],a.term_month,SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,[NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb1 where NO=2) Union
	(select sub,[NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb1 where NO=2)Union
	(select sub,[NO],term_month,0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb1 where NO=2)) a
	group by a.sub,a.term_month 	
	UNION
	select 4 as [NO],a.sub,'Effective Portion of Changes in Fair Value - Recorded in OCI' as [Items],a.term_month,
	SUM(ISNULL(a.[AOCI  (Effective)],0)) as [Total Amount] from (
	(select sub,[NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb1 where NO=3)UNION
	(select sub,[NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb1 where NO=4)

	) a
	group by a.sub,a.term_month 	 
	UNION
	select 5 as [NO],a.sub,'Ineffective Portion of Changes in Fair Value - Recorded in Earnings' as [Items],a.term_month,
	SUM(ISNULL(a.[PNL Ineff],0)) as [Total Amount] from (
	(select sub,[NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb1 where NO=3)UNION
	(select sub,[NO],term_month,[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb1 where NO=4)
	) a
	group by a.sub,a.term_month 	
	--UNION
	--select 6 as [NO],a.sub,'Net Option Premium Payments' as [Items],SUM(a.[Total MTM]) as [Total Amount] from
	--(select  sub,[Total MTM] from #temp_op) a
	--group by a.sub,a.term_month 	 
	UNION
	select 7 as [NO],a.sub,'Purchase/Sale of Existing Contracts or Portfolios Subject to MTM' as [Items],a.term_month,
	SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[Total MTM],0)) as [Total Amount] from(
	(select sub,[NO],term_month,0 AS [AOCI  (Effective)],0 AS [PNL Ineff],[PNL Ineff] as [PNL MTM] ,0 as [Total MTM] from #temp_fair_valueb1 where NO=3)UNION
	(select sub,[NO],term_month,0 AS [AOCI  (Effective)],0 AS [PNL Ineff],0 as [PNL MTM] ,ISNULL([Total MTM],0) as [Total MTM] from #temp_mtmbb1 where NO=3) UNION
	(select sub,[NO],term_month,ISNULL([AOCI  (Effective)],0) AS [AOCI  (Effective)],ISNULL([PNL Ineff],0) AS [PNL Ineff],0 as [PNL MTM] ,0 as [Total MTM] from #temp_cash_flowb1 where NO=3)
	) a
	group by a.sub,a.term_month 	 
	 ) x 

	--select * from #temp_table1  order by term
	--return

END

if @summary_option='b'
	Begin

	create table #temp_table2(sub varchar(100) COLLATE DATABASE_DEFAULT,str varchar(100) COLLATE DATABASE_DEFAULT,term varchar(100) COLLATE DATABASE_DEFAULT,[Total MTM] float)
	set @temptable_name='#temp_table2'
 	
	insert into  #temp_table2 select x.[Sub] as [Subsidiary],[str] as [Strategy],
	term_month,ISNULL(x.[Total Amount],0) as [Total Amount] from(
		select 1 as [NO],a.term_month,a.sub,a.str,'Total MTM Energy Contract Net Assets at('+ dbo.FNADateFormat(@beginning_date)+')' as [Items],SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb2 where NO=1) Union
	(select sub,str,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb2 where NO=1)Union
	(select sub,str,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb2 where NO=1)) a
	group by a.sub,a.str,a.term_month
	UNION
	select 2 as [NO],a.term_month,a.sub,a.str,'Total Change in Fair Value Excluding Reclassification to Realized at Settlement of Contracts' as [Items],
	SUM(Isnull(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb2 where NO=4)Union
	(select sub,str,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb2 where NO=4)) a
	group by a.sub ,a.str,a.term_month
	UNION
	select 3 as [NO],a.term_month,a.sub,a.str,'Reclassification to Realized at Settlement of Contracts' as [Items],SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb2 where NO=2) Union
	(select sub,str,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb2 where NO=2)Union
	(select sub,str,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb2 where NO=2)) a
	group by a.sub	,a.str,a.term_month

	UNION
	select 4 as [NO],a.term_month,a.sub,a.str,'Effective Portion of Changes in Fair Value - Recorded in OCI' as [Items],
	SUM(ISNULL(a.[AOCI  (Effective)],0)) as [Total Amount] from (
	(select sub,str,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb2 where NO=3)UNION
	(select sub,str,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb2 where NO=4)
	) a
	group by a.sub	 ,a.str,a.term_month
	UNION
	select 5 as [NO],a.term_month,a.sub,a.str,'Ineffective Portion of Changes in Fair Value - Recorded in Earnings' as [Items],
	SUM(ISNULL(a.[PNL Ineff],0)) as [Total Amount] from (
	(select sub,str,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb2 where NO=3)UNION
		(select sub,str,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb2 where NO=4)
	) a
	group by a.sub	,a.str,a.term_month
	UNION
	select 7 as [NO],a.term_month,a.sub,a.str,'Purchase/Sale of Existing Contracts or Portfolios Subject to MTM' as [Items],
	SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[Total MTM],0)) as [Total Amount] from(
	(select sub,str,term_month,[NO],0 AS [AOCI  (Effective)],0 AS [PNL Ineff], [PNL Ineff] as [PNL MTM] ,0 as [Total MTM] from #temp_fair_valueb2 where NO=3)UNION
	(select sub,str,term_month,[NO],0 AS [AOCI  (Effective)],0 AS [PNL Ineff],0 as [PNL MTM] ,ISNULL([Total MTM],0) as [Total MTM] from #temp_mtmbb2 where NO=3) UNION
	(select sub,str,term_month,[NO],ISNULL([AOCI  (Effective)],0) AS [AOCI  (Effective)],ISNULL([PNL Ineff],0) AS [PNL Ineff],0 as [PNL MTM] ,0 as [Total MTM] from #temp_cash_flowb2 where NO=3)
	) a
	group by a.sub	 ,a.str,a.term_month
	) x 
	

END

if @summary_option='c'
	Begin

	create table #temp_table3(sub varchar(100) COLLATE DATABASE_DEFAULT,str varchar(100) COLLATE DATABASE_DEFAULT,book varchar(100) COLLATE DATABASE_DEFAULT,term varchar(100) COLLATE DATABASE_DEFAULT,[Total MTM] float)
	set @temptable_name='#temp_table3'
 	
	insert into  #temp_table3 select x.[Sub] as [Subsidiary],[str] as [Strategy],[book] as Book,
	term_month,ISNULL(x.[Total Amount],0) as [Total Amount] from(
		select 1 as [NO],a.term_month,a.sub,a.str,a.book,'Total MTM Energy Contract Net Assets at('+ dbo.FNADateFormat(@beginning_date)+')' as [Items],SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,book,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb3 where NO=1) Union
	(select sub,str,book,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb3 where NO=1)Union
	(select sub,str,book,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb3 where NO=1)) a
	group by a.sub,a.str,a.book,a.term_month
	UNION
	select 2 as [NO],a.term_month,a.sub,a.str,a.book,'Total Change in Fair Value Excluding Reclassification to Realized at Settlement of Contracts' as [Items],
	SUM(Isnull(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,book,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb3 where NO=4)Union
	(select sub,str,book,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb3 where NO=4)) a
	group by a.sub ,a.str,a.book,a.term_month
	UNION
	select 3 as [NO],a.term_month,a.sub,a.str,a.book,'Reclassification to Realized at Settlement of Contracts' as [Items],SUM(ISNULL(a.[AOCI  (Effective)],0))+SUM(iSNULL(a.[PNL Ineff],0))+SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[TOTAL MTM],0))  as [Total Amount] from (
	(select sub,str,book,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb3 where NO=2) Union
	(select sub,str,book,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],[PNL MTM],0 as [TOTAL MTM]  from #temp_fair_valueb3 where NO=2)Union
	(select sub,str,book,term_month,[NO],0 as [AOCI  (Effective)],0 as [PNL Ineff],0 as  [PNL MTM],[TOTAL MTM] from #temp_mtmbb3 where NO=2)) a
	group by a.sub	,a.str,a.book,a.term_month
	UNION
	select 4 as [NO],a.term_month,a.sub,a.str,a.book,'Effective Portion of Changes in Fair Value - Recorded in OCI' as [Items],
	SUM(ISNULL(a.[AOCI  (Effective)],0)) as [Total Amount] from (
	(select sub,str,book,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb3 where NO=3)UNION
	(select sub,str,book,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb3 where NO=4)
	) a
	group by a.sub	 ,a.str,a.book,a.term_month
	UNION
	select 5 as [NO],a.term_month,a.sub,a.str,a.book,'Ineffective Portion of Changes in Fair Value - Recorded in Earnings' as [Items],
	SUM(ISNULL(a.[PNL Ineff],0)) as [Total Amount] from (
	(select sub,str,book,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb3 where NO=3)UNION
		(select sub,str,book,term_month,[NO],[AOCI  (Effective)],[PNL Ineff],0 as [PNL MTM] ,0  as [TOTAL MTM] from #temp_cash_flowb3 where NO=4)
	) a
	group by a.sub	,a.str,a.book,a.term_month
	UNION
	select 7 as [NO],a.term_month,a.sub,a.str,a.book,'Purchase/Sale of Existing Contracts or Portfolios Subject to MTM' as [Items],
	SUM(ISNULL(a.[PNL MTM],0))+SUM(ISNULL(a.[Total MTM],0)) as [Total Amount] from(
	(select sub,str,book,term_month,[NO],0 AS [AOCI  (Effective)],0 AS [PNL Ineff], [PNL Ineff] as [PNL MTM] ,0 as [Total MTM] from #temp_fair_valueb3 where NO=3)UNION
	(select sub,str,book,term_month,[NO],0 AS [AOCI  (Effective)],0 AS [PNL Ineff],0 as [PNL MTM] ,ISNULL([Total MTM],0) as [Total MTM] from #temp_mtmbb3 where NO=3) UNION
	(select sub,str,book,term_month,[NO],ISNULL([AOCI  (Effective)],0) AS [AOCI  (Effective)],ISNULL([PNL Ineff],0) AS [PNL Ineff],0 as [PNL MTM] ,0 as [Total MTM] from #temp_cash_flowb3 where NO=3)
	) a
	group by a.sub	 ,a.str,a.book,a.term_month
	) x 


END

DECLARE @sub varchar(100), @clm_name varchar(10),@count int,@totcount int,@sum_sql int, @clm_names varchar(10),@max_term varchar(100)

if @summary_option='s' 
	Begin
		insert into #temp_table select deal_date,option_premium from #temp_opts
	
		set @max_term=(select max(term) from (select top 6 x.term from (select distinct cast(substring([term],0,5) as varchar) as term from #temp_table)x order by x.term)z)
		set @max_term=@max_term+'-01'
		
		update #temp_table set term=''+@max_term+'' where cast(substring([term],0,5) as varchar) >cast(substring(@max_term,0,5) as varchar) 

		set @count=6		
		DECLARE a_cursor CURSOR FOR
		select distinct cast(substring([term],0,5) as varchar)
		from #temp_table order by cast(substring([term],0,5) as varchar) asc
		set @sql1 = 'select '
		set @sql2 = 'select  (cast(substring([term],0,5) as varchar))  as term'
				
		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @clm_name
		WHILE @count<>0
		BEGIN 
			if @clm_name<>0
			Begin
			if @count=6
			set @sql1 = @sql1 + 'sum([' + @clm_name + ']) AS [' + ISNULL(@clm_name,0) + ']' 
			ELSE IF @count=1
			set @sql1 = @sql1 + ',sum([' + @clm_name + ']) AS [' + ISNULL(@clm_name,0) +'+'+ ']' 
			ELSE
			set @sql1 = @sql1 + ',sum([' + @clm_name + ']) AS [' + ISNULL(@clm_name,0) + ']' 
			

			set @sql2 = @sql2 + ' ,case when (cast(substring([term],0,5) as varchar) = ''' + @clm_name +''' ) 
			then round(sum([total mtm]),0) else 0 end AS [' + @clm_name + ']' 
			End
			set @clm_name=@clm_name+1
			--FETCH NEXT FROM a_cursor INTO  @clm_names,@sub
			set @count=@count-1

		END 
		CLOSE a_cursor
		DEALLOCATE  a_cursor		
		
	End

Else if @summary_option='a' 
	Begin

		insert into #temp_table1 select [sub],deal_date,option_premium from #temp_opts		
		--set @totcount=(select count(*) from (select distinct cast(substring([term],0,5) as varchar) as term from #temp_table1)x)
	
		set @max_term=(select max(term) from (select top 6 x.term from (select distinct cast(substring([term],0,5) as varchar) as term from #temp_table1)x order by x.term)z)
		set @max_term=@max_term+'-01'
		
		update #temp_table1 set term=''+@max_term+'' where cast(substring([term],0,5) as varchar) >cast(substring(@max_term,0,5) as varchar) 
		

		DECLARE a_cursor CURSOR FOR
		select distinct cast(substring([term],0,5) as varchar),sub
		from #temp_table1 order by cast(substring([term],0,5) as varchar) asc,sub 
		set @sql1 = 'select  xx. [Sub] as Sub '	
		set @sql2 = 'select  [Sub] '
		
		
		set @count=6
		set @sum_sql=0
		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @clm_name,@sub
		WHILE @count<>0
		BEGIN 	
			
			IF @count=1
			set @sql1 = @sql1 + ',sum([' + @clm_name + ']) AS [' + ISNULL(@clm_name,0) +'+'+ ']' 
			else
			set @sql1 = @sql1 + ', sum([' + @clm_name + ']) AS [' + @clm_name + ']'
			
			set @sql2 = @sql2 + ', case when (cast(substring([term],0,5) as varchar) = ''' + @clm_name +''' )
			 then round(SUM([total mtm]),0) else 0 end AS [' + @clm_name + ']'
			set @clm_name=@clm_name+1
			--FETCH NEXT FROM a_cursor INTO  @clm_names,@sub
			set @count=@count-1
			
		END 
		
		CLOSE a_cursor

		DEALLOCATE  a_cursor		
		
		--set @sql1 = @sql1 +', '+cast(@sum_sql as varchar)+' as [Total Amount] '
		
	End


if @summary_option='b'
	Begin
		insert into #temp_table2 select [sub],[str],deal_date,option_premium from #temp_opts		
		set @max_term=(select max(term) from (select top 6 x.term from (select distinct cast(substring([term],0,5) as varchar) as term from #temp_table2)x order by x.term)z)
		set @max_term=@max_term+'-01'
		
		update #temp_table2 set term=''+@max_term+'' where cast(substring([term],0,5) as varchar) >cast(substring(@max_term,0,5) as varchar) 
	
		set @count=6
		DECLARE a_cursor CURSOR FOR
		select distinct cast(substring([term],0,5) as varchar)
		from #temp_table2 order by cast(substring([term],0,5) as varchar)
		set @sql1 = 'select  xx.[Sub] as Sub,xx.[Str] as Strategy '
		set @sql2 = 'select [Sub],[Str] '

				
		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @clm_name
		WHILE @count<>0
		BEGIN 
			
			IF @count=1
			set @sql1 = @sql1 + ',sum([' + @clm_name + ']) AS [' + ISNULL(@clm_name,0) +'+'+ ']' 
			else			
			set @sql1 = @sql1 + ', sum([' + @clm_name + ']) AS [' + @clm_name + ']' 
			set @sql2 = @sql2 + ', case when (cast(substring([term],0,5) as varchar) = ''' + @clm_name +''' ) then sum([total mtm]) else 0 end AS [' + @clm_name + ']' 
			set @clm_name=@clm_name+1
			--FETCH NEXT FROM a_cursor INTO  @clm_name
			set @count=@count-1
		END 

		CLOSE a_cursor
		DEALLOCATE  a_cursor		

	End
if @summary_option='c'
	Begin

		insert into #temp_table3 select [sub],[str],[book],deal_date,option_premium from #temp_opts		
		set @max_term=(select max(term) from (select top 6 x.term from (select distinct cast(substring([term],0,5) as varchar) as term from #temp_table3)x order by x.term)z)
		set @max_term=@max_term+'-01'
		
		update #temp_table3 set term=''+@max_term+'' where cast(substring([term],0,5) as varchar) >cast(substring(@max_term,0,5) as varchar) 

		set @count=6	
		DECLARE a_cursor CURSOR FOR
		select distinct cast(substring([term],0,5) as varchar)
		from #temp_table3 order by cast(substring([term],0,5) as varchar)
		set @sql1 = 'select  xx.[Sub] as Sub,xx.[Str] as Strategy,xx.[Book] as Book '
		set @sql2 = 'select [Sub],[Str],[Book] '

		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @clm_name

		WHILE @count<>0
		BEGIN 
				
			IF @count=1
			set @sql1 = @sql1 + ',sum([' + @clm_name + ']) AS [' + ISNULL(@clm_name,0) +'+'+ ']' 
			else
			set @sql1 = @sql1 + ', sum([' + @clm_name + ']) AS [' + @clm_name + ']' 
			set @sql2 = @sql2 + ', case when (cast(substring([term],0,5) as varchar) = ''' + @clm_name +''' ) then sum([total mtm]) else 0 end AS [' + @clm_name + ']' 
			--FETCH NEXT FROM a_cursor INTO  @clm_name
			set @clm_name=@clm_name+1	
			set @count=@count-1
		END 
		CLOSE a_cursor
		DEALLOCATE  a_cursor		

	End
	if @summary_option='d'
	Begin
		
		DECLARE a_cursor CURSOR FOR
		select distinct cast(substring([term],0,5) as varchar)
			from #temp_table4 order by cast(substring([term],0,5) as varchar)
		set @sql1 = 'Select [Sub],[Str],[Book] '
		set @sql2 = 'Select [Sub],[Str],[Book]'
				
		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @clm_name
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			set @sql1 = @sql1 + ', sum([' + @clm_name + ']) AS [' + @clm_name + ']' 
			set @sql2 = @sql2 + ', case when (cast(substring([term],0,5) as varchar) = ''' + @clm_name +''' ) then [total mtm] else 0 end AS [' + @clm_name + ']' 

			FETCH NEXT FROM a_cursor INTO  @clm_name
		END 
		CLOSE a_cursor
		DEALLOCATE  a_cursor		
		
	End

	IF @summary_option='s'
			Begin
				if @sql1 <> 'select '
					set @sql1=@sql1 +','
			set @sql1=@sql1+' sum([Total Values]) as [Total Values] '
				set @sql3 =  ' from( ' + @sql2 + ' from #temp_table group by cast(substring([term],0,5) as varchar)) xx
			inner join 
			(select cast(substring([term],0,5) as varchar) as term, sum([total mtm]) as [Total Values] from #temp_table 
			group by cast(substring([term],0,5) as varchar)) z on 
			xx.term=z.term'
			
		End	
	
		ELSE IF @summary_option='a'
			Begin
			set @sql1=@sql1+' ,max(z.[Total Values]) as [Total Values] '
			set @sql3 =  ' from( ' + @sql2 + ' from #temp_table1 group by sub,cast(substring([term],0,5) as varchar)) xx inner join 
				(select sub, sum([total mtm]) as [Total Values] from #temp_table1 group by sub) z on xx.sub=z.sub group by xx.sub '
	

		End	
		Else IF @summary_option='b'
			Begin
			set @sql1=@sql1+' ,max(z.[Total Values]) as [Total Values]'
			set @sql3 =  ' from( ' + @sql2 + ' from #temp_table2 group by sub,str,cast(substring([term],0,5) as varchar)) xx 
			inner join 

			(select sub,str, sum([total mtm]) as [Total Values] from #temp_table2 group by sub,str) z on
			xx.sub=z.sub and xx.str=z.str 	group by xx.sub,xx.str order by xx.sub,xx.str'		
			
			End
		Else IF @summary_option='c'
			begin
			set @sql1=@sql1+' ,max(z.[Total Values]) as [Total Values]'
			set @sql3 =  ' from( ' + @sql2 + ' from #temp_table3 group by sub,str,book,cast(substring([term],0,5) as varchar)) xx
			inner join 
			(select sub,str,book, sum([total mtm]) as [Total Values] from #temp_table3 group by sub,str,book) z on
			xx.sub=z.sub and xx.str=z.str and xx.book=z.book	 group by xx.sub,xx.str,xx.book order by xx.sub,xx.str,xx.book'
			End

		Else IF @summary_option='d'		
			set @sql3 =  ' from( ' + @sql2 + ' from #temp_table4 group by sub,str,book,cast(substring([term],0,5) as varchar)) xx group by sub,str,book order by sub,str,book'		

		EXEC spa_print @sql1, @sql3
		EXEC(@sql1+@sql3)
		

		
		
	End












