IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_credit_iceberg_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_credit_iceberg_report]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Operation for Credit IceBerg Report
	Parameters :
	@as_of_date_from : Date From,
	@as_of_date_to : Date To,
	@source_counterparty_id : Unique Counterparty ID
	@flag: flag
	@grouping_contract: grouping contract 
*/

CREATE PROC [dbo].[spa_credit_iceberg_report]
@as_of_date_from date,
@as_of_date_to date =  NULL,
@source_counterparty_id varchar(500)  = NULL,
@flag char = NULL,
@grouping_contract  varchar(500) = NULL
AS

----/*  Test Data:
--exec spa_drop_all_temp_table
--	 Declare 
--	 @as_of_date_from date  = '2020-08-07'
--	,@as_of_date_to date	=  NULL
--	,@source_counterparty_id varchar(500) = NULL
--    ,@flag char = 'b',
--	 @grouping_contract  varchar(500) = 'EFET Gas'
----*/	

SET NOCOUNT ON

DECLARE @_sql Nvarchar(Max)
Declare @_tmpTable table (dates date)

IF (@as_of_date_to IS NULL)
BEGIN
 SET @as_of_date_to = @as_of_date_from
END

CREATE TABLE #get_max_date_date
	(m_as_of_date datetime, counterparty_id int)

Create table #temp_date_data
	(sql_date_value datetime, first_day_month datetime, last_day_month datetime,last_month_last_day datetime, rundate datetime)
	
Create table #ultimate_final
(as_of_date date,counterparty_id varchar(500)  COLLATE DATABASE_DEFAULT , counterparty varchar(500)  COLLATE DATABASE_DEFAULT , Pivot_value float, credit_limit float, source_counterparty_id varchar(500)  COLLATE DATABASE_DEFAULT ,credit_limit_to_us float,  total_exp float, Limit_voilation varchar(50)  COLLATE DATABASE_DEFAULT , Broker_Notification varchar(50)  COLLATE DATABASE_DEFAULT , Pivot_name varchar(500)  COLLATE DATABASE_DEFAULT , m_as_of_date datetime, as_of_date_to datetime , broker_relevant varchar(50) COLLATE DATABASE_DEFAULT)

--Create table #ultimate_final_broker
--(as_of_date varchar(20),counterparty_id varchar(500)  COLLATE DATABASE_DEFAULT , counterparty varchar(500)  COLLATE DATABASE_DEFAULT ,  source_counterparty_id varchar(500)  COLLATE DATABASE_DEFAULT , Limit_voilation varchar(50)  COLLATE DATABASE_DEFAULT , Broker_Notification varchar(50)  COLLATE DATABASE_DEFAULT , as_of_date_to datetime , broker_relevant varchar(50) COLLATE DATABASE_DEFAULT, data_order int)


CREATE TABLE #as_of_date
(as_of_date varchar(20)  COLLATE DATABASE_DEFAULT )

Create table #udf_data_broker_relevant
(source_counterparty_id int, udf_value VARCHAR(50))

INSERT INTO #udf_data_broker_relevant
SELECT sc.source_counterparty_id, musdv.static_data_udf_values
FROM maintain_udf_static_data_detail_values musdv
INNER JOIN application_ui_template_fields autf ON musdv.application_field_id = autf.application_field_id
INNER JOIN application_ui_template_definition autd ON autd.application_ui_field_id = autf.application_ui_field_id
INNER JOIN source_counterparty sc ON sc.source_counterparty_id = musdv.primary_field_object_id
where autd.default_label = 'Broker Relevant'

WHILE @as_of_date_from <= @as_of_date_to
BEGIN
    INSERT INTO @_tmpTable (dates) values (@as_of_date_from)
    SET @as_of_date_from = DATEADD(DAY, 1, @as_of_date_from)
END
INSERT INTO #as_of_date
SELECT max(dates) from @_tmpTable as o
GROUP BY datepart(MONTH, dates),datepart(YEAR, dates) 

