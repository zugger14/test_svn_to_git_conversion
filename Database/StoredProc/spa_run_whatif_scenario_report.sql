/****** Object:  StoredProcedure [dbo].[spa_run_whatif_scenario_report]    Script Date: 06/11/2011 21:28:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_run_whatif_scenario_report]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_whatif_scenario_report]
GO


/****** Object:  StoredProcedure [dbo].[spa_run_whatif_scenario_report]    Script Date: 06/11/2011 21:28:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	Display WhatIf Report

	Parameters :
	@as_of_date : Date to retrieve data
	@report_type : Reporting Type 'm' - MTM Report 'v' - VAR report 'c' - Cashflow Report 'e' - Earnings
	@whatif_criteria_id : WhatIf Criteria id to retrieve data
	@cross_tab : Cross Tab 'y' - Yes, 'n' - No
	@criteria_group : Group to filter criteria
	@drill_criteria : Drill Criteria
	@drill_source : Drill Source

**/
CREATE PROC [dbo].[spa_run_whatif_scenario_report]
	@as_of_date VARCHAR(20),
	@report_type CHAR(1)='m',
	@whatif_criteria_id VARCHAR(100),
	@cross_tab CHAR(1)='n',
	@criteria_group INT = NULL,
	@drill_criteria VARCHAR(100)=NULL,
	@drill_source VARCHAR(100)=NULL
	, @batch_process_id VARCHAR(250) = NULL
	, @batch_report_param VARCHAR(500) = NULL  
	, @enable_paging INT = 0  -- '1' = enable, '0' = disable 
	, @page_size INT = NULL
	, @page_no INT = NULL 
	
AS 
SET NOCOUNT ON

/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT
DECLARE @user_login_id VARCHAR(2000)

SET @str_batch_table = '' 

SET @user_login_id = dbo.FNADBUser()  

SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
   
IF @enable_paging = 1 -- paging processing 
BEGIN 
	IF @batch_process_id IS NULL 
		SET @batch_process_id = dbo.FNAGetNewID()

	SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no) 

	-- retrieve data from paging table instead of main table 
	IF @page_no IS NOT NULL  
	BEGIN 
		SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)  
		EXEC (@sql_paging)  
		RETURN  
	END 
END
/*******************************************1st Paging Batch END**********************************************/ 


DECLARE @sql_stmt VARCHAR(MAX)

IF @criteria_group IS NOT NULL AND @whatif_criteria_id IS NULL
	BEGIN
		SET @whatif_criteria_id = NULL
		SELECT @whatif_criteria_id = COALESCE(@whatif_criteria_id + ',', '') + cast(mwc.criteria_id AS VARCHAR) 
		FROM maintain_whatif_criteria mwc
		WHERE mwc.scenario_criteria_group = @criteria_group    
	END

IF OBJECT_ID(N'tempdb..#tmp_term_filter') IS NOT NULL
	DROP TABLE #tmp_term_filter

SELECT 
	pms.mapping_source_usage_id AS criteria_id,
	dbo.FNAGetContractMonth(ISNULL(pmt.term_start, DATEADD (MONTH, CAST(pmt.starting_month AS INT), @as_of_date))) term_start,
	dbo.FNALastDayInDate(ISNULL(pmt.term_end, DATEADD (MONTH, CAST(pmt.no_of_month AS INT), @as_of_date))) term_end
INTO #tmp_term_filter
FROM dbo.FNASplit(@whatif_criteria_id, ',') d
INNER JOIN portfolio_mapping_source pms ON d.item = pms.mapping_source_usage_id
LEFT JOIN portfolio_mapping_tenor pmt ON pmt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
WHERE pms.mapping_source_value_id = 23201

IF OBJECT_ID(N'tempdb..#source_deal_pnl_WhatIf') IS NOT NULL
	DROP TABLE #source_deal_pnl_WhatIf

