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
DECLARE @_sql_2 Nvarchar(Max)
Declare @_tmpTable table (dates date)

IF (@as_of_date_to IS NULL)
BEGIN
 SET @as_of_date_to = @as_of_date_from
END

CREATE TABLE #get_max_date_date
	(m_as_of_date datetime, from_as_of_date datetime)

Create table #temp_date_data
	(sql_date_value datetime, first_day_month datetime, last_day_month datetime,last_month_last_day datetime, rundate datetime)
	
Create table #ultimate_final
(as_of_date date,counterparty_id varchar(500)  COLLATE DATABASE_DEFAULT , counterparty varchar(500)  COLLATE DATABASE_DEFAULT , Pivot_value float, credit_limit float, source_counterparty_id varchar(500)  COLLATE DATABASE_DEFAULT ,  total_exp float, Limit_voilation varchar(50)  COLLATE DATABASE_DEFAULT , Broker_Notification varchar(50)  COLLATE DATABASE_DEFAULT , Pivot_name varchar(500)  COLLATE DATABASE_DEFAULT , m_as_of_date datetime, as_of_date_to datetime , broker_relevant varchar(50) COLLATE DATABASE_DEFAULT)

Create table #settlement_values
(counterparty_id int, contract_id int, month_term int, year_term int,  settlement_value float, settlement_value_positive float, settlement_value_negative float, apply_netting_rule char,as_of_date date, m_as_of_date date, from_as_of_date date, netting_contract_id int, netting_group_detail_id int)

CREATE TABLE #as_of_date
(as_of_date varchar(20)  COLLATE DATABASE_DEFAULT )

Create table #udf_data_broker_relevant
(source_counterparty_id int, udf_value VARCHAR(50))

Create table #combine_data
(as_of_date date,	counterparty_id int,	contract_id int,	year_term int,	month_term int,	und_pnl float,	contract_value float,	settlement_value float,	apply_netting_rule char, m_as_of_date date, from_as_of_date date, term_start date, settlement_value_positive float, settlement_value_negative float, contract_value_positive float, contract_value_negative float, netting_contract_id int, netting_group_detail_id int)

create table #forward_values
(source_deal_header_id int , leg int ,pnl_as_of_date date, term_start date, term_end date, und_pnl float, contract_value float, m_as_of_date date, from_as_of_date date)

create table #forward_values_final
(counterparty_id int, contract_id int, term_month  int, term_year int,  und_pnl float, contract_value float, contract_value_positive float, contract_value_negative float, pnl_as_of_date date, apply_netting_rule char,m_as_of_date date, from_as_of_date date, term_start date, netting_contract_id int, netting_group_detail_id int)

