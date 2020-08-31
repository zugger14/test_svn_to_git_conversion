
IF OBJECT_ID(N'[dbo].[spa_credit_exposure_calculation_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_credit_exposure_calculation_report
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].spa_credit_exposure_calculation_report
	@flag CHAR(1) = 'r',
	@as_of_date DATE = NULL,
	@to_as_of_date DATE = NULL,
	@counterparty_id INT = NULL
AS
SET NOCOUNT ON

DECLARE @_sql VARCHAR(MAX), 
		@_prior_aod VARCHAR(30), 
		@_aod VARCHAR(30), 
		@_counterparty_id VARCHAR(MAX)

IF @to_as_of_date IS NOT NULL
	SET @_prior_aod = @to_as_of_date
	
IF @as_of_date IS NOT NULL
	SET @_aod = @as_of_date

IF @counterparty_id IS NOT NULL
	SET @_counterparty_id = @counterparty_id
	
IF OBJECT_ID(N'tempdb..#tmp_credit_exposure_detail') IS NOT NULL
    DROP TABLE #tmp_credit_exposure_detail

IF OBJECT_ID(N'tempdb..#tmp_exposure') IS NOT NULL
    DROP TABLE #tmp_exposure     	

IF OBJECT_ID(N'tempdb..#tmp_due_date_incr') IS NOT NULL
    DROP TABLE #tmp_due_date_incr
    
IF OBJECT_ID(N'tempdb..#tmp_efff_exp') IS NOT NULL
    DROP TABLE #tmp_efff_exp
    
IF OBJECT_ID(N'tempdb..#tmp_credit_unique_val') IS NOT NULL
    DROP TABLE #tmp_credit_unique_val       

SELECT 20001 due_date, 0 increment INTO #tmp_due_date_incr UNION ALL SELECT 20002, 1 UNION ALL SELECT 20004, 2 UNION ALL SELECT 20005, 2 UNION ALL SELECT 20006, 3 UNION ALL SELECT 20000, 0 UNION ALL SELECT 20003, 1 UNION ALL SELECT 20007, 3 UNION ALL SELECT 20008, 4 UNION ALL SELECT 20009, 4 UNION ALL SELECT 20010, 5 UNION ALL SELECT 20011, 5       
    

CREATE TABLE #tmp_credit_exposure_detail(
	[id] INT IDENTITY(1, 1),
	[counterparty_name] [varchar](250) COLLATE DATABASE_DEFAULT NULL,
	[counterparty_id] [int] NULL,
	[counterparty_code] [varchar](250) COLLATE DATABASE_DEFAULT NULL,
	[counterparty_type] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
	[parent_counterparty] [varchar](250) COLLATE DATABASE_DEFAULT NULL,
	[netting_parent_group_name] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[source_deal_header_id] [int] NULL,
	[trader_id] [int] NULL,
	[trader] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[exposure_type] [varchar](20) COLLATE DATABASE_DEFAULT NULL,
	[sic_code] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
	[risk_rating] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
	[industry_type1] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
	[industry_type2] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
	[debt_rating] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
	[as_of_date] [datetime] NULL,
	[to_as_of_date] [datetime] NULL,
	[term_start] [datetime] NULL,
	[agg_term_start] [varchar](20) COLLATE DATABASE_DEFAULT NULL,
	[net_exposure_to_us] [float] NULL,
	[net_exposure_to_them] [float] NULL,
	[d_net_exposure_to_us] [float] NULL,
	[d_net_exposure_to_them] [float] NULL,
	[sub_id] [int] NULL,
	[stra_id] [int] NULL,
	[book_id] [int] NULL,
	[CVA] [float] NULL,
	[DVA] [float] NULL,
	[PFE] [float] NULL,
	[fixed_exposure] [float] NULL,
	[mtm_exposure] [float] NULL,
	[d_mtm_exposure] [float] NULL,
	[d_mtm_exposure_to_them] [float] NULL,
	[total_future_exposure] [float] NULL,
	[limit_variance] [float] NULL,
	[limit_provided] [float] NULL,
	[limit_received] [float] NULL,
	[percentage] [float] NULL,
	[as_of_date_day] [int] NULL,
	[as_of_date_month] [int] NULL,
	[as_of_date_month_name] [nvarchar](30) COLLATE DATABASE_DEFAULT NULL,
	[as_of_date_year] [int] NULL,
	[order] [bigint] NULL,
	[as_of_date_year_month] [varchar](8) COLLATE DATABASE_DEFAULT NULL,
	[netting_counterparty_id] [int] NULL,
	[counterparty_type_id] [int] NULL,
	[region] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
	[country] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
	[account_status] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
	[int_ext_flag] [char](1) COLLATE DATABASE_DEFAULT NULL,
	[gross_exposure] [float] NULL,
	[total_net_exposure] [float] NULL,
	[limit_available_to_us] [float] NULL,
	[limit_available_to_them] [float] NULL,
	[limit_to_us_violated] [int] NULL,
	[limit_to_them_violated] [int] NULL,
	[limit_to_us_variance] [float] NULL,
	[limit_to_them_variance] [float] NULL,
	[tenor_limit] [int] NULL,
	[tenor_days] [int] NULL,
	[currency] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
	[deal_id] [varchar](200) COLLATE DATABASE_DEFAULT NULL,
	[payment_date] [Datetime] NULL,
	[AR] [float] NULL,
	[AP] [float] NULL,
	[BOM_exposure_to_us] [float] NULL,
	[BOM_exposure_to_them] [float] NULL,
	[mtm_exposure_to_us] [float] NULL,
	[mtm_exposure_to_them] [float] NULL,
	[apply_netting_rule] [char](1) COLLATE DATABASE_DEFAULT NULL,
	[colletral_received] [int] NULL,
	[colletral_provided] [int] NULL,
	[contract_id] [int] NULL,
	[contract_name] [varchar] (50) COLLATE DATABASE_DEFAULT NULL
)
	
