IF OBJECT_ID(N'spa_Get_Assessment_Results', N'P') IS NOT NULL
	DROP PROCEDURE spa_Get_Assessment_Results
GO 

/**
	This Procedure returns assessment results.

	Parameters
	@subsidiary_id : Fas Subsidiary Ids.
	@strategy_id : Fas Strategy Ids.
	@book_id : Fas Book Ids.
	@hedge_relationship_type_id : Hedge Relationship Type Id to get eff_test_profile_id, link_id and calc_level.
	@date_from : As of date (from) fas_eff_ass_test_results.
	@date_to : As of date (to) fas_eff_ass_test_results.
	@initial_ongoing : Expected --'i' from Initial and 'o' for Ongoing.
	@round_value : Round Value needed after decimal.
	@batch_process_id : Batch Process Id.
	@batch_report_param : Param report for batch.
	@enable_paging : --'1' = enable, '0' = disable.
	@page_size : Page Size.
	@page_no : Page No.
*/



-- DROP PROC spa_Get_Assessment_Results
-- exec spa_Get_Assessment_Results '291,30,1,257,258,256', NULL, NULL, NULL, '2001-01-01', '2008-04-01', 'o'
-- EXEC spa_Get_Assessment_Results NULL, NULL, NULL, '4-11', '2003-01-01', '2005-06-01', 'o'
-- EXEC spa_Get_Assessment_Results NULL, NULL, NULL, '532', '2003-01-01', '2005-06-01', 'o'

--SELECT '''' + REPLACE (REPLACE('4-11, 27-11,423,3123', ' ', ''), ',' , ''',''') + ''''
CREATE  PROC [dbo].[spa_Get_Assessment_Results]  
					@subsidiary_id varchar (MAX) = NULL,
					@strategy_id varchar (MAX) = NULL,				
					@book_id varchar (MAX) = NULL,
					@hedge_relationship_type_id varchar (8000) = NULL,
					@date_from varchar(100),
					@date_to varchar(100),
					@initial_ongoing varchar(1) = NULL,
					@round_value CHAR(1) = '2',
					@link_id VARCHAR(1000) = NULL,
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
		SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no)
	END
 
	--retrieve data from paging table instead of main table
	IF @page_no IS NOT NULL 
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no) 
		EXEC (@sql_paging) 
		RETURN 
	END
END
/*******************************************1st Paging Batch END**********************************************/
--declare				@fas_sub_id varchar (100),
--					@strategy_id varchar (100),				
--					@book_id varchar (100),
--					@hedge_relationship_type_id varchar (8000),
--					@date_from varchar(100),
--					@date_to varchar(100),
--					@initial_ongoing varchar(1)
-- 
--	set		@fas_sub_id=null
--	set				@strategy_id=null
--	set				@book_id=44
--	set				@hedge_relationship_type_id='2-432'
--	set				@date_from='2005-12-31'
--	set				@date_to= '2005-12-31'
--	set				@initial_ongoing='o'
--
--SET NOCOUNT ON
--drop table #assessments_mult
CREATE TABLE #assessments_mult(
	eff_test_profile_id INT,
	link_id INT,
	calc_level INT
)

SET NOCOUNT ON
INSERT INTO #assessments_mult EXEC spa_get_all_assessments_to_run @subsidiary_id,@strategy_id,@book_id,@hedge_relationship_type_id
--select * from #assessments_mult
--return
DECLARE @Sql_Select VARCHAR(5000)
 