CREATE TABLE #source_deal_pnl_WhatIf(
	pnl_as_of_date	datetime,
	pnl_currency_id	int,
	und_pnl	float,
	criteria_id	int,
	term_start	datetime,
	term_end	datetime,
	source_deal_header_id	int,
	Leg	int,
	pnl_source_value_id	int,
	market_value float,
	org_mtm float )

	SET @sql_stmt = 'INSERT INTO #source_deal_pnl_WhatIf
	SELECT sdpw.pnl_as_of_date,
		sdpw.pnl_currency_id,
		CASE WHEN ISNULL(mwc.use_discounted_value, ''n'') = ''n'' THEN sdpw.und_pnl ELSE sdpw.dis_pnl END *ISNULL(ABS(del.delta), 1) und_pnl,
		sdpw.criteria_id,
		sdpw.term_start,
		sdpw.term_end,
		sdpw.source_deal_header_id,
		sdpw.Leg,
		sdpw.pnl_source_value_id,
		sdpw.market_value,
		sdp.und_pnl org_mtm
	FROM maintain_whatif_criteria mwc
	INNER JOIN source_deal_pnl_WhatIf sdpw ON mwc.criteria_id = sdpw.criteria_id
	INNER JOIN #tmp_term_filter ttf ON mwc.criteria_id = ttf.criteria_id
		AND (ttf.term_start IS NULL OR sdpw.term_start >= ttf.term_start)
		AND (ttf.term_end IS NULL OR sdpw.term_end <= ttf.term_end)
	OUTER APPLY (
			SELECT delta 
			FROM source_deal_pnl_detail_options_whatif sdpdow 
			WHERE sdpdow.as_of_date = sdpw.pnl_as_of_date 
				AND sdpdow.source_deal_header_id = sdpw.source_deal_header_id 
				AND sdpdow.term_Start = sdpw.term_Start
				AND sdpdow.criteria_id = sdpw.criteria_id 
				) del
	LEFT JOIN source_deal_pnl sdp ON sdp.pnl_as_of_date = sdpw.pnl_as_of_date
		AND sdp.source_deal_header_id = sdpw.source_deal_header_id
		AND sdp.term_start = sdpw.term_start
		AND sdp.term_end = sdpw.term_end
		AND sdp.Leg = sdpw.Leg
		AND sdp.pnl_source_value_id = sdpw.pnl_source_value_id
	WHERE sdpw.pnl_as_of_date = ''' + @as_of_date + '''' +
	CASE WHEN @criteria_group IS NULL THEN '' ELSE ' AND mwc.scenario_criteria_group = ' + CAST(@criteria_group AS VARCHAR) + '' END

	--PRINT(@sql_stmt)
	EXEC(@sql_stmt)

