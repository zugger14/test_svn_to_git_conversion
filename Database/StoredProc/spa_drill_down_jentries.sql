
IF OBJECT_ID(N'spa_drill_down_jentries', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_drill_down_jentries]
 GO 





--THIS PROCEDURE DRILLS DOWN ON JOURNAL ENTRY ITEM
--EXEC spa_drill_down_jentries '2005-06-30', 182, 'y'
--EXEC spa_drill_down_jentries '2004-08-30', 112, 'y'
--spa_html.php?spa=EXEC spa_drill_down_jentries '2005-06-30', 182, 'y'
create PROC [dbo].[spa_drill_down_jentries]  	@as_of_date varchar(20),
					@link_id int,
					@reverse_option varchar(1),
					@gl_number varchar(250) = null,
					@account_name varchar(250) = null
	
AS
-- declare @as_of_date varchar(20)
-- declare @link_id int
-- declare @reverse_option varchar(1)
declare @st varchar(8000)
declare @prior_as_of_date varchar(20)


-- set @as_of_date = '6/30/2005'
-- --set @as_of_date = '8/30/2004'
-- set @link_id = 182
-- --set @link_id = 175
-- set @reverse_option = 'y'
-- drop table #temp



if @reverse_option <> 'n'
begin
	create table #max_date (as_of_date datetime)
	declare @st_where varchar(100)
	set @st_where ='as_of_date<'''+@as_of_date+''' and link_id='+cast(@link_id as varchar)+ ' and link_deal_flag=''l'''
--print @st_where
	insert into #max_date (as_of_date) exec  spa_get_Script_ProcessTableFunc 'max','as_of_date','report_measurement_values',@st_where
	select @prior_as_of_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from #max_date
end
--	select @prior_as_of_date  = dbo.FNAGetSQLStandardDate(max(as_of_date)) from 
--			report_measurement_values where as_of_date <  @as_of_date 
--			and (link_id = @link_id)
--			and (link_deal_flag = 'l')
else
	set @prior_as_of_date = '1900-01-01'
