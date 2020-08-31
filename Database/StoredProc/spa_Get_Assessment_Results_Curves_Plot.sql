IF OBJECT_ID(N'[dbo].[spa_Get_Assessment_Results_Curves_Plot]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_Get_Assessment_Results_Curves_Plot]
GO 


--exec spa_Get_Assessment_Results_curves_Plot 691

CREATE PROC [dbo].[spa_Get_Assessment_Results_Curves_Plot] 
	@result_id int
	
AS

-- not whatif
If (select calc_level from fas_eff_ass_test_results where eff_test_result_id = @result_id) <> 3
	SELECT     fas_eff_ass_test_results_process_detail.price_date AsOfDate, 
			case fas_eff_hedge_rel_type.use_hedge_as_depend_var 
				when 'y' then  round(fas_eff_ass_test_results_process_detail.y_series, 3) 
				else round(fas_eff_ass_test_results_process_detail.x_series, 3)  
-- 				when 'y' then  cast(round(fas_eff_ass_test_results_process_detail.y_series, 3) as varchar)
-- 				else cast(round(fas_eff_ass_test_results_process_detail.x_series, 3)  as varchar)
			end as Hedge,
			case fas_eff_hedge_rel_type.use_hedge_as_depend_var 
				when 'y' then  round(fas_eff_ass_test_results_process_detail.x_series, 3)  
				else round(fas_eff_ass_test_results_process_detail.y_series, 3)  
-- 				when 'y' then  cast(round(fas_eff_ass_test_results_process_detail.x_series, 3)  as varchar)
-- 				else cast(round(fas_eff_ass_test_results_process_detail.y_series, 3)  as varchar)
			end as Item
	FROM         	fas_eff_ass_test_results_process_detail INNER JOIN
	                fas_eff_ass_test_results ON fas_eff_ass_test_results_process_detail.eff_test_result_id = fas_eff_ass_test_results.eff_test_result_id INNER JOIN
	                fas_eff_hedge_rel_type ON fas_eff_ass_test_results.eff_test_profile_id = fas_eff_hedge_rel_type.eff_test_profile_id
	WHERE     	(fas_eff_ass_test_results_process_detail.eff_test_result_id = @result_id)
	ORDER BY 	fas_eff_ass_test_results_process_detail.price_date
Else
	SELECT    fas_eff_ass_test_results_process_detail.price_date  AsOfDate, 
			case fas_eff_hedge_rel_type_whatif.use_hedge_as_depend_var 
				when 'y' then  round(fas_eff_ass_test_results_process_detail.y_series, 3)
				else round(fas_eff_ass_test_results_process_detail.x_series, 3)
-- 				when 'y' then  cast (round(fas_eff_ass_test_results_process_detail.y_series, 3) as varchar)
-- 				else cast (round(fas_eff_ass_test_results_process_detail.x_series, 3) as varchar)
			end as Hedge,
			case fas_eff_hedge_rel_type_whatif.use_hedge_as_depend_var 
				when 'y' then  round(fas_eff_ass_test_results_process_detail.x_series, 3)
				else round(fas_eff_ass_test_results_process_detail.y_series, 3)
-- 				when 'y' then  cast (round(fas_eff_ass_test_results_process_detail.x_series, 3) as varchar)
-- 				else cast (round(fas_eff_ass_test_results_process_detail.y_series, 3) as varchar)
			end as Item
	FROM         	fas_eff_ass_test_results_process_detail INNER JOIN
	                fas_eff_ass_test_results ON fas_eff_ass_test_results_process_detail.eff_test_result_id = fas_eff_ass_test_results.eff_test_result_id INNER JOIN
	                fas_eff_hedge_rel_type_whatif ON fas_eff_ass_test_results.eff_test_profile_id = fas_eff_hedge_rel_type_whatif.eff_test_profile_id
	WHERE     	(fas_eff_ass_test_results_process_detail.eff_test_result_id = @result_id)
	ORDER BY 	fas_eff_ass_test_results_process_detail.price_date









