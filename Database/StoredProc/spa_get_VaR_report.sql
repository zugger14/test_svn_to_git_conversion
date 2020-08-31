

IF OBJECT_ID('[dbo].[spa_get_VaR_report]','p') IS NOT NULL
DROP PROC [dbo].[spa_get_VaR_report]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/************************
Created By: Anal Shrestha
Created On:12-15-2008
--========================--
--Modified by: Shushil Bohara
--Midified dt: 6-Jul-2012
--========================--
Modification History:
Modified By		:Pawan KC
Modified Date	:02-17-2009
Modification    :Added @marginal_var_flag  for 
				 the Marginal Var Reports
Modified By		:Pawan KC
Modified Date	:02-18-2009
Modification    :Added @xml and @report_type='x' Block  for 
				 the Incremental Var Reports Logic

SP to get the VaR Results
EXEC spa_get_VaR_report 'v',null,NULL,'2007-07-31',NULL

exec spa_get_VaR_report 'v','a',NULL,'2000-07-09',NULL,'n'

*************************/
CREATE PROC [dbo].[spa_get_VaR_report]
	@report_type CHAR(1)='v', --'v' var report, 'w' what if report,x--incremental var
	@report_options CHAR(1)=NULL, --'c' credit risks var, 'm' market risks var,'i' integrated risks var
	@measure_id INT=NULL,
	@as_of_date VARCHAR(250) = NULL,
	@var_criteria_id VARCHAR(250)=NULL,
	@marginal_var_flag CHAR(1)=NULL,
	@xml VARCHAR(MAX) = NULL,
	@as_of_date_to VARCHAR(250) = NULL,
	@counterparty_id INT = NULL,
	@graph CHAR(1) = NULL
AS
SET NOCOUNT ON 
BEGIN
DECLARE @round_value CHAR = '6'
DECLARE @sql_str VARCHAR(8000)
DECLARE @group_by AS VARCHAR(8000)
DECLARE @select_list AS VARCHAR(8000)--Field names for graph report
DECLARE @calc_for VARCHAR(20)

DECLARE @measure INT  --ie. 17351=>VaR, 17353=>EaR, 17352=> CFaR
IF @measure_id IS NULL    --Now measure is mandatory
	SELECT 
		@measure = measure
	FROM [dbo].[var_measurement_criteria_detail]
	WHERE id = @var_criteria_id
ELSE
	SET @measure = @measure_id
	
--Storing mesage based on measure to be used in validation
IF @measure = 17352
BEGIN
	SET @calc_for = 'CFaR'
END
ELSE IF @measure = 17353
BEGIN
	SET @calc_for = 'EaR'
END		
ELSE IF @measure = 17355
BEGIN
	SET @calc_for = 'PFE'
END
ELSE IF @measure = 17357
BEGIN
	SET @calc_for = 'GMaR'
END	
ELSE
BEGIN
	SET @calc_for = 'VaR'
END		
	
IF @measure IS NULL
	SET @measure = 17351
	
IF @as_of_date_to IS NULL 
	SET @as_of_date_to = @as_of_date
	
CREATE TABLE #tmp_mtm_values(
		id INT IDENTITY(1,1),
		[Term] VARCHAR(15) COLLATE DATABASE_DEFAULT , 
		[One DAY VAR] FLOAT, 
		[Daily MTM Change] FLOAT, 
		[One DAY VaRC] FLOAT, 
		[Daily MTMC Change] FLOAT, 
		[One DAY VaRI] FLOAT, 
		[Daily MTMI Change] FLOAT )	