--select @prior_as_of_date
-- basis amortization period
create table #temp (
RelId int, Item varchar(100) COLLATE DATABASE_DEFAULT,[Value] float, factor int)
declare  @st1 varchar(8000)
set @st='insert into #temp
select cur.link_id RelId, ''Basis Asjustment Amortization'' Item,
(isnull(cur.basis_amortization, 0) - isnull(pre.basis_amortization, 0)) [Value], 1 as  factor
from (SELECT     link_id, ''l'' as link_deal_flag, sum(basis_amortization) basis_amortization
FROM    calcprocess_amortization
WHERE     (as_of_date <='''+ @as_of_date+''') and link_id = '+cast(@link_id as varchar)+'
group by link_id) cur LEFT  OUTER JOIN
(SELECT     link_id, ''l'' as link_deal_flag, sum(basis_amortization) basis_amortization
FROM         calcprocess_amortization
WHERE     (as_of_date <='''+ @prior_as_of_date+''') and link_id ='+ cast(@link_id as varchar)+'
group by link_id) pre ON pre.link_id = cur.link_id and 
pre.link_deal_flag = cur.link_deal_flag
UNION
-- interest period hedge
select cur.link_id RelID, ''Hedge Interest'' Item,
(isnull(cur.interest_expense, 0) - isnull(pre.interest_expense, 0)) [Value], 1 as  factor
from(SELECT     link_id, ''l'' as link_deal_flag, SUM(interest_expense) AS interest_expense
FROM         calcprocess_interest_expense
WHERE     (as_of_date <= '''+@as_of_date+''') and hedge_or_item  = ''h''  and link_id ='+ cast(@link_id as varchar)+'
GROUP BY link_id) cur LEFT OUTER JOIN
(SELECT     link_id, ''l'' as link_deal_flag, SUM(interest_expense) AS interest_expense
FROM         calcprocess_interest_expense
WHERE     (as_of_date <= '''+@prior_as_of_date+''') and hedge_or_item  = ''h''  and link_id = '+cast(@link_id as varchar)+'
GROUP BY link_id) pre ON pre.link_id = cur.link_id and 
pre.link_deal_flag = cur.link_deal_flag
UNION
-- interest period item
select cur.link_id RelID,  ''Hedged Item Interest '' Item,
(isnull(cur.interest_expense, 0) - isnull(pre.interest_expense, 0)) [Value], 1 as  factor
from
(SELECT     link_id, ''l'' as link_deal_flag,  SUM(interest_expense) AS interest_expense
FROM         calcprocess_interest_expense
WHERE     (as_of_date <= '''+@as_of_date+''') and hedge_or_item  = ''i''  and link_id ='+ cast(@link_id as varchar)+'
GROUP BY link_id) cur LEFT OUTER JOIN 
(SELECT     link_id, ''l'' as link_deal_flag,  SUM(interest_expense) AS interest_expense
FROM         calcprocess_interest_expense
WHERE     (as_of_date <= '''+@prior_as_of_date+''') and hedge_or_item  = ''i''  and link_id ='+ cast(@link_id as varchar)+'
GROUP BY link_id) pre ON pre.link_id = cur.link_id and 
pre.link_deal_flag = cur.link_deal_flag
UNION
--options amortization cumulative
select cur.link_id RelID, ''Options Premium Amortization'' Item,
(isnull(cur.options_amortization, 0) - isnull(pre.options_amortization, 0)) [Value], 1 as  factor
from
(SELECT     link_id, link_deal_flag, options_amortization
FROM         calcprocess_options_amortization
where as_of_date = '''+@as_of_date+'''  and link_id = '+cast(@link_id as varchar)+') cur LEFT OUTER JOIN
(SELECT     link_id, link_deal_flag, options_amortization
FROM         calcprocess_options_amortization
where as_of_date ='''+ @prior_as_of_date +''' and link_id = '+cast(@link_id as varchar)+') pre
ON pre.link_id = cur.link_id and 
pre.link_deal_flag = cur.link_deal_flag
UNION '
set @st1='
--AOCI amortization period
select cur.link_id RelID, ''AOCI Amortization'' Item,
(isnull(cur.aoci_amortization, 0) - isnull(pre.aoci_amortization, 0)) [Value], 1 as  factor
from
(SELECT     link_id, link_deal_flag, SUM(u_aoci_to_release) AS aoci_amortization
FROM         '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'calcprocess_aoci_release') + ' calcprocess_aoci_release
WHERE     (oci_rollout_approach_value_id = 502) AND (reclassify_date IS NOT NULL)
	and as_of_date <= '''+@as_of_date+'''  and link_id = '+cast(@link_id as varchar)+'
GROUP BY link_id, link_deal_flag) cur LEFT OUTER JOIN
(SELECT     link_id, link_deal_flag, SUM(u_aoci_to_release) AS aoci_amortization
FROM         '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'calcprocess_aoci_release') + 'calcprocess_aoci_release
WHERE     (oci_rollout_approach_value_id = 502) AND (reclassify_date IS NOT NULL)
	and as_of_date <= '''+@prior_as_of_date+'''  and link_id ='+ cast(@link_id as varchar)+'
GROUP BY link_id, link_deal_flag) pre
ON pre.link_id = cur.link_id and 
pre.link_deal_flag = cur.link_deal_flag 
UNION
--AOCI amortization period
select cur.link_id RelID, ''AOCI Reclassified to Inventory'' Item,
(isnull(cur.aoci_amortization, 0) - isnull(pre.aoci_amortization, 0)) [Value], 0 as  factor
from
(SELECT     link_id, link_deal_flag, SUM(u_aoci_to_release) AS aoci_amortization
FROM         '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'calcprocess_aoci_release') + ' calcprocess_aoci_release
WHERE     (oci_rollout_approach_value_id = 501)  
	and as_of_date <= '''+@as_of_date +''' and link_id = '+cast(@link_id as varchar)+'
GROUP BY link_id, link_deal_flag) cur LEFT OUTER JOIN
(SELECT     link_id, link_deal_flag, SUM(u_aoci_to_release) AS aoci_amortization
FROM         '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'calcprocess_aoci_release') + ' calcprocess_aoci_release
WHERE     (oci_rollout_approach_value_id = 501)
	and as_of_date <= '''+@prior_as_of_date +''' and link_id = '+cast(@link_id as varchar)+'
GROUP BY link_id, link_deal_flag) pre
ON pre.link_id = cur.link_id and 
pre.link_deal_flag = cur.link_deal_flag '
exec (@st+@st1)
--select * from #temp
-- select @as_of_date
-- select @prior_as_of_date
set @st='
select RelID, Item, round(Value, 2) as [Revenue (Expense)]  from (
select RelID, Item, Value from  #temp
union
-- --Settlement  Cumulative
select cur.link_id RelID, ''Settlement (Earnings)'' Item,
((isnull(cur.u_pnl_settlement, 0) - isnull(pre.u_pnl_settlement, 0)) - isnull(other_items.Others, 0)) as [Value]
from
(SELECT   link_id, link_deal_flag, SUM(u_pnl_settlement) AS u_pnl_settlement
FROM      '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'report_measurement_values') + ' report_measurement_values
WHERE     (link_deal_flag = ''l'') 
	and as_of_date ='''+ @as_of_date +''' and link_id ='+ cast(@link_id as varchar)+'
GROUP BY link_id, link_deal_flag) cur LEFT OUTER  JOIN
(SELECT   link_id, link_deal_flag, SUM(u_pnl_settlement) AS u_pnl_settlement
FROM      report_measurement_values
WHERE     (link_deal_flag = ''l'') 
	and as_of_date ='''+ @prior_as_of_date +''' and link_id = '+cast(@link_id as varchar)+'
GROUP BY link_id, link_deal_flag) pre
ON pre.link_id = cur.link_id and 
pre.link_deal_flag = cur.link_deal_flag LEFT OUTER JOIN
(select RelID, sum(Value*factor) as Others from #temp group by RelID) other_items 
ON other_items.RelID = cur.link_id) all_values
where abs(Value) > 0.5'
exec(@st)









