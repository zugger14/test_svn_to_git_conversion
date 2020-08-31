/****** Object:  StoredProcedure [dbo].[spa_create_failed_assessment_reports]    Script Date: 03/09/2010 10:36:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_failed_assessment_reports]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_failed_assessment_reports]
 GO 
/****** Object:  StoredProcedure [dbo].[spa_create_failed_assessment_reports]    Script Date: 03/09/2010 10:35:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

-- exec spa_create_failed_assessment_reports '1,2,20', NULL, NULL, NULL, 'e'
-- exec spa_create_failed_assessment_reports '1,2,20', '3,4,5,6', '10', '3/31/2003', 'a'

-- exception_flag = 'e' means only failed and 'a' means all
CREATE procedure [dbo].[spa_create_failed_assessment_reports] 
	@subsidiary_id varchar(MAX),
	@strategy_id varchar(MAX) = NULL,
	@book_id varchar(MAX) = NULL,		
	@as_of_date varchar(20) = NULL,
	@show_option varchar(1) = 'e',
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL,
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
as
/*******************************************1st Paging Batch START**********************************************/
 
SET NOCOUNT ON 
 
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
DECLARE @sql_stmt varchar(8000)
create table #max_date (as_of_date datetime)


if @as_of_date IS NULL
	select @as_of_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from measurement_run_dates

SET @sql_stmt = '
SELECT ''' + @as_of_date + ''' AS Date, ph_sub.entity_name AS Subsidiary, ph_str.entity_name Strategy, 
		dbo.FNATRMWinHyperlink(''a'', 10233700, ph_book.entity_name + '' ('' + all_values.link_description + '')'', ABS(all_values.link_id),null,null,null,null,null,null,null,null,null,null,null,0) AS [Book (Relation ID)],
		dbo.FNATRMWinHyperlink(''a'', 10231900, (cast(all_values.eff_test_profile_id as varchar) + '' - '' + all_values.eff_test_name), ABS(all_values.eff_test_profile_id),null,null,null,null,null,null,null,null,null,null,null,0) AS [Relation Type Name],
		--dbo.FNAHyperLinkText(10233710, ph_book.entity_name + '' ('' + all_values.link_description + '')'' , all_values.link_id) [Book (Relation ID)], 
		--dbo.FNAHyperLinkText(10231910, (cast(all_values.eff_test_profile_id as varchar) + '' - '' + all_values.eff_test_name), all_values.eff_test_profile_id) AS [Relation Type Name],
		all_values.[Assesment Type],
		case when (all_values.Test = 0) then ''Failed'' else ''Passed'' end as Status,
		ROUND(all_values.use_assessment_values, 2) as [Value 1], 
	--cast(round(all_values.use_assessment_values, 2) as varchar) as [Value 1], 
	cast(round(all_values.test_range_from, 2) as varchar) [Test Range From 1], 
	cast(round(all_values.test_range_to, 2) as varchar) [Test Range To 1], 
	cast(round(all_values.use_additional_assessment_values, 2) as varchar) as [Value 2],
	cast(round(all_values.additional_test_range_from, 2) as varchar) [Test Range From 2], 
        cast(round(all_values.additional_test_range_to, 2) as varchar) [Test Range To 2],
	cast(round(all_values.use_additional_assessment_values2, 2) as varchar) as [Value 3],
	cast(round(all_values.additional_test_range_from2, 2) as varchar) [Test Range From 3], 
        cast(round(all_values.additional_test_range_to2, 2) as varchar) [Test Range To 3]
' + @str_batch_table + '
from (SELECT
        cd.fas_subsidiary_id, cd.fas_strategy_id, cd.fas_book_id, 
		cast(cd.link_id as varchar) link_id,  
		max(case when(cd.on_eff_test_approach_value_id <> 302) then use_assessment_values else dol_offset  end) use_assessment_values, 
		max(cd.test_range_from) test_range_from, max(cd.test_range_to) test_range_to, 
		max(cd.use_additional_assessment_values) use_additional_assessment_values, 
		max(cd.additional_test_range_from) additional_test_range_from, 
		max(cd.additional_test_range_to) additional_test_range_to,
		max(cd.use_additional_assessment_values2) use_additional_assessment_values2, 
		max(cd.additional_test_range_from2) additional_test_range_from2, 
		max(cd.additional_test_range_to2) additional_test_range_to2,
		max(cd.assessment_test) Test,
		max(rel.eff_test_profile_id) eff_test_profile_id,
		max(rel.eff_test_name) eff_test_name,
		max(sdv.code) as [Assesment Type],
		cast(cd.link_id as varchar) + '' - '' +max(flh.link_description) link_description
FROM    '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + '  cd inner join
fas_eff_hedge_rel_type rel on rel.eff_test_profile_id = cd.use_eff_test_profile_id inner join
static_data_value sdv on sdv.value_id = cd.on_eff_test_approach_value_id inner join
fas_link_header flh ON flh.link_id = cd.link_id
WHERE   cd.eff_test_profile_id IS NOT NULL AND as_of_date =  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)
AND cd.fas_subsidiary_id IN (' + @subsidiary_id + ')'

If @strategy_id IS NOT NULL
	SET @sql_stmt = @sql_stmt + ' AND cd.fas_strategy_id IN (' + @strategy_id + ')'
If @book_id IS NOT NULL
	SET @sql_stmt = @sql_stmt + ' AND cd.fas_book_id IN (' + @book_id + ')'

SET @sql_stmt = @sql_stmt +
'
group by cd.fas_subsidiary_id, cd.fas_strategy_id, cd.fas_book_id, cd.eff_test_profile_id, cd.link_id 
)
 all_values INNER JOIN
portfolio_hierarchy ph_sub on ph_sub.entity_id = all_values.fas_subsidiary_id INNER JOIN
portfolio_hierarchy ph_str on ph_str.entity_id = all_values.fas_strategy_id INNER JOIN
portfolio_hierarchy ph_book on ph_book.entity_id = all_values.fas_book_id 
where all_values.Test = case when (''' + @show_option + '''= ''e'') then 0 else all_values.Test end'

EXEC (@sql_stmt)

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
IF @is_batch = 1
 
BEGIN
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 
	EXEC (@str_batch_table)
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_create_failed_assessment_reports', 'Failed Assessment Values Report') --TODO: modify sp and report name
 
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