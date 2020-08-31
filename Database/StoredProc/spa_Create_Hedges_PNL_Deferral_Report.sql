/****** Object:  StoredProcedure [dbo].[spa_Create_Hedges_PNL_Deferral_Report]    Script Date: 11/07/2011 13:10:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Create_Hedges_PNL_Deferral_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_Hedges_PNL_Deferral_Report]
GO

/****** Object:  StoredProcedure [dbo].[spa_Create_Hedges_PNL_Deferral_Report]    Script Date: 11/07/2011 20:15:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- exec spa_Create_Hedges_PNL_Deferral_Report '2010-10-01', 202
-- exec spa_Create_Hedges_PNL_Deferral_Report '2010-10-01', 202, null, null, null, null, 'd', 'd'
-- exec spa_Create_Hedges_PNL_Deferral_Report '2010-10-01', 202, null, null, null, null, 'd', 'd', 2, '2010-01-01', 19

CREATE PROCEDURE [dbo].[spa_Create_Hedges_PNL_Deferral_Report] (
	@as_of_date VARCHAR(20),
	@sub_entity_id VARCHAR(500),
	@strategy_entity_id VARCHAR(500) = NULL,
	@book_entity_id VARCHAR(500) = NULL,
	@term_start VARCHAR(20) = NULL, 
	@term_end VARCHAR(20) = NULL, 
	@discounting_option VARCHAR(1) = 'd',
	@summary_option VARCHAR(1) = 's',   --'s' summary, 'd' detail , 't' detail at deal level
	@round INT = 2, 
	@drill_pnl_term VARCHAR(20) = NULL, 
	@drill_eff_test_id VARCHAR(20) = NULL, 
	@pnl_source_value_id INT = 4500,
	@allocation_option INT = NULL,
	@hedge_id INT = NULL,
	@item_id INT = NULL,
	@source_deal_header_id VARCHAR(1000) = NULL,
	@deal_id VARCHAR(100) = NULL,
	@deal_list_table VARCHAR(300) = NULL, -- contains list of deals to be processed
	--@deal_filter_id VARCHAR(200) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
)
AS

SET NOCOUNT ON 
/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch bit

SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 


IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)


IF @enable_paging = 1 --paging processing
BEGIN
   IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()


   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)


   --retrieve data from paging table instead of main table
   IF @page_no IS NOT NULL 
   BEGIN
      SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
      EXEC (@sql_paging) 
      RETURN 
   END
END
/*******************************************1st Paging Batch END**********************************************/

-----------------TESTING BEGINS HERE
/*
DECLARE @sub_entity_id varchar(500)
DECLARE @strategy_entity_id varchar(500)
DECLARE @book_entity_id varchar(500)
DECLARE @as_of_date varchar(20)
DECLARE @term_start varchar(20)
DECLARE @term_end varchar(20)
DECLARE @discounting_option varchar(1)
DECLARE @summary_option varchar(1)
DECLARE @drill_pnl_term varchar(20)
DECLARE @drill_eff_test_id varchar(20)
DECLARE @round INT
DECLARE @pnl_source_value_id INT 

set @sub_entity_id=202
set @strategy_entity_id=null
set @book_entity_id=null
set @as_of_date='2010-10-01'
set @term_start=null
set @term_end=null
set @discounting_option='d'
set @summary_option='s'
set @drill_pnl_term='2010-09-01'
set @round=2
set @pnl_source_value_id=4500

drop table #books
drop table #results1
drop table #t_values
drop table #pnl_def
drop table #alloc_months
--*/
---------TESTING ENDS HERE

DECLARE @Sql_SelectB VARCHAR(5000)        
DECLARE @Sql_WhereB VARCHAR(5000)        
DECLARE @Sql_B VARCHAR(5000)
DECLARE @sql_batch VARCHAR(MAX)
DECLARE @assignment_type INT        
        
SET @Sql_WhereB = ''        

