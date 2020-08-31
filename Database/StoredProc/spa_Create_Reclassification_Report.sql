
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Create_Reclassification_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_Reclassification_Report]
GO 



-- DROP PROC spa_Create_Reclassification_Report
-- --===========================================================================================
-- --This Procedure create Measuremetnt Reports
-- --Input Parameters:
-- --@as_of_date - effective date
-- --@sub_entity_id - subsidiary Id
-- --@strategy_entity_id - strategy Id
-- --@book_entity_id - book Id
-- --@discount_option - takes two values 'd' or 'u', corresponding to 'discounted', 'undiscounted' 
-- --@settlement_option -  takes 'f','c','s','a' corrsponding to 'forward', 'current & forward', 'current & settled', 'all' transactions
-- --@report_type - takes 'f', 'c',  corresponding to 'fair value', 'cash flow', 'm' for mark to market (new feature)

-- --===========================================================================================
  CREATE PROC [dbo].[spa_Create_Reclassification_Report] @as_of_date varchar(50), @sub_entity_id varchar(100), 
 	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, @discount_option char(1), 
	@report_type char(1),@summary_option char(1),@tax float=NULL
 AS

 SET NOCOUNT ON

Declare @Sql_Select varchar(5000)

Declare @Sql_From varchar(8000)

Declare @Sql_Where varchar(5000)

Declare @Sql_GpBy varchar(5000)


Declare @Sql1 varchar(8000)
Declare @Sql2 varchar(8000)
Declare @Sql3 varchar(8000)
Declare @Sql4 varchar(8000)
Declare @Sql5 varchar(8000)
Declare @Sql6 varchar(8000)
Declare @Sql7 varchar(8000)
Declare @Sql8 varchar(8000)
Declare @Sql9 varchar(8000)
Declare @beginning_date varchar(50)
Declare @date_desc varchar(100)
Declare @prior_months int
Declare @temp_table varchar(100)


set @tax=@tax*100
if @prior_months is null
	set @prior_months = 1

--if beginning date is null used the last run date as the beginning date
if @beginning_date is null
begin
	-- @prior_months <> 0	
	--	select @beginning_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from 
	--	report_measurement_values where as_of_date <= dbo.FNALastDayInDate(dateadd(mm, -1 * @prior_months, @as_of_date))
	--Else
	SET @beginning_date = NULL
	IF @beginning_date IS NULL
		SET @beginning_date = '1900-01-01'

--print @beginning_date
end


--If @prior_months = 0 
	set @date_desc = ' (' + dbo.FNADateFormat(@as_of_date) + ')'
--Else
--	set @date_desc = ' (' + dbo.FNADateFormat(@beginning_date) + ' - ' + dbo.FNADateFormat(@as_of_date) + ')'

--print @date_desc

--==================================================================================================

IF @report_type = 'c' 

