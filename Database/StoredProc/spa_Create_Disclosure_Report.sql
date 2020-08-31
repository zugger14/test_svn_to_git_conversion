
/****** Object:  StoredProcedure [dbo].[spa_Create_Disclosure_Report]    Script Date: 03/09/2010 10:37:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Create_Disclosure_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_Disclosure_Report]
 GO 
/****** Object:  StoredProcedure [dbo].[spa_Create_Disclosure_Report]    Script Date: 03/09/2010 10:37:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 


-- exec spa_Create_Disclosure_Report '2005-03-31','291,30,1,257,258,256',NULL, NULL, 'd', 'c', '0', 3, 's'

-- DROP PROC spa_Create_Disclosure_Report
-- --===========================================================================================
-- --This Procedure create Measuremetnt Reports
-- --Input Parameters:
-- --@as_of_date - effective date
-- --@subsidiary_id - subsidiary Id
-- --@strategy_id - strategy Id
-- --@book_id - book Id
-- --@discount_option - takes two values 'd' or 'u', corresponding to 'discounted', 'undiscounted' 
-- --@settlement_option -  takes 'f','c','s','a' corrsponding to 'forward', 'current & forward', 'current & settled', 'all' transactions
-- --@hedge_type - takes 'f', 'c',  corresponding to 'fair value', 'cash flow', 'm' for mark to market (new feature)

-- --===========================================================================================
CREATE PROC [dbo].[spa_Create_Disclosure_Report] @as_of_date varchar(50), @subsidiary_id varchar(MAX), 
 	@strategy_id varchar(MAX) = NULL, 
	@book_id varchar(MAX) = NULL, @discount_option char(1), 
	@hedge_type char(1), @settlement_month int =NULL,
	@prior_months int = NULL,
	@report_type char(1)=NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL,
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
 AS

 SET NOCOUNT ON
 /*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR (8000)
 
DECLARE @user_login_id VARCHAR (50)
 
DECLARE @sql_paging VARCHAR (8000)
 
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
 
SET @user_login_id = dbo.FNADBUser() 
 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
BEGIN 
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id) 
END

IF @enable_paging = 1 --paging processing 
BEGIN 
	IF @batch_process_id IS NULL 
	BEGIN
 		SET @batch_process_id = dbo.FNAGetNewID()
	END

	SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no)	
 
	--retrieve data from paging table instead of main table
 
	IF @page_no IS NOT NULL  
	BEGIN 
		SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no)  
		EXEC (@sql_paging)  
		RETURN  
	END 
END
 
/*******************************************1st Paging Batch END**********************************************/
----------------------BEGIN TESTING ---------------------------
/*
 declare @as_of_date varchar(50), @subsidiary_id varchar(100), 
  	@strategy_id varchar(100), 
  	@book_id varchar(100), @discount_option char(1), 
  	@settlement_option char(1), @hedge_type char(1), --@settlement_month int, 
 	@prior_months int, @report_type char(1)
  
 set  @as_of_date='2009-11-30'
 set  @subsidiary_id ='2'
 set  @discount_option ='d'
 set  @hedge_type ='c'
 SET @settlement_option='0'
 set @strategy_id = null
 set @book_id  = null
 set @prior_months =3
 set @report_type = 'c'

 drop table #max_date 
 drop table #rmv
  drop table #temp_tabe
  drop table  #temp_term
  drop table  #temp_sub
  
--*/
-------------------------END TESTING ---------------------------




declare @counts int,@i int,@subname varchar(100),@item_name varchar(300),@strname varchar(100),@bookname varchar(100)
Declare @Sql_Select varchar(5000)

Declare @Sql_From varchar(8000)

Declare @Sql_Where varchar(5000)

Declare @Sql_GpBy varchar(5000)


Declare @Sql0 varchar(8000)
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
Declare @date_desc varchar(100)
create table #max_date (as_of_date datetime)
declare @st varchar(8000)
declare @st_where varchar(100)

if @prior_months is null
	set @prior_months = 1

--if beginning date is null used the last run date as the beginning date
if @beginning_date is null
begin


	If @prior_months <> 0	
		select @beginning_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from 
			measurement_run_dates where as_of_date <= dbo.FNALastDayInDate(dateadd(mm, -1 * @prior_months, @as_of_date))
	Else
		SET @beginning_date = NULL
	IF @beginning_date IS NULL
		SET @beginning_date = '1900-01-01'

