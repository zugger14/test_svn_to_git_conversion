

IF OBJECT_ID(N'spa_Create_Missing_Assessment_Values_Exception_Report', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Create_Missing_Assessment_Values_Exception_Report]
 GO 


---drop proc spa_Create_Missing_Assessment_Values_Exception_Report
----EXEC spa_Create_Missing_Assessment_Values_Exception_Report  '1,2,20', null, null, null, '4/5/2004', 'o', 'e'
----EXEC spa_Create_Missing_Assessment_Values_Exception_Report  '1,2,20', null, null, '3/31/2004', null, 'o', 'a'
--
----exec spa_Create_Missing_Assessment_Values_Exception_Report'1',NULL,NULL,'2003-06-30','2004-08-19','i','e'
----exec spa_Create_Missing_Assessment_Values_Exception_Report'1',NULL,NULL,'2003-06-30',NULL,'i','e'

CREATE PROC [dbo].[spa_Create_Missing_Assessment_Values_Exception_Report] 
				@subsidiary_id varchar(MAX), 
 				@strategy_id varchar(MAX) = NULL, 
				@book_id varchar(MAX) = NULL, 
				@as_of_date varchar(50) = null,
				@threshold_date varchar(50) = null ,
				@assessment char(1), 
				@exception char(1),
				@batch_process_id    VARCHAR(50) = NULL, 
				@batch_report_param  VARCHAR(1000) = NULL

As

SET NOCOUNT ON

-------------------------COMMENT THIS TO TEST----------------
/* 
 Declare @subsidiary_id varchar(100), 
  	@strategy_id varchar(100), 
 	@book_id varchar(100) , 
 	@as_of_date varchar(50) ,
 	@threshold_date varchar(50) ,
 	@assessment char(1), 
 	@exception char(1)
 
 SET @subsidiary_id = '57'
 SET @strategy_id = '58'
 SET @book_id = '73'
 SET @as_of_date = '2009-12-31'
 SET @threshold_date = NULL --'12/31/2005'
 SET @assessment = 'o'
 SET @exception = 'e'
 drop table #assmt
*/
----------------------UNCOMMENT ABOVE TO TEST ------------------
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
 
/*******************************************1st Paging Batch END**********************************************/
create table #assmt (eff_test_profile_id int null, link_id int null, calc_level int null, 
	rel_id varchar(50) COLLATE DATABASE_DEFAULT  null, rel_name varchar(250) COLLATE DATABASE_DEFAULT , rel_url varchar(500) COLLATE DATABASE_DEFAULT )

