IF OBJECT_ID(N'spa_Create_Dedesignation_Values_Report', N'P') IS NOT NULL
DROP PROCEDURE spa_Create_Dedesignation_Values_Report
 GO 




-- exec spa_Create_Dedesignation_Values_Report '2005-03-31', '30', '208', '225', 'd', 'c', 'd', NULL

-- EXEC spa_Create_Dedesignation_Values_Report '9/1/2004', 1, NULL, NULL, 'u', 'c', 'd',50
-- EXEC spa_Create_Dedesignation_Values_Report '1/31/2003', 1, NULL, NULL, 'u', NULL, 'd', 50
--===========================================================================================
--This Procedure create dedesignation values report
--Input Parameters_
--@as_of_date - effective date
--@sub_entity_id - subsidiary Id
--@strategy_entity_id - strategy Id
--@book_entity_id - book Id
--@discount_option - takes two values 'd' or 'u', corresponding to 'discounted', 'undiscounted' 
--@report_type- 'c' for cash flow and 'f' for fair value
--@summary_option - takes 'd', 's' corresponding to 'detail' , 'summary' report
--===========================================================================================
create PROC [dbo].[spa_Create_Dedesignation_Values_Report] 
		@as_of_date varchar(50), 
		@sub_entity_id varchar(MAX),
		@strategy_entity_id varchar(MAX) = NULL,
		@book_entity_id varchar(MAX) = NULL, 
		@discount_option char(1),
		@report_type char(1),
		@summary_option char(1), 
		@link_id varchar(100) = NULL,
		@round_value char(2) = '0',
		@term_start DATETIME=NULL,
		@term_end DATETIME=NULL,
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
--select * from static_data_value where type_id = 450
DECLARE @sqlStmt varchar(8000)