--select * from #source_deal_pnl_WhatIf return
-- Final report Output
IF @report_type = 'm' -- Get MTM report for the report
BEGIN
	SET @sql_stmt = 
	    'SELECT dbo.FNADateFormat(sdpw.pnl_as_of_date) [As Of Date],
			dbo.FNATRMWinHyperlink(''a'',10183400,mwc.criteria_name, mwc.criteria_id,null,null,null,null,null,null,null,null,null,null,null,0) [Criteria],
			dbo.FNATRMWinHyperlink(''a'',10182500,MAX(msg.scenario_group_name), MAX(msg.scenario_group_id),null,null,null,null,null,null,null,null,null,null,null,0) [Scenario Group],	
			CASE MAX(ISNULL(wcm.position, ''n'')) WHEN ''y'' THEN ''......'' ELSE NULL END [Position],	
			CASE MAX(mwc.use_market_value) WHEN ''y'' THEN ROUND(SUM(sdpw.market_value), 6) ELSE CASE MAX(wcm.[MTM]) WHEN ''y'' THEN ROUND(SUM(sdpw.und_pnl), 6) ELSE CONVERT(FLOAT, NULL) END END [MTM],
			CASE MAX(wcm.Var) WHEN ''y'' THEN vrw.VaR ELSE CONVERT(FLOAT, NULL) END [VAR],
			CASE MAX(wcm.Cfar) WHEN ''y'' THEN ROUND(SUM(mcsw.cash_flow), 6) ELSE CONVERT(FLOAT, NULL) END [Cash Flow], 
			CASE MAX(wcm.Cfar) WHEN ''y'' THEN crw.cfar ELSE CONVERT(FLOAT, NULL) END [CFaR],
			CASE MAX(wcm.Ear) WHEN ''y'' THEN ROUND(SUM(mesw.earning), 6) ELSE CONVERT(FLOAT, NULL) END [Earnings],
			CASE MAX(wcm.Ear) WHEN ''y'' THEN erw.ear ELSE CONVERT(FLOAT, NULL) END [EaR],
			CASE MAX(wcm.pfe) WHEN ''y'' THEN ROUND(MAX(pr.pfe), 2) ELSE CONVERT(FLOAT, NULL) END [PFE],
			
			CASE MAX(wcm.gmar) WHEN ''y'' THEN CAST((ROUND(MAX(grw.gross_margin), 4)*100) AS VARCHAR)+''%'' ELSE NULL END [GM],
			CASE MAX(wcm.gmar) WHEN ''y'' THEN CAST((ROUND(MAX(grw.gmar), 4)*100) AS VARCHAR)+''%'' ELSE NULL END [GMaR],
			sc.currency_name [Currency] ' + @str_batch_table + ' 
		FROM maintain_whatif_criteria mwc
		INNER JOIN #source_deal_pnl_WhatIf sdpw ON sdpw.criteria_id = mwc.criteria_id 
			AND sdpw.term_start >= 
				dbo.FNAGetContractMonth(COALESCE(mwc.term_start, CASE WHEN mwc.tenor_from IS NULL THEN sdpw.term_start ELSE DATEADD(MONTH, CAST(mwc.tenor_from AS INT), ''' + @as_of_date + ''') END))
			AND sdpw.term_end <= 
				dbo.FNALastDayInDate(COALESCE(mwc.term_end, CASE WHEN mwc.tenor_to IS NULL THEN sdpw.term_end ELSE DATEADD(MONTH, CAST(mwc.tenor_to AS INT), ''' + @as_of_date + ''')END))
		--INNER JOIN source_deal_pnl_detail_WhatIf sdpdw ON sdpw.criteria_id = sdpdw.criteria_id 
		--	AND sdpw.pnl_as_of_date = sdpdw.pnl_as_of_date
		--	AND sdpw.source_deal_header_id = sdpdw.source_deal_header_id
		--	AND sdpw.term_start = sdpdw.term_start
		--	AND sdpw.term_end = sdpdw.term_end
		--	AND sdpw.Leg = sdpdw.Leg
		--	AND sdpw.pnl_source_value_id = sdpdw.pnl_source_value_id
		LEFT JOIN source_deal_header sdh ON sdpw.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN var_results_whatif vrw ON sdpw.criteria_id = vrw.whatif_criteria_id
			AND vrw.as_of_date = sdpw.pnl_as_of_date
		LEFT JOIN mtm_cfar_simulation_whatif mcsw ON sdpw.criteria_id = mcsw.whatif_criteria_id
			AND mcsw.as_of_date = sdpw.pnl_as_of_date
			AND mcsw.term = sdpw.term_start
			AND mcsw.source_deal_header_id = sdpw.source_deal_header_id
		LEFT JOIN cfar_results_whatif crw ON sdpw.criteria_id = crw.whatif_criteria_id
			AND crw.as_of_date = sdpw.pnl_as_of_date	
		LEFT JOIN mtm_ear_simulation_whatif mesw ON sdpw.criteria_id = mesw.whatif_criteria_id
			AND mesw.as_of_date = sdpw.pnl_as_of_date
			AND mesw.term = sdpw.term_start
			AND mesw.source_deal_header_id = sdpw.source_deal_header_id
		LEFT JOIN ear_results_whatif erw ON sdpw.criteria_id = erw.whatif_criteria_id
			AND erw.as_of_date = sdpw.pnl_as_of_date
		LEFT JOIN gmar_results_whatif grw ON grw.whatif_criteria_id = sdpw.criteria_id
			AND grw.as_of_date = sdpw.pnl_as_of_date 
		OUTER APPLY(
               SELECT SUM(pfe) pfe
               FROM   pfe_results_whatif
               WHERE  criteria_id = sdpw.criteria_id
                      AND as_of_date = sdpw.pnl_as_of_date
                      AND pfe <> 0
           ) pr		
		INNER JOIN source_currency sc ON sdpw.pnl_currency_id = sc.source_currency_id
		INNER JOIN whatif_criteria_measure wcm ON wcm.criteria_id = mwc.criteria_id
		LEFT JOIN maintain_scenario_group msg ON msg.scenario_group_id = mwc.scenario_group_id
		WHERE 1 = 1 
			AND sdpw.criteria_id IN (' + @whatif_criteria_id + ')
			AND sdpw.pnl_as_of_date = ''' + @as_of_date + '''
		GROUP BY 
			sdpw.pnl_as_of_date,
			mwc.criteria_name,
			mwc.criteria_id,
			vrw.VaR,
			crw.cfar,
			erw.ear,
			sc.currency_name,
			wcm.MTM,
			wcm.[Var],
			wcm.Cfar,
			wcm.Ear'	
	
	--PRINT (@sql_stmt)
	EXEC (@sql_stmt)	