INSERT #assmt
EXEC spa_get_all_assessments_to_run  @subsidiary_id, @strategy_id, @book_id, NULL, 'y'
--select * from #assmt
DECLARE @sql_stmnt VARCHAR(MAX)
SET @sql_stmnt = ('SELECT	phsub.entity_name Subsidiary,  
					phs.entity_name Strategy, 
					CASE WHEN (fs.fas_strategy_id IS NOT NULL) THEN '''' ELSE phb.entity_name END Book, 
					a.eff_test_profile_id [Relation Type ID],
					a.rel_url [Relation Name], sdv.code [Assesment Type Name], res.assessment_values [Value], dbo.FNADateFormat(res.assessment_date) [As of Date], 
					dbo.FNADateFormat(res.run_date) [Run Date], res.run_user [Run By],
					case when ( ' + CASE WHEN @as_of_date IS NULL THEN 'NULL' ELSE '''' + @as_of_date + '''' END  
					+ ' is not null and ' + CASE WHEN @threshold_date IS NULL THEN 'NULL' ELSE '''' + @threshold_date + '''' END  + ' is null AND datediff(m, res.assessment_date, ' + CASE WHEN @as_of_date IS NULL THEN 'NULL' ELSE '''' + @as_of_date + '''' END  + ') >= 3) then ''Exceeds 3 months''
			 WHEN (' + CASE WHEN @threshold_date IS NULL THEN 'NULL' ELSE '''' + @threshold_date + '''' END  + ' is not null AND res.assessment_date < ' + CASE WHEN @threshold_date IS NULL THEN 'NULL' ELSE '''' + @threshold_date + '''' END  + ') then ''Exceeds threshold date''
		ELSE '''' END [Exceeds] '
+ @str_batch_table + '
from #assmt a left outer join
	fas_link_header flh on flh.link_id = a.link_id left outer join
	fas_eff_hedge_rel_type fehrt on fehrt.eff_test_profile_id = a.eff_test_profile_id left outer join
	fas_books lbb on lbb.fas_book_id = -1*a.link_id left outer join

	fas_strategy fs on fs.fas_strategy_id = -1*a.link_id left outer join
	portfolio_hierarchy phpfs on phpfs.entity_id = fs.fas_strategy_id left outer join
	
	portfolio_hierarchy phb on phb.entity_id = coalesce(flh.fas_book_id, lbb.fas_book_id, fehrt.fas_book_id) left outer join
	portfolio_hierarchy phs on phs.entity_id = coalesce(phb.parent_entity_id, fs.fas_strategy_id) left outer join
	portfolio_hierarchy phsub on phsub.entity_id = coalesce(phs.parent_entity_id, phpfs.parent_entity_id) 
LEFT OUTER JOIN
(
SELECT 	C.eff_test_profile_id, 
	B.result_value as assessment_values,
	B.additional_result_value as additional_assessment_values,
	B.additional_result_value2 as additional_assessment_values2,
	B.as_of_date AS assessment_date, 
	C.on_eff_test_approach_value_id,
	D.regression_df as ddf,
	CAST(case 	when (C.on_eff_test_approach_value_id = 305) then fs.test_range_from/2
			when (C.on_eff_test_approach_value_id IN (307, 309, 311, 313)) then fs.additional_test_range_from/2
			when (C.on_eff_test_approach_value_id = 306) then fs.test_range_from
			when (C.on_eff_test_approach_value_id IN (308, 310, 312, 314)) then fs.additional_test_range_from
	END AS VARCHAR) alpha,
	CASE WHEN(B.link_id IS NULL) THEN -1 ELSE B.link_id END as link_id, 
	CASE WHEN(B.calc_level IS NULL) THEN -1 ELSE B.calc_level END as calc_level, 
	B.eff_test_result_id,
	isnull(C.force_intercept_zero, ''n'') as short_cut_method,
	isnull(C.ineffectiveness_in_hedge, ''n'') as exclude_spot_forward_diff,
	sdv.code [Assesment Type Name],
	B.create_ts run_date,
	au.user_l_name + '', '' + isnull(au.user_m_name + '' '', '''') + au.user_f_name run_user
--INTO #ass_info
FROM
(
SELECT    MaxDate.eff_test_profile_id, MaxDate.link_id, MaxDate.calc_level, MaxDate.as_of_date, 
	  MAX(featr.eff_test_result_id) AS eff_test_result_id
FROM      fas_eff_ass_test_results featr(NOLOCK) 
	LEFT OUTER JOIN
          (
		SELECT	eff_test_profile_id, link_id, calc_level, MAX(as_of_date) AS as_of_date
		FROM    fas_eff_ass_test_results(NOLOCK)
		                         
		WHERE   ((' + CASE WHEN @as_of_date IS NULL THEN 'NULL' ELSE '''' + @as_of_date + '''' END  + ' is null OR as_of_date <= ' + CASE WHEN @as_of_date IS NULL THEN 'NULL' ELSE '''' + @as_of_date + '''' END  + ') AND initial_ongoing = ''' + @assessment + ''' AND calc_level <> 3)                           
		GROUP BY eff_test_profile_id, link_id, calc_level
	   ) MaxDate ON featr.eff_test_profile_id = MaxDate.eff_test_profile_id AND 
	      	featr.as_of_date = MaxDate.as_of_date AND featr.link_id = MaxDate.link_id 
		AND featr.calc_level = MaxDate.calc_level 
GROUP BY MaxDate.eff_test_profile_id, MaxDate.link_id, MaxDate.calc_level, MaxDate.as_of_date
)
As A 
	LEFT OUTER JOIN
fas_eff_ass_test_results B(NOLOCK)
ON A.eff_test_profile_id = B.eff_test_profile_id AND A.as_of_date = B.as_of_date AND 
	A.eff_test_result_id = B.eff_test_result_id
RIGHT OUTER JOIN 
(select eff_test_profile_id, 
		case when (''' + @assessment + ''' = ''o'') then on_eff_test_approach_value_id else init_eff_test_approach_value_id end on_eff_test_approach_value_id,
		force_intercept_zero, ineffectiveness_in_hedge, fas_book_id from fas_eff_hedge_rel_type (NOLOCK))
 C ON A.eff_test_profile_id = C.eff_test_profile_id
LEFT OUTER JOIN 
fas_eff_ass_test_results_process_header D ON D.eff_test_result_id = B.eff_test_result_id
LEFT OUTER JOIN portfolio_hierarchy book ON book.entity_id = C.fas_book_id
LEFT OUTER JOIN fas_strategy fs ON book.parent_entity_id = fs.fas_strategy_id
LEFT OUTER JOIN static_data_value sdv on sdv.value_id = C.on_eff_test_approach_value_id 
LEFT OUTER JOIN application_users au on au.user_login_id = B.create_user
WHERE C.on_eff_test_approach_value_id <> 302 AND C.on_eff_test_approach_value_id <> 304 AND C.on_eff_test_approach_value_id <> 317
) res ON res.eff_test_profile_id = a.eff_test_profile_id AND res.link_id = a.link_id AND res.calc_level = a.calc_level
LEFT OUTER JOIN static_data_value sdv on sdv.value_id = case when (''' + @assessment + ''' = ''o'') then fehrt.on_eff_test_approach_value_id else fehrt.init_eff_test_approach_value_id end

WHERE case when (''' + @assessment + ''' = ''o'') then fehrt.on_eff_test_approach_value_id else fehrt.init_eff_test_approach_value_id end NOT IN (302, 304, 317)
AND (''' + @exception + ''' = ''a'' OR res.assessment_values IS NULL)

ORDER BY phsub.entity_name ,  phs.entity_name , a.eff_test_profile_id, a.rel_id')

EXEC(@sql_stmnt) 
/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
IF @is_batch = 1
 
BEGIN
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 
	EXEC (@str_batch_table)
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_Create_Missing_Assessment_Values_Exception_Report', 'Missing Assessment Values Report') --TODO: modify sp and report name
 
	EXEC (@str_batch_table)
 
	RETURN
 
END
 
/*******************************************2nd Paging Batch END**********************************************/
 
GO