CREATE TABLE #books (fas_book_id INT, source_system_book_id1 INT, source_system_book_id2 INT, source_system_book_id3 INT, source_system_book_id4 INT) 
CREATE TABLE #source_deal_header_id (source_deal_header_id INT)
IF OBJECT_ID(@deal_list_table) IS NOT NULL
BEGIN
    EXEC ('INSERT INTO #source_deal_header_id  SELECT DISTINCT source_deal_header_id FROM ' + @deal_list_table)
END
IF @pnl_source_value_id IS NULL
	SET @pnl_source_value_id=4500

SET @Sql_SelectB=        
'INSERT INTO  #books     
SELECT	distinct book.entity_id fas_book_id,
		ssbm.source_system_book_id1, ssbm.source_system_book_id2, ssbm.source_system_book_id3, ssbm.source_system_book_id4 
FROM portfolio_hierarchy book (nolock) INNER JOIN
            Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
            source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
WHERE 1 = 1
'   
              
IF @sub_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '         
 IF @strategy_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        
 IF @book_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN(' + @book_entity_id + ')) '        
        
SET @Sql_SelectB=@Sql_SelectB+@Sql_WhereB        
              
EXEC (@Sql_SelectB)

CREATE TABLE #sdh (source_deal_header_id INT)
IF @source_deal_header_id IS NOT NULL 
	EXEC('INSERT INTO #sdh select source_deal_header_id from source_deal_header where source_deal_header_id in ('+@source_deal_header_id+')')