IF @report_type='v'
BEGIN
	IF @graph = 'y'
	BEGIN
		SET @sql_str = 'INSERT INTO #tmp_mtm_values([Term], [One Day VaR], [Daily MTM Change], [One Day VaRC], [Daily MTMC Change], [One Day VaRI], [Daily MTMI Change])
						SELECT dbo.FNADateFormat(ISNULL(mv.as_of_date, mv1.as_of_date)) [Term],'
			
		SET @sql_str = @sql_str +  'MAX(vr.var) AS [One Day VaR]'
										+ ', SUM(mv.MTM_value) [Daily MTM Change], MAX(vr.varC) AS [One Day VaRC]'											
										+ ', SUM(mv.MTM_value_C) [Daily MTMC Change], MAX(vr.varI) AS [One Day VaRI]'
										+ ',SUM(mv.MTM_value_I) [Daily MTMI Change]'	
			
		IF @report_options = 'a' OR ISNULL(@report_options,'') NOT IN('a', 'm', 'c', 'i')
			SET @select_list = '[Daily MTM Change], [One Day VaR], [Daily MTMC Change], [One Day VaRC], [Daily MTMI Change], [One Day VaRI]'	
		ELSE IF @report_options='m' 
			SET @select_list = '[Daily MTM Change], [One Day VaR]'													  
		ELSE IF @report_options='c' 
			SET @select_list = '[Daily MTMC Change], [One Day VaRC]'													  
		ELSE IF @report_options='i' 
			SET @select_list = ' [Daily MTMI Change], [One Day VaRI]'													  
					
		SET @sql_str = @sql_str + ' FROM
			var_measurement_criteria_detail vmcd 
			INNER JOIN var_results vr on vmcd.id=vr.var_criteria_id
			LEFT JOIN marginal_var mv ON vmcd.id = mv.var_criteria_id
				AND vr.as_of_date = mv.as_of_date
			LEFT JOIN mtm_var_simulation mv1 ON vmcd.id = mv1.var_criteria_id
				AND vr.as_of_date = mv1.as_of_date
		WHERE 1=1 '
			+ CASE WHEN @as_of_date IS NOT NULL THEN ' AND vr.as_of_date >='''+CAST(@as_of_date AS VARCHAR)+'''' ELSE '' END
			+ CASE WHEN @as_of_date_to IS NOT NULL THEN ' AND vr.as_of_date <='''+CAST(@as_of_date_to AS VARCHAR)+'''' ELSE '' END					
			+ CASE WHEN  @measure_id IS NOT NULL THEN ' AND vmcd.measure='+CAST (@measure_id AS VARCHAR) ELSE '' END
			+ CASE WHEN  @var_criteria_id IS NOT NULL THEN ' AND vmcd.id IN (' + @var_criteria_id + ')'  ELSE '' END
			+ ' GROUP BY ISNULL(mv.as_of_date, mv1.as_of_date)'	
		
		EXEC(@sql_str)
	
		SET @sql_str = '
		SELECT [Term], ' + @select_list + ' 
		FROM (
			SELECT a.id, [Term], [One Day VaR]*-1 [One Day VaR],  
			((SELECT b.[Daily MTM Change] FROM #tmp_mtm_values b WHERE b.id = a.id + 1) - a.[Daily MTM Change]) AS [Daily MTM Change],
			[One Day VaRC]*-1 [One Day VaRC],
			((SELECT b.[Daily MTMC Change] FROM #tmp_mtm_values b WHERE b.id = a.id + 1) - a.[Daily MTMC Change]) AS [Daily MTMC Change],
			[One Day VaRI]*-1 [One Day VaRI],
			((SELECT b.[Daily MTMI Change] FROM #tmp_mtm_values b WHERE b.id = a.id + 1) - a.[Daily MTMI Change]) AS [Daily MTMI Change]
		FROM #tmp_mtm_values a ) mtm
		WHERE 1 = 1
			AND([Daily MTM Change] IS NOT NULL OR [Daily MTMC Change] IS NOT NULL OR [Daily MTMI Change] IS NOT NULL)'
			
		--PRINT(@sql_str)
		EXEC(@sql_str)
		SET @sql_str = NULL
	END	
	ELSE
	BEGIN
		IF @marginal_var_flag='y'
			BEGIN
			
			SET @sql_str='SELECT dbo.FNADateFormat(mv.as_of_date) [As Of Date],dbo.FNATRMWinHyperlink(''a'',10181200,vmcd.[name],vmcd.id,null,null,null,null,null,null,null,null,null,null,null,0) AS [' + @calc_for + ' Criteria],sdv.description [Measurement Approach],
						spcd.curve_name [Risk Bucket],dbo.FNADateFormat(mv.term) [Term] ' 
										
			IF (@report_options = 'a')
			BEGIN
				SET	@sql_str = @sql_str+ ',mv.MTM_value [MTM], mv.MVaR [MVaR] 
										,mv.MTM_value_C [MTMC],mv.MVaR_C [MVaRC] 
										,mv.MTM_value_I [MTMI],MVaR_I [MVaRI]'
				SET @select_list = '[MTM], [MVar], [MTMC], [MVarC], [MTMI], [MVaRI]'
			END									
								
			ELSE IF(@report_options = 'm')
			BEGIN
				SET	@sql_str = @sql_str+ ',mv.MTM_value [MTM],mv.MVaR [MVaR] '
				SET @select_list = '[MTM], [MVaR]'
			END
			ELSE IF (@report_options = 'c')
			BEGIN
				SET	@sql_str = @sql_str+ ',mv.MTM_value_C [MTMC],mv.MVaR_C [MVaRC] '
				SET @select_list = '[MTMC], [MVarC]'
			END	
			ELSE IF (@report_options = 'i')
			BEGIN
				SET	@sql_str = @sql_str+ ',mv.MTM_value_I [MTMI],MVaR_I [MVaRI]  '
				SET @select_list = '[MTMI], [MVARI]'
			END	
				
			SET @select_list = '[Term], ' + @select_list 
			
			SET	@sql_str= @sql_str+' FROM marginal_var mv
				JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=mv.curve_id
				JOIN var_measurement_criteria_detail vmcd ON vmcd.id=mv.var_criteria_id
				JOIN static_data_value sdv ON vmcd.var_approach=sdv.value_id
				WHERE 1=1'
				
			IF @as_of_date IS NOT NULL
			BEGIN
				SET @sql_str=@sql_str + ' AND mv.as_of_date >=''' + CAST(@as_of_date AS VARCHAR) + ''''
			END

			IF @as_of_date_to IS NOT NULL
			BEGIN
				SET @sql_str=@sql_str + ' AND mv.as_of_date <=''' + CAST(@as_of_date_to AS VARCHAR) + ''''
			END

			IF @var_criteria_id IS NOT NULL
			BEGIN
				SET @sql_str=@sql_str + ' AND mv.var_criteria_id IN (' + @var_criteria_id + ')' 
			END
		END
		ELSE
		BEGIN
			IF @measure = '17351'
			BEGIN
				SET @sql_str = 'SELECT dbo.FNADateFormat(vr.as_of_date) [As Of Date],' +  CASE WHEN @graph = 'y' THEN 'dbo.FNADateFormat(mv.term) [Term],' ELSE '' END 
							 +'dbo.FNATRMWinHyperlink(''a'',10181200,vmcd.[name],vmcd.id,null,null,null,null,null,null,null,null,null,null,null,0) AS [' + @calc_for + ' Criteria],
							va.code as [Measurement Approach],
							ci.code as [Confidence Interval],'
					
				IF @report_options = 'a' OR ISNULL(@report_options,'') NOT IN('a', 'm', 'c', 'i')
				BEGIN
					SET @sql_str = @sql_str +  'ROUND(MAX(vr.var),'+@round_value+') AS [VaR]'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ', ROUND(MAX(vr.RAROC1),'+@round_value+') AS [RAROC %]' END
												+ ', ROUND(ISNULL(SUM(marginal_var.MTM),SUM(mtm_var_simulation.MTM)),'+@round_value+') MTM, ROUND(MAX(vr.varC),'+@round_value+') AS [VaRC]'											
												+ ', ROUND(ISNULL(SUM(marginal_var.MTMC),SUM(mtm_var_simulation.MTMC)),'+@round_value+') MTMC, ROUND(MAX(vr.varI),'+@round_value+') AS [VaRI]'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ', ROUND(MAX(vr.RAROC2),'+@round_value+') AS [RAROC %]' END
												+ ', ROUND(ISNULL(SUM(marginal_var.MTMI),SUM(mtm_var_simulation.MTMI)),'+@round_value+') MTMI, MAX(sc.currency_name) [Currency]'
												  
					SET @select_list = '[MTM], [VaR], [MTMC], [VaRC], [MTMI], [VaRI]'	
																	  
					SET @group_by = 'vr.var, vr.RAROC1, vr.varC, vr.varI, vr.RAROC2, sc.currency_name '
						
				END
				
				ELSE IF @report_options='m' 
				BEGIN
					SET @sql_str = @sql_str + ' ROUND(MAX(vr.var),'+@round_value+') AS [VaR]' 
												+ ', ROUND(ISNULL(SUM(marginal_var.MTM),SUM(mtm_var_simulation.MTM)),'+@round_value+') MTM'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ', ROUND(MAX(vr.RAROC1),'+@round_value+') AS [RAROC %], MAX(sc.currency_name) [Currency]' END
												
					SET @select_list = '[MTM], [VaR]'													  
					SET @group_by = ' vr.var, sc.currency_name, vr.RAROC1'																				  
				END
							 
				ELSE IF @report_options='c' 
				BEGIN
					SET @sql_str = @sql_str + ' ROUND(MAX(vr.varC),'+@round_value+') AS [VaRC]'
												+ ', ROUND(ISNULL(SUM(marginal_var.MTMC),SUM(mtm_var_simulation.MTMC)),'+@round_value+') MTMC'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ',MAX(sc.currency_name) [Currency]' END
					SET @select_list = '[MTMC], [VaRC]'													  
											  
					SET @group_by = ' vr.varC, sc.currency_name'													  
				END
				ELSE IF @report_options='i' 
				BEGIN
					SET @sql_str = @sql_str + ' ROUND(MAX(vr.varI),'+@round_value+') AS [VaRI]'
												+ ', ROUND(ISNULL(SUM(marginal_var.MTMI),SUM(mtm_var_simulation.MTMI)),'+@round_value+') MTMI'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ', ROUND(MAX(vr.RAROC2),'+@round_value+') AS [RAROC %], MAX(sc.currency_name) [Currency]' END
												
					SET @select_list = ' [MTMI], [VaRI]'													  
						
					SET @group_by = ' vr.varI, sc.currency_name, vr.RAROC2'												
				END
			END	
			ELSE IF @measure = '17352'
			BEGIN
				SET @sql_str = 'SELECT dbo.FNADateFormat(vr.as_of_date) [As Of Date],' +  CASE WHEN @graph = 'y' THEN 'dbo.FNADateFormat(mv.term) [Term],' ELSE '' END 
						 +'dbo.FNATRMWinHyperlink(''a'',10181200,vmcd.[name],vmcd.id,null,null,null,null,null,null,null,null,null,null,null,0) as [' + @calc_for + ' Criteria],
						va.code as [Measurement Approach],
						ci.code as [Confidence Interval],'
				
				IF @report_options = 'a' OR ISNULL(@report_options,'') NOT IN('a', 'm', 'c', 'i')
				BEGIN
					SET @sql_str = @sql_str +  'ROUND(MAX(vr.var),'+@round_value+') AS [CFaR]'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ', ROUND(MAX(vr.RAROC1),'+@round_value+') AS [RAROC %]' END
												+ ', ROUND(ISNULL(SUM(marginal_var.MTM),SUM(mtm_var_simulation.MTM)),'+@round_value+') CashFlow' --ROUND(MAX(vr.varC),'+@round_value+') AS [CFaRC]											
												--+ ', ROUND(ISNULL(SUM(marginal_var.MTMC),SUM(mtm_var_simulation.MTMC)),'+@round_value+') CashFlowC, ROUND(MAX(vr.varI),'+@round_value+') AS [CFaRI]'
												--+ CASE WHEN @graph = 'y' THEN '' ELSE ', ROUND(MAX(vr.RAROC2),'+@round_value+') AS [RAROC %]' END
												--+ ', ROUND(ISNULL(SUM(marginal_var.MTMI),SUM(mtm_var_simulation.MTMI)),'+@round_value+') CashFlowI, 
												+ ', MAX(sc.currency_name) [Currency]'
												  
					SET @select_list = '[CFaR], [CashFlow]'--[CashFlowC], [CFaRC], [CashFlowI], [CFaRI]'	
					SET @group_by = 'vr.var, vr.RAROC1, sc.currency_name '--vr.varC, vr.varI, vr.RAROC2,  '
						
				END
				
				ELSE IF @report_options='m' 
				BEGIN
					SET @sql_str = @sql_str + ' ROUND(MAX(vr.var),'+@round_value+') AS [CFaR]' 
												+ ', ROUND(ISNULL(SUM(marginal_var.MTM),SUM(mtm_var_simulation.MTM)),'+@round_value+') CashFlow'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ', ROUND(MAX(vr.RAROC1),'+@round_value+') AS [RAROC %], MAX(sc.currency_name) [Currency]' END
												
					SET @select_list = '[CashFlow], [CFaR]'													  
					SET @group_by = ' vr.var, sc.currency_name, vr.RAROC1'																				  
				END
							 
				ELSE IF @report_options='c' 
				BEGIN
					SET @sql_str = @sql_str + ' ROUND(MAX(vr.varC),'+@round_value+') AS [CFaRC]'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ',MAX(sc.currency_name) [Currency]' END
												+ ', ROUND(ISNULL(SUM(marginal_var.MTMC),SUM(mtm_var_simulation.MTMC)),'+@round_value+') CashFlowC'
					SET @select_list = '[CashFlowC], [CFaRC]'													  
											  
					SET @group_by = ' vr.varC, sc.currency_name'													  
				END
				ELSE IF @report_options='i' 
				BEGIN
					SET @sql_str = @sql_str + ' ROUND(MAX(vr.varI),'+@round_value+') AS [CFaRI]'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ', MAX(sc.currency_name) [Currency], ROUND(MAX(vr.RAROC2),'+@round_value+') AS [RAROC %]' END													  
												+ ', ROUND(ISNULL(SUM(marginal_var.MTMI),SUM(mtm_var_simulation.MTMI)),'+@round_value+') CashFlowI'
					SET @select_list = ' [CashFlowI], [CFaRI]'													  
						
					SET @group_by = ' vr.varI, sc.currency_name, vr.RAROC2'												
				END	
			END	
			ELSE IF @measure = '17353'
			BEGIN
				SET @sql_str = 'SELECT dbo.FNADateFormat(vr.as_of_date) [As Of Date],' +  CASE WHEN @graph = 'y' THEN 'dbo.FNADateFormat(mv.term) [Term],' ELSE '' END 
						 +'dbo.FNATRMWinHyperlink(''a'',10181200,vmcd.[name],vmcd.id,null,null,null,null,null,null,null,null,null,null,null,0) as [' + @calc_for + ' Criteria],
						va.code as [Measurement Approach],
						ci.code as [Confidence Interval],'
				
				IF @report_options = 'a' OR ISNULL(@report_options,'') NOT IN('a', 'm', 'c', 'i')
				BEGIN
					SET @sql_str = @sql_str +  'ROUND(MAX(vr.var),'+@round_value+') AS [EaR]'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ', ROUND(MAX(vr.RAROC1),'+@round_value+') AS [RAROC %]' END
												+ ', ROUND(ISNULL(SUM(marginal_var.MTM),SUM(mtm_var_simulation.MTM)),'+@round_value+') Earning ' --, ROUND(MAX(vr.varC),'+@round_value+') AS [EaRC]'											
												--+ ', ROUND(ISNULL(SUM(marginal_var.MTMC),SUM(mtm_var_simulation.MTMC)),'+@round_value+') EarningC, ROUND(MAX(vr.varI),'+@round_value+') AS [EaRI]'
												--+ CASE WHEN @graph = 'y' THEN '' ELSE ', ROUND(MAX(vr.RAROC2),'+@round_value+') AS [RAROC %]' END
												--+ ', ROUND(ISNULL(SUM(marginal_var.MTMI),SUM(mtm_var_simulation.MTMI)),'+@round_value+') EarningI, 
												+ ', MAX(sc.currency_name) [Currency]'
												  
					SET @select_list = '[EaR], [Earning]'--, [EarningC], [EaRC], [EarningI], [EaRI]'	
					SET @group_by = 'vr.var, vr.RAROC1, sc.currency_name ' --, vr.varC, vr.varI, vr.RAROC2 '
						
				END
				
				ELSE IF @report_options='m' 
				BEGIN
					SET @sql_str = @sql_str + ' ROUND(MAX(vr.var),'+@round_value+') AS [EaR]' 
												+ ', ROUND(ISNULL(SUM(marginal_var.MTM),SUM(mtm_var_simulation.MTM)),'+@round_value+') Earning'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ', ROUND(MAX(vr.RAROC1),'+@round_value+') AS [RAROC %], MAX(sc.currency_name) [Currency]' END
												
					SET @select_list = '[Earning], [EaR]'													  
					SET @group_by = ' vr.var, sc.currency_name, vr.RAROC1'																				  
				END
							 
				ELSE IF @report_options='c' 
				BEGIN
					SET @sql_str = @sql_str + ' ROUND(MAX(vr.varC),'+@round_value+') AS [EaRC]'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ',MAX(sc.currency_name) [Currency]' END
												+ ', ROUND(ISNULL(SUM(marginal_var.MTMC),SUM(mtm_var_simulation.MTMC)),'+@round_value+') EarningC'
					SET @select_list = '[EarningC], [EaRC]'													  
											  
					SET @group_by = ' vr.varC, sc.currency_name'													  
				END
				ELSE IF @report_options='i' 
				BEGIN
					SET @sql_str = @sql_str + ' ROUND(MAX(vr.varI),'+@round_value+') AS [EaRI]'
												+ CASE WHEN @graph = 'y' THEN '' ELSE ', MAX(sc.currency_name) [Currency], ROUND(MAX(vr.RAROC2),'+@round_value+') AS [RAROC %]' END													  
												+ ', ROUND(ISNULL(SUM(marginal_var.MTMI),SUM(mtm_var_simulation.MTMI)),'+@round_value+') EarningI'
					SET @select_list = ' [EarningI], [EaRI]'													  
						
					SET @group_by = ' vr.varI, sc.currency_name, vr.RAROC2'												
				END
			END	
			--PFE Report
			ELSE IF @measure = '17355'
			BEGIN
				SET @sql_str = '
				SELECT dbo.FNADateFormat(pr.as_of_date) [As Of Date],
					pr.counterparty [Counterparty],
					dbo.FNATRMWinHyperlink(''a'',10181200,pr.criteria_name, pr.criteria_id,null,null,null,null,null,null,null,null,null,null,null,0) as [' + @calc_for + ' Criteria],
					sdv.code [Measurement Approach],
					sdv1.code [Confidence Interval],
					pr.fixed_exposure [Fixed Exposure],
					pr.current_exposure [Current Forward Exposure],
					pr.pfe [PFE],
					pr.total_future_exposure [Total Potential Exposure]
				FROM
					pfe_results pr
				LEFT JOIN static_data_value sdv ON sdv.value_id = pr.measurement_approach
				LEFT JOIN static_data_value sdv1 ON sdv1.value_id = pr.confidence_interval 	
				WHERE 1=1'
				
				IF @var_criteria_id IS NOT NULL
					SET @sql_str = @sql_str + ' AND pr.criteria_id IN (' + @var_criteria_id + ')'
					
				IF @as_of_date IS NOT NULL
					SET @sql_str = @sql_str + ' AND pr.as_of_date >= ''' + CAST(@as_of_date AS VARCHAR) + ''''	
				
				IF @as_of_date_to IS NOT NULL
					SET @sql_str = @sql_str + ' AND pr.as_of_date <= ''' + CAST(@as_of_date_to AS VARCHAR) + ''''
						
				IF @counterparty_id IS NOT NULL
					SET @sql_str = @sql_str + ' AND pr.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR)
					
					SET @sql_str = @sql_str + ' ORDER BY [As Of Date]'
					
				--PRINT(@sql_str)
				EXEC(@sql_str)			
			END	
			
			SET @select_list = '[Term], ' + @select_list 
			
			SET @sql_str = @sql_str + ' FROM
				var_measurement_criteria_detail vmcd 
				INNER JOIN var_results vr on vmcd.id=vr.var_criteria_id
				LEFT JOIN static_data_value va ON va.value_id=vmcd.var_approach
				LEFT JOIN static_data_value ci ON ci.value_id=vmcd.confidence_interval
				LEFT JOIN source_currency sc on sc.source_currency_id=vr.currency_id
				OUTER APPLY(
						 SELECT SUM(mv.MTM_value) [MTM], SUM(mv.MTM_value_C)[MTMC],SUM(mv.MTM_value_I)[MTMI] FROM marginal_var mv WHERE vmcd.id = mv.var_criteria_id AND vr.as_of_date=mv.as_of_date AND va.value_id=''1520''
						) marginal_var
				OUTER APPLY(
						 SELECT SUM(mvs.MTM_value) [MTM], SUM(mvs.MTM_value_C)[MTMC],SUM(mvs.MTM_value_I)[MTMI] FROM mtm_var_simulation mvs WHERE vmcd.id = mvs.var_criteria_id AND vr.as_of_date=mvs.as_of_date AND va.value_id<>''1520''
						) mtm_var_simulation
			WHERE 1=1'
				+ CASE WHEN @as_of_date IS NOT NULL THEN ' AND vr.as_of_date >='''+CAST(@as_of_date AS VARCHAR)+'''' ELSE '' END
				+ CASE WHEN @as_of_date_to IS NOT NULL THEN ' AND vr.as_of_date <='''+CAST(@as_of_date_to AS VARCHAR)+'''' ELSE '' END					
				+ CASE WHEN  @measure_id IS NOT NULL THEN ' AND vmcd.measure='+CAST (@measure_id AS VARCHAR) ELSE '' END
				+ CASE WHEN  @var_criteria_id IS NOT NULL THEN ' AND vmcd.id IN (' + @var_criteria_id + ')'  ELSE '' END
				+ ' GROUP BY vmcd.[name],vmcd.id, va.code,ci.code,va.value_id,vr.as_of_date,' + @group_by  +  CASE WHEN @graph = 'y' THEN ', mv.term' ELSE '' END + ' ORDER BY [As Of Date]'
		END		
	END
END	
ELSE IF @report_type = 'x'
BEGIN
		DECLARE @idoc INT,@process_id VARCHAR(50)

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
		SELECT * INTO #tmp
		FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
			WITH (
				term DATETIME	'@edit_grid2',      
				curve_id VARCHAR(50)	'@edit_grid3',      
				value_var FLOAT	'@edit_grid4',      
				cur INT	'@edit_grid5'     
		)
	
		EXEC sp_xml_removedocument @idoc

		SET @sql_str='SELECT dbo.FNATRMWinHyperlink(''a'',10181200,vmcd.[name],vmcd.id,null,null,null,null,null,null,null,null,null,null,null,0) as [' + @calc_for + ' Criteria],sdv.description [Measurement Approach],
					 dbo.FNADateFormat(mv.as_of_date) [As of Date], spcd.curve_name [Risk Bucket],dbo.FNADateFormat(mv.term) [Term],
					 t.value_var [Value] ' 
					 
		IF (@report_options = 'a')
		BEGIN							
			SET	@sql_str= @sql_str+ ',mv.MVaR [MVaR],t.value_var * mv.MVaR [Incremental VaR]
										,mv.MVaR_C [MVaRC],t.value_var * mv.MVaR_C [Incremental VaRC]  
										,MVaR_I [MVaRI],t.value_var * mv.MVaR_I [Incremental VaRI]'
			SET @select_list = '[MVaR], [Incremental VaR], [MVaRC], [Incremental VaRC], [MVaRI], [Incremental VaRI]'
		END
				 
		ELSE IF (@report_options = 'm')
		BEGIN
			SET	@sql_str = @sql_str+ ',mv.MVaR [MVaR],t.value_var*mv.MVaR [Incremental VaR] '
			SET @select_list = '[MVaR], [Incremental VaR]'
		END
		ELSE IF (@report_options = 'c')
		BEGIN
			SET	@sql_str = @sql_str+ ',mv.MVaR_C [MVaRC],t.value_var*mv.MVaR_C [Incremental VaR]  '
			SET @select_list = '[MVaRC], [Incremental VaR]'
		END	
		ELSE IF (@report_options = 'i')
		BEGIN
			SET	@sql_str = @sql_str + ',MVaR_I [MVaRI],t.value_var*mv.MVaR_I [Incremental VaR]   '
			SET @select_list = '[MVaRI], [Incremental VaR]'
		END	
		SET @select_list = '[Term], ' + @select_list 
		SET	@sql_str = @sql_str + ' FROM marginal_var mv
		
		JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=mv.curve_id
		JOIN var_measurement_criteria_detail vmcd ON vmcd.id=mv.var_criteria_id
		JOIN static_data_value sdv ON vmcd.var_approach=sdv.value_id
		INNER JOIN #tmp t ON t.curve_id=mv.curve_id and t.term=mv.term
			WHERE 1=1'
			
		IF @as_of_date IS NOT NULL
		BEGIN
			SET @sql_str = @sql_str + ' AND mv.as_of_date >=''' + CAST(@as_of_date AS VARCHAR) + ''''
		END

		IF @as_of_date_to IS NOT NULL
		BEGIN
			SET @sql_str = @sql_str + ' AND mv.as_of_date <=''' + CAST(@as_of_date_to AS VARCHAR) + ''''
		END
		IF @var_criteria_id IS NOT NULL
		BEGIN
			SET @sql_str = @sql_str + ' AND mv.var_criteria_id IN (' + @var_criteria_id + ')' 
		END		
		
END
ELSE IF @report_type = 'r' --SPAN added to not to display hyperlink in criteria from the drilldown report (R - eport manager)
BEGIN
	SET @sql_str = '
	SELECT dbo.FNADateFormat(pr.as_of_date) [As Of Date],
		pr.counterparty [Counterparty],
		''<span data="TRMWinHyperlink(10181200,'' + CAST(pr.criteria_id AS VARCHAR) + '',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)">'' + pr.criteria_name + ''</span>'' [Criteria],
		sdv.code [Measurement Approach],
		sdv1.code [Confidence Interval],
		pr.fixed_exposure [Fixed Exposure],
		pr.current_exposure [Current Forward Exposure],
		pr.pfe [PFE],
		pr.total_future_exposure [Total Potential Exposure]
	FROM
		pfe_results pr
	LEFT JOIN static_data_value sdv ON sdv.value_id = pr.measurement_approach
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = pr.confidence_interval 	
	WHERE 1=1'
				
	IF @var_criteria_id IS NOT NULL
		SET @sql_str = @sql_str + ' AND pr.criteria_id IN (' + @var_criteria_id + ')'
					
	IF @as_of_date IS NOT NULL
		SET @sql_str = @sql_str + ' AND pr.as_of_date >= ''' + CAST(@as_of_date AS VARCHAR) + ''''	
				
	IF @as_of_date_to IS NOT NULL
		SET @sql_str = @sql_str + ' AND pr.as_of_date <= ''' + CAST(@as_of_date_to AS VARCHAR) + ''''
						
	IF @counterparty_id IS NOT NULL
		SET @sql_str = @sql_str + ' AND pr.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR)
					
		SET @sql_str = @sql_str + ' ORDER BY [As Of Date]'
					
	--PRINT(@sql_str)
	EXEC(@sql_str)
END
ELSE IF @report_type = 'g'
BEGIN
				--GMaR
	IF @measure = '17357'
	BEGIN
			SELECT dbo.FNATRMWinHyperlink('a',10181200,vmcd.[name],vmcd.id,null,null,null,null,null,null,null,null,null,null,null,0) AS [GMaR Criteria], 
				--vmcd.name AS [Criteria],
				dbo.FNADateFormat(gr.as_of_date) AS [As of Date],
				ROUND(gr.positive_cashflow, 4) AS [Revenue],
				ROUND(gr.negative_cashflow, 4) AS [Cost],
				ROUND(gr.total_cashflow, 4) AS [Net Cashflow],
				CAST(ROUND(gr.gross_margin, 4)*100 AS VARCHAR)+' %' AS [GM],
				CAST(ROUND(gr.GMaR, 4)*100 AS VARCHAR)+' %' AS GMaR,
				sc.currency_name AS [Currency]
			FROM var_measurement_criteria_detail vmcd 
			INNER JOIN gmar_results gr ON vmcd.id = gr.criteria_id 
			LEFT JOIN source_currency sc ON sc.source_currency_id = gr.currency_id
			WHERE gr.criteria_id = @var_criteria_id AND gr.as_of_date = @as_of_date
	END
END	
END	
IF @sql_str IS NOT NULL
BEGIN
	--EXEC spa_print @sql_str
	
	IF  @graph = 'y'
	BEGIN
		EXEC('SELECT * INTO #tmp FROM (' + @sql_str + ') tmp; SELECT  ' + @select_list + ' FROM #tmp ORDER BY dbo.FNACovertToSTDDate([Term]) ASC')
			
	END
	ELSE
	BEGIN			
		EXEC (@sql_str)
	END
END