if @summary_option = 's'
	set @sqlStmt =
		' select sub.entity_name Sub, stra.entity_name Strategy, book.entity_name Book, sc.currency_name Currency,' + 
		'round(sum(' + @discount_option+ '_hedge_mtm),'+ @round_value +')  [Dedesignated Hedge PNL], ' +
		'round(sum(' + @discount_option+ '_total_aoci),'+ @round_value +')  [Dedesignated AOCI], ' +
		'round(sum(' + @discount_option+ '_total_pnl),'+ @round_value +')  [Dedesignated PNL] '
		 + @str_batch_table + 
		' from ' + dbo.FNAGetProcessTableName(@as_of_date,'report_measurement_values') + ' rmv INNER JOIN
		portfolio_hierarchy sub ON sub.entity_id = rmv.sub_entity_id INNER JOIN
		portfolio_hierarchy stra ON stra.entity_id = rmv.strategy_entity_id INNER JOIN
		portfolio_hierarchy book ON book.entity_id = rmv.book_entity_id  INNER JOIN
		--WhatIf Changes
		fas_books fb ON fb.fas_book_id = rmv.book_entity_id INNER JOIN 
		source_currency sc ON sc.source_currency_id = rmv.currency_unit
		where rmv.hedge_type_value_id = ' + case when (@report_type = 'c') then '150'  else '151' end + ' and 
		rmv.link_type_value_id <> 450 and  
		--WhatIf Changes
		(fb.no_link IS NULL OR fb.no_link = ''n'') AND 
		rmv.as_of_date = ''' + @as_of_date + '''
		'
		+ case when (@sub_entity_id is not null) then ' and sub_entity_id in (' + @sub_entity_id + ')' else '' end
		+ case when (@strategy_entity_id is not null) then ' and strategy_entity_id in (' + @strategy_entity_id + ')' else '' end
		+ case when (@book_entity_id is not null) then ' and book_entity_id in (' + @book_entity_id + ')' else '' end
		+ case when (@link_id is not null) then ' and link_id in (' + @link_id + ')' else '' end
		+ CASE 
			WHEN (@term_start IS NOT NULL AND @term_end IS NULL)
			THEN ' AND convert(varchar(10),rmv.term_month,120) >=''' + CONVERT(varchar(10),@term_start,120) + ''''
			WHEN (@term_start IS NULL AND @term_end IS NOT NULL)
			THEN ' AND convert(varchar(10),rmv.term_month,120) <=''' + CONVERT(varchar(10),@term_end,120) + ''''
			WHEN (@term_start IS NOT NULL AND @term_end IS NOT NULL)
			THEN ' AND convert(varchar(10),rmv.term_month,120) BETWEEN ''' + CONVERT(varchar(10),@term_start,120) + ''' AND ''' + CONVERT(varchar(10),@term_end,120) + ''''
			ELSE ''
		  END
		+
		' group by sub.entity_name, stra.entity_name, book.entity_name, sc.currency_name
		'
else
	set @sqlStmt =
		' select sub.entity_name Sub, stra.entity_name Strategy, book.entity_name Book, 
		dbo.FNATrmWinHyperlink (''a'',10233700, rmv.link_id, rmv.link_id, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, 0) [Hedge Rel ID],
		dbo.FNADateFormat(flh.link_end_date) [Dedesignation Date],
		dbo.FNADateFormat(rmv.term_month) [Term], 
		sc.currency_name Currency,' + 
		'round(sum(' + @discount_option+ '_hedge_mtm),'+ @round_value +') [Dedesignated Hedge PNL], ' +
		'round(sum(' + @discount_option+ '_total_aoci),'+ @round_value +') [Dedesignated AOCI], ' +
		'round(sum(' + @discount_option+ '_total_pnl),'+ @round_value +') [Dedesignated PNL] '
		+ @str_batch_table + 
		' from ' + dbo.FNAGetProcessTableName(@as_of_date,'report_measurement_values') + ' rmv INNER JOIN
		portfolio_hierarchy sub ON sub.entity_id = rmv.sub_entity_id INNER JOIN
		portfolio_hierarchy stra ON stra.entity_id = rmv.strategy_entity_id INNER JOIN
		portfolio_hierarchy book ON book.entity_id = rmv.book_entity_id  INNER JOIN
		--WhatIf Changes
		fas_books fb ON fb.fas_book_id = rmv.book_entity_id INNER JOIN
		source_currency sc ON sc.source_currency_id = rmv.currency_unit INNER JOIN
		fas_link_header flh ON flh.link_id = rmv.link_id
		where rmv.hedge_type_value_id = ' + case when (@report_type = 'c') then '150'  else '151' end + ' and 
		--WhatIf Changes
		(fb.no_link IS NULL OR fb.no_link = ''n'') AND 
		rmv.link_type_value_id <> 450 and  
		rmv.as_of_date = ''' + @as_of_date + '''
		'
		+ case when (@sub_entity_id is not null) then ' and sub_entity_id in (' + @sub_entity_id + ')' else '' end
		+ case when (@strategy_entity_id is not null) then ' and strategy_entity_id in (' + @strategy_entity_id + ')' else '' end
		+ case when (@book_entity_id is not null) then ' and book_entity_id in (' + @book_entity_id + ')' else '' end
		+ case when (@link_id is not null) then ' and rmv.link_id in (' + @link_id + ')' else '' end
		+ CASE 
			WHEN (@term_start IS NOT NULL AND @term_end IS NULL)
			THEN ' AND convert(varchar(10),rmv.term_month,120) >=''' + CONVERT(varchar(10),@term_start,120) + ''''
			WHEN (@term_start IS NULL AND @term_end IS NOT NULL)
			THEN ' AND convert(varchar(10),rmv.term_month,120) <=''' + CONVERT(varchar(10),@term_end,120) + ''''
			WHEN (@term_start IS NOT NULL AND @term_end IS NOT NULL)
			THEN ' AND convert(varchar(10),rmv.term_month,120) BETWEEN ''' + CONVERT(varchar(10),@term_start,120) + ''' AND ''' + CONVERT(varchar(10),@term_end,120) + ''''
			ELSE ''
		  END 
		+
		' group by sub.entity_name, stra.entity_name, book.entity_name, sc.currency_name,
				rmv.link_id, flh.link_end_date, rmv.term_month 
		ORDER BY sub.entity_name, stra.entity_name, book.entity_name, rmv.link_id, rmv.term_month 
		'

EXEC spa_print @sqlStmt
exec(@sqlStmt)

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
IF @is_batch = 1
 
BEGIN
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 
	EXEC (@str_batch_table)
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_Create_Dedesignation_Values_Report', 'De-Designation Values Report') --TODO: modify sp and report name
 
	EXEC (@str_batch_table)
 
	RETURN
 
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
 
IF @enable_paging = 1 AND @page_no IS NULL 
BEGIN 
	SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no) 
	EXEC (@sql_paging) 
END
 
/*******************************************2nd Paging Batch END**********************************************/
 
GO