ELSE IF @deal_id IS NOT NULL
	EXEC('INSERT INTO #sdh select source_deal_header_id from source_deal_header where deal_id in ('''+@deal_id+''')')
IF OBJECT_ID(@deal_list_table) IS NOT NULL
BEGIN
    EXEC ('INSERT INTO #sdh  SELECT DISTINCT source_deal_header_id FROM ' + @deal_list_table)
END

--SELECT * FROM #source_deal_header_id
--FIRST INSERT INTO A TEMPORARY TABLE
SELECT  hdv.as_of_date,hdv.set_type,hdv.eff_test_profile_id,
		hdv.source_deal_header_id,hdv.cash_flow_term,
		hdv.pnl_term,hdv.strip_from,hdv.lag,strip_to,hdv.und_mtm,hdv.dis_mtm,hdv.und_pnl,hdv.dis_pnl,
		hdv.per_alloc,hdv.create_ts,hdv.create_user,'Released' [Type]
INTO #hedge_deferral_values 
FROM	source_deal_header sdh 
		INNER JOIN #books b 
			ON b.source_system_book_id1 = sdh.source_system_book_id1 
			AND b.source_system_book_id2 = sdh.source_system_book_id2 
			AND b.source_system_book_id3 = sdh.source_system_book_id3 
			AND b.source_system_book_id4 = sdh.source_system_book_id4 
		INNER JOIN hedge_deferral_values hdv 
			ON hdv.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN fas_eff_hedge_rel_type f 
			ON f.eff_test_profile_id = hdv.eff_test_profile_id LEFT JOIN
		#sdh s ON s.source_deal_header_id = sdh.source_deal_header_id
		
WHERE	as_of_date = @as_of_date 
		AND hdv.set_type='f'
		AND f.eff_test_profile_id = ISNULL(@drill_eff_test_id, f.eff_test_profile_id)		
		AND (cash_flow_term BETWEEN ISNULL(@term_start, cash_flow_term) AND ISNULL(@term_end, cash_flow_term) OR
			pnl_term BETWEEN ISNULL(@term_start, pnl_term) AND ISNULL(@term_end, pnl_term)) 		
		AND (@source_deal_header_id IS NULL OR (@source_deal_header_id IS NOT NULL AND s.source_deal_header_id IS NOT NULL))
		AND (@deal_list_table IS NULL OR (@deal_list_table IS NOT NULL AND s.source_deal_header_id IN (SELECT source_deal_header_id FROM #source_deal_header_id)))

INSERT INTO #hedge_deferral_values 
SELECT hdv.as_of_date,hdv.set_type,hdv.eff_test_profile_id,hdv.source_deal_header_id,
		hdv.cash_flow_term,hdv.pnl_term,hdv.strip_from,hdv.lag,strip_to,hdv.und_mtm,hdv.dis_mtm,
		hdv.und_pnl,hdv.dis_pnl,hdv.per_alloc,hdv.create_ts,hdv.create_user, 'Released' [Type]
FROM	source_deal_header sdh 
		INNER JOIN #books b 
			ON b.source_system_book_id1 = sdh.source_system_book_id1 
			AND b.source_system_book_id2 = sdh.source_system_book_id2 
			AND b.source_system_book_id3 = sdh.source_system_book_id3 
			AND b.source_system_book_id4 = sdh.source_system_book_id4 
		INNER JOIN hedge_deferral_values hdv 
			ON hdv.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN fas_eff_hedge_rel_type f 
			ON f.eff_test_profile_id = hdv.eff_test_profile_id LEFT JOIN
		#sdh s ON s.source_deal_header_id = sdh.source_deal_header_id
		
WHERE	hdv.set_type='s'
		AND f.eff_test_profile_id = ISNULL(@drill_eff_test_id, f.eff_test_profile_id)
		AND (cash_flow_term BETWEEN ISNULL(@term_start, cash_flow_term) AND ISNULL(@term_end, cash_flow_term) OR
			pnl_term BETWEEN ISNULL(@term_start, pnl_term) AND ISNULL(@term_end, pnl_term)) 		
		AND (@source_deal_header_id IS NULL OR (@source_deal_header_id IS NOT NULL AND s.source_deal_header_id IS NOT NULL))
		AND (@deal_list_table IS NULL OR (@deal_list_table IS NOT NULL AND s.source_deal_header_id IN (SELECT source_deal_header_id FROM #source_deal_header_id)))


INSERT INTO #hedge_deferral_values
select	h.as_of_date, h.set_type, h.eff_test_profile_id, h.source_deal_header_id, h.cash_flow_term, h.cash_flow_term pnl_term, 
		max(h.strip_from) strip_from, max(h.lag) lag, max(h.strip_to) strip_to, MAX(h.und_mtm) und_mtm, MAX(h.dis_mtm) dis_mtm, 
		MAX(h.und_mtm) und_pnl, MAX(h.dis_mtm) dis_pnl,
		MAX(h.per_alloc) per_alloc, MAX(h.create_ts) create_ts, MAX(h.create_user) create_user,  'Original' [Type]
		
from hedge_deferral_values h INNER JOIN
	 #hedge_deferral_values hdv ON hdv.as_of_date = h.as_of_date AND hdv.set_type = h.set_type AND 
	 hdv.source_deal_header_id = h.source_deal_header_id AND hdv.cash_flow_term = h.cash_flow_term
	 AND hdv.pnl_term = h.pnl_term
--where h.pnl_term = ISNULL(@drill_pnl_term, h.pnl_term)
group by h.as_of_date, h.set_type, h.eff_test_profile_id, h.source_deal_header_id, h.cash_flow_term


INSERT INTO #hedge_deferral_values
select	h.as_of_date, h.set_type, h.eff_test_profile_id, h.source_deal_header_id, h.cash_flow_term, h.cash_flow_term pnl_term, 
		max(h.strip_from) strip_from, max(h.lag) lag, max(h.strip_to) strip_to, -1*MAX(h.und_mtm) und_mtm, -1*MAX(h.dis_mtm) dis_mtm, 
		-1*MAX(h.und_mtm) und_pnl, -1*MAX(h.dis_mtm) dis_pnl,
		MAX(h.per_alloc) per_alloc, MAX(h.create_ts) create_ts, MAX(h.create_user) create_user,  'Deferred' [Type]
		
from hedge_deferral_values h INNER JOIN
	 #hedge_deferral_values hdv ON hdv.as_of_date = h.as_of_date AND hdv.set_type = h.set_type AND 
	 hdv.source_deal_header_id = h.source_deal_header_id AND hdv.cash_flow_term = h.cash_flow_term
	 AND hdv.pnl_term = h.pnl_term
where h.pnl_term = ISNULL(@drill_pnl_term, h.pnl_term)
group by h.as_of_date, h.set_type, h.eff_test_profile_id, h.source_deal_header_id, h.cash_flow_term


IF @drill_pnl_term IS NOT NULL
BEGIN
	SET @sql_batch = 'SELECT	dbo.FNADateFormat(''' + @as_of_date + ''') [As Of Date],
			dbo.FNAHyperLinkText(10232000, f.eff_test_name, f.eff_test_profile_id) [Deferral Group Name],
			dbo.FNAHyperLinkText(10131010, CAST(sdh.source_deal_header_id AS VARCHAR), CAST(sdh.source_deal_header_id AS VARCHAR)) [Deal ID],
			MAX(sdh.deal_id) [Deal REF ID],
			CAST(MAX(hdv.strip_from) as varchar) + ''-'' + CAST(MAX(hdv.lag) as varchar) + ''-'' + CAST(MAX(hdv.strip_to) as varchar) [Lag],			
			dbo.FNADateFormat(hdv.cash_flow_term) [Hedge Month],
			dbo.FNADateFormat(hdv.pnl_term) [PNL Month],
			round(MAX(hdv.per_alloc*100),3) [Allocation%],
			ROUND(SUM(CASE WHEN ''' + @discounting_option + ''' = ''d'' THEN hdv.und_mtm ELSE hdv.dis_mtm END), ' + CAST(@round AS VARCHAR(2)) + ') [Hedge Amount],
			ROUND(SUM(CASE WHEN ''' + @discounting_option + ''' = ''d'' THEN hdv.dis_pnl ELSE hdv.und_pnl END), ' + CAST(@round AS VARCHAR(2)) + ') [Deferred Amount]
			' + @str_batch_table + '
			FROM	source_deal_header sdh 
					INNER JOIN #hedge_deferral_values hdv ON hdv.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN fas_eff_hedge_rel_type f ON f.eff_test_profile_id = hdv.eff_test_profile_id
			GROUP BY eff_test_name, f.eff_test_profile_id, hdv.cash_flow_term, hdv.pnl_term, sdh.source_deal_header_id
			ORDER BY [Deferral Group Name],[Deal ID]'
			
	--PRINT (@sql_batch)
    EXEC(@sql_batch)
END
ELSE IF @summary_option='s'
BEGIN
	  SET @sql_batch = '
      SELECT dbo.FNADateFormat('''+@as_of_date+''') [As Of Date],
			 ''<a target="_blank" href="' +
                  './spa_html.php?__user_name__=' + dbo.FNADBUser() 
                  + '&spa=EXEC spa_Create_Hedges_PNL_Deferral_Report ''''' +  @as_of_date 
				  + ''''','+ CASE WHEN @sub_entity_id IS NULL THEN 'null' ELSE '''''' + @sub_entity_id +'''''' end 
				  + ','+ CASE WHEN @strategy_entity_id IS NULL THEN 'null' ELSE '''''' + @strategy_entity_id +'''''' END   
				  + ','+ CASE WHEN @book_entity_id IS NULL THEN 'null' ELSE '''''' + @book_entity_id +'''''' END  
				  + ', ' + CASE WHEN @term_start IS NULL THEN 'NULL' ELSE '''''' + @term_start + ''''''  END +  
				  + ', ' + CASE WHEN @term_end IS NULL THEN 'NULL' ELSE '''''' + @term_end + ''''''  END +  
				  + ',' +  ISNULL(@discounting_option, 'd') 
				  + ', ''''s'''',' + CAST(@round AS VARCHAR) 
				  +  ',''''''+ISNULL(dbo.FNAGetSQLStandardDate(hdv.pnl_term), NULL)+'''''', NULL ,' + 
				  CAST(@pnl_source_value_id AS VARCHAR) + '"> ''+dbo.FNADateFormat(hdv.pnl_term)+'' </a>'' [Month]
             , ROUND(SUM(CASE WHEN ([Type] = ''Original'') THEN '+CASE WHEN @discounting_option = 'd' THEN 'hdv.dis_pnl' ELSE 'hdv.und_pnl' END+' ELSE 0 END),'+CAST(@round AS VARCHAR)+') [Hedge Amount]
             , ROUND(SUM(CASE WHEN ([Type] = ''Deferred'') THEN '+CASE WHEN @discounting_option = 'd' THEN 'hdv.dis_pnl' ELSE 'hdv.und_pnl' END+' ELSE 0 END),'+CAST(@round AS VARCHAR)+') [Deferred Amount]
             , ROUND(SUM(CASE WHEN ([Type] = ''Released'') THEN '+CASE WHEN @discounting_option = 'd' THEN 'hdv.dis_pnl' ELSE 'hdv.und_pnl' END+' ELSE 0 END),'+CAST(@round AS VARCHAR)+') [Released Amount]
             
             '+@str_batch_table+'
      FROM   #hedge_deferral_values hdv 
	  GROUP BY pnl_term ORDER BY pnl_term '
      --PRINT (@sql_batch)
      EXEC(@sql_batch)
--select top 100 * from hedge_deferral_values
END

ELSE IF @summary_option='d'
BEGIN

	  SET @sql_batch = '
			  SELECT dbo.FNADateFormat('''+@as_of_date+''') [As Of Date],
					 dbo.FNAHyperLinkText(10232000, f.eff_test_name, f.eff_test_profile_id) [Deferral Group Name],
			         ''<a target="_blank" href="' +
			         './spa_html.php?__user_name__=' + dbo.FNADBUser() 
			         + '&spa=EXEC spa_Create_Hedges_PNL_Deferral_Report ''''' +  @as_of_date 
			         + ''''',' + CASE WHEN @sub_entity_id IS NULL THEN 'null' ELSE '''''' + @sub_entity_id +'''''' end 
			         + ', ' + ISNULL(@strategy_entity_id, 'NULL') 
			         + ', ' + ISNULL(@book_entity_id, 'NULL') 
					 + ', ' + CASE WHEN @term_start IS NULL THEN 'NULL' ELSE '''''' + @term_start + ''''''  END +  
					 + ', ' + CASE WHEN @term_end IS NULL THEN 'NULL' ELSE '''''' + @term_end + ''''''  END +  
			         + ',' +  ISNULL(@discounting_option, 'd') 
			         + ', ''''s'''',' + CAST(@round AS VARCHAR)  
			         +  ',''''''+ISNULL(dbo.FNAGetSQLStandardDate(hdv.pnl_term), NULL)+'''''','' 
			         + CAST(f.eff_test_profile_id AS VARCHAR) + '',' 
			         + CAST(@pnl_source_value_id AS VARCHAR) + ',NULL,NULL,NULL,NULL,NULL,NULL"> ''+dbo.FNADateFormat(hdv.pnl_term)+'' </a>'' [MONTH]
				 , ROUND(SUM(CASE WHEN ([Type] = ''Original'') THEN '+CASE WHEN @discounting_option = 'd' THEN 'hdv.dis_pnl' ELSE 'hdv.und_pnl' END+' ELSE 0 END),'+CAST(@round AS VARCHAR)+') [Hedge Amount]
				 , ROUND(SUM(CASE WHEN ([Type] = ''Deferred'') THEN '+CASE WHEN @discounting_option = 'd' THEN 'hdv.dis_pnl' ELSE 'hdv.und_pnl' END+' ELSE 0 END),'+CAST(@round AS VARCHAR)+') [Deferred Amount]
				 , ROUND(SUM(CASE WHEN ([Type] = ''Released'') THEN '+CASE WHEN @discounting_option = 'd' THEN 'hdv.dis_pnl' ELSE 'hdv.und_pnl' END+' ELSE 0 END),'+CAST(@round AS VARCHAR)+') [Released Amount]
			  '+@str_batch_table+'
			  FROM   #hedge_deferral_values hdv 
					 INNER JOIN fas_eff_hedge_rel_type f ON  f.eff_test_profile_id = hdv.eff_test_profile_id
			  GROUP BY f.eff_test_name, f.eff_test_profile_id, hdv.pnl_term
	ORDER BY [Deferral Group Name],CAST(hdv.pnl_term AS DATETIME)'
	--PRINT (@sql_batch)
    EXEC(@sql_batch)
END
ELSE
BEGIN

	  SET @sql_batch = '
			SELECT	dbo.FNADateFormat(''' + @as_of_date + ''') [As Of Date],
					dbo.FNAHyperLinkText(10232000, f.eff_test_name, f.eff_test_profile_id) [Deferral Group Name],
					CASE WHEN (dateadd(MONTH,1,cast(convert(varchar(8),hdv.pnl_term, 120)+''01'' AS DATETIME))-1 > ''' + @as_of_date + ''') THEN ''Forward'' Else ''Actual'' END [Type],
					--CASE WHEN (hdv.set_type = ''s'') THEN ''Actual'' ELSE ''Forward'' END [Type],
					sdh.source_deal_header_id [Deal ID],
					MAX(sdh.deal_id) [Deal REF ID],
					dbo.FNAHyperLinkText(10131010, 
						CAST(MAX(hdv.strip_from) as varchar) + ''-'' + CAST(MAX(hdv.lag) as varchar) + ''-'' + CAST(MAX(hdv.strip_to) as varchar),
						CAST(sdh.source_deal_header_id AS VARCHAR)) AS [Lag],
					dbo.FNADateFormat(hdv.pnl_term) [Month]
					 , ROUND(SUM(CASE WHEN ([Type] = ''Original'') THEN '+CASE WHEN @discounting_option = 'd' THEN 'hdv.dis_pnl' ELSE 'hdv.und_pnl' END+' ELSE 0 END),'+CAST(@round AS VARCHAR)+') [Hedge Amount]
					 , ROUND(SUM(CASE WHEN ([Type] = ''Deferred'') THEN '+CASE WHEN @discounting_option = 'd' THEN 'hdv.dis_pnl' ELSE 'hdv.und_pnl' END+' ELSE 0 END),'+CAST(@round AS VARCHAR)+') [Deferred Amount]
					 , ROUND(SUM(CASE WHEN ([Type] = ''Released'') THEN '+CASE WHEN @discounting_option = 'd' THEN 'hdv.dis_pnl' ELSE 'hdv.und_pnl' END+' ELSE 0 END),'+CAST(@round AS VARCHAR)+') [Released Amount]
			'+@str_batch_table+'
			FROM	source_deal_header sdh INNER JOIN 
					#hedge_deferral_values hdv ON hdv.source_deal_header_id = sdh.source_deal_header_id INNER JOIN 
					fas_eff_hedge_rel_type f ON f.eff_test_profile_id = hdv.eff_test_profile_id
			GROUP BY eff_test_name, f.eff_test_profile_id, sdh.source_deal_header_id, hdv.pnl_term, 
					CASE WHEN (hdv.pnl_term >= ''' + @as_of_date + ''') THEN ''Forward'' Else ''Actual'' END
			ORDER BY eff_test_name, f.eff_test_profile_id, sdh.source_deal_header_id, hdv.pnl_term
		'	
	--PRINT (@sql_batch)
    EXEC(@sql_batch)
END


/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)

   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_Create_Hedges_PNL_Deferral_Report', 'Hedges PNL Deferral Report')
   EXEC(@sql_paging)  

   RETURN
END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/