SET @_sql = cast('' as varchar(max)) + 'INSERT INTO #tmp_credit_exposure_detail
(
 [counterparty_name],
 [counterparty_id],
 [counterparty_code],
 [counterparty_type],
 [parent_counterparty],
 [netting_parent_group_name],
 [source_deal_header_id],
 [trader_id],
 [trader],
 [exposure_type],
 [sic_code],
 [risk_rating],
 [industry_type1],
 [industry_type2],
 [debt_rating],
 [as_of_date],
 [to_as_of_date],
 [term_start],
 [agg_term_start],
 [net_exposure_to_us],
 [net_exposure_to_them],
 [d_net_exposure_to_us],
 [d_net_exposure_to_them],
 [sub_id],
 [stra_id],
 [book_id],
 [CVA],
 [DVA],
 [PFE],
 [fixed_exposure],
 [mtm_exposure],
 [d_mtm_exposure],
 [d_mtm_exposure_to_them],
 [total_future_exposure],
 [limit_variance],
 [limit_provided],
 [limit_received],
 [percentage],
 [as_of_date_day],
 [as_of_date_month],
 [as_of_date_month_name],
 [as_of_date_year],
 [order],
 [as_of_date_year_month],
 [netting_counterparty_id],
 [counterparty_type_id],
 [region],
 [country],
 [account_status],
 [int_ext_flag],
 [gross_exposure],
 [total_net_exposure],
 [limit_available_to_us],
 [limit_available_to_them],
 [limit_to_us_violated],
 [limit_to_them_violated],
 [limit_to_us_variance],
 [limit_to_them_variance],
 [tenor_limit],
 [tenor_days],
 [currency],
 [deal_id],
 [payment_date],
 [AR],
 [AP],
 [BOM_exposure_to_us],
 [BOM_exposure_to_them],
 [mtm_exposure_to_us],
 [mtm_exposure_to_them],
 [apply_netting_rule],
 [colletral_received],
 [colletral_provided],
 [contract_id],
 [contract_name]
)
SELECT
	MAX(ced.counterparty_name) [counterparty_name],
	MAX(ced.Source_Counterparty_ID) [counterparty_id],
	MAX(sc.counterparty_id) [counterparty_code],
	MAX(counterparty_type) [counterparty_type],
	MAX(ced.parent_counterparty_name) [parent_counterparty],
	MAX(ced.Netting_Parent_Group_Name) [netting_parent_group_name],
	ced.Source_Deal_Header_ID [source_deal_header_id],
	MAX(st.source_trader_id) [trader_id],
	MAX(st.trader_name) [trader],
	MAX(ced.exp_type) [exposure_type],
	MAX(sdv_sic.code) [sic_code],
	MAX(sdv_risk.code) [risk_rating],
	MAX(sdv_indstry1.code) [industry_type1],
	MAX(sdv_indstry2.code) [industry_type2],
	MAX(sdv_debt.code) [debt_rating],
	MAX(ced.as_of_date) [as_of_date],
	MAX(ced.as_of_date) [to_as_of_date],
	ced.term_start [term_start],
	ced.agg_term_start [agg_term_start],
	MAX(ced.net_exposure_to_us) [net_exposure_to_us],
	MAX(ced.net_exposure_to_them) [net_exposure_to_them],
	MAX(ced.d_net_exposure_to_us) [d_net_exposure_to_us],
	MAX(ced.d_net_exposure_to_them) [d_net_exposure_to_them],
	MAX(ced.fas_subsidiary_id) [sub_id],
	MAX(ced.fas_strategy_id) [stra_id],
	MAX(ced.fas_book_id) [book_id],
	SUM(ISNULL(sdc.cva, 0)) CVA,
	SUM(ISNULL(sdc.dva, 0)) DVA,
	ISNULL(SUM(pr.pfe), 0)  PFE,
	SUM(CASE WHEN ced.exp_type_id = 1 THEN 0
			WHEN ced.exp_type_id = 2 THEN 0
			ELSE ced.net_exposure_to_us
		END
	) [fixed_exposure],
	MAX(CASE WHEN ced.exp_type_id IN(1,2) THEN ced.net_exposure_to_us                
			ELSE 0
		END
	) [mtm_exposure],
	--MAX(CASE WHEN ced.exp_type_id IN(1,2) THEN ced.net_exposure_to_them                
	--		ELSE 0
	--	END
	--) [mtm_exposure_to_them],
	MAX(CASE WHEN ced.exp_type_id IN(1,2) THEN ced.d_net_exposure_to_us                
			ELSE 0
		END
	) [d_mtm_exposure],
	MAX(CASE WHEN ced.exp_type_id IN(1,2) THEN ced.d_net_exposure_to_them                
			ELSE 0
		END
	) [d_mtm_exposure_to_them],
	SUM(ced.net_exposure_to_us) + ISNULL(SUM(pr.pfe), 0) [total_future_exposure],
	MAX(ced.total_limit_provided) - SUM(ISNULL(ced.net_exposure_to_us, 0)) [limit_variance],
	MAX(total_limit_provided) [limit_provided],
	MAX(ced.total_limit_received) [limit_received],
	(MAX(ced.total_limit_provided) - MAX(ISNULL(ced.net_exposure_to_us, 0))) / CASE when MAX(total_limit_provided) = 0 THEN 1 ELSE MAX(total_limit_provided) END  * 100 [percentage] ,
	DAY(MAX(ced.as_of_date)) [as_of_date_day],
	MONTH(MAX(ced.as_of_date)) [as_of_date_month],
	DATENAME(m, MAX(ced.as_of_date)) [as_of_date_month_name],
	YEAR(MAX(ced.as_of_date)) [as_of_date_year],
	ROW_NUMBER() OVER(ORDER BY SUM(ced.net_exposure_to_us) DESC) AS [order],
	CAST(YEAR(MAX(ced.as_of_date)) AS VARCHAR(5)) + ''-'' + RIGHT(''0''+ CAST(MONTH(MAX(ced.as_of_date)) AS VARCHAR(2)), 2) [as_of_date_year_month],
	MAX(ced.netting_counterparty_id) [netting_counterparty_id],
	MAX(ced.counterparty_type_id) [counterparty_type_id],
	MAX(reg.code) [region],
	MAX(country.code) [country],
	MAX(acc.code) [account_status],
	MAX(sc.int_ext_flag) [int_ext_flag],       
	MAX(ced.gross_exposure) [gross_exposure],
	MAX(ced.total_net_exposure) [total_net_exposure],
	MAX(ced.limit_to_us_avail) [limit_available_to_us],
	MAX(ced.limit_to_them_avail) [limit_available_to_them],
	MAX(ced.limit_to_us_violated) [limit_to_us_violated],
	MAX(ced.limit_to_them_violated) [limit_to_them_violated],
	MAX(ced.limit_to_us_variance) [limit_to_us_variance],
	MAX(ced.limit_to_them_variance) [limit_to_them_variance],
	MAX(ced.tenor_limit) [tenor_limit],
	MAX(ced.tenor_days) [tenor_days],
	MAX(ced.currency_name) [currency],
	sdh.deal_id,
	
	MAX(CASE WHEN tddi.increment IS NOT NULL THEN 
    	DATEADD(DD, CASE WHEN ISNULL(cg.payment_days, 1) = 0 THEN 0 WHEN ISNULL(cg.payment_days, 1) < 0 THEN ISNULL(cg.payment_days, 1) ELSE ISNULL(cg.payment_days, 1)-1 END, DATEADD(MM, tddi.increment, dbo.FNAGetContractMonth(ced.term_start))) 
    ELSE NULL END) payment_date,
	
		
	CASE 
		WHEN DATEDIFF(dd, CASE 
					WHEN max(tddi.increment) IS NOT NULL
						THEN DATEADD(DD, CASE 
									WHEN ISNULL(max(cg.payment_days), 1) = 0
										THEN 0
									WHEN ISNULL(max(cg.payment_days), 1) < 0
										THEN ISNULL(max(cg.payment_days), 1)
									ELSE ISNULL(max(cg.payment_days), 1) - 1
									END, DATEADD(MM, max(tddi.increment), dbo.FNAGetContractMonth(ced.term_start)))
					ELSE NULL
					END, max(ced.as_of_date)) < 0
			THEN ISNULL(CASE 
						WHEN ced.exp_type_id IN (
								3
								,4
								)
							THEN SUM(ced.net_exposure_to_us)
						ELSE 0
						END,0)
		ELSE 0
		END AR,
	
	CASE 
		WHEN DATEDIFF(dd, CASE 
					WHEN max(tddi.increment) IS NOT NULL
						THEN DATEADD(DD, CASE 
									WHEN ISNULL(max(cg.payment_days), 1) = 0
										THEN 0
									WHEN ISNULL(max(cg.payment_days), 1) < 0
										THEN ISNULL(max(cg.payment_days), 1)
									ELSE ISNULL(max(cg.payment_days), 1) - 1
									END, DATEADD(MM, max(tddi.increment), dbo.FNAGetContractMonth(ced.term_start)))
					ELSE NULL
					END, max(ced.as_of_date)) < 0
			THEN ISNULL(CASE 
						WHEN ced.exp_type_id IN (
								5
								,6
								)
							THEN SUM(ced.net_exposure_to_them)
						ELSE 0
						END,0)
		ELSE 0
		END AP,
	
	CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(''' + CAST(@as_of_date AS VARCHAR(20)) + '''), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (1, 2) THEN  
				SUM(ced.net_exposure_to_us)
		ELSE 0 END BOM_exposure_to_us,
	
	CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(''' + CAST(@as_of_date AS VARCHAR(20)) + '''), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (1, 2) THEN 
				SUM(ced.net_exposure_to_them)
		ELSE 0 END BOM_exposure_to_them,
	
	CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(''' + CAST(@as_of_date AS VARCHAR(20)) + '''), dbo.FNAGetContractMonth(ced.term_start)) > 0 AND ced.exp_type_id IN (1, 2) THEN 
				SUM(ced.net_exposure_to_us)
		ELSE 0 END mtm_exposure_to_us,
	 
	CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(''' + CAST(@as_of_date AS VARCHAR(20)) + '''), dbo.FNAGetContractMonth(ced.term_start)) > 0 AND ced.exp_type_id IN (1, 2) THEN 
				SUM(ced.net_exposure_to_them)
		ELSE 0 END mtm_exposure_to_them,
	cca.apply_netting_rule,
	ISNULL(SUM(coll.colletral_received), 0),
	ISNULL(SUM(coll.colletral_provided), 0),
	MAX(cg.contract_id),
	MAX(cg.contract_name)