Create Table #temp
	(as_of_date datetime, counterparty_id varchar(500)  COLLATE DATABASE_DEFAULT ,counterparty_name varchar(500)  COLLATE DATABASE_DEFAULT , contract_name varchar (500)  COLLATE DATABASE_DEFAULT , apply_netting_rule varchar(500)  COLLATE DATABASE_DEFAULT ,prior_value_n float, pnl_value_n float, prior_value_y float, pnl_value_y float, current_settlement_n float, current_settlement_y float,mtm_value float,credit_limit float, source_counterparty_id int,
	contract_id int,
	credit_limit_to_us float,
	Source_Deal_Header_ID int,
	m_as_of_date datetime,
	amount float,
	term_start datetime,
	first_day_month datetime,
	last_day_month datetime,
	broker_relevant varchar(50) COLLATE DATABASE_DEFAULT)
		
IF CURSOR_STATUS('local','cycle_report') > = -1
		BEGIN
			DEALLOCATE cycle_report
		END

	 DECLARE cycle_report CURSOR LOCAL FOR
	
		SELECT as_of_date
		FROM   #as_of_date
		DECLARE @as_of_date varchar(100)
		
		OPEN cycle_report 
		FETCH NEXT FROM cycle_report 
		INTO @as_of_date  
		WHILE @@FETCH_STATUS = 0
		BEGIN

	SET @as_of_date_from = @as_of_date

INSERT INTO #get_max_date_date
	SELECT max(as_of_date), Source_Counterparty_ID FROM credit_exposure_detail 
	WHERE as_of_date <=  @as_of_date_from
	GROUP BY Source_Counterparty_ID

INSERT INTO #temp_date_data
	SELECT DISTINCT sql_date_value ,first_day_of_month,	last_day_of_month ,dd.last_day_of_prev_month, dd.sql_date_value  
	FROM [vw_date_details] dd 
	WHERE  dd.sql_date_value = @as_of_date_from
			