--put '' in each key
SET @hedge_relationship_type_id = '''' + REPLACE (REPLACE(@hedge_relationship_type_id, ' ', ''), ',' , ''',''') + ''''
--print @hedge_relationship_type_id 
SET @Sql_Select = 'SELECT 
		dbo.FNADateFormat(fas_eff_ass_test_results.as_of_date) AS [As of Date], 
		static_data_value_1.code AS [Assessment Type], 
        CAST(CAST(fas_eff_ass_test_results.result_value AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS [Assessment Value], 
		CAST(CAST(fas_eff_ass_test_results.additional_result_value AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS [Add Assessment Value], 
		case when (fas_eff_ass_test_results.link_id <> -1) then cast(flh.link_id as varchar) + '' - '' + flh.link_description + '' using '' else '''' end +		
                dbo.FNATRMWinHyperlink(''a'', 10231900, fas_eff_hedge_rel_type.eff_test_name, ABS(fas_eff_hedge_rel_type.eff_test_profile_id),null,null,null,null,null,null,null,null,null,null,null,0) AS [Relation Name],
		--fas_eff_hedge_rel_type.eff_test_name [Rel Name], 
		fas_eff_ass_test_results.eff_test_result_id AS [Result ID],
		phsub.entity_name [Subsidiary],
		phstr.entity_name [Strategy],
		phbook.entity_name [Book],
		case when fas_eff_ass_test_results.user_override = ''y'' THEN ''Yes'' ELSE ''No'' END AS [Overriden By User], 
		CAST(CAST(rph.regression_rsq AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS RSQ, 
		CAST(CAST(rph.regression_corr AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS Correlation, 
		CAST(CAST(rph.regression_slope AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS Slope,
		CAST(CAST(rph.regression_intercept AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS Intercept,
		CAST(CAST(rph.regression_tvalue AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS TValue,
		CAST(CAST(rph.regression_fvalue AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS FValue,
		rph.regression_df As DF,
		fas_eff_ass_test_results.eff_test_profile_id [Rel ID], 
		cast(case when (fas_eff_ass_test_results.link_id = -1) then '' '' else fas_eff_ass_test_results.link_id end as varchar) [Link ID], 
                dbo.FNADateTimeFormat(fas_eff_ass_test_results.create_ts,2) AS   [Created Time Stamp], 
                fas_eff_ass_test_results.create_user AS [Created User], 
		fas_eff_ass_test_results.update_user AS [Updated User], 
		case when initial_ongoing = ''o'' then ''Ongoing'' else ''Inception'' end Type		' + @str_batch_table + '
FROM  #assessments_mult asm inner join  fas_eff_ass_test_results on asm.link_id=fas_eff_ass_test_results.link_id and asm.calc_level=fas_eff_ass_test_results.calc_level
LEFT JOIN fas_eff_hedge_rel_type  on asm.eff_test_profile_id=fas_eff_hedge_rel_type.eff_test_profile_id and asm.calc_level=1
LEFT JOIN fas_link_header flh  on asm.link_id=flh.link_id and asm.calc_level=2 and asm.link_id>0
LEFT JOIN fas_books book on abs(asm.link_id)=book.fas_book_id and asm.calc_level=2 and asm.link_id<0
LEFT JOIN fas_strategy st on abs(asm.link_id)=st.fas_strategy_id and asm.calc_level=2 and asm.link_id<0
--left join portfolio_hierarchy st1 on st.fas_strategy_id=st1.parent_entity_id 
INNER JOIN static_data_value static_data_value_1 ON fas_eff_ass_test_results.eff_test_approach_value_id = static_data_value_1.value_id
LEFT JOIN portfolio_hierarchy phbook ON phbook.entity_id = COALESCE(flh.fas_book_id,book.fas_book_id)
LEFT JOIN portfolio_hierarchy phstr ON phstr.entity_id = COALESCE(phbook.parent_entity_id ,st.fas_strategy_id)
LEFT JOIN portfolio_hierarchy phsub ON phsub.entity_id = phstr.parent_entity_id
LEFT OUTER JOIN fas_eff_ass_test_results_process_header rph ON rph.eff_test_result_id = fas_eff_ass_test_results.eff_test_result_id 
'
SET @Sql_Select = @Sql_Select + ' WHERE 
				--fas_eff_ass_test_results.calc_level IN  (1, 2) AND 
				fas_eff_ass_test_results.as_of_date BETWEEN  CONVERT(DATETIME, ''' + @date_from + ''', 102) AND CONVERT(DATETIME, ''' + @date_to + ''', 102)'

IF @initial_ongoing IS NOT NULL
	SET  @Sql_Select = @Sql_Select + ' AND initial_ongoing = ''' + @initial_ongoing + ''''

IF @link_id IS NOT NULL
	SET @Sql_Select = @Sql_Select + ' AND cast(case when (fas_eff_ass_test_results.link_id = -1) then '' '' else fas_eff_ass_test_results.link_id end as varchar) = ' + @link_id
	
SET @Sql_Select = @Sql_Select 
				+ ' ORDER BY phsub.entity_name,
						phstr.entity_name,
						phbook.entity_name,
						fas_eff_hedge_rel_type.eff_test_profile_id, 
						fas_eff_ass_test_results.eff_test_result_id desc,
						fas_eff_hedge_rel_type.eff_test_name, 
						fas_eff_ass_test_results.as_of_date DESC, 
						fas_eff_ass_test_results.create_ts DESC'

EXEC spa_print @Sql_Select
EXEC (@Sql_Select)

-- ***************** FOR BATCH PROCESSING **********************************    
 
IF  @batch_process_id IS NOT NULL        
BEGIN        
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)
	EXEC(@str_batch_table)     
	DECLARE @report_name VARCHAR(100)
	SET @report_name = 'Assessment Report'   
	
	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(),
				 'spa_Get_Assessment_Results', @report_name) 
	EXEC(@str_batch_table)     
 
END        
-- ********************************************************************