FROM   credit_exposure_detail ced
INNER JOIN source_counterparty sc ON sc.source_counterparty_id = ced.Source_Counterparty_ID 
LEFT JOIN counterparty_credit_info cci ON  cci.Counterparty_id = ced.Source_Counterparty_ID
LEFT JOIN static_data_value sdv_sic ON  sdv_sic.value_id = cci.SIC_Code
LEFT JOIN static_data_value sdv_risk ON  sdv_risk.value_id = cci.Risk_rating
LEFT JOIN static_data_value sdv_indstry1 ON  sdv_indstry1.value_id = cci.Industry_type1
LEFT JOIN static_data_value sdv_indstry2 ON  sdv_indstry2.value_id = cci.Industry_type2
LEFT JOIN static_data_value sdv_debt ON  sdv_debt.value_id = cci.Debt_rating
OUTER APPLY (
	SELECT SUM(cva) cva, SUM(dva) dva
	FROM source_deal_cva sdc
	WHERE sdc.Source_Counterparty_ID = ced.Source_Counterparty_ID
	AND sdc.as_of_date = ced.as_of_date 
    AND sdc.source_deal_header_id = ced.Source_Deal_Header_ID
    AND sdc.term_start = ced.term_start
	GROUP BY sdc.Source_Deal_Header_ID, sdc.Source_Counterparty_ID
) sdc
OUTER APPLY (SELECT ISNULL(MAX(colletral_received), 0) colletral_received, ISNULL(MAX(colletral_provided), 0) colletral_provided 
		FROM (
			SELECT 
				CASE WHEN cce.margin = ''y'' THEN ISNULL(SUM(cce.amount), 0) ELSE 0 END colletral_received,
				CASE WHEN cce.margin = ''n'' THEN ISNULL(SUM(cce.amount), 0) ELSE 0 END colletral_provided
			FROM counterparty_credit_enhancements cce
			WHERE cce.counterparty_credit_info_id = cci.counterparty_credit_info_id
				AND ''' + CAST(@as_of_date AS VARCHAR(20)) + ''' BETWEEN ISNULL(cce.eff_date, ''' + CAST(@as_of_date AS VARCHAR(20)) + ''') AND ISNULL(cce.expiration_date, ''' + CAST(@as_of_date AS VARCHAR(20)) + ''') 
				and cce.exclude_collateral = ''n''
				and cce.eff_date <= ''' + CAST(@as_of_date AS VARCHAR(20)) + '''
				--and cce.enhance_type <> -10101
			GROUP BY cce.margin
			) a ) coll