BEGIN
		
		Declare @ToDate2 varchar(10)
		SET @ToDate2 = cast(month(DATEADD(month, 12, @as_of_date)) as varchar) + '/01/' + 
				--cast(day(DATEADD(month, -(@settlement_month-1), @as_of_date)) as varchar) + '/' + 
				cast(year(DATEADD(month, 12, @as_of_date)) as varchar)

		
	if @summary_option='s'
			SET @Sql_Select = 'SELECT 2 AS NO,RMV.sub_entity_id, ''Reclassification of AOCI into earnings within next 12 months:'' AS [ItemsToBeDisclosed] , SUM(RMV.' + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ) AS [TotalAmount] ,0 as term_month' 
	else if @summary_option='t'
			SET @Sql_Select = 'SELECT 2 AS NO,RMV.sub_entity_id,RMV.strategy_entity_id, ''Reclassification of AOCI into earnings within next 12 months:'' AS [ItemsToBeDisclosed] , SUM(RMV.' + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ) AS [TotalAmount],0 as term_month ' 
	else if @summary_option='b'
			SET @Sql_Select = 'SELECT 2 AS NO,RMV.sub_entity_id,RMV.strategy_entity_id,RMV.book_entity_id, ''Reclassification of AOCI into earnings within next 12 months:'' AS [ItemsToBeDisclosed] , SUM(RMV.' + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ) AS [TotalAmount],0 as term_month ' 
							
		SET @Sql_From = ' FROM     report_measurement_values RMV 
						INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id'
		
		SET @Sql_Where = ' WHERE   (link_deal_flag <> ''d'') AND



						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND
						(RMV.term_month between  CONVERT(DATETIME, ''' + @as_of_date  +''', 102) AND CONVERT(DATETIME, ''' + @ToDate2  +''', 102)) 
						AND   
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		--For Cash Flow
		SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id = 150 '

		if @summary_option='s'
			SET @Sql_Where = @Sql_Where+ ' group by RMV.sub_entity_id'
		else if @summary_option='t'
			SET @Sql_Where = @Sql_Where +' group by RMV.sub_entity_id,RMV.strategy_entity_id'
		else if @summary_option='b'
			SET @Sql_Where = @Sql_Where +' group by RMV.sub_entity_id,RMV.strategy_entity_id,RMV.book_entity_id'
		
		
		SET @Sql5 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		
		

		----------------------------------------
	
		if @summary_option='s'
		SET @Sql_Select = 'SELECT 3 AS NO,RMV.sub_entity_id, ''Maximum length of time that the entity is hedging its exposure is '' +
					dbo.FNADateFormat(MAX(RMV.term_month )) + 
					  ''  (Months)'' AS [ItemsToBeDisclosed] ,
					cast(DATEDIFF(month,CONVERT(DATETIME, ''' + @as_of_date  +''', 102),MAX(RMV.term_month )) as varchar)  AS [TotalAmount],MAX(RMV.term_month ) as term_month' 
		if @summary_option='t'
		SET @Sql_Select = 'SELECT 3 AS NO,RMV.sub_entity_id,RMV.strategy_entity_id, ''Maximum length of time that the entity is hedging its exposure is '' +
					dbo.FNADateFormat(MAX(RMV.term_month )) + 
					  ''  (Months)'' AS [ItemsToBeDisclosed] ,
					cast(DATEDIFF(month,CONVERT(DATETIME, ''' + @as_of_date  +''', 102),MAX(RMV.term_month )) as varchar) AS [TotalAmount],MAX(RMV.term_month ) as term_month ' 

		if @summary_option='b'
		SET @Sql_Select = 'SELECT 3 AS NO,RMV.sub_entity_id,RMV.strategy_entity_id,RMV.book_entity_id, ''Maximum length of time that the entity is hedging its exposure is '' +
					dbo.FNADateFormat(MAX(RMV.term_month )) + 
					  ''  (Months)'' AS [ItemsToBeDisclosed] ,
					cast(DATEDIFF(month,CONVERT(DATETIME, ''' + @as_of_date  +''', 102),MAX(RMV.term_month )) as varchar) AS [TotalAmount],MAX(RMV.term_month ) as term_month ' 
	
					
		SET @Sql_From = ' FROM     report_measurement_values RMV 
						INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id'
		
		SET @Sql_Where = ' WHERE   (link_deal_flag <> ''d'') AND
						(RMV.as_of_date =  CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		--For Cash Flow
		SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id = 150 '
		if @summary_option='s'
			SET @Sql_Where = @Sql_Where+ ' group by RMV.sub_entity_id'
		if @summary_option='t'
			SET @Sql_Where = @Sql_Where+ ' group by RMV.sub_entity_id,RMV.strategy_entity_id'
		if @summary_option='b'
			SET @Sql_Where = @Sql_Where+ ' group by RMV.sub_entity_id,RMV.strategy_entity_id,RMV.book_entity_id'
		
		
		SET @Sql7 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
	
		-------------------
	
		if @summary_option='s'
			SET @Sql_Select = 'SELECT 1 AS NO,now.sub_entity_id, ''Gains and Losses of Hedges recognized in  AOCI' + @date_desc + ''' AS [ItemsToBeDisclosed] ,
				ISNULL(SUM( ISNULL(now.total_aoci,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ',0)),0) AS [TotalAmount] ,0 as term_month' 
			
		else if @summary_option='t'
			SET @Sql_Select = 'SELECT 1 AS NO,now.sub_entity_id,now.strategy_entity_id, ''Gains and Losses of Hedges recognized in  AOCI' + @date_desc + ''' AS [ItemsToBeDisclosed] ,
				ISNULL(SUM( ISNULL(now.total_aoci,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ',0)),0) AS [TotalAmount],0 as term_month ' 
		else if @summary_option='b'
			SET @Sql_Select = 'SELECT 1 AS NO,now.sub_entity_id,now.strategy_entity_id,now.book_entity_id, ''Gains and Losses of Hedges recognized in  AOCI' + @date_desc + ''' AS [ItemsToBeDisclosed] ,
					ISNULL(SUM( ISNULL(now.total_aoci,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ',0)),0) AS [TotalAmount] ,0 as term_month' 
					
		SET @Sql_From = ' FROM     	(
						SELECT   rmv.sub_entity_id,rmv.strategy_entity_id,rmv.book_entity_id,as_of_date, rmv.link_id, term_month, ' 
						+ case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' as total_aoci
						from report_measurement_values rmv (nolock) '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102) AND
						(RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
						
		IF @strategy_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
		IF @book_entity_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
		
		SET @Sql_Where = @Sql_Where + ')AS now
						LEFT OUTER JOIN report_measurement_values beginning(nolock)
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 150  '
		if @summary_option='s'
			SET @Sql_Where = @Sql_Where+ ' group by now.sub_entity_id'
		if @summary_option='t'
			SET @Sql_Where = @Sql_Where+ ' group by now.sub_entity_id,now.strategy_entity_id'
		if @summary_option='b'
			SET @Sql_Where = @Sql_Where+ ' group by now.sub_entity_id,now.strategy_entity_id,now.book_entity_id'

		
		
		SET @Sql8 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		
		--Exec(@Sql8)	
		
		--print @Sql8


	--EXEC (@sql5+ ' UNION ' + @sql7 + ' UNION ' + @sql8)	

		set @temp_table='#temp_table'
		create table #temp_table([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,
		[NO] int, [ItemsTOBeDisclosed] varchar(100) COLLATE DATABASE_DEFAULT,TotalAmount float,term_month varchar(100) COLLATE DATABASE_DEFAULT) 
		
		
	if @summary_option='s'
		EXEC(' Insert into '+@temp_table+' Select s.entity_name AS Sub,'''','''' ,r.NO,  
		r.ItemsTOBeDisclosed,r.[TotalAmount],r.term_month
		FROM (Select A.NO AS NO,A.sub_entity_id AS Sub,A.ItemsTOBeDisclosed AS ItemsTOBeDisclosed,A.[TotalAmount],a.term_month
		FROM ( ' + @sql5 + ' UNION ' + @sql7 + ' UNION ' + @sql8 +') A )r 
		 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.sub')
	
	if @summary_option='t'
		EXEC(' Insert into '+@temp_table+' Select s.entity_name AS Sub, st.entity_name AS Str,'''',r.NO,  
		r.ItemsTOBeDisclosed,r.[TotalAmount],r.term_month
		FROM (Select A.NO AS NO,A.sub_entity_id AS Sub,A.strategy_entity_id AS Str,
		A.ItemsTOBeDisclosed AS ItemsTOBeDisclosed,A.[TotalAmount],a.term_month
		FROM ( ' + @sql5 + ' UNION ' + @sql7 + ' UNION ' + @sql8 +') A )r 
		 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.sub
		 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str')
	
	if @summary_option='b'
		EXEC(' Insert into '+@temp_table+' Select s.entity_name AS Sub, st.entity_name AS Str,b.entity_name as Book,r.NO,  
		r.ItemsTOBeDisclosed,r.[TotalAmount],r.term_month
		FROM (Select A.NO AS NO,A.sub_entity_id AS Sub,A.strategy_entity_id AS Str,
		A.book_entity_id AS Book,A.ItemsTOBeDisclosed AS ItemsTOBeDisclosed,A.[TotalAmount],a.term_month
		FROM ( ' + @sql5 + ' UNION ' + @sql7 + ' UNION ' + @sql8 +') A )r 
		 LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = r.sub
		 LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = r.Str
		 LEFT OUTER JOIN portfolio_hierarchy b ON b.entity_id = r.Book')
	

		DECLARE @sub varchar(100), @clm_name varchar(10), @term_month varchar(100)

		DECLARE a_cursor CURSOR FOR
		select distinct [NO]
		from #temp_table order by [NO]
	if @summary_option='s'
		BEgin
		set @sql1 = 'select  [Sub] '
		set @sql2 = 'select [Sub] '
		End
	if @summary_option='t'
		Begin
		set @sql1 = 'select  [Sub],[Str] '
		set @sql2 = 'select [Sub],[Str] '
		End

	if @summary_option='b'		
		Begin
		set @sql1 = 'select  [Sub],[Str],[Book] '
		set @sql2 = 'select [Sub],[Str],[Book] '
		End
				
		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @clm_name
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			select @term_month=dbo.Fnadateformat(term_month) from #temp_table where [NO] = '' + @clm_name +''
			EXEC spa_print @term_month
			set @term_month=dbo.FNAContractMonthFormat(''+@term_month+'')
			
			if @clm_name=1
			if @tax is null
				set @sql1 = @sql1 + ', sum([' + @clm_name + ']) AS [AOCI Before Tax]' 
			else
				set @sql1 = @sql1 + ', ' + cast((1-@tax/100) as varchar)  + ' * sum([' + @clm_name + ']) AS [AOCI After Tax('+cast(@tax as varchar)+' %)]' 
			eLSE if @clm_name=2
			set @sql1 = @sql1 + ', sum([' + @clm_name + ']) AS [To be Reclassified in 12 Months ]' 
			eLSE if @clm_name=3		
			set @sql1 = @sql1 + ', cast(sum([' + @clm_name + ']) as varchar)+'' ('+@term_month+')'' AS [Maximum Term(months)] ' 

			set @sql2 = @sql2 + ', case when ([NO] = ''' + @clm_name +''' ) then sum([TotalAmount]) else 0 end AS [' + @clm_name + ']' 
			FETCH NEXT FROM a_cursor INTO  @clm_name
		END 
		CLOSE a_cursor
		DEALLOCATE  a_cursor		

	if @summary_option='s'
		set @sql3 =  ' from( ' + @sql2 + ' from #temp_table group by sub,NO) xx group by Sub order by Sub'		
	else if @summary_option='t'
		set @sql3 =  ' from( ' + @sql2 + ' from #temp_table group by sub,str,NO) xx group by Sub,str order by Sub,Str'		
	else if @summary_option='b'			
		set @sql3 =  ' from( ' + @sql2 + ' from #temp_table group by sub,str,book,NO) xx group by Sub,str,book order by Sub,str,book'

	Exec(@sql1+@sql3)	

	


	


END