SET @_sql_2 = 'INSERT INTO #udf_data_broker_relevant
SELECT sc.source_counterparty_id, musdv.static_data_udf_values
FROM maintain_udf_static_data_detail_values musdv
INNER JOIN application_ui_template_fields autf ON musdv.application_field_id = autf.application_field_id
INNER JOIN application_ui_template_definition autd ON autd.application_ui_field_id = autf.application_ui_field_id
INNER JOIN source_counterparty sc ON sc.source_counterparty_id = musdv.primary_field_object_id
WHERE 
autd.default_label = ''Broker Relevant''' + 
CASE WHEN @source_counterparty_id IS NOT NULL THEN ' AND sc.source_counterparty_id IN (' + @source_counterparty_id + ')' ELSE '' END  --+

exec(@_sql_2)

WHILE @as_of_date_from <= @as_of_date_to
BEGIN
    INSERT INTO @_tmpTable (dates) values (@as_of_date_from)
    SET @as_of_date_from = DATEADD(DAY, 1, @as_of_date_from)
END

	
INSERT INTO #as_of_date
SELECT max(dates) from @_tmpTable as o
GROUP BY datepart(MONTH, dates),datepart(YEAR, dates) 


Create Table #temp
	(as_of_date datetime, 
	 year_term int,
	 counterparty_id varchar(500)  COLLATE DATABASE_DEFAULT 
	,counterparty_name varchar(500)  COLLATE DATABASE_DEFAULT ,
	 contract_id int,
	 contract_name varchar (500)  COLLATE DATABASE_DEFAULT, 
	 apply_netting_rule varchar(500)  COLLATE DATABASE_DEFAULT, 
	 limit float,
	 broker_relevant varchar(50) COLLATE DATABASE_DEFAULT,
	 mtm_value float,
	contract_value float,
	settlement_value float,			
	m_as_of_date datetime,
	term_month int,
	source_counterparty_id int,
	from_as_of_date date,
	last_day_month date,
	last_month_last_day date,
	term_start date,
	contract_value_positive  float, 
	contract_value_negative   float,
	settlement_value_positive float, 
	settlement_value_negative float,
	total_settle_n float, 
	total_settle_y float,
	netting_contract_id int,
	netting_group_detail_id int
	)
	   	
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

	INSERT INTO #get_max_date_date
	SELECT max(pnl_as_of_date), @as_of_date_from FROM source_deal_pnl_detail 
	WHERE pnl_as_of_date <=  @as_of_date


INSERT INTO #forward_values
SELECT source_deal_header_id, leg, pnl_as_of_date, term_start, term_end, und_pnl, contract_value, pnl_as_of_date, from_as_of_date
FROM source_deal_pnl_detail 
INNER JOIN  #get_max_date_date gmdd ON gmdd.m_as_of_date = pnl_as_of_date
--WHERE term_start > @as_of_date
	

INSERT INTO #temp_date_data
	SELECT DISTINCT sql_date_value ,first_day_of_month,	last_day_of_month ,dd.last_day_of_prev_month, dd.sql_date_value  
	FROM [vw_date_details] dd 
	WHERE  dd.sql_date_value = @as_of_date

INSERT INTO #settlement_values
	SELECT 
	sdh.counterparty_id, sdh.contract_id, 
	ISNULL(month(ifbs.term_start),month(sds.term_start)) term,  
	ISNULL(year(ifbs.term_start), year(sds.term_start)) year,
	sum(isnull(ifbs.value, sds.settlement_amount)) settlement_value,	
	sum(isnull(case when ifbs.value > 0 then ifbs.value else 0 end , case when sds.settlement_amount > 0 then sds.settlement_amount else 0 end)) settlement_value_positive,
	sum(isnull(case when ifbs.value < 0 then ifbs.value else 0 end , case when sds.settlement_amount < 0 then sds.settlement_amount else 0 end)) settlement_value_negative,
	cca.apply_netting_rule,
	isnull(ifbs.as_of_date , sds.as_of_date) as_of_date,
	m.m_as_of_date, 
	@as_of_date, 
	stmtn.netting_contract_id, 
	stmtd.netting_group_detail_id 
	from source_deal_header sdh
	LEFT JOIN index_fees_breakdown_settlement ifbs ON sdh.source_deal_header_id = ifbs.source_deal_header_id and ifbs.field_id in (50000444,50000445)
	LEFT JOIN source_deal_settlement sds ON sdh.source_deal_header_id = sds.source_deal_header_id
	LEFT JOIN counterparty_contract_address cca on cca.counterparty_id = sdh.counterparty_id and cca.contract_id = sdh.contract_id
	LEFT JOIN stmt_netting_group stmtn ON stmtn.counterparty_id = cca.counterparty_id and netting_type = 109800
	LEFT JOIN stmt_netting_group_detail stmtd ON stmtd.contract_detail_id = sdh.contract_id and stmtn.netting_group_id = stmtd.netting_group_id
	OUTER APPLY(SELECT m_as_of_date, from_as_of_date FROM #get_max_date_date) m
	INNER JOIN counterparty_credit_info cci on cci.Counterparty_id = sdh.counterparty_id
	INNER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id
	WHERE ISNULL((ifbs.as_of_date),(sds.as_of_date)) < =  @as_of_date
	--and ISNULL(year(ifbs.term_start), year(sds.term_start)) = year(@as_of_date_from )
	and isnull(ifbs.source_deal_header_id,sds.source_deal_header_id) is not null
	and check_apply != 'y' 
	group by sdh.counterparty_id, sdh.contract_id,  ISNULL(month(ifbs.term_start),month(sds.term_start)),cca.apply_netting_rule, ISNULL(year(ifbs.term_start), year(sds.term_start)),isnull(ifbs.as_of_date , sds.as_of_date),m.m_as_of_date, m.from_as_of_date, stmtn.netting_contract_id, stmtd.netting_group_detail_id 


	INSERT INTO #forward_values_final
	SELECT sdh.counterparty_id, sdh.contract_id, month(term_start) ,year(term_start), sum(und_pnl) und_pnl, sum(contract_value) contract_value, sum(case when contract_value > 0 then contract_value else 0 end) contract_value_positive, sum(case when contract_value < 0 then contract_value else 0 end) contract_value_negative, fv.pnl_as_of_date , cca.apply_netting_rule, m_as_of_date,@as_of_date, term_start, stmtn.netting_contract_id, stmtd.netting_group_detail_id 
	from #forward_values fv
	INNER JOIN source_deal_header sdh on sdh.source_deal_header_id = fv.source_deal_header_id 
	LEFT JOIN counterparty_contract_address cca on cca.counterparty_id = sdh.counterparty_id and cca.contract_id = sdh.contract_id
	LEFT JOIN stmt_netting_group stmtn ON stmtn.counterparty_id =  cca.counterparty_id and netting_type = 109800
	LEFT JOIN stmt_netting_group_detail stmtd ON stmtd.contract_detail_id =  cca.contract_id  and stmtn.netting_group_id = stmtd.netting_group_id
	INNER JOIN counterparty_credit_info cci on cci.Counterparty_id = sdh.counterparty_id
	INNER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id
	where  check_apply != 'y' 
	GROUP BY sdh.counterparty_id, sdh.contract_id, month(term_start),year(term_start), pnl_as_of_date,cca.apply_netting_rule, m_as_of_date, from_as_of_date, term_start, stmtn.netting_contract_id, stmtd.netting_group_detail_id 

	INSERT INTO #combine_data
	select as_of_date as_of_date, counterparty_id, contract_id, year_term, month_term, NULL as und_pnl, NULL as contract_value, settlement_value , apply_netting_rule , m_as_of_date, @as_of_date, NULL term_start ,settlement_value_positive, settlement_value_negative, NULL contract_value_positive,  NULL contract_value_negative, netting_contract_id, netting_group_detail_id  from #settlement_values
	union
	select pnl_as_of_date as_of_date, counterparty_id, contract_id, term_year as year_term,  term_month as month_term, und_pnl,  contract_value, NULL settlement_value , apply_netting_rule ,m_as_of_date, @as_of_date, term_start ,NULL As settlement_value_positive, NULL AS settlement_value_negative, contract_value_positive,  contract_value_negative, netting_contract_id , netting_group_detail_id  from  #forward_values_final
	
	set @_sql_2 = ' 
	INSERT INTO #temp
	select 
	as_of_date,
	cd.year_term,
	cd.counterparty_id,
	sc.counterparty_name,
	cg.contract_id,
	cg.contract_name,
	cd.apply_netting_rule,
	(isnull(ccl.credit_limit, 0) + isnull(cce.amount, 0)) limit,
	udf_br.udf_value [broker_relevant],
	cd.und_pnl mtm_value,
    contract_value,
	cd.settlement_value,	
	m_as_of_date,
	cd.month_term,
	cd.counterparty_id source_counterparty_id,
	from_as_of_date,
	last_day_month,
	last_month_last_day,
	cd.term_start,
	contract_value_positive,  
	contract_value_negative,  
	settlement_value_positive,
	settlement_value_negative,
	case when apply_netting_rule = ''n'' then (isnull(contract_value_positive, 0) + isnull(settlement_value_positive, 0)) else NULL end total_settle_n,
	
	case when apply_netting_rule = ''y'' 
	then case when (isnull(contract_value,0) + isnull(settlement_value, 0)) > 0 
	then (isnull(contract_value,0) + isnull(settlement_value, 0)) 
	else NULL end end total_settle_y,
	
	netting_contract_id,
	netting_group_detail_id 
	from #combine_data cd
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = cd.counterparty_id
	INNER JOIN contract_group cg on cg.contract_id = CASE when netting_group_detail_id is null then cd.contract_id  when netting_group_detail_id is not null then netting_contract_id end
	--INNER JOIN #get_max_date_date gmdd ON gmdd.m_as_of_date = cd.as_of_date
	INNER JOIN #temp_date_data tdd ON tdd.rundate = tdd.rundate 
	LEFT JOIN counterparty_credit_limits ccl on ccl.counterparty_id = sc.source_counterparty_id and ccl.effective_Date <=  tdd.rundate 
	LEFT JOIN counterparty_credit_info cci on cci.Counterparty_id = sc.source_counterparty_id
	LEFT JOIN counterparty_credit_enhancements cce on cce.counterparty_credit_info_id = cci.counterparty_credit_info_id and margin = ''y'' and cce.eff_date <=  tdd.rundate and  isnull(cce.expiration_date, - 1) <=  tdd.rundate
	LEFT JOIN #udf_data_broker_relevant udf_br ON udf_br.source_counterparty_id = sc.source_counterparty_id
	WHERE 1 = 1 '+  
   	CASE WHEN @source_counterparty_id IS NOT NULL THEN ' AND sc.source_counterparty_id IN (' + @source_counterparty_id + ')' ELSE '' END +
	CASE WHEN @flag IS NOT NULL THEN ' AND udf_br.udf_value = ''y''' ELSE '' END
	
	EXEC(@_sql_2)

	
	select 
	as_of_date,
	year_term,
    counterparty_id, 
	counterparty_name,
	contract_id,
	contract_name, 
	apply_netting_rule,
	limit, 
	broker_relevant,
	source_counterparty_id,
	sum(isnull(settlement_value,0)) sum_settle,
	SUM(isnull(contract_value,0)) sum_current,
	sum(isnull(mtm_value,0))  sum_mtm, 
	sum(isnull(total_settle_y, 0)) total_settle_y,
	sum(isnull(total_settle_n, 0)) total_settle_n, 
	from_as_of_date,
	last_day_month ,
	last_month_last_day ,
	m_as_of_date, 
	term_month,
	term_start
	INTO #TEMP_update
	FROM #TEMP 
	where (isnull(isnull(settlement_value,0),isnull(contract_value,0))) is not null
	Group by contract_id, contract_name, counterparty_id,term_month,year_term,last_month_last_day,last_day_month,counterparty_name,limit,as_of_date,apply_netting_rule,broker_relevant,source_counterparty_id,from_as_of_date,m_as_of_date,term_month,term_start
		
		
	select
	as_of_date,
	year_term,
    counterparty_id, 
	counterparty_name,
	contract_id,
	contract_name, 
	apply_netting_rule,
	limit, 
	broker_relevant,
	source_counterparty_id,
	case when month((last_month_last_day)) = (term_month)  --AND
	--month((last_day_month)) = (term_month) 
	and year((last_month_last_day)) = (year_term) then
	case when apply_netting_rule = 'y' then 
		total_settle_y
		ELSE
	    total_settle_n
	end 
	end sett,
	case when month((last_day_month)) = (term_month) --AND month((last_day_month)) = (term_month)
	and year((last_day_month)) = (year_term) 
	THEN 
	case when apply_netting_rule = 'y' then 
		total_settle_y
		ELSE
	    total_settle_n
	end end crent,
	CASE when month((last_month_last_day)) = (term_month) 
	and year((last_month_last_day)) = (year_term) THEN NULL
	when month((last_day_month)) = (term_month) 
	and year((last_day_month)) = (year_term)  
	--and term_start > last_day_month
 	THEN NULL
	when term_start < @as_of_date then NULL
	ELSE
	ISNULL(sum_mtm,0) end mtmm,
	from_as_of_date,
	last_day_month ,
	last_month_last_day ,
	 m_as_of_date, 
	NULL as Net_exposure  
	, term_start
	INTO #temp_update_data
	from #TEMP_update


 INSERT INTO #ultimate_final
	SELECT 
		(from_as_of_date)    as_of_date,
		max(counterparty_id) counterparty_id,
		max(counterparty_name) counterparty,
		SUM(isnull(crent, 0)+isnull(sett, 0)+ isnull(mtmm,0)) Pivot_value,
		max (limit) credit_limit,
		tf.source_counterparty_id,	
		total_exp.total_exp,
		case when total_exp.total_exp > max(limit) then 'Yes' else 'No' end Limit_voilation,
		case when total_exp.total_exp > max(limit)  then 3  else 1 end Broker_Notification,
		contract_name Pivot_name,
		max(m_as_of_date) m_as_of_date,
		NULL as_of_date_to,
		(broker_relevant) Broker_relevant
	FROM #temp_update_data tf	
	Outer APPLY (select (SUM(isnull(sett, 0)+ isnull(crent, 0)+ isnull(mtmm,0))) as total_exp , source_counterparty_id  from #temp_update_data group by source_counterparty_id) total_exp 
	WHERE tf.source_counterparty_id = total_exp.source_counterparty_id
	Group by
		tf.source_counterparty_id, contract_id,m_as_of_date,contract_name,total_exp,Broker_relevant,from_as_of_date
	UNION ALL
	SELECT 
		DISTINCT
		(from_as_of_date)    as_of_date,
		max(counterparty_id) counterparty_id,
		max(counterparty_name) counterparty,
		total_exp.total_exp Pivot_value,
		0 credit_limit,
		tf.source_counterparty_id,	
		total_exp.total_exp,
		case when total_exp.total_exp > max(limit) then 'Yes' else 'No' end Limit_voilation,
		case when total_exp.total_exp > max(limit) then  3  else 1 end Broker_Notification,
		'Total Exposure' AS Pivot_name,
		max(m_as_of_date) m_as_of_date,
		NULL as_of_date_to,
		(broker_relevant)Broker_relevant 
	FROM #temp_update_data tf	
	Outer APPLY (select (SUM(isnull(sett, 0)+ isnull(crent, 0)+ isnull(mtmm,0))) as total_exp , source_counterparty_id  from #temp_update_data group by source_counterparty_id) total_exp 
	WHERE tf.source_counterparty_id = total_exp.source_counterparty_id
	Group by
		tf.source_counterparty_id, contract_id,m_as_of_date,contract_name,total_exp,Broker_relevant,from_as_of_date
	UNION ALL 
	SELECT 
		DISTINCT
		(from_as_of_date)    as_of_date,
		max(counterparty_id) counterparty_id,
		max(counterparty_name) counterparty,
		max (limit) Pivot_value,
		0 credit_limit,
		tf.source_counterparty_id,	
		total_exp.total_exp,
		case when total_exp.total_exp > max(limit) then 'Yes' else 'No' end Limit_voilation,
		case when total_exp.total_exp > max(limit) then 3 else 1 end Broker_Notification,
		'Total Limit' AS Pivot_name,
		max(m_as_of_date) m_as_of_date,
		NULL as_of_date_to,
		(broker_relevant) Broker_relevant
	FROM #temp_update_data tf	
	Outer APPLY (select (SUM(isnull(sett, 0)+ isnull(crent, 0)+ isnull(mtmm,0))) as total_exp , source_counterparty_id  from #temp_update_data group by source_counterparty_id) total_exp 
	WHERE tf.source_counterparty_id = total_exp.source_counterparty_id
	Group by
		tf.source_counterparty_id, contract_id,m_as_of_date,contract_name,total_exp,broker_relevant,from_as_of_date
		

	--DROP TABLE #TEMP_final	
	Delete from #forward_values
	Delete from #forward_values_final
	DELETE FROM #combine_data
	DELETE FROM #TEMP
	DELETE FROM #temp_date_data
	DROP TABLE #TEMP_update
	DELETE FROM #get_max_date_date
	DELETE FROM #settlement_values
	DROP TABLE #temp_update_data
--	Drop table #temp_update_data_positive

		
		FETCH NEXT FROM cycle_report INTO @as_of_date
		END
		CLOSE cycle_report
		DEALLOCATE cycle_report

 IF (@flag = 'b')
 BEGIN
 
	select 
	Distinct
	cast(year(as_of_date) as VARCHAR) as_of_date,
	ut.counterparty, 
	ut.counterparty_id,
	ut.source_counterparty_id,	
	CASE WHEN (cca.apply_netting_rule = 'y' and cg.contract_name = 'EFET GAS'  and Broker_Notification = 3) then 2  else Broker_Notification end  Broker_Notification, 
	CASE WHEN year(as_of_date) = year(getdate()) Then -3 Else 
	-2 end data_order,
	cg.contract_name,
	ut.broker_relevant
	into #temp_year_data_g
	from #ultimate_final ut	
	INNER JOIN source_counterparty sc on sc.source_counterparty_id = ut.counterparty_id
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
	CASE WHEN year(as_of_date) = year(getdate()) and month (as_of_date) = month (getdate()) Then -1 
		else  concat(year(as_of_date), CONVERT(char(2),as_of_date, 101)) end data_order,
	 cg.contract_name AS grouping_contract
	FROM 
	#ultimate_final	 ut
	INNER JOIN source_counterparty sc on sc.source_counterparty_id  = ut.counterparty_id
	LEFT JOIN contract_group cg on cg.contract_name = pivot_name
	LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.Source_Counterparty_ID 
	and  ISNULL(cg.contract_id,-1) =cca.contract_id 
	where ut.broker_relevant = 'y' and contract_name  = 'EFET GAS'		
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
	JOIN (select as_of_date, source_counterparty_id, MAX(broker_notification) broker_notification from #temp_year_data_g group by as_of_date, source_counterparty_id) a
	ON a.as_of_date = a.as_of_date and
	t.source_counterparty_id = a.source_counterparty_id and a.broker_notification  = t.Broker_Notification
	where  broker_relevant = 'y' and contract_name  = 'EFET GAS' and a.as_of_date = t.as_of_date
	Order by data_order asc ,as_of_date,source_counterparty_id			

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
	CASE WHEN year(as_of_date) = year(getdate()) Then -3 Else
       - 2 end data_order,
	cg.contract_name,
	ut.broker_relevant
	into #temp_year_data_p
	from #ultimate_final ut	
	INNER JOIN source_counterparty sc on sc.source_counterparty_id = ut.counterparty_id
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
	CASE WHEN year(as_of_date) = year(getdate()) and month (as_of_date) = month (getdate()) Then -1 
	     else  concat(year(as_of_date), CONVERT(char(2),as_of_date, 101)) end data_order,
	cg.contract_name AS grouping_contract
	FROM 
	#ultimate_final	 ut
	INNER JOIN source_counterparty sc on sc.source_counterparty_id = ut.counterparty_id
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
	JOIN (select as_of_date, source_counterparty_id, MAX(broker_notification) broker_notification from #temp_year_data_p group by as_of_date, source_counterparty_id) a
	ON a.as_of_date = a.as_of_date and
	t.source_counterparty_id = a.source_counterparty_id and a.broker_notification  = t.Broker_Notification
	WHERE broker_relevant = 'y'
	AND contract_name  = 'EFET POWER' and a.as_of_date = t.as_of_date
	Order by data_order asc ,as_of_date,source_counterparty_id	
	
END
ELSE 
BEGIN	
  SELECT  *, CASE WHEN pivot_name = 'Total Exposure' THEN 2
	WHEN pivot_name = 'Total Limit' THEN 3
	ELSE 1 end [order]
	FROM 
	#ultimate_final	
	order by counterparty_id
END