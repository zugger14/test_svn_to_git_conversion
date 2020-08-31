IF OBJECT_ID(N'[dbo].[spa_Get_Assessment_Results_Plot]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_Get_Assessment_Results_Plot]
GO 





--===========================================================================================
--This Procedure returns assessment results so that it can be plotted
--Input Parameters:
--@result_id - assement result id


--===========================================================================================

--DROP PROC spa_Get_Assessment_Results_Plot
--EXEC spa_Get_Assessment_Results_Plot 342

CREATE PROC [dbo].[spa_Get_Assessment_Results_Plot] 
	@result_id int
	
AS

SET NOCOUNT ON

DECLARE @use_hedge_as_depend_var char

-- not whatif
If (select calc_level from fas_eff_ass_test_results where eff_test_result_id = @result_id) <> 3
	SELECT     @use_hedge_as_depend_var = fas_eff_hedge_rel_type.use_hedge_as_depend_var
	FROM       fas_eff_ass_test_results_process_detail INNER JOIN
	           fas_eff_ass_test_results ON fas_eff_ass_test_results_process_detail.eff_test_result_id = fas_eff_ass_test_results.eff_test_result_id INNER JOIN
	           fas_eff_hedge_rel_type ON fas_eff_ass_test_results.eff_test_profile_id = fas_eff_hedge_rel_type.eff_test_profile_id
	WHERE fas_eff_ass_test_results_process_detail.eff_test_result_id = @result_id
Else
	SELECT     @use_hedge_as_depend_var = fas_eff_hedge_rel_type_whatif.use_hedge_as_depend_var
	FROM       fas_eff_ass_test_results_process_detail INNER JOIN
	           fas_eff_ass_test_results ON fas_eff_ass_test_results_process_detail.eff_test_result_id = fas_eff_ass_test_results.eff_test_result_id INNER JOIN
	           fas_eff_hedge_rel_type_whatif ON fas_eff_ass_test_results.eff_test_profile_id = fas_eff_hedge_rel_type_whatif.eff_test_profile_id
	WHERE fas_eff_ass_test_results_process_detail.eff_test_result_id = @result_id

--SELECT @use_hedge_as_depend_var

IF @use_hedge_as_depend_var = 'n'
BEGIN
	select max(cast(round(fas_eff_ass_test_results_process_detail.x_series, 2) AS NUMERIC(30,2))) AS [Hedge], 
		max(cast(round(fas_eff_ass_test_results_process_detail.y_series, 2)AS NUMERIC(30,2)))  AS [Item], 
                --fas_eff_ass_test_results_process_detail.y_reg_series AS [PredictedItem]
                max (cast(round(fas_eff_ass_test_results_process_detail.y_reg_series, 2)AS NUMERIC(30,2)) )  AS [PredictedItem]
-- SELECT     fas_eff_ass_test_results_process_detail.eff_test_result_id AS [ResultId], dbo.FNADateFormat(fas_eff_ass_test_results_process_detail.price_date) AS Date, 
--                       fas_eff_ass_test_results_process_header.regression_intercept AS Intercept, fas_eff_ass_test_results_process_header.regression_slope AS Slope, 
--                       fas_eff_ass_test_results_process_header.regression_corr AS Correlation, fas_eff_ass_test_results_process_header.regression_rsq AS RSQ, 
--                       fas_eff_ass_test_results_process_detail.x_series AS [XSeries], fas_eff_ass_test_results_process_detail.y_series AS [YSeries], 
--                       fas_eff_ass_test_results_process_detail.x_reg_series AS [XSLSeries], fas_eff_ass_test_results_process_detail.y_reg_series AS [YSLSeries]
	FROM         fas_eff_ass_test_results_process_detail INNER JOIN
                      fas_eff_ass_test_results_process_header ON 
                      fas_eff_ass_test_results_process_detail.eff_test_result_id = fas_eff_ass_test_results_process_header.eff_test_result_id
	WHERE		fas_eff_ass_test_results_process_detail.eff_test_result_id = @result_id
	--ORDER BY fas_eff_ass_test_results_process_detail.x_series
	GROUP BY cast (round(fas_eff_ass_test_results_process_detail.x_series, 2) as varchar), 
		cast (round(fas_eff_ass_test_results_process_detail.y_series, 2) as varchar), 
                cast (round(fas_eff_ass_test_results_process_detail.y_reg_series, 2) as varchar)
--ORDER BY fas_eff_ass_test_results_process_detail.price_date
END
Else
BEGIN
	SELECT  max(cast(round(fas_eff_ass_test_results_process_detail.x_series, 2) AS NUMERIC(30,2))) AS [Item], 
		max(cast(round(fas_eff_ass_test_results_process_detail.y_series, 2)AS NUMERIC(30,2)))  AS [Hedge], 
                max (cast(round(fas_eff_ass_test_results_process_detail.y_reg_series, 2)AS NUMERIC(30,2)) )   AS [PredictedHedge]
	FROM         fas_eff_ass_test_results_process_detail INNER JOIN
                      fas_eff_ass_test_results_process_header ON 
                      fas_eff_ass_test_results_process_detail.eff_test_result_id = fas_eff_ass_test_results_process_header.eff_test_result_id
	WHERE		fas_eff_ass_test_results_process_detail.eff_test_result_id = @result_id
--	ORDER BY fas_eff_ass_test_results_process_detail.x_series
	GROUP BY cast (round(fas_eff_ass_test_results_process_detail.x_series, 2) as varchar), 
		cast (round(fas_eff_ass_test_results_process_detail.y_series, 2) as varchar), 
                cast (round(fas_eff_ass_test_results_process_detail.y_reg_series, 2) as varchar)
END