--	If @prior_months <> 0	
--	begin
--		set @st_where ='as_of_date<='''+convert(varchar(10),dbo.FNALastDayInDate(dateadd(mm, -1 * @prior_months, @as_of_date)),120)+''''
--		insert into #max_date (as_of_date) exec  spa_get_Script_ProcessTableFunc 'max','as_of_date','report_measurement_values',@st_where
--		select @beginning_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from #max_date
--	end
--	Else
--		SET @beginning_date = NULL
--	IF @beginning_date IS NULL
--		SET @beginning_date = '1900-01-01'

--print @beginning_date
end


If @prior_months = 0 
	set @date_desc = ' (' + dbo.FNADateFormat(@as_of_date) + ')'
Else
	set @date_desc = ' (' + dbo.FNADateFormat(@beginning_date) + ' - ' + dbo.FNADateFormat(@as_of_date) + ')'

--print @date_desc

--select required data into temp report measurement values
select * into #rmv from report_measurement_values  where 1 = 2

set @Sql_Select = 'insert into #rmv select rmv.* from ' + dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + 
	' rmv
		--WhatIf Changes
		INNER JOIN fas_books fb ON fb.fas_book_id = rmv.book_entity_id
		where 
			--WhatIf Changes
			(fb.no_link IS NULL OR fb.no_link = ''n'') AND 
			as_of_date = ''' +  @as_of_date + ''''
exec(@Sql_Select)
if @beginning_date <> '1900-01-01'
BEGIN
	set @Sql_Select = 'insert into #rmv select rmv.* from ' + dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') +
	' rmv
		--WhatIf Changes
		INNER JOIN fas_books fb ON fb.fas_book_id = rmv.book_entity_id
		where 
			--WhatIf Changes
			(fb.no_link IS NULL OR fb.no_link = ''n'') AND 
			as_of_date = ''' +  @beginning_date + ''''
	exec(@Sql_Select)
END

--select * into adiha_process.dbo.ttt from #rmv 
--==================================================================================================

IF @hedge_type = 'f' 

	BEGIN
		if(@report_type='s')
		SET @Sql_Select = 'SELECT 1 AS No, ''Amount of hedges Ineffectiveness recongized in earnings' + @date_desc + ''' AS [ItemsToBeDisclosed] , 
					ISNULL(SUM( ISNULL(now.pnl_ineffectiveness,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_ineffectiveness' else 'u_pnl_ineffectiveness' end + ',0)),0) AS [TotalAmount] ' 
		else
		SET @Sql_Select = 'SELECT 1 AS No,s.entity_name as Sub, st.entity_name Str, b.entity_name As Book,''Amount of hedges Ineffectiveness recongized in earnings' + @date_desc + ''' AS [ItemsToBeDisclosed] , 
					ISNULL( ISNULL(now.pnl_ineffectiveness,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_ineffectiveness' else 'u_pnl_ineffectiveness' end + ',0),0) AS [TotalAmount] ' 		
					

		SET @Sql_From = ' FROM     	(
						SELECT '+  
		case when (@report_type <> 's') then 'sub_entity_id, strategy_entity_id, book_entity_id, ' else '' end +
				'as_of_date, rmv.link_id, term_month, ' 
						+ case when (@discount_option = 'd') then 'd_pnl_ineffectiveness' else 'u_pnl_ineffectiveness' end + ' as pnl_ineffectiveness
						
						from #rmv rmv '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102) AND
						(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
						
		IF @strategy_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
		IF @book_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
		
		
		SET @Sql_Where = @Sql_Where + ')AS now '+
		case when (@report_type <> 's') then
			' INNER JOIN portfolio_hierarchy s ON s.entity_id = now.sub_entity_id
			INNER JOIN portfolio_hierarchy st ON st.entity_id = now.strategy_entity_id 
			 INNER JOIN portfolio_hierarchy b ON b.entity_id = now.book_entity_id '	
			else '' end +

						' LEFT OUTER JOIN #rmv beginning 
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 151  '
		
		
		
		SET @Sql1 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		--print @Sql1
		--EXEC(@Sql1) 

		
		----------------------------------
		if(@report_type='s')
		SET @Sql_Select = 'SELECT 2 AS No, ''Component of hedges excluded from hedge ineffectiveness' + @date_desc + ''' AS [ItemsToBeDisclosed] , 
					ISNULL(SUM( ISNULL(now.pnl_extrinsic,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_extrinsic' else 'u_pnl_extrinsic' end + ',0)),0) AS [TotalAmount] ' 
		else
		SET @Sql_Select = 'SELECT 2 AS No, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Component of hedges excluded from hedge ineffectiveness' + @date_desc + ''' AS [ItemsToBeDisclosed] , 
					ISNULL( ISNULL(now.pnl_extrinsic,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_extrinsic' else 'u_pnl_extrinsic' end + ',0),0) AS [TotalAmount] ' 

		
		SET @Sql_From = ' FROM     	( SELECT '+
		case when (@report_type <> 's') then 'sub_entity_id, strategy_entity_id, book_entity_id, ' else '' end +'

						as_of_date, rmv.link_id, term_month, ' 
						+ case when (@discount_option = 'd') then 'd_pnl_extrinsic' else 'u_pnl_extrinsic' end + ' as pnl_extrinsic
						
						from #rmv rmv  '
	
		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102) AND
						(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
						
		IF @strategy_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
		IF @book_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
		
		
		SET @Sql_Where = @Sql_Where + ')AS now '+
		case when (@report_type <> 's') then
			' INNER JOIN portfolio_hierarchy s ON s.entity_id = now.sub_entity_id
			INNER JOIN portfolio_hierarchy st ON st.entity_id = now.strategy_entity_id 
			 INNER JOIN portfolio_hierarchy b ON b.entity_id = now.book_entity_id '	
			else '' end +
				' LEFT OUTER JOIN #rmv beginning
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 151  '
		
		
		SET @Sql2 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		----------------------------------
		if(@report_type='s')
		SET @Sql_Select = 'SELECT 3 AS No, ''Amount of net gain or loss in earnings due to de-designation' + @date_desc + ''' AS [ItemsToBeDisclosed] , 
					ISNULL(SUM( ISNULL(now.pnl_dedesignation,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_dedesignation' else 'u_pnl_dedesignation' end + ',0)),0) AS [TotalAmount] ' 
		else
		SET @Sql_Select = 'SELECT 3 AS No,s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Amount of net gain or loss in earnings due to de-designation' + @date_desc + ''' AS [ItemsToBeDisclosed] , 
					ISNULL(ISNULL(now.pnl_dedesignation,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_dedesignation' else 'u_pnl_dedesignation' end + ',0),0) AS [TotalAmount] ' 

		
		SET @Sql_From = ' FROM     	(SELECT '+
		case when (@report_type <> 's') then 'sub_entity_id, strategy_entity_id, book_entity_id, ' else '' end +'
		  as_of_date, rmv.link_id, term_month, ' 
						+ case when (@discount_option = 'd') then 'd_pnl_dedesignation' else 'u_pnl_dedesignation' end + ' as pnl_dedesignation
						
						from #rmv rmv  '
						
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 151 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102) AND
						(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
						
		IF @strategy_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
		IF @book_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
		
		
		SET @Sql_Where = @Sql_Where + ')AS now '+
		case when (@report_type <> 's') then
			' INNER JOIN portfolio_hierarchy s ON s.entity_id = now.sub_entity_id
			INNER JOIN portfolio_hierarchy st ON st.entity_id = now.strategy_entity_id 
			 INNER JOIN portfolio_hierarchy b ON b.entity_id = now.book_entity_id '	
			else '' end +
				' LEFT OUTER JOIN #rmv beginning 
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 151  '
		
		
		SET @Sql3 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		--END
		
if @report_type<>'s'
	Begin

		create table #temp_tabel ([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,[No] int,
		ItemsToBeDisclosed varchar(200) COLLATE DATABASE_DEFAULT,TotalAmount float)


		EXEC('insert into #temp_tabel select r.SUB,r.str,r.book,ISNULL(r.No,0) as [No],
		ISNULL(r.ItemsToBeDisclosed,0) as [ItemsToBeDisclosed],r.[TotalAmount] as [TotalAmount] from ('+@sql1 + 
		' UNION ' + @sql2 + ' UNION ' + @sql3 +') r 
		') 
		
		--insert into #temp_tabel values('Europe Energy','NBP Hedges (CF)','ExxonMobil',1,'asas',100)
		
		create table #temp_sub1([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,[No] int,
		ItemsToBeDisclosed varchar(100) COLLATE DATABASE_DEFAULT, TotalAmount float)

		DECLARE a_cursor CURSOR FOR
		select distinct   sub,str,book from #temp_tabel
		order by sub
		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @subname,@strname,@bookname
		WHILE @@FETCH_STATUS = 0   
		BEGIN 

			set @i=3
			while @i<>0
				Begin
			
					if @i=1
					set @item_name='Amount of hedges Ineffectiveness recongized in earnings '+@date_desc
					else if @i=2
					set @item_name='Component of hedges excluded from hedge ineffectiveness'+@date_desc
					else if @i=3
					set @item_name='Amount of net gain or loss in earnings due to de-designation'+@date_desc
					insert into #temp_sub1 values(@subname,@strname,@bookname,@i,@item_name,0)					
					set @i=@i-1
				End
			
			FETCH NEXT FROM a_cursor INTO  @subname,@strname,@bookname
			END 
	CLOSE a_cursor
		DEALLOCATE  a_cursor		
	
	End


	if @report_type='s'
	EXEC  ('SELECT No [S.N.], ItemsToBeDisclosed [Items to be Disclosed] , TotalAmount [Total Amount] ' + @str_batch_table + ' FROM ( ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 +') c')
	else if @report_type='a'
	EXEC('select ISNULL(z.No,0) as [S.N.], ISNULL(z.SUB,0) as Subsidiary,ISNULL(z.ItemsToBeDisclosed,0) as [Items to be Disclosed],round(ISNULL(SUM(r.[TotalAmount]),0),0) as [Total Amount] ' + @str_batch_table + ' from ('+@sql1 + 
	' UNION ' + @sql2 + ' UNION ' + @sql3 +') r 
	RIGHT OUTER JOIN (select sub,No,ItemsToBeDisclosed,sum(totalamount)as [TotalAmount] from #temp_sub1 group by sub,No,ItemsToBeDisclosed) z
	on r.No=z.No and r.sub=z.sub 
	group by z.SUB,z.No,z.ItemsToBeDisclosed order by z.SUB,z.No') 

	else if @report_type='b'
	EXEC  ('select ISNULL(z.No,0) as [S.N.], ISNULL(z.SUB,0) as [Subsidiary],ISNULL(z.str,0) as Strategy,ISNULL(z.ItemsToBeDisclosed,0) as [Items to be Disclosed],round(ISNULL(SUM(r.[TotalAmount]),0),0) as [Total Amount] ' + @str_batch_table + ' from ('+@sql1 + 
	' UNION ' + @sql2 + ' UNION ' + @sql3 +') r 
	RIGHT OUTER JOIN (select sub,str,No,ItemsToBeDisclosed,sum(totalamount)as [TotalAmount] from #temp_sub1 group by sub,str,No,ItemsToBeDisclosed) z
	on r.No=z.No and r.sub=z.sub and r.str=z.str
	group by z.SUB,z.str,z.No,z.ItemsToBeDisclosed order by z.SUB,z.str,z.No') 
	
	else if @report_type='c'
	EXEC  ('select ISNULL(z.No,0) as [S.N.], ISNULL(z.SUB,0) as Subsidiary,ISNULL(z.str,0) as Strategy,ISNULL(z.book,0) as Book,ISNULL(z.ItemsToBeDisclosed,0) as [Items to be Disclosed],round(ISNULL(SUM(r.[TotalAmount]),0),0) as [Total Amount] ' + @str_batch_table + '  from ('+@sql1 + 
	' UNION ' + @sql2 + ' UNION ' + @sql3 +') r 
	RIGHT OUTER JOIN (select sub,str,book,No,ItemsToBeDisclosed,sum(totalamount)as [TotalAmount] from #temp_sub1 group by sub,str,book,No,ItemsToBeDisclosed) z
	on r.No=z.No and r.sub=z.sub and r.str=z.str and r.book=z.book
	group by z.SUB,z.str,z.book,z.No,z.ItemsToBeDisclosed order by z.SUB,z.str,z.book,z.No') 

END

--==================================================================================================

IF @hedge_type = 'c' 

BEGIN
		if(@report_type='s')
		SET @Sql_Select = 'SELECT 0 AS No, ''Amount of derivatives recognized in earnings' + @date_desc + ''' AS [ItemsToBeDisclosed] , 
						ISNULL(SUM( ISNULL(now.pnl_mtm,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ',0)),0) AS [TotalAmount] ' 
		else
		SET @Sql_Select = 'SELECT 0 AS No,s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Amount of derivatives recognized in earnings' + @date_desc + ''' AS [ItemsToBeDisclosed] , 
						ISNULL( ISNULL(now.pnl_mtm,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ',0),0) AS [TotalAmount]' 

--		SET @Sql_Select = 'SELECT 0 AS No,s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Amount of hedges Ineffectiveness recognized in earnings' + @date_desc + ''' AS [ItemsToBeDisclosed] , 
--						ISNULL( ISNULL(now.pnl_ineffectiveness,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_ineffectiveness' else 'u_pnl_ineffectiveness' end + ',0),0) AS [TotalAmount]' 

		
		SET @Sql_From = ' FROM     	(
						SELECT  '+
		case when (@report_type <> 's') then 'sub_entity_id,  book_entity_id, ' else '' end +'
						 as_of_date, rmv.link_id, term_month, ' 
						+ case when (@discount_option = 'd') then 'd_pnl_mtm' else 'u_pnl_mtm' end + ' as pnl_mtm,
						strategy_entity_id
						from #rmv rmv  INNER JOIN fas_strategy fs ON fs.fas_strategy_id = rmv.strategy_entity_id '
						
		
		SET @Sql_Where = ' WHERE fs.hedge_type_value_id = 150 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102) AND
						(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
						
		IF @strategy_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
		IF @book_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
		
		
		SET @Sql_Where = @Sql_Where + ')AS now '+
		case when (@report_type <> 's') then
			' INNER JOIN portfolio_hierarchy s ON s.entity_id = now.sub_entity_id
			INNER JOIN portfolio_hierarchy st ON st.entity_id = now.strategy_entity_id 
			 INNER JOIN portfolio_hierarchy b ON b.entity_id = now.book_entity_id 
			'	
			else '' end +
				' LEFT OUTER JOIN #rmv beginning 
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102) LEFT OUTER JOIN
					fas_strategy fs ON fs.fas_strategy_id = now.strategy_entity_id
			WHERE fs.hedge_type_value_id = 150  
'

		--print @Sql_Select+ @Sql_From + @Sql_Where

		
		SET @Sql0 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		--print @Sql0 

	----------------------------------
		
		if(@report_type='s')
		SET @Sql_Select = 'SELECT 1 AS No, ''Amount of hedges Ineffectiveness recognized in earnings' + @date_desc + ''' AS [ItemsToBeDisclosed] , 
						ISNULL(SUM( ISNULL(now.pnl_ineffectiveness,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_ineffectiveness' else 'u_pnl_ineffectiveness' end + ',0)),0) AS [TotalAmount] ' 
		else
		SET @Sql_Select = 'SELECT 1 AS No,s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Amount of hedges Ineffectiveness recognized in earnings' + @date_desc + ''' AS [ItemsToBeDisclosed] , 
						ISNULL( ISNULL(now.pnl_ineffectiveness,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_ineffectiveness' else 'u_pnl_ineffectiveness' end + ',0),0) AS [TotalAmount]' 

		
		SET @Sql_From = ' FROM     	(
						SELECT  '+
		case when (@report_type <> 's') then 'sub_entity_id, strategy_entity_id, book_entity_id, ' else '' end +'
						 as_of_date, rmv.link_id, term_month, ' 
						+ case when (@discount_option = 'd') then 'd_pnl_ineffectiveness' else 'u_pnl_ineffectiveness' end + ' as pnl_ineffectiveness
						
						from #rmv rmv  '
						
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102) AND
						(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
						
		IF @strategy_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
		IF @book_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
		
		
		SET @Sql_Where = @Sql_Where + ')AS now '+
		case when (@report_type <> 's') then
			' INNER JOIN portfolio_hierarchy s ON s.entity_id = now.sub_entity_id
			INNER JOIN portfolio_hierarchy st ON st.entity_id = now.strategy_entity_id 
			 INNER JOIN portfolio_hierarchy b ON b.entity_id = now.book_entity_id '	
			else '' end +
				' LEFT OUTER JOIN #rmv beginning 
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 150  '

		--print @Sql_Select+ @Sql_From + @Sql_Where

		
		SET @Sql1 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy


		----------------------------------
		if(@report_type='s')
		SET @Sql_Select = 'SELECT 2 AS No, ''Component of hedges excluded from hedge ineffectiveness' + @date_desc + ''' AS [ItemsToBeDisclosed] ,
					ISNULL(SUM( ISNULL(now.pnl_extrinsic,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_extrinsic' else 'u_pnl_extrinsic' end + ',0)),0) AS [TotalAmount] ' 
		else
		SET @Sql_Select = 'SELECT 2 AS No,s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Component of hedges excluded from hedge ineffectiveness' + @date_desc + ''' AS [ItemsToBeDisclosed] ,
					ISNULL(ISNULL(now.pnl_extrinsic,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_extrinsic' else 'u_pnl_extrinsic' end + ',0),0) AS [TotalAmount]' 

		
		SET @Sql_From = ' FROM     	(
						SELECT '+
			case when (@report_type <> 's') then 'sub_entity_id, strategy_entity_id, book_entity_id, ' else '' end +'   as_of_date, rmv.link_id, term_month, ' 
			+ case when (@discount_option = 'd') then 'd_pnl_extrinsic' else 'u_pnl_extrinsic' end + ' as pnl_extrinsic
						from #rmv rmv '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102) AND
						(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
						
		IF @strategy_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
		IF @book_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
		
		SET @Sql_Where = @Sql_Where + ')AS now '+
		case when (@report_type <> 's') then
			' INNER JOIN portfolio_hierarchy s ON s.entity_id = now.sub_entity_id
			INNER JOIN portfolio_hierarchy st ON st.entity_id = now.strategy_entity_id 
			 INNER JOIN portfolio_hierarchy b ON b.entity_id = now.book_entity_id '	
			else '' end +	' LEFT OUTER JOIN #rmv beginning 
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 150  '
		
		
		SET @Sql2 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-------------------------------
	
-- 		IF @settlement_month = 0
-- 			SET @Sql3 = 'SELECT 3 AS No, ''Reclassification of AOCI into earnings due to settlement:'' AS [ItemsToBeDisclosed] ,CAST(0 AS Float) AS [TotalAmount] ' 
-- 		ELSE
-- 			BEGIN 
-- 			Declare @FromDate2 varchar(10)
-- 			SET @FromDate2 = cast(month(DATEADD(month, -(@beginning_date-1), @as_of_date)) as varchar) + '/01/' + 
-- 					cast(year(DATEADD(month, -(@beginning_date-1), @as_of_date)) as varchar)
	
			-- get u_aoci_release ( for both discount and undiscouted) - sum this column.			
		if(@report_type='s')
		SET @Sql_Select = 'SELECT 3 AS No, ''Reclassification of AOCI into earnings due to settlement' + @date_desc + ''' AS [ItemsToBeDisclosed] , ' +
						'SUM(isnull(RMV.u_aoci_released, 0) - isnull(RMV.u_pnl_inventory, 0)) AS [TotalAmount] ' 
						--SUM(RMV.' + case when (@discount_option = 'd') then 'd_pnl_settlement' else 'u_pnl_settlement' end + ') AS [TotalAmount] ' 
		else
		SET @Sql_Select = 'SELECT 3 AS No,s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Reclassification of AOCI into earnings due to settlement' + @date_desc + ''' AS [ItemsToBeDisclosed] , ' +
						'isnull(RMV.u_aoci_released, 0) - isnull(RMV.u_pnl_inventory, 0) AS [TotalAmount]' 			
		SET @Sql_From = ' FROM     #rmv  RMV 
							INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id'
		If (@report_type <> 's')
			SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '

			
		SET @Sql_Where = ' WHERE   (link_deal_flag <> ''d'') AND
							(RMV.term_month between  CONVERT(DATETIME, ''' + CASE WHEN (@prior_months <> 0) then dbo.FNAGetContractMonth(@beginning_date) else dbo.FNAGetContractMonth(@as_of_date) end  +''', 102) AND CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
							AND   
							(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
							
			IF @strategy_id IS NOT NULL
				SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
			IF @book_id IS NOT NULL
				SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
			
			--For Cash Flow
			SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id = 150'
			
			
			SET @Sql3 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

			if(@report_type='s')		
			SET @Sql_Select = 'SELECT 4 AS No, ''Reclassification of AOCI into initial carrying amount of assets/liabilities' + @date_desc + ''' AS [ItemsToBeDisclosed] ,
					   SUM(ISNULL(u_pnl_inventory,0)) AS [TotalAmount] ' 
						--SUM(RMV.' + case when (@discount_option = 'd') then 'd_pnl_settlement' else 'u_pnl_settlement' end + ') AS [TotalAmount] ' 
			else
			SET @Sql_Select = 'SELECT 4 AS No, s.entity_name as Sub, st.entity_name Str, b.entity_name As Book,

					 ''Reclassification of AOCI into initial carrying amount of assets/liabilities' + @date_desc + ''' AS [ItemsToBeDisclosed] ,
					   ISNULL(u_pnl_inventory,0) AS [TotalAmount]' 

			SET @Sql_From = ' FROM    #rmv  RMV 
							INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id'

			If (@report_type <> 's')
			SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '

			
			SET @Sql_Where = ' WHERE   (link_deal_flag <> ''d'') AND
							(RMV.term_month between  CONVERT(DATETIME, ''' + CASE WHEN (@prior_months <> 0) then dbo.FNAGetContractMonth(@beginning_date) else dbo.FNAGetContractMonth(@as_of_date) end  +''', 102) AND CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
							AND   
							(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
							
			IF @strategy_id IS NOT NULL
				SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
			IF @book_id IS NOT NULL
				SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
			
			--For Cash Flow
			SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id = 150'
		
		SET @Sql4 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		-----------------------------------

		Declare @ToDate2 varchar(10)
		SET @ToDate2 = cast(month(DATEADD(month, 12, @as_of_date)) as varchar) + '/01/' + 
				--cast(day(DATEADD(month, -(@settlement_month-1), @as_of_date)) as varchar) + '/' + 
				cast(year(DATEADD(month, 12, @as_of_date)) as varchar)

		if(@report_type='s')
		SET @Sql_Select = 'SELECT 5 AS No, ''Reclassification of AOCI into earnings within next 12 months:'' AS [ItemsToBeDisclosed] , SUM(RMV.' + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' ) AS [TotalAmount] ' 
		else
		SET @Sql_Select = 'SELECT 5 AS No,s.entity_name as Sub, st.entity_name Str, b.entity_name As Book,
		 ''Reclassification of AOCI into earnings within next 12 months:'' AS [ItemsToBeDisclosed] , RMV.' + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + '  AS [TotalAmount]' 
						
		SET @Sql_From = ' FROM #rmv  RMV 
						INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id'
		
		If (@report_type <> 's')
			SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '

		SET @Sql_Where = ' WHERE   (link_deal_flag <> ''d'') AND
						(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND
						(RMV.term_month between  CONVERT(DATETIME, ''' + @as_of_date  +''', 102) AND CONVERT(DATETIME, ''' + @ToDate2  +''', 102)) 
						AND   
						(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
						
		IF @strategy_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
		IF @book_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
		
		--For Cash Flow
		SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id = 150'
		
		
		SET @Sql5 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy

		----------------------------------------
		if(@report_type='s')
		SET @Sql_Select = 'SELECT 6 AS No, ''Reclassification of AOCI into earnings due to forcasted transactions will not be probable' + @date_desc + ''' AS [ItemsToBeDisclosed] ,
					ISNULL(SUM( ISNULL(now.pnl_dedesignation,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_dedesignation' else 'u_pnl_dedesignation' end + ',0)),0) AS [TotalAmount] ' 
		else
		SET @Sql_Select = 'SELECT 6 AS No,s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Reclassification of AOCI into earnings due to forcasted transactions will not be probable' + @date_desc + ''' AS [ItemsToBeDisclosed] ,
					ISNULL(ISNULL(now.pnl_dedesignation,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_pnl_dedesignation' else 'u_pnl_dedesignation' end + ',0),0) AS [TotalAmount]' 
	
						
		SET @Sql_From = ' FROM     	(SELECT '+
			case when (@report_type <> 's') then 'sub_entity_id, strategy_entity_id, book_entity_id, ' else '' end +'
			  as_of_date, rmv.link_id, term_month, ' 
						+ case when (@discount_option = 'd') then 'd_pnl_dedesignation' else 'u_pnl_dedesignation' end + ' as pnl_dedesignation
						from #rmv  rmv  '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102) AND
						(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
						
		IF @strategy_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
		IF @book_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
		
		SET @Sql_Where = @Sql_Where + ')AS now '+
		case when (@report_type <> 's') then
			' INNER JOIN portfolio_hierarchy s ON s.entity_id = now.sub_entity_id
			INNER JOIN portfolio_hierarchy st ON st.entity_id = now.strategy_entity_id 
			 INNER JOIN portfolio_hierarchy b ON b.entity_id = now.book_entity_id '	
			else '' end +	
					' LEFT OUTER JOIN #rmv beginning 
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 150  '
		
		
		SET @Sql6 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		
		--------------------------------------
	
		if(@report_type='s')
		SET @Sql_Select = 'SELECT 7 AS No, ''Maximum length of time that the entity is hedging its exposure is '' +
					dbo.FNADateFormat(MAX(RMV.term_month )) + 
					  ''  (Months)'' AS [ItemsToBeDisclosed] ,
					DATEDIFF(month,CONVERT(DATETIME, ''' + @as_of_date  +''', 102),MAX(RMV.term_month ))  AS [TotalAmount] ' 
		else
		SET @Sql_Select = 'SELECT 7 AS No,s.entity_name as Sub, st.entity_name Str, b.entity_name As Book,''Maximum length of time that the entity is hedging its exposure is '' +
					dbo.FNADateFormat(RMV.term_month) + 
					  ''  (Months)'' AS [ItemsToBeDisclosed] ,
					DATEDIFF(month,CONVERT(DATETIME, ''' + @as_of_date  +''', 102),RMV.term_month ) AS [TotalAmount]' 

		
			
		SET @Sql_From = ' FROM  #rmv  RMV 
						INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id'

		If (@report_type <> 's')
		SET @Sql_From = @Sql_From + ' INNER JOIN portfolio_hierarchy s ON s.entity_id = sub_entity_id
						 INNER JOIN portfolio_hierarchy st ON st.entity_id = strategy_entity_id 
						 INNER JOIN portfolio_hierarchy b ON b.entity_id = book_entity_id '
		
		SET @Sql_Where = ' WHERE   (link_deal_flag <> ''d'') AND
						(RMV.as_of_date =  CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
						
		IF @strategy_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
		IF @book_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
		
		--For Cash Flow
		SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id = 150'
		
		
			SET @Sql7 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		
		-------------------
		If (@report_type='s')
		SET @Sql_Select = 'SELECT 8 AS No, ''Gains and Losses of Hedges recognized in  AOCI' + @date_desc + ''' AS [ItemsToBeDisclosed] ,
					ISNULL(SUM( ISNULL(now.total_aoci,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ',0)),0) AS [TotalAmount] ' 
		else
		SET @Sql_Select = 'SELECT 8 AS No,s.entity_name as Sub, st.entity_name Str, b.entity_name As Book, ''Gains and Losses of Hedges recognized in  AOCI' + @date_desc + ''' AS [ItemsToBeDisclosed] ,
					ISNULL(ISNULL(now.total_aoci,0) -ISNULL(beginning.' + case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ',0),0) AS [TotalAmount]' 							
		SET @Sql_From = ' FROM     	(SELECT  '+
		case when (@report_type <> 's') then 'sub_entity_id, strategy_entity_id, book_entity_id, ' else '' end +'
			 as_of_date, rmv.link_id, term_month, ' 
						+ case when (@discount_option = 'd') then 'd_total_aoci' else 'u_total_aoci' end + ' as total_aoci
						from #rmv  rmv '
		
		SET @Sql_Where = ' WHERE hedge_type_value_id = 150 AND   as_of_date  = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)  
						and rmv.link_deal_flag <> ''d''
						and term_month > CONVERT(DATETIME, ''' + @as_of_date  +''', 102) AND
						(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
						
		IF @strategy_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
		IF @book_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
		
		SET @Sql_Where = @Sql_Where + ')AS now '+
		case when (@report_type <> 's') then
			' INNER JOIN portfolio_hierarchy s ON s.entity_id = now.sub_entity_id
			INNER JOIN portfolio_hierarchy st ON st.entity_id = now.strategy_entity_id 
			 INNER JOIN portfolio_hierarchy b ON b.entity_id = now.book_entity_id '	
			else '' end +	' LEFT OUTER JOIN #rmv  beginning 
						ON now.link_id = beginning.link_id AND now.term_month = beginning.term_month
						 	AND beginning.as_of_date = CONVERT(DATETIME, ''' + @beginning_date  +''', 102)
						AND beginning.link_deal_flag <> ''d'' AND beginning.hedge_type_value_id = 150  '
		
		--print @Sql_Select + @Sql_From + @Sql_Where
		SET @Sql8 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		
		--print @Sql8

		

if @report_type<>'s'
	Begin
		create table #temp_tabe ([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,[No] int,
		ItemsToBeDisclosed varchar(300) COLLATE DATABASE_DEFAULT,TotalAmount float)
	
		EXEC('insert into #temp_tabe select r.SUB,r.str,r.book,ISNULL(r.No,0) as [No],ISNULL(r.ItemsToBeDisclosed,0) as [ItemsToBeDisclosed],r.[TotalAmount] as [TotalAmount] from ('+@sql1 + 
		' UNION ' + @sql2 + ' UNION ' + @sql3 +' UNION ' + @sql4  + ' UNION ' + @sql5 + ' UNION ' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8+') r 
		') 


		create table #temp_term(term varchar(100) COLLATE DATABASE_DEFAULT)
		SET @Sql_Select = 'insert into #temp_term SELECT dbo.FNADateFormat(MAX(RMV.term_month ))'
	
		SET @Sql_From = ' FROM     #rmv  RMV 
						INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id'

		SET @Sql_Where = ' WHERE   (link_deal_flag <> ''d'') AND
						(RMV.as_of_date =  CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) 
						AND   
						(RMV.sub_entity_id IN( ' + @subsidiary_id + ')) '
						
		IF @strategy_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'
		IF @book_id IS NOT NULL
			SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '
		
		--For Cash Flow
		SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id = 150'
		
		
		SET @Sql10 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
		EXEC(@Sql10)
		Declare @term_month varchar(100)
		select @term_month=term from #temp_term
		
		
				
		create table #temp_sub([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,[No] int,
		ItemsToBeDisclosed varchar(300) COLLATE DATABASE_DEFAULT, TotalAmount float)

		DECLARE a_cursor CURSOR FOR
		select distinct   sub,str,book from #temp_tabe
		order by sub
		
		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @subname,@strname,@bookname
			WHILE @@FETCH_STATUS = 0   
		BEGIN 
			set @i=8
			while @i<>0
				Begin
					if @i=1
					set @item_name='Amount of hedges Ineffectiveness recognized in earnings'+@date_desc
					else if @i=2
					set @item_name='Component of hedges excluded from hedge ineffectiveness'+@date_desc
					else if @i=3
					set @item_name='Reclassification of AOCI into earnings due to settlement'+@date_desc
					else if @i=4
					set @item_name='Reclassification of AOCI into initial carrying amount of assets/liabilities'+@date_desc
					else if @i=5
					set @item_name='Reclassification of AOCI into earnings within next 12 months:'
					else if @i=6
					set @item_name='Reclassification of AOCI into earnings due to forcasted transactions will not be probable' +@date_desc
					else if @i=7
					set @item_name='Maximum length of time that the entity is hedging its exposure is '+@term_month+'(Months)' 
					else if @i=8
					set @item_name='Gains and Losses of Hedges recognized in AOCI'+@date_desc

					insert into #temp_sub values(@subname,@strname,@bookname,@i,@item_name,0)					
					set @i=@i-1
				End
			
			FETCH NEXT FROM a_cursor INTO  @subname,@strname,@bookname
		END 
		CLOSE a_cursor
		DEALLOCATE  a_cursor		

	
	End
		
	if @report_type='s'
	EXEC  ('SELECT No [S.N.], ItemsToBeDisclosed [Items to be Disclosed] , TotalAmount [Total Amount] ' + @str_batch_table + ' FROM ( ' + @sql0 + ' UNION ' + @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ' UNION ' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8 +') c')
	else if @report_type='a'
	Begin
		EXEC('select z.No as [S.N.], z.SUB as Subsidiary,ISNULL(z.ItemsToBeDisclosed,0) as [Items to be Disclosed],
		case when z.No=7 then round(ISNULL(max(r.[TotalAmount]),0),0) 
		else  round(ISNULL(SUM(r.[TotalAmount]),0),0) 
			End as [Total Amount] ' + @str_batch_table + ' from ('+@sql0 + ' UNION ' + @sql1 + 
		' UNION ' + @sql2 + ' UNION ' + @sql3 +' UNION ' + @sql4  + ' UNION ' + @sql5 + ' UNION ' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8+') r 
		RIGHT OUTER JOIN (select sub,No,ItemsToBeDisclosed,max(totalamount) as [TotalAmount]
		 from #temp_sub group by sub,No,ItemsToBeDisclosed) z
		on r.No=z.No and r.sub=z.sub 
		group by z.SUB,z.No,z.ItemsToBeDisclosed order by z.SUB,z.No') 
	End
	else if @report_type='b'
		EXEC('select ISNULL(z.No,0) as [S.N.], ISNULL(z.SUB,0) as [Subsidiary],ISNULL(z.str,0) as Strategy,
		ISNULL(z.ItemsToBeDisclosed,0) as [Items to be Disclosed],
		case when z.No=7 then round(ISNULL(max(r.[TotalAmount]),0),0) 
			else  round(ISNULL(SUM(r.[TotalAmount]),0),0) END  as [Total Amount] ' + @str_batch_table + ' from ('+@sql0 + ' UNION ' + @sql1 +
		' UNION ' + @sql2 + ' UNION ' + @sql3 +'UNION ' + @sql4  + ' UNION ' + @sql5 + ' UNION ' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8+') r 
		RIGHT OUTER JOIN (select sub,str,No,ItemsToBeDisclosed,sum(totalamount)as 
		[TotalAmount] from #temp_sub group by sub,str,No,ItemsToBeDisclosed) z
		on r.No=z.No and r.sub=z.sub and r.str=z.str
		group by z.SUB,z.str,z.No,z.ItemsToBeDisclosed order by z.SUB,z.str,z.No') 
	
	else if @report_type='c'
	BEGIN
		exec spa_print 'select ISNULL(z.No,0) as [S.N.], ISNULL(z.SUB,0) as Subsidiary,ISNULL(z.str,0) as Strategy,ISNULL(z.book,0 as Book
		,ISNULL(z.ItemsToBeDisclosed,0) as [Items to be Disclosed],
		case when z.No=7 then round(ISNULL(max(r.[TotalAmount]),0),0) 
		else  round(ISNULL(SUM(r.[TotalAmount]),0),0) END  as [Total Amount]  from ('
	
		EXEC spa_print @sql0, ' UNION ', @sql1 
		EXEC spa_print	' UNION ', @sql2, ' UNION ' 
		EXEC spa_print @sql3, 'UNION ' 
		EXEC spa_print @sql4, ' UNION ' 
		EXEC spa_print @sql5,' UNION ',@sql6 
		EXEC spa_print ' UNION ', @sql7, ' UNION '
		EXEC spa_print @sql8, ') r 
		RIGHT OUTER JOIN (select sub,str,book,No,ItemsToBeDisclosed,sum(totalamount)as [TotalAmount] from #temp_sub group by sub,str,book,No,ItemsToBeDisclosed) z
		on r.No=z.No and r.sub=z.sub and r.str=z.str and r.book=z.book
		group by z.SUB,z.str,z.book,z.No,z.ItemsToBeDisclosed order by z.SUB,z.str,z.book,z.No'

		
		EXEC('select ISNULL(z.No,0) as [S.N.],ISNULL(z.SUB,0) as Subsidiary,ISNULL(z.str,0) as Strategy,ISNULL(z.book,0) as Book,
		ISNULL(z.ItemsToBeDisclosed,0) as [Items to be Disclosed],
		case when z.No=7 then round(ISNULL(max(r.[TotalAmount]),0),0) 
		else  round(ISNULL(SUM(r.[TotalAmount]),0),0) END  as [Total Amount] ' + @str_batch_table + ' from ('+@sql0 + ' UNION ' + @sql1 +
		' UNION ' + @sql2 + ' UNION ' + @sql3 +'UNION ' + @sql4  + ' UNION ' + @sql5 + ' UNION ' + @sql6 + ' UNION ' + @sql7 + ' UNION ' + @sql8+') r 
		RIGHT OUTER JOIN (select sub,str,book,No,ItemsToBeDisclosed,sum(totalamount)as [TotalAmount] from #temp_sub group by sub,str,book,No,ItemsToBeDisclosed) z
		on r.No=z.No and r.sub=z.sub and r.str=z.str and r.book=z.book
		group by z.SUB,z.str,z.book,z.No,z.ItemsToBeDisclosed order by z.SUB,z.str,z.book,z.No') 
		--print @sql1 + ' UNION ' + @sql2 + ' UNION ' + @sql3 + ' UNION ' + @sql4  + ' UNION ' + @sql5 + ' UNION ' + @sql6
	END 
END

--==================================================================================================

IF @hedge_type = 'm' 

BEGIN
	EXEC spa_Create_Reconciliation_Report @as_of_date, @subsidiary_id, @strategy_id, @book_id, @discount_option, 'm', @report_type, @prior_months, NULL, @batch_process_id, @batch_report_param
END

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
IF @is_batch = 1
 
BEGIN
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 
	EXEC (@str_batch_table)
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_Create_Disclosure_Report', 'Accounting Disclosure Report') --TODO: modify sp and report name
 
	EXEC (@str_batch_table)
 
	RETURN
 
END

IF @enable_paging = 1 AND @page_no IS NULL 
BEGIN 
	SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no) 
	EXEC (@sql_paging) 
END

/*******************************************2nd Paging Batch END**********************************************/
 
GO