LEFT JOIN pfe_results pr ON  pr.as_of_date = ced.as_of_date AND pr.counterparty_id = ced.Source_Counterparty_ID
LEFT JOIN static_data_value reg ON reg.value_id = sc.region
LEFT JOIN static_data_value country ON country.value_id = sc.country
LEFT JOIN static_data_value acc ON acc.value_id = cci.account_status
LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = ced.Source_Deal_Header_ID
		AND sdh.counterparty_id = sc.source_counterparty_id
LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sdh.counterparty_id
		AND cca.contract_id = sdh.contract_id
LEFT JOIN source_traders st ON st.source_trader_id = sdh.trader_id
LEFT JOIN contract_group cg ON cca.contract_id = cg.contract_id
LEFT JOIN #tmp_due_date_incr tddi ON cg.invoice_due_date = tddi.due_date
WHERE  1 = 1'
+ 
CASE WHEN @_prior_aod IS  NULL THEN 'AND ced.as_of_date = ''' + CAST(@as_of_date AS VARCHAR(20)) + '''' 
				WHEN @_prior_aod IS NOT NULL AND @_aod IS NOT NULL THEN 'AND ced.as_of_date BETWEEN ''' + CAST(@to_as_of_date AS VARCHAR(20)) + ''' AND ''' + CAST(@as_of_date AS VARCHAR(20)) + '''' END
+
CASE WHEN @_counterparty_id IS NOT NULL THEN ' AND ced.Source_Counterparty_ID IN (' + CAST(@counterparty_id AS VARCHAR(10)) + ')'  ELSE '' END 
+
'  
GROUP BY
       ced.Source_Counterparty_ID,
       ced.Netting_Parent_Group_ID,
       ced.term_start, 
       ced.agg_term_start, 
       ced.exp_type_id,
       ced.Source_Deal_Header_ID,
       sdh.deal_id,
       --tddi.payment_date,
       cca.apply_netting_rule'    

EXEC(@_sql)
--RETURN
SELECT DISTINCT counterparty_id
	,contract_id
	,apply_netting_rule
	,CASE 
		WHEN apply_netting_rule = 'y'
			THEN CASE 
					WHEN (SUM(ar + ap + BOM_exposure_to_us + BOM_exposure_to_them + mtm_exposure_to_us + mtm_exposure_to_them)) > 0
						THEN (SUM(AR) + SUM(AP))
					ELSE 0
					END
		ELSE SUM(AR)
		END AR
	,CASE 
		WHEN apply_netting_rule = 'y'
			THEN CASE 
					WHEN (SUM(ar + ap + BOM_exposure_to_us + BOM_exposure_to_them + mtm_exposure_to_us + mtm_exposure_to_them)) < 0
						THEN (SUM(AR) + SUM(AP))
					ELSE 0
					END
		ELSE SUM(AP)
		END AP
	,CASE 
		WHEN apply_netting_rule = 'y'
			THEN CASE 
					WHEN (SUM(ar + ap + BOM_exposure_to_us + BOM_exposure_to_them + mtm_exposure_to_us + mtm_exposure_to_them)) > 0
						THEN (SUM(BOM_exposure_to_us) + SUM(BOM_exposure_to_them))
					ELSE 0
					END
		ELSE SUM(BOM_exposure_to_us)
		END BOM_exposure_to_us
	,CASE 
		WHEN apply_netting_rule = 'y'
			THEN CASE 
					WHEN (SUM(ar + ap + BOM_exposure_to_us + BOM_exposure_to_them + mtm_exposure_to_us + mtm_exposure_to_them)) < 0
						THEN (SUM(BOM_exposure_to_us) + SUM(BOM_exposure_to_them))
					ELSE 0
					END
		ELSE SUM(BOM_exposure_to_them)
		END BOM_exposure_to_them
	,CASE 
		WHEN apply_netting_rule = 'y'
			THEN CASE 
					WHEN (SUM(ar + ap + BOM_exposure_to_us + BOM_exposure_to_them + mtm_exposure_to_us + mtm_exposure_to_them)) > 0
						THEN (SUM(mtm_exposure_to_us) + SUM(mtm_exposure_to_them))
					ELSE 0
					END
		ELSE SUM(mtm_exposure_to_us)
		END mtm_exposure_to_us
	,CASE 
		WHEN apply_netting_rule = 'y'
			THEN CASE 
					WHEN (SUM(ar + ap + BOM_exposure_to_us + BOM_exposure_to_them + mtm_exposure_to_us + mtm_exposure_to_them)) < 0
						THEN (SUM(mtm_exposure_to_us) + SUM(mtm_exposure_to_them))
					ELSE 0
					END
		ELSE SUM(mtm_exposure_to_them)
		END mtm_exposure_to_them
	,CASE 
		WHEN apply_netting_rule = 'y'
			THEN CASE 
					WHEN (SUM(AR) + SUM(AP) + SUM(BOM_exposure_to_us) + SUM(BOM_exposure_to_THEM) + SUM(mtm_exposure_to_US) + SUM(mtm_exposure_to_them)) > 0
						THEN (SUM(AR) + SUM(AP) + SUM(BOM_exposure_to_us) + SUM(BOM_exposure_to_THEM) + SUM(mtm_exposure_to_US) + SUM(mtm_exposure_to_them))
					ELSE 0
					END
		ELSE SUM(AR) + SUM(BOM_exposure_to_us) + SUM(mtm_exposure_to_US)
		END exposure_to_us
	,CASE 
		WHEN apply_netting_rule = 'y'
			THEN CASE 
					WHEN (SUM(AR) + SUM(AP) + SUM(BOM_exposure_to_us) + SUM(BOM_exposure_to_THEM) + SUM(mtm_exposure_to_US) + SUM(mtm_exposure_to_them)) < 0
						THEN (SUM(AR) + SUM(AP) + SUM(BOM_exposure_to_us) + SUM(BOM_exposure_to_THEM) + SUM(mtm_exposure_to_US) + SUM(mtm_exposure_to_them))
					ELSE 0
					END
		ELSE SUM(AP) + SUM(BOM_exposure_to_them) + SUM(mtm_exposure_to_them)
		END exposure_to_them
INTO #tmp_exposure
FROM #tmp_credit_exposure_detail
GROUP BY counterparty_id
	,contract_id
	,apply_netting_rule
	
	
	--select *  FROM #tmp_credit_exposure_detail
	SELECT ced.counterparty_id
	,ced.contract_id
	,(MAX(ced.limit_received) - MAX(ced.Colletral_provided)) limit_received
	,(MAX(ced.limit_provided) - MAX(ced.Colletral_received)) limit_provided,
	--,CASE 
	--	WHEN MAX(te.exposure_to_us) > (MAX(ced.limit_provided))
	--		THEN CASE 
	--				WHEN (MAX(te.exposure_to_us)  - MAX(ced.limit_provided)) > 0
	--					THEN (MAX(te.exposure_to_us)  - MAX(ced.limit_provided))
	--				ELSE 0
	--				END
	--	ELSE 0
		--END 
		case when
		max(te.exposure_to_us)-MAX(ced.Colletral_received)<0
		then 0 else  max(te.exposure_to_us)-MAX(ced.Colletral_received) end effective_exposure,
	--,CASE 
	--	WHEN ABS(MAX(te.exposure_to_them)) >  MAX(ced.limit_received)
	--		THEN CASE 
	--				WHEN (MAX(te.exposure_to_them) + MAX(ced.limit_received)) < 0
	--					THEN (MAX(te.exposure_to_them)  + MAX(ced.limit_received))
	--				ELSE 0
	--				END
	--	ELSE 0
	--	END 
	case when MAX(te.exposure_to_them) +  MAX(ced.Colletral_provided)>0 then 0
	else MAX(te.exposure_to_them) +  MAX(ced.Colletral_provided)
	end  effective_exposure_to_them
	,

	
	--CASE 
	--	WHEN (MAX(te.exposure_to_us) - MAX(ced.Colletral_received)) > 0
	--		THEN CASE 
	--				WHEN (MAX(ced.limit_provided) - MAX(ced.colletral_received)) > (MAX(te.exposure_to_us) - MAX(ced.Colletral_received))
	--					THEN ((MAX(ced.limit_provided) - MAX(ced.Colletral_received)) - (MAX(te.exposure_to_us) - MAX(ced.colletral_received)))
	--				ELSE 0
	--				END
	--	ELSE (MAX(ced.limit_provided) - MAX(ced.colletral_received))
		--END 
	--	Max(0,(max(ced.limit_provided) - MAX(te.exposure_to_us))) limit_available_to_us

		Case when 
		(max(ced.limit_provided) - MAX(te.exposure_to_us))>0 then (max(ced.limit_provided) - MAX(te.exposure_to_us))
		else 0 end
		limit_available_to_us
	,
	
	
	
	--CASE 
	--	WHEN (MAX(te.exposure_to_them) + MAX(ced.Colletral_provided)) < 0
	--		THEN CASE 
	--				WHEN (MAX(ced.limit_received) - MAX(ced.colletral_provided)) > (MAX(ABS(te.exposure_to_them)) - MAX(ced.colletral_provided))
	--					THEN ((MAX(ced.limit_received) - MAX(ced.Colletral_provided)) + (MAX(te.exposure_to_them) + MAX(ced.colletral_provided)))
	--				ELSE 0
	--				END
	--	ELSE (MAX(ced.limit_received) - MAX(ced.colletral_provided))
	--	END 
	---Max(0,max(ced.limit_received) - abs(MAX(te.exposure_to_them))) 
	
	case when (max(ced.limit_received) - abs(MAX(te.exposure_to_them)))>0
	then (max(ced.limit_received) - abs(MAX(te.exposure_to_them))) else 0 end
		limit_available_to_them
INTO #tmp_efff_exp
FROM #tmp_credit_exposure_detail ced
INNER JOIN #tmp_exposure te ON te.counterparty_id = ced.counterparty_id
	AND te.contract_id = ced.contract_id
GROUP BY ced.counterparty_id
	,ced.contract_id

IF @flag = 'r'
BEGIN
	SELECT
		ced.id,
		ced.counterparty_name,
		ced.counterparty_id,
		ced.counterparty_code,
		ced.counterparty_type,
		ced.parent_counterparty,
		ced.netting_parent_group_name,
		ced.source_deal_header_id,
		ced.trader_id,
		ced.trader,
		ced.exposure_type,
		ced.sic_code,
		ced.risk_rating,
		ced.industry_type1,
		ced.industry_type2,
		ced.debt_rating,
		ced.as_of_date,
		ced.to_as_of_date,
		ced.term_start,
		ced.agg_term_start,
		ced.net_exposure_to_us,
		ced.net_exposure_to_them,
		ced.d_net_exposure_to_us,
		ced.d_net_exposure_to_them,
		ced.sub_id,
		ced.stra_id,
		ced.book_id,
		ced.CVA,
		ced.DVA,
		ced.PFE,
		ced.fixed_exposure,
		ced.mtm_exposure,
		ced.d_mtm_exposure,
		ced.d_mtm_exposure_to_them,
		ced.total_future_exposure,
		ced.limit_variance,
		ee.limit_provided,
		ee.limit_received,
		ced.percentage,
		ced.as_of_date_day,
		ced.as_of_date_month,
		ced.as_of_date_month_name,
		ced.as_of_date_year,
		ced.[order],
		ced.as_of_date_year_month,
		ced.netting_counterparty_id,
		ced.counterparty_type_id,
		ced.region,
		ced.country,
		ced.account_status,
		ced.int_ext_flag,
		ced.gross_exposure,
		ced.total_net_exposure,
		ced.limit_to_us_violated,
		ced.limit_to_them_violated,
		ced.limit_to_us_variance,
		ced.limit_to_them_variance,
		ced.tenor_limit,
		ced.tenor_days,
		ced.currency,
		ced.deal_id,
		ced.payment_date,
		te.AR,
		te.AP,
		te.BOM_exposure_to_us,
		te.BOM_exposure_to_them,
		te.mtm_exposure_to_us,
		te.mtm_exposure_to_them,
		ced.apply_netting_rule,
		ced.colletral_received,
		ced.colletral_provided,
		ced.contract_id,
		ced.contract_name,
		te.exposure_to_us,
		te.exposure_to_them,
		ee.effective_exposure,
		ee.effective_exposure_to_them,
		ee.limit_available_to_us,
		ee.limit_available_to_them
	--[__batch_report__]				
	FROM #tmp_credit_exposure_detail ced
	INNER JOIN #tmp_exposure te ON te.counterparty_id = ced.counterparty_id and ced.contract_id=te.contract_id
	INNER JOIN #tmp_efff_exp ee on ee.counterparty_id=ced.counterparty_id and ee.contract_id=ced.contract_id
END
ELSE IF @flag = 'a'
BEGIN
	SELECT
        ced.counterparty_name,
        ced.counterparty_id,
        ced.parent_counterparty,
        ced.as_of_date,
        te.exposure_to_us,
        ee.limit_provided,
        ced.gross_exposure,
        ced.limit_provided - te.exposure_to_us as [limit_to_us_variance],
        ee.limit_available_to_us,
        ced.colletral_received + ee.limit_provided as [Total_Limit_Provided]
    FROM #tmp_credit_exposure_detail ced
    INNER JOIN #tmp_exposure te ON te.counterparty_id = ced.counterparty_id and ced.contract_id=te.contract_id
    INNER JOIN #tmp_efff_exp ee on ee.counterparty_id=ced.counterparty_id and ee.contract_id=ced.contract_id
END