SET @_sql = '
	Insert into #temp 
	SELECT 
	Distinct 
	ced.as_of_date, 
	sc.counterparty_id,
	sc.counterparty_name,
	cg.contract_name,
	CASE When cca.apply_netting_rule  = ''y'' THEN ''Contract Netting''
		WHEN cca.apply_netting_rule  is NULL THEN ''Cross Contract Netting''
		WHEN cca.apply_netting_rule = ''n'' THEN ''Not Applied''   
	END apply_netting_rule,

	CASE WHEN cca.apply_netting_rule = ''n''
	 and as_of_date = m_as_of_date 
	 AND month(ced.term_start) =  month(last_month_last_day) 
	 AND year(ced.term_start) = Year(last_month_last_day)
	 --AND ced.term_start <> sdpd.term_start
	 AND (sdpd.source_deal_pnl_id is NOT NULL AND ced.term_start <> sdpd.term_start)
	 THEN (ar_prior + ar_current) ELse NULL
	 END prior_value_n,
	
	CASE WHEN cca.apply_netting_rule = ''n'' 
	and as_of_date = m_as_of_date
		 AND month(ced.term_start) =  month(last_month_last_day) 
		 AND year(ced.term_start) = Year(last_month_last_day)
			 AND ced.term_start = sdpd.term_start
			THEN Case when und_pnl_set > 0 then und_pnl_set else NULL end
		ELSE NULL END pnl_value_n,
			
	CASE WHEN ISNULL(cca.apply_netting_rule,''y'') = ''y''
	 AND as_of_date = m_as_of_date 
	 AND month(ced.term_start) =  month(last_month_last_day) 
	 AND year(ced.term_start) = Year(last_month_last_day)
	 --AND ced.term_start <> sdpd.term_start
	 AND (sdpd.source_deal_pnl_id is NOT NULL AND ced.term_start <> sdpd.term_start)
	 THEN (ar_prior + ap_prior + ap_current + ar_current) 
	 ELSE NULL END prior_value_y,
	
	CASE WHEN ISNULL(cca.apply_netting_rule,''y'') = ''y''
	 AND as_of_date = m_as_of_date 
	  and year(ced.term_start) = Year(last_month_last_day)
	  AND month(ced.term_start) =  month(last_month_last_day)
	  AND ced.term_start = sdpd.term_start
	 THEN (und_pnl_set) ELSE NULL END pnl_value_y,	 

	CASE WHEN cca.apply_netting_rule = ''n''
	 AND as_of_date = m_as_of_date 
	 AND ced.term_start = first_day_month
	  AND ced.term_start = sdpd.term_start
		THEN Case when und_pnl_set  > 0 THEN und_pnl_set ELSE NULL END
			ELSE NULL 
		END current_settlement_n,
	CASE WHEN ISNULL(cca.apply_netting_rule,''y'') = ''y'' 
	AND as_of_date = m_as_of_date
	 AND ced.term_start = first_day_month
	  AND ced.term_start = sdpd.term_start
			THEN und_pnl_set
			ELSE 
			NULL
		END current_settlement_y,
		CASE WHEN cca.apply_netting_rule = ''n'' 
		AND   (ced.term_start) > (last_day_month) 
		--AND  Year(ced.term_start) = Year(last_day_month) 
		THEN (d_mtm_exposure_to_them + d_mtm_exposure_to_us)
	     WHEN isnull(cca.apply_netting_rule,''y'') = ''y'' 
               AND  (ced.term_start) > (last_day_month) 
		-- AND  Year(ced.term_start) = Year(last_day_month) 
		 THEN (d_mtm_exposure_to_them + d_mtm_exposure_to_us)	
		 Else 0	
		 END AS [mtm_value],	
	 ccl.credit_limit,
	sc.source_counterparty_id,
	cg.contract_id,
	ccl.credit_limit_to_us,
	ced.Source_Deal_Header_ID,
	m_as_of_date,
	amount,
	ced.term_start,
	tdd.first_day_month,
	tdd.last_day_month,
	udf_br.udf_value [broker_relevant]
	FROM  credit_exposure_detail ced
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = ced.Source_Counterparty_ID
	INNER JOIN contract_group cg on cg.contract_id = ced.contract_id
	INNER JOIN counterparty_contract_address cca ON cca.counterparty_id = ced.Source_Counterparty_ID and ced.contract_id = cca.contract_id
	INNER JOIN #get_max_date_date gmdd ON gmdd.counterparty_id = ced.Source_Counterparty_ID and gmdd.m_as_of_date = ced.as_of_date
	INNER JOIN #temp_date_data tdd ON tdd.rundate = tdd.rundate  
	LEFT JOIN source_deal_pnl_detail sdpd ON sdpd.source_deal_header_id = ced.Source_Deal_Header_ID and pnl_as_of_date = gmdd.m_as_of_date
	LEFT JOIN counterparty_credit_limits ccl on ccl.counterparty_id = sc.source_counterparty_id and ccl.effective_Date <=  tdd.rundate 
	LEFT JOIN counterparty_credit_info cci on cci.Counterparty_id = sc.source_counterparty_id
	LEFT JOIN counterparty_credit_enhancements cce on cce.counterparty_credit_info_id = cci.counterparty_credit_info_id and margin = ''y'' and expiration_date <=   tdd.rundate and cce.eff_date <=  tdd.rundate
	LEFT JOIN #udf_data_broker_relevant udf_br ON udf_br.source_counterparty_id = sc.source_counterparty_id
	WHERE 1 = 1 AND 
	as_of_date = m_as_of_date'
   +  
   	CASE WHEN @source_counterparty_id IS NOT NULL THEN ' AND sc.source_counterparty_id IN (' + @source_counterparty_id + ')' ELSE '' END
	EXEC(@_sql)

	SELECT 
	 TE.as_of_date
	,TE.counterparty_id
	,TE.counterparty_name
	,TE.contract_name
	,TE.apply_netting_rule
	,(isnull(prior_value_n, 0) + isnull(pnl_value_n,0) + isnull(prior_value_y, 0) + isnull(pnl_value_y,0)) Prior_Month_Settlement
	,(isnull(current_settlement_n, 0)+  Isnull(current_settlement_y, 0)) Current_Month_Settlement
	,mtm_value MTM,
	CASE WHEN 
	    (sum_value) < 0 THEN 
		(isnull(prior_value_n, 0) + isnull(pnl_value_n,0) + isnull(current_settlement_n, 0)+ isnull(mtm_value,0))
	ELSE 
	   (isnull(prior_value_n, 0) + isnull(pnl_value_n,0) + isnull(current_settlement_n, 0)+ isnull(mtm_value,0) + isnull(prior_value_y, 0) + isnull(pnl_value_y,0)+ isnull(current_settlement_y, 0))
	END
	Net_Exposure,
	ISNULL(credit_limit,0) credit_limit,
	source_counterparty_id source_counterparty_id,
	TE.contract_id contract_id,
	ISNULL(credit_limit_to_us,0) credit_limit_to_us,
	m_as_of_date,
	term_start,
	last_day_month,
	broker_relevant,
	t.contract_name sum_contract_group,
	t.counterparty_id sum_counterparty_group
	INTO #TEMP_final
	FROM #TEMP	TE
	OUTER APPLY(select sum(isnull(prior_value_y,0)) + sum(isnull(pnl_value_y,0)) + sum(isnull(current_settlement_y,0)) AS sum_value, contract_name, counterparty_id from #TEMP Group by contract_name, counterparty_id)T
	WHERE t.contract_name = TE.contract_name AND t.counterparty_id = TE.counterparty_id
	ORDER BY term_start

	INSERT INTO #ultimate_final
	SELECT 
		max(last_day_month)    as_of_date,
		max(counterparty_id) counterparty_id,
		max(counterparty_name) counterparty,
		sum (Net_Exposure) Pivot_value,
		max (credit_limit) credit_limit,
		tf.source_counterparty_id,	
		max (credit_limit_to_us) credit_limit_to_us,
		total_exp.total_exp,
		case when total_exp.total_exp > max(credit_limit) then 'Yes' else 'No' end Limit_voilation,
		case when total_exp.total_exp > max(credit_limit)  then 3  else 1 end Broker_Notification,
		contract_name Pivot_name,
		max(m_as_of_date) m_as_of_date,
		NULL as_of_date_to,
		max(broker_relevant)
	FROM #TEMP_final tf	
	Outer APPLY (select sum (Net_Exposure) as total_exp , source_counterparty_id  from #TEMP_final group by source_counterparty_id) total_exp 
	WHERE tf.source_counterparty_id = total_exp.source_counterparty_id
	Group by
		tf.source_counterparty_id, contract_id,m_as_of_date,contract_name,total_exp
	UNION ALL
	SELECT 
		DISTINCT
		max(last_day_month)    as_of_date,
		max(counterparty_id) counterparty_id,
		max(counterparty_name) counterparty,
		total_exp.total_exp Pivot_value,
		0 credit_limit,
		tf.source_counterparty_id,	
		0 credit_limit_to_us,
		total_exp.total_exp,
		case when total_exp.total_exp > max(credit_limit) then 'Yes' else 'No' end Limit_voilation,
		case when total_exp.total_exp > max(credit_limit) then  3  else 1 end Broker_Notification,
		'Total Exposure' AS Pivot_name,
		max(m_as_of_date) m_as_of_date,
		NULL as_of_date_to,
		max(broker_relevant)
	FROM #TEMP_final tf	
	Outer APPLY (select sum (Net_Exposure) as total_exp , source_counterparty_id  from #TEMP_final group by source_counterparty_id) total_exp 
	WHERE tf.source_counterparty_id = total_exp.source_counterparty_id
	Group by
		tf.source_counterparty_id, contract_id,m_as_of_date,contract_name,total_exp
	UNION ALL 
	SELECT 
		DISTINCT
		max(last_day_month)    as_of_date,
		max(counterparty_id) counterparty_id,
		max(counterparty_name) counterparty,
		max (credit_limit) Pivot_value,
		0 credit_limit,
		tf.source_counterparty_id,	
		0 credit_limit_to_us,
		total_exp.total_exp,
		case when total_exp.total_exp > max(credit_limit) then 'Yes' else 'No' end Limit_voilation,
		case when total_exp.total_exp > max(credit_limit) then 3 else 1 end Broker_Notification,
		'Total Limit' AS Pivot_name,
		max(m_as_of_date) m_as_of_date,
		NULL as_of_date_to,
		max(broker_relevant)
	FROM #TEMP_final tf	
	Outer APPLY (select sum (Net_Exposure) as total_exp , source_counterparty_id  from #TEMP_final group by source_counterparty_id) total_exp 
	WHERE tf.source_counterparty_id = total_exp.source_counterparty_id
	Group by
		tf.source_counterparty_id, contract_id,m_as_of_date,contract_name,total_exp
			  
	Drop table #TEMP_final	
	Delete from #TEMP
	Delete from #temp_date_data
	Delete from #get_max_date_date
		
		FETCH NEXT FROM cycle_report INTO @as_of_date
		END
		CLOSE cycle_report
		DEALLOCATE cycle_report

 IF (@flag = 'b')
 BEGIN
 --INSERT INTO #ultimate_final_broker

 --drop table #temp_year_data
	select 
	Distinct
	cast(year(as_of_date) as VARCHAR) as_of_date,
	ut.counterparty, 
	ut.counterparty_id,
	ut.source_counterparty_id,	
	CASE WHEN (cca.apply_netting_rule = 'y' and cg.contract_name = 'EFET GAS'  and Broker_Notification = 3) then 2  else Broker_Notification end  Broker_Notification, 
	CASE WHEN year(as_of_date) = year(getdate()) Then 3 Else 
	2 end data_order,
	cg.contract_name,
	ut.broker_relevant
	into #temp_year_data_g
	from #ultimate_final ut	
	INNER JOIN source_counterparty sc on sc.counterparty_id = ut.counterparty_id
	LEFT JOIN contract_group cg on cg.contract_name = pivot_name
	LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.Source_Counterparty_ID 
	and  ISNULL(cg.contract_id,-1) =cca.contract_id 
	where ut.broker_relevant = 'y' AND contract_name  = 'EFET GAS'
	Order by data_order desc ,as_of_date,ut.source_counterparty_id

	SELECT 
	CASE when year(as_of_date) = year(getdate()) and month(as_of_date) = month(getdate()) then 'Spot' else cast(as_of_date as varchar(20)) end as_of_date,
	ut.counterparty as counterparty_id, 
	ut.counterparty, 
	ut.source_counterparty_id,	
	Limit_voilation, 
	case when (cca.apply_netting_rule = 'y' and cg.contract_name = 'EFET GAS' and Broker_Notification = 3) then 2  else Broker_Notification end  Broker_Notification, 
	ut.broker_relevant,
	as_of_date as_of_date_to,
	CASE WHEN year(as_of_date) = year(getdate()) and month (as_of_date) = month (getdate()) Then 1 
		WHEN year(as_of_date) = year(getdate()) and month (as_of_date) != month (getdate()) Then 0 
		 WHEN year(as_of_date) = (year(getdate()) + 1) Then -1
		 WHEN year(as_of_date) = (year(getdate()) + 2) Then -2
		 WHEN year(as_of_date) = (year(getdate()) + 3) Then -3
		 WHEN year(as_of_date) = (year(getdate()) + 4) Then -4
		 WHEN year(as_of_date) = (year(getdate()) + 5) Then -5
		 WHEN year(as_of_date) = (year(getdate()) + 6) Then -6
	Else 
	NULL end data_order,
	cg.contract_name AS grouping_contract
	FROM 
	#ultimate_final	 ut
	INNER JOIN source_counterparty sc on sc.counterparty_id = ut.counterparty_id
	LEFT JOIN contract_group cg on cg.contract_name = pivot_name
	LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.Source_Counterparty_ID 
	and  ISNULL(cg.contract_id,-1) =cca.contract_id 
	where ut.broker_relevant = 'y' and contract_name  = 'EFET GAS'
	--where ut.broker_relevant = 'y'
	--Order by data_order desc ,as_of_date,ut.source_counterparty_id	
	UNION 
	select Distinct t.as_of_date,
	 counterparty counterparty_id, 
	t.counterparty, 
	t.source_counterparty_id, 
	NULL Limit_voilation,	
	a.broker_notification,
	t.broker_relevant,
	NULL as_of_date_to,
	t.data_order,
	contract_name grouping_contract
	from #temp_year_data_g t
	JOIN (select as_of_date, source_counterparty_id, min(broker_notification) broker_notification from #temp_year_data_g group by as_of_date, source_counterparty_id) a
	ON a.as_of_date = a.as_of_date and
	t.source_counterparty_id = a.source_counterparty_id and a.broker_notification  = t.Broker_Notification
	where  broker_relevant = 'y' and contract_name  = 'EFET GAS' and a.as_of_date = t.as_of_date
	Order by data_order desc ,as_of_date,source_counterparty_id			
END
ELSE IF (@flag = 'c')
 BEGIN
 --INSERT INTO #ultimate_final_broker
	select 
	Distinct cast(year(as_of_date) as VARCHAR) as_of_date,
	ut.counterparty, 
	ut.counterparty_id,
	ut.source_counterparty_id,	
	CASE WHEN (cca.apply_netting_rule = 'y' and cg.contract_name =  'EFET POWER'  and Broker_Notification = 3) then 2  else Broker_Notification end  Broker_Notification, 
	CASE WHEN year(as_of_date) = year(getdate()) Then 3 Else
        2 end data_order,
	cg.contract_name,
	ut.broker_relevant
	into #temp_year_data_p
	from #ultimate_final ut	
	INNER JOIN source_counterparty sc on sc.counterparty_id = ut.counterparty_id
	LEFT JOIN contract_group cg on cg.contract_name = pivot_name
	LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.Source_Counterparty_ID 
	and  ISNULL(cg.contract_id,-1) =cca.contract_id 
	where ut.broker_relevant = 'y'  AND contract_name  = 'EFET POWER'
	Order by data_order desc ,as_of_date,ut.source_counterparty_id

	SELECT 
	CASE when year(as_of_date) = year(getdate()) and month(as_of_date) = month(getdate()) then 'Spot' else cast(as_of_date as varchar(20)) end as_of_date,
	ut.counterparty as counterparty_id, 
	ut.counterparty, 
	ut.source_counterparty_id,	
	Limit_voilation, 
	case when (cca.apply_netting_rule = 'y' and cg.contract_name =  'EFET POWER' and Broker_Notification = 3) then 2  else Broker_Notification end  Broker_Notification, 
	ut.broker_relevant,
	as_of_date as_of_date_to,
	CASE WHEN year(as_of_date) = year(getdate()) and month (as_of_date) = month (getdate()) Then 1 
	    WHEN year(as_of_date) = year(getdate()) and month (as_of_date) != month (getdate()) Then 0 
		 WHEN year(as_of_date) = (year(getdate()) + 1) Then -1
		 WHEN year(as_of_date) = (year(getdate()) + 2) Then -2
		 WHEN year(as_of_date) = (year(getdate()) + 3) Then -3
		 WHEN year(as_of_date) = (year(getdate()) + 4) Then -4
		 WHEN year(as_of_date) = (year(getdate()) + 5) Then -5
		 WHEN year(as_of_date) = (year(getdate()) + 6) Then -6
	Else 
	NULL end data_order,
	cg.contract_name AS grouping_contract
	FROM 
	#ultimate_final	 ut
	INNER JOIN source_counterparty sc on sc.counterparty_id = ut.counterparty_id
	LEFT JOIN contract_group cg on cg.contract_name = pivot_name
	LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.Source_Counterparty_ID 
	and  ISNULL(cg.contract_id,-1) =cca.contract_id 
	WHERE ut.broker_relevant = 'y' AND contract_name  = 'EFET POWER'
	--Order by data_order desc ,as_of_date,ut.source_counterparty_id	
	UNION 
	select Distinct t.as_of_date,
	 counterparty counterparty_id, 
	t.counterparty, 
	t.source_counterparty_id, 
	NULL Limit_voilation,	
	a.broker_notification,
	t.broker_relevant,
	NULL as_of_date_to,
	t.data_order,
	contract_name grouping_contract
	from #temp_year_data_p t
	JOIN (select as_of_date, source_counterparty_id, min(broker_notification) broker_notification from #temp_year_data_p group by as_of_date, source_counterparty_id) a
	ON a.as_of_date = a.as_of_date and
	t.source_counterparty_id = a.source_counterparty_id and a.broker_notification  = t.Broker_Notification
	WHERE broker_relevant = 'y'
	AND contract_name  = 'EFET POWER' and a.as_of_date = t.as_of_date
	Order by data_order desc ,as_of_date,source_counterparty_id			
END
ELSE 
BEGIN	
	SELECT  *, CASE WHEN pivot_name = 'Total Exposure' THEN 2
	WHEN pivot_name = 'Total Limit' THEN 3
	ELSE 1 end [order]
	FROM 
	#ultimate_final	
END