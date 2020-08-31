
IF OBJECT_ID(N'spa_compare_msmt_values', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_compare_msmt_values]
 GO 


-- select * from application_users
-- exec  spa_compare_msmt_values  722,  NULL,  'n',  '2005-10-30',  'y',  null,  'd','n','y'

--This procedure approves generated hedging relationships for repricing 
--DROP PROC spa_compare_msmt_values
-- EXEC spa_compare_msmt_values 312, null, 'n', '2004-10-30', 'y', NULL, 'd', 'n', 'y'  
-- EXEC spa_compare_msmt_values 68, '2003-02-28', 'y', null, 'y', NULL, 'd'  
-- EXEC spa_compare_msmt_values 117, null, 'y', '2004-6-30', 'y', NULL, 'd'  
-- EXEC spa_compare_msmt_values 104, null, 'y', '2004-7-30', 'n', '2004-07-15', 'd'  
-- exec spa_compare_msmt_values 527, NULL, 'n', '2005-10-30', 'n', null, 'd','n','n'
 -- exec spa_compare_msmt_values 507, NULL, 'n', '2005-10-30', 'y', null, 'd','n','y'
CREATE PROCEDURE [dbo].[spa_compare_msmt_values]	@link_id int,
						@as_of_date1 varchar(20) = NULL,
						@recalc_1 varchar(1) = 'n',
						@as_of_date2 varchar(20) = NULL,
						@recalc_2 varchar(1) = 'y',
						@reprice_date varchar(20) = NULL,
						@discount_option varchar(1) = 'd',
						@reclac_mtm varchar(1) = null,
						@save_msmt varchar(1)=Null,
						@called_from_html_export varchar(1) = 'y' 										    
AS

-- drop table #temp1
-- drop table #temp2
-- -- drop table #temp3
-- -- 
-- drop table #calc_status_compare
-- 
-- DECLARE		@link_id int,
-- 		@as_of_date1 varchar(20),
-- 		@recalc_1 varchar(1),
-- 		@as_of_date2 varchar(20),	
-- 		@recalc_2 varchar(1),
-- 		@reprice_date varchar(20),
-- 		@discount_option varchar(1)
-- 
-- SET @link_id = 104
-- set @as_of_date1 =null
-- set @recalc_1 ='n'
-- set @as_of_date2 =null
-- set @recalc_2 = 'n'
-- set @reprice_date = '2004-07-15'
-- set @discount_option = 'u'



Declare	@what_if_msmt1 varchar(128)
Declare	@what_if_msmt2 varchar(128)
Declare @curve_source_id int
DECLARE @what_if varchar(1)

--IF @reclac_mtm = 'y'
IF @save_msmt = 'y'
	set @what_if = 'n'
ELSE
	set @what_if = 'y'

SELECT     @curve_source_id = var_value
FROM         adiha_default_codes_values
WHERE     (instance_no = 1) AND (default_code_id = 13) AND (seq_no = 1)


DECLARE @user_name varchar(50)
set @user_name = user_name()

if @user_name ='dbo'
	set @user_name = 'farrms_admin'


CREATE TABLE #calc_status_compare
	(
	
	ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
	Module varchar(50) COLLATE DATABASE_DEFAULT,
	Source varchar(50) COLLATE DATABASE_DEFAULT,
	type varchar(50) COLLATE DATABASE_DEFAULT,
	[description] varchar(250) COLLATE DATABASE_DEFAULT,
	[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
	
	)

If @discount_option IS NULL
	set @discount_option = 'd'

If @reprice_date IS NOT NULL AND @as_of_date1 IS NULL AND @as_of_date2 IS NULL 
BEGIN
	Select @as_of_date1 = dbo.FNAGetSQLStandardDate(max(as_of_date)) from report_measurement_values where as_of_date <= @reprice_date
	Select @as_of_date2 = dbo.FNAGetSQLStandardDate(min(as_of_date)) from report_measurement_values where as_of_date >  @reprice_date

END


--calc MTM of hedged items if needed
-- If @reprice_date is not NULL
-- BEGIN
If @recalc_1 = 'y' AND @as_of_date1 IS NOT NULL AND (@reprice_date IS NOT NULL OR @reclac_mtm = 'y')
	INSERT #calc_status_compare
	EXEC spa_calc_new_items_mtm @link_id, @as_of_date1, @curve_source_id
If @recalc_2 = 'y' AND @as_of_date2 IS NOT NULL AND (@reprice_date IS NOT NULL OR @reclac_mtm = 'y')
	INSERT #calc_status_compare
	EXEC spa_calc_new_items_mtm @link_id, @as_of_date2, @curve_source_id
-- END

If (select count(*) from #calc_status_compare where ErrorCode = 'Error') > 0
BEGIN
	SELECT * FROM  #calc_status_compare
	RETURN
END



-- If @as_of_date1 IS NULL or @as_of_date2 IS NULL
-- BEGIN
-- 	Select  'Error', 'Compare Measurement Values', 
-- 				'spa_compare_msmt_values', 'Input Error', 
-- 				'Invalid as of date passed.', ''
-- 	RETURN
-- END



CREATE TABLE #temp1
(
Entry varchar(20) COLLATE DATABASE_DEFAULT,
as_of_date datetime,
assessment varchar(50) COLLATE DATABASE_DEFAULT,
term_month datetime,
d_hedge_mtm float,
d_item_mtm float,
d_total_aoci float,
d_total_pnl float,
u_pnl_settlement float,
u_cash float,
sort_order int
)


CREATE TABLE #temp2
(
Entry varchar(20) COLLATE DATABASE_DEFAULT,
as_of_date datetime,
assessment varchar(50) COLLATE DATABASE_DEFAULT,
term_month datetime,
d_hedge_mtm float,
d_item_mtm float,
d_total_aoci float,
d_total_pnl float,
u_pnl_settlement float,
u_cash float,
sort_order int
)

DECLARE @job_name varchar(100)
DECLARE @process_id varchar(50)
DECLARE @total_status INT

If @recalc_1 = 'y' AND @as_of_date1 IS NOT NULL
BEGIN
	SET @process_id = REPLACE(newid(),'-','_')
	SET @job_name = 'assmt_' + @process_id

	SET @what_if_msmt1 = dbo.FNAProcessTableName('what_if_msmt', @user_name, @process_id)

	--INSERT #msmt_value 
	EXEC spa_run_measurement_process_job  '', '', '', @as_of_date1, null, @process_id, @job_name, @user_name, 0, @what_if, @link_id 	


	--Check to see if errors found
	SELECT     @total_status  = COUNT(*) 
	FROM         measurement_process_status
	WHERE     (process_id = @process_id --and calc_type = 'm' 
			and can_proceed = 'n')
	
	--Measurement call encountered error
	If @total_status > 0 
	BEGIN
		SELECT     status_code AS Status, 'Measurement' AS Area, run_as_of_date AS [Run Date],
					'' Code, '' [Message], status_description Description
		FROM         measurement_process_status where process_id = @process_id
		RETURN
	END

END


If @recalc_2 = 'y' AND @as_of_date2 IS NOT NULL
BEGIN
	SET @process_id = REPLACE(newid(),'-','_')
	SET @job_name = 'assmt_' + @process_id

	--print @process_id
-- 	EXEC spa_print @job_name
-- 	EXEC spa_print @as_of_date2
-- 	EXEC spa_print @user_name
-- 	EXEC spa_print @link_id

	SET @what_if_msmt2 = dbo.FNAProcessTableName('what_if_msmt', @user_name, @process_id)

	EXEC spa_run_measurement_process_job  '', '', '', @as_of_date2, null, @process_id, @job_name, @user_name, 1, @what_if, @link_id		
--	EXEC spa_run_measurement_process_job  '', '', '', @as_of_date2, null, @process_id, @job_name, @user_name, 0, @what_if, @link_id		
	
	
	--Check for errors
	SELECT     @total_status  = COUNT(*) 
	FROM         measurement_process_status
	WHERE     (process_id = @process_id --and calc_type = 'm' 
		and can_proceed = 'n')
	
	--Measurement call encountered error
	If @total_status > 0 
	BEGIN
		SELECT     status_code AS Status, 'Measurement' AS Area, run_as_of_date AS [Run Date],
					'' Code, '' [Message], status_description Description
		FROM         measurement_process_status where process_id = @process_id
		RETURN

	END
END

--If measurement results have been  saved retrieve from report_measurement_values_report
IF @what_if = 'n'
BEGIN
	SET @recalc_1 = 'n' 
	SET @recalc_2 = 'n' 
END

--print 'after second'
--select * from #msmt_value
--print '*****************1'

DECLARE @sql_stmt varchar(8000)

If @recalc_1 = 'n' OR (@recalc_1 = 'y' AND @as_of_date1 IS NOT NULL)
BEGIN
	SET @sql_stmt = '
	INSERT INTO #temp1
	select 	''Cumulative'' [Entry],  ''' +  @as_of_date1 +''' as_of_date, 
	(case when (assessment_test = 1) then ''Passed'' else ''Failed'' end + '' ('' + assessment_type + '')'') as assessment,
	term_month term_month, 
	case when (''' + @discount_option + ''' = ''d'') then isnull(d_hedge_mtm, 0) else isnull(u_hedge_mtm, 0) end as d_hedge_mtm, 
	case when (''' + @discount_option + ''' = ''d'') then isnull(d_item_mtm,0) else  isnull(u_item_mtm,0) end as d_item_mtm, 
	case when (''' + @discount_option + ''' = ''d'') then isnull(d_total_aoci, 0) else isnull(u_total_aoci, 0)  end  as d_total_aoci, 
	case when (''' + @discount_option + ''' = ''d'') then isnull(d_total_pnl, 0) else isnull(u_total_pnl, 0)  end  as d_total_pnl, 
	u_pnl_settlement, u_cash,
	1 as sort_order
	from '  + CASE  when (@recalc_1 = 'n') then ' report_measurement_values ' else @what_if_msmt1 end +
	' where as_of_date = ''' + @as_of_date1 +  '''' + CASE  when (@recalc_1 = 'y') then '' else 
		' and link_id =  ' + cast(@link_id as varchar) + '  and link_deal_flag = ''l''' end
	
	--print '1. ' + @sql_stmt
	EXEC (@sql_stmt)
END

--print '*****************2'

If @recalc_2 = 'n' OR (@recalc_2 = 'y' AND @as_of_date2 IS NOT NULL)
BEGIN
	SET @sql_stmt = '
	INSERT INTO #temp2
	select 	''Cumulative'' [Entry],  ''' + @as_of_date2 + ''' as_of_date, 
	(case when (link_deal_flag = ''d'' OR settled_test > 0) then ''N/A'' when (assessment_test = 1) then ''Passed'' else ''Failed'' end + '' ('' + assessment_type + '')'') as assessment,
	term_month term_month, 
	case when (''' + @discount_option + ''' = ''d'') then isnull(d_hedge_mtm, 0) else isnull(u_hedge_mtm, 0) end as d_hedge_mtm, 
	case when (''' + @discount_option + ''' = ''d'') then isnull(d_item_mtm,0) else  isnull(u_item_mtm,0) end as d_item_mtm, 
	case when (''' + @discount_option + ''' = ''d'') then isnull(d_total_aoci, 0) else isnull(u_total_aoci, 0)  end  as d_total_aoci, 
	case when (''' + @discount_option + ''' = ''d'') then isnull(d_total_pnl, 0) else isnull(u_total_pnl, 0)  end  as d_total_pnl, 
	u_pnl_settlement, u_cash,
	1 as sort_order
	from '  + CASE when (@recalc_2 = 'n') then ' report_measurement_values ' else @what_if_msmt2 end +
	' where as_of_date = ''' + @as_of_date2 + '''' + CASE  when (@recalc_2 = 'y') then '' else 
		' and link_id =  ' + cast(@link_id as varchar) + '  and link_deal_flag = ''l''' end
	
	--print '2. ' + @sql_stmt
	EXEC (@sql_stmt)
END

--print '*****************3'

-- select * from #tem1
-- select * from #tem1

---Commenting period  values entry for now 09/12/04 UB

-- select '<b><i>Period</i></b>' [Entry], @as_of_date2 as_of_date, coalesce(#temp1.term_month,  #temp2.term_month) term_month,
-- 	isnull(#temp2.d_hedge_mtm, 0) - isnull(#temp1.d_hedge_mtm, 0) d_hedge_mtm, 
-- 	isnull(#temp2.d_item_mtm, 0) - isnull(#temp1.d_item_mtm, 0) d_item_mtm, 
-- 	isnull(#temp2.d_total_aoci, 0) - isnull(#temp1.d_total_aoci, 0) d_total_aoci,  
-- 	isnull(#temp2.d_total_pnl, 0) - isnull(#temp1.d_total_pnl, 0) d_total_pnl, 
-- 	3 as sort_order
-- into #temp3
-- from #temp1 FULL OUTER JOIN 
-- #temp2 ON #temp1.term_month = #temp2.term_month

--Delete the tables that has what-if measurement values
DECLARE @delete_stmt varchar(8000)
set @delete_stmt  = dbo.FNAProcessDeleteTableSql(@what_if_msmt1)
exec (@delete_stmt )
set @delete_stmt  = dbo.FNAProcessDeleteTableSql(@what_if_msmt2)
exec (@delete_stmt )


select Entry, dbo.FNADateFormat(as_of_date) [As of Date], 
	assessment as Test,
	dbo.FNAContractMonthFormat(term_month) [Term],	
	round(d_hedge_mtm, 0) [Hedge CFV], 
	round(d_item_mtm, 0)  [Item CFV], 
	round(d_total_aoci, 0)  [AOCI],
	round(d_total_pnl, 0)   [PNL Ineffectiveness],
	round(u_pnl_settlement, 0)   [Realized Earnings],
	round(u_cash, 0)   [Cash],

-- 	CASE WHEN (@reclac_mtm = 'n' OR @recalc_1 = 'y') THEN ''
-- 	     ELSE '<a target="_blank" HREF="../../dev/spa_html.php?spa=EXEC spa_Create_MTM_Journal_Entry_Report_Reverse ''' + 
-- 		dbo.FNAGetSQLStandardDate(as_of_date) + ''', null, null,null, ''' + @discount_option + ''',
-- 		''f'', ''a'', ''s'', ''n'', ''' + cast(@link_id as varchar)+ '''">GL</a>' END
	Reports AS [Reports]
-- 	cast(round(d_hedge_mtm, 0) as varchar) [Hedge CFV], 
-- 	cast(round(d_item_mtm, 0) as varchar)  [Item CFV], 
-- 	cast(round(d_total_aoci, 0) as varchar)  [AOCI],
-- 	cast(round(d_total_pnl, 0) as varchar)  [PNL Ineffectiveness]
from
(
select 	Entry, as_of_date, assessment, term_month,  
	d_hedge_mtm, d_item_mtm, d_total_aoci,
	d_total_pnl, u_pnl_settlement, u_cash, sort_order,
	CASE WHEN (@recalc_1 = 'y') THEN ''
	     ELSE '<a target="_blank" HREF="' + case when (@called_from_html_export <> 'y') then  '../' else '' end +
			'../dev/spa_html.php?spa=EXEC spa_Create_MTM_Journal_Entry_Report_Reverse ''' + 
		dbo.FNAGetSQLStandardDate(as_of_date) + ''', null, null,null, ''' + @discount_option + ''',
		''a'', ''a'', ''s'', ''y'', ''' + cast(@link_id as varchar)+ ''', NULL, NULL, 0">GL</a>' END
	AS [Reports]
	from #temp1
UNION
select Entry, as_of_date, assessment, term_month, 
	d_hedge_mtm , d_item_mtm, d_total_aoci,
	d_total_pnl, u_pnl_settlement, u_cash, sort_order, 
	CASE WHEN (@recalc_2 = 'y') THEN ''
	     ELSE '<a target="_blank" HREF="' + case when (@called_from_html_export <> 'y') then  '../' else '' end +
			'../dev/spa_html.php?spa=EXEC spa_Create_MTM_Journal_Entry_Report_Reverse ''' + 
		dbo.FNAGetSQLStandardDate(as_of_date) + ''', null, null,null, ''' + @discount_option + ''',
		''a'', ''a'', ''s'', ''y'', ''' + cast(@link_id as varchar)+ ''', NULL, NULL, 0">GL</a>' END
	AS [Reports]
	from #temp2 
-- UNION
-- select Entry, as_of_date,  '' as assessment, term_month, 
-- 	d_hedge_mtm , d_item_mtm, d_total_aoci,
-- 	d_total_pnl , sort_order from  #temp3
) xxx
where  (d_hedge_mtm <> 0 OR d_item_mtm <> 0 OR d_total_aoci <> 0 OR d_total_pnl <> 0 OR 
	u_pnl_settlement <> 0 OR u_cash <> 0)
order by term_month, sort_order