EXEC spa_print 'MTM REPORT'
END

ELSE IF @report_type IN('d', 'c', 'e')  -- Get MTM report for the report
BEGIN
	SET @sql_stmt = 
	    'SELECT dbo.FNADateFormat(sdpw.pnl_as_of_date) [As Of Date],
			--dbo.FNATRMWinHyperlink(''a'',10183400,mwc.criteria_name, mwc.criteria_id,null,null,null,null,null,null,null,null,null,null,null,0) [Criteria],
			--dbo.FNATRMWinHyperlink(''a'',10182500,MAX(msg.scenario_group_name), MAX(msg.scenario_group_id),null,null,null,null,null,null,null,null,null,null,null,0) [Scenario Group],
			 mwc.criteria_name [Criteria],
			 MAX(msg.scenario_group_name)[Scenario Group],
			 ABS(sdpw.source_deal_header_id) [Deal ID],
			 CASE WHEN sdpw.source_deal_header_id < 0 THEN ''Hypothetical'' ELSE sdh.deal_id END [Deal Ref ID],
			 CASE WHEN sdpw.source_deal_header_id < 0 THEN sdht.physical_financial_flag ELSE sdh.physical_financial_flag END [Phy / Fin],
			 ' + 
			 CASE @report_type 
				WHEN 'c' THEN 'ROUND(SUM(mcsw.cash_flow), 6) [Cash Flow],'
				WHEN 'e' THEN 'ROUND(SUM(mesw.earning), 6) [Earnings],'
				ELSE ' dbo.FNADateFormat(sdpw.term_start) AS [Term],
				ROUND(SUM(sdpw.org_mtm), 6) AS [Original MTM],
				CASE MAX(mwc.use_market_value) WHEN ''y'' THEN ROUND(SUM(sdpw.market_value), 6) ELSE ROUND(SUM(sdpw.und_pnl), 6) END [What-If MTM],
				ROUND((SUM(sdpw.org_mtm) - CASE MAX(mwc.use_market_value) WHEN ''y'' THEN SUM(sdpw.market_value) ELSE SUM(sdpw.und_pnl) END), 6) [Delta MTM],' 
			 END +
			 'sc.currency_name [Currency] ' + @str_batch_table + ' 
			 
		FROM #source_deal_pnl_WhatIf sdpw
		INNER JOIN maintain_whatif_criteria mwc ON sdpw.criteria_id = mwc.criteria_id
			AND sdpw.term_start >= 
				dbo.FNAGetContractMonth(COALESCE(mwc.term_start, CASE WHEN mwc.tenor_from IS NULL THEN sdpw.term_start ELSE DATEADD(MONTH, CAST(mwc.tenor_from AS INT), ''' + @as_of_date + ''') END))
			AND sdpw.term_end <= 
				dbo.FNALastDayInDate(COALESCE(mwc.term_end, CASE WHEN mwc.tenor_to IS NULL THEN sdpw.term_end ELSE DATEADD(MONTH, CAST(mwc.tenor_to AS INT), ''' + @as_of_date + ''')END))
		INNER JOIN source_deal_pnl_detail_WhatIf sdpdw ON sdpw.criteria_id = sdpdw.criteria_id 
			AND sdpw.pnl_as_of_date = sdpdw.pnl_as_of_date
			AND sdpw.source_deal_header_id = sdpdw.source_deal_header_id
			AND sdpw.term_start = sdpdw.term_start
			AND sdpw.term_end = sdpdw.term_end
			AND sdpw.Leg = sdpdw.Leg
			AND sdpw.pnl_source_value_id = sdpdw.pnl_source_value_id
		LEFT JOIN source_deal_header sdh ON sdpw.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_currency sc ON sdpdw.pnl_currency_id = sc.source_currency_id
		LEFT JOIN maintain_scenario_group msg ON msg.scenario_group_id = mwc.scenario_group_id
		LEFT JOIN mtm_cfar_simulation_whatif mcsw ON sdpw.criteria_id = mcsw.whatif_criteria_id
			AND mcsw.as_of_date = sdpw.pnl_as_of_date
			AND mcsw.term = sdpw.term_start
			AND mcsw.source_deal_header_id = sdpw.source_deal_header_id
		LEFT JOIN mtm_ear_simulation_whatif mesw ON sdpw.criteria_id = mesw.whatif_criteria_id
			AND mesw.as_of_date = sdpw.pnl_as_of_date
			AND mesw.term = sdpw.term_start
			AND mesw.source_deal_header_id = sdpw.source_deal_header_id
		LEFT JOIN portfolio_mapping_other pmo ON pmo.portfolio_mapping_other_id*-1 = sdpw.source_deal_header_id
		LEFT JOIN source_deal_header_template sdht ON sdht.template_id = pmo.template_id
		WHERE 1 = 1 ' 
     + CASE WHEN @whatif_criteria_id IS NOT NULL THEN 
     			'AND sdpw.criteria_id IN (' + @whatif_criteria_id + ') '
			ELSE 
				''
	   END
	 + CASE WHEN @as_of_date IS NOT NULL THEN 
	 			' AND sdpw.pnl_as_of_date = ''' + @as_of_date + ''''
			ELSE 
				''
		END 
	 + ' GROUP BY 
			sdpw.pnl_as_of_date,
			mwc.criteria_name,
			mwc.criteria_id,
			sdpw.source_deal_header_id,
			sdh.deal_id,
			sdh.physical_financial_flag,
			sdht.physical_financial_flag,
			sc.currency_name '	+
			CASE WHEN @report_type = 'd' THEN ',sdpw.term_start' ELSE '' END	
	
	--PRINT (@sql_stmt)
	EXEC (@sql_stmt)	

EXEC spa_print 'MTM REPORT'
END
ELSE IF @report_type = 'p' --SPAN added to not to display hyperlink in criteria from the drilldown report
BEGIN
	SET @sql_stmt = '
		SELECT dbo.FNADateFormat(prw.as_of_date) [As Of Date],
		prw.counterparty [Counterparty],
		--dbo.FNATRMWinHyperlink(''a'',10183400,prw.criteria_name, prw.criteria_id,null,null,null,null,null,null,null,null,null,null,null,1) [Criteria],
		''<span data="TRMWinHyperlink(10183400,'' + CAST(prw.criteria_id AS VARCHAR) + '',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)">'' + prw.criteria_name + ''</span>'' [Criteria],
		--prw.criteria_name [Criteria],
		sdv.code [Measurement Approach],
		sdv1.code [Confidence Interval],
		prw.fixed_exposure [Fixed Exposure],
		prw.current_exposure [Current Forward Exposure],
		prw.pfe [PFE],
		prw.total_future_exposure [Total Potential Exposure] ' + @str_batch_table + ' 
	FROM
		pfe_results_whatif prw
	LEFT JOIN static_data_value sdv ON sdv.value_id = prw.measurement_approach
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = prw.confidence_interval 	
	WHERE 1=1 
		AND prw.criteria_id IN (' + @whatif_criteria_id + ')
		AND prw.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''
		
	--PRINT (@sql_stmt)
	EXEC (@sql_stmt)	
						
END
ELSE IF @report_type = 'v'
BEGIN
--VaR		
	SET @sql_stmt = '
	SELECT DISTINCT dbo.FNADateFormat(sdpw.pnl_as_of_date) [As Of Date],
		   dbo.FNATRMWinHyperlink(''a'',10183400,mwc.criteria_name, mwc.criteria_i,null,null,null,null,null,null,null,null,null,null,null,0) [Criteria],
		   dbo.FNATRMWinHyperlink(''a'',10182500,MAX(msg.scenario_group_name), MAX(msg.scenario_group_id),null,null,null,null,null,null,null,null,null,null,null,0) [Scenario Group],
	       mtm.MTM,
	       vrw.VaR,
	       vrw.VaRC,
	       vrw.VaRI,
	       sc.currency_desc Currency ' + @str_batch_table + ' 
	FROM   source_deal_pnl_WhatIf sdpw
	INNER JOIN maintain_whatif_criteria mwc ON sdpw.criteria_id = mwc.criteria_id
		AND sdpw.term_start >= 
			dbo.FNAGetContractMonth(COALESCE(mwc.term_start, CASE WHEN mwc.tenor_from IS NULL THEN sdpw.term_start ELSE DATEADD(MONTH, CAST(mwc.tenor_from AS INT), ''' + @as_of_date + ''') END))
		AND sdpw.term_end <= 
			dbo.FNALastDayInDate(COALESCE(mwc.term_end, CASE WHEN mwc.tenor_to IS NULL THEN sdpw.term_end ELSE DATEADD(MONTH, CAST(mwc.tenor_to AS INT), ''' + @as_of_date + ''')END))
	LEFT JOIN maintain_scenario_group msg ON mwc.scenario_group_id = msg.scenario_group_id
	LEFT JOIN var_results_whatif vrw ON  mwc.criteria_id = vrw.whatif_criteria_id
	LEFT JOIN (
			SELECT criteria_id,
				   pnl_as_of_date,
				   SUM(und_pnl) MTM
			FROM   source_deal_pnl_whatif
			WHERE  1 = 1 '  
			+ CASE WHEN @as_of_date IS NOT NULL THEN 
				  'AND pnl_as_of_date = ''' + @as_of_date +'''
				   AND term_start > ''' + @as_of_date +'''' 
			   ELSE 
           		   '' 
			  END +'
			GROUP BY
				   criteria_id,
				   pnl_as_of_date
		) mtm
		ON  mwc.criteria_id = mtm.criteria_id
	LEFT JOIN source_currency sc ON  sc.source_currency_id = vrw.currency_id
	WHERE  1 = 1' + CASE WHEN @whatif_criteria_id IS NOT NULL THEN ' AND sdpw.criteria_id IN (' + @whatif_criteria_id + ')'
	                     ELSE ''
	                END
	                + 
	                CASE WHEN @as_of_date IS NOT NULL THEN ' AND vrw.as_of_date = ''' + @as_of_date + ''''
	                     ELSE ''
	                END 
	+ ' ORDER BY
	       AsOfDate'
	
	--PRINT (@sql_stmt)	
	EXEC (@sql_stmt)	


EXEC spa_print 'VAR REPORT'

END

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_run_whatif_scenario_report', 'What If Analysis Report')
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