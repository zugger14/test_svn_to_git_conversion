IF OBJECT_ID(N'spa_Get_WhatIf_Assessment_Results', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Get_WhatIf_Assessment_Results]
GO 

--===========================================================================================
--This Procedure returns what if assessment results for a given hedge relationship type
--Input Parameters:
--@fas_sub_id: id of the subsidiary
--@fas_strategy_id: strategy id optional
--@fas_book_id: book id optional
--@hedge_relationship_type_id - hedge relationship type id
--@date_from - Results starting from as of date
--@date_to - Results starting to as of date


--===========================================================================================

-- DROP PROC spa_Get_WhatIf_Assessment_Results
-- EXEC spa_Get_WhatIf_Assessment_Results NULL, NULL, '15', NULL, '2002-01-01', '2005-06-01', 'o'
-- EXEC spa_Get_WhatIf_Assessment_Results NULL, NULL, NULL, NULL, '2002-01-01', '2005-06-01', 'o'

--SELECT '''' + REPLACE (REPLACE('4-11, 27-11,423,3123', ' ', ''), ',' , ''',''') + ''''

CREATE PROC [dbo].[spa_Get_WhatIf_Assessment_Results]
	@fas_sub_id VARCHAR(100) = NULL,
	@fas_strategy_id VARCHAR(100) = NULL,				
	@fas_book_id VARCHAR(100) = NULL,
	@hedge_relationship_type_id VARCHAR(8000) = NULL,
	@date_from VARCHAR(100),
	@date_to VARCHAR(100),
	@initial_ongoing VARCHAR(1) = NULL
AS

SET NOCOUNT ON

DECLARE @Sql_Select VARCHAR(5000)

--put '' in each key
--SET @hedge_relationship_type_id = '''' + REPLACE (REPLACE(@hedge_relationship_type_id, ' ', ''), ',' , ''',''') + ''''
--print @hedge_relationship_type_id 
SET @Sql_Select = 'SELECT
		dbo.FNADateFormat(fas_eff_ass_test_results.as_of_date) AS [As Of Date], 
		static_data_value_1.code AS [Assessment Type], 
                Cast(round(fas_eff_ass_test_results.result_value, 2) as varchar) AS [Assmt Value], 
	     	Cast(round(fas_eff_ass_test_results.additional_result_value, 2) as varchar) AS [Add Assmt Value], 
		case when (fas_eff_ass_test_results.link_id <> -1) then cast(flh.link_id as varchar) + '' - '' + flh.link_description + '' using '' else '''' end +
			fas_eff_hedge_rel_type_whatif.eff_test_name [Rel Name], 
		fas_eff_ass_test_results.eff_test_result_id AS [Result ID],
		phsub.entity_name [Subsidiary],
		phstr.entity_name [Strategy],
		phbook.entity_name [Book],
		case when fas_eff_ass_test_results.user_override = ''y'' THEN ''Yes'' ELSE ''No'' END AS [Overriden By User], 
		Cast(round(rph.regression_rsq, 2) as varchar) As RSQ,
		Cast(round(rph.regression_corr, 2) as varchar) As Correlation,
		Cast(round(rph.regression_slope ,2) as varchar)  As Slope,
		Cast(round(rph.regression_intercept, 2) as varchar) As Intercept,
		Cast(round(rph.regression_tvalue, 2) as varchar) As TValue,
		Cast(round(rph.regression_fvalue, 2) as varchar) As FValue,
		rph.regression_df As DF,
		fas_eff_ass_test_results.eff_test_profile_id [Rel ID], 
		cast(case when (fas_eff_ass_test_results.link_id = -1) then '' '' else fas_eff_ass_test_results.link_id end as varchar) [Link ID], 
                dbo.FNADateTimeFormat(fas_eff_ass_test_results.create_ts,2) AS   [Created TimeStamp], 
                fas_eff_ass_test_results.create_user AS [Created User], 
		fas_eff_ass_test_results.update_user AS [Updated User]		
FROM         fas_eff_ass_test_results INNER JOIN
             fas_eff_hedge_rel_type_whatif ON fas_eff_ass_test_results.eff_test_profile_id = fas_eff_hedge_rel_type_whatif.eff_test_profile_id INNER JOIN
             static_data_value static_data_value_1 ON fas_eff_ass_test_results.eff_test_approach_value_id = static_data_value_1.value_id INNER JOIN
	     portfolio_hierarchy phbook ON phbook.entity_id = fas_eff_hedge_rel_type_whatif.fas_book_id INNER JOIN
	     portfolio_hierarchy phstr ON phstr.entity_id = phbook.parent_entity_id INNER JOIN
	     portfolio_hierarchy phsub ON phsub.entity_id = phstr.parent_entity_id LEFT OUTER JOIN
	     fas_eff_ass_test_results_process_header rph ON rph.eff_test_result_id = fas_eff_ass_test_results.eff_test_result_id LEFT OUTER JOIN
	    fas_link_header flh  ON flh.link_id = fas_eff_ass_test_results.link_id'


SET @Sql_Select = @Sql_Select + ' WHERE fas_eff_ass_test_results.calc_level IN  (3) AND fas_eff_ass_test_results.as_of_date BETWEEN  CONVERT(DATETIME, ''' + @date_from + ''', 102) AND CONVERT(DATETIME, ''' + @date_to + ''', 102)'

IF @initial_ongoing IS NOT NULL
	SET  @Sql_Select = @Sql_Select + ' AND initial_ongoing = ''' + @initial_ongoing + ''''

IF @fas_sub_id IS NOT NULL
	SET @Sql_Select = @Sql_Select + ' AND phsub.entity_id IN (' + @fas_sub_id + ')'

IF @fas_strategy_id IS NOT NULL
	SET @Sql_Select = @Sql_Select + ' AND phstr.entity_id IN (' + @fas_strategy_id + ')'

IF @fas_book_id IS NOT NULL
	SET @Sql_Select = @Sql_Select + ' AND phbook.entity_id IN (' + @fas_book_id + ')'

--IF @hedge_relationship_type_id IS NOT NULL
	SET @Sql_Select = @Sql_Select + ' AND fas_eff_ass_test_results.link_id = -1 and fas_eff_ass_test_results.calc_level = 3 and 
		fas_eff_ass_test_results.eff_test_profile_id  IN (' + isnull(@hedge_relationship_type_id, -1) + ')'
--	SET @Sql_Select = @Sql_Select + ' AND fas_eff_hedge_rel_type_whatif.eff_test_profile_id IN (' + @hedge_relationship_type_id + ')'
		
	
SET @Sql_Select = @Sql_Select + ' ORDER BY 	phsub.entity_name,
		phstr.entity_name,
		phbook.entity_name,
		fas_eff_hedge_rel_type_whatif.eff_test_profile_id, 
		fas_eff_ass_test_results.eff_test_result_id desc,
		fas_eff_hedge_rel_type_whatif.eff_test_name, 
		fas_eff_ass_test_results.as_of_date DESC, 
		fas_eff_ass_test_results.create_ts DESC'


EXEC spa_print @Sql_Select
EXEC (@Sql_Select)















