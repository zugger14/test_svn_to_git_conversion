

IF OBJECT_ID(N'spa_drill_down_settlement', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_drill_down_settlement]
 GO 


--EXEC spa_drill_down_settlement 'Settlement', '2005-07-31', '622', 'a', NULL

-- EXEC spa_drill_down_settlement 'Settlement', '10/31/2005', 230, 'a', '2005-10', 'b'
-- EXEC spa_drill_down_settlement 'Settlement', '08/30/2004', 182, NULL, 
-- EXEC spa_drill_down_settlement 'Settlement', '2004-12-31', '182', 'a', '2004-09'

create PROC [dbo].[spa_drill_down_settlement] @type varchar(100), @as_of_date varchar(20),
					@link_id int, @settlement_option varchar(1),
					@term_month varchar(20) = NULL,
					@link_deal_flag varchar(1) = 'l', @disc_flag varchar(1)='u'

				
AS
SET NOCOUNT ON
----UNCOMMENT HERE TO TEST
/*
declare @as_of_date varchar(20)
declare @term_month varchar(20)
declare @link_id int
declare @settlement_option varchar(1)
declare @link_deal_flag varchar(1)
declare @disc_flag varchar(1)

 set @as_of_date = '2009-08-31'
 set @term_month = '2009-08'
 set @link_id = 613
 set @link_deal_flag = 'l'
 set @disc_flag = 'u'

 drop table #aoci_released
*/

----END OF TEST
SET @as_of_date =  dbo.FNAClientToSqlDate(@as_of_date)
declare @prior_as_of_date varchar(20)
declare @st varchar(8000)
--declare @reverse_option varchar(1)

-- 
-- 

if @disc_flag is null
	set @disc_flag = 'u'

DECLARE @link_type_value_id int
IF @link_deal_flag = 'l'
	select @link_type_value_id  = link_type_value_id from fas_link_header where link_id = @link_id
ELSE
	set @link_type_value_id = 450 -- This means deals and just defaulting to 450 rather than NULL

IF @term_month IS NOT NULL 
BEGIN
	set @term_month = @term_month + '-01'
--	set @reverse_option = 'y'
END


CREATE TABLE #aoci_released
(link_id INT, Item varchar(500) COLLATE DATABASE_DEFAULT , term_start datetime, released_amount float)


If (@link_type_value_id = 452)
	SET @st = 
		'
		INSERT INTO #aoci_released
		select link_id [Rel ID], ''AOCI Release to Earnings due to De-Designation Not Probable'' Item, term_start [Contract Month], 
		sum(' + case when (@disc_flag='u') then 'p_u_aoci' else 'p_u_aoci' end + ') as [Realized Revenue (Expense)]
		from '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'calcprocess_deals') + 'cd
		WHERE   (link_id = '+cast(@link_id as varchar) +') AND substring(link_type, 1, 1) = '''+cast(@link_deal_flag as varchar) +''' AND (as_of_date ='''+ @as_of_date+''') AND term_start = '+case when @term_month is null then 'term_start' else ''''+@term_month+'''' end +'
		AND term_start <= as_of_date
		group by link_id, term_start
		'
ELSE
	SET @st = 
		'
		INSERT INTO #aoci_released
		select link_id [Rel ID], ''AOCI Release to Earnings'' Item, i_term [Contract Month], 
			sum(' + case when (@disc_flag='u') then 'aoci_released' else 'd_aoci_released' end + ') as [Realized Revenue (Expense)]
		from 
		(
		select link_id, i_term, 
		sum(case when (i_term <= as_of_date) then case when (rollout_per_type in (520, 522)) then isnull(aoci_allocation_vol, 0) else isnull(aoci_allocation_pnl, 0) end else 0 end) aoci_released,
		sum(case when (i_term <= as_of_date) then case when (rollout_per_type in (520, 522)) then isnull(d_aoci_allocation_vol, 0) else isnull(d_aoci_allocation_pnl, 0) end else 0 end) d_aoci_released
		from ' + dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_aoci_release') + ' car 
		WHERE link_id = ' + cast(@link_id as varchar) + ' AND as_of_date = ''' + @as_of_date + ''' AND 
		i_term = '+case when @term_month is null then 'i_term' else ''''+@term_month+'''' end +'
		group by as_of_date, link_id, source_deal_header_id, i_term
		) car
		group by link_id, i_term
		'

--print @st
EXEC(@st)

set @st='
select [Rel ID], Item, dbo.FNAContractMonthFormat([Contract Month]) [Contract Month], [Realized Revenue (Expense)]  from
(
	select link_id [Rel ID], Item, term_start [Contract Month], released_amount [Realized Revenue (Expense)] from #aoci_released

	UNION
	select rmv.link_id [Rel ID], rmv.Item, rmv.term_month [Contract Month], sum(rmv.u_pnl_settlement) - sum(isnull(r.released_amount, 0)) [Realized Revenue (Expense)]
	from (
	select link_id, ''Earnings'' Item, term_month, sum(' + case when (@disc_flag='u') then 'u_pnl_settlement' else 'd_pnl_settlement' end + ') u_pnl_settlement
	from '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'report_measurement_values') + ' report_measurement_values 
	WHERE   (link_id ='+ cast(@link_id as varchar) +') AND link_deal_flag = '''+cast(@link_deal_flag as varchar) +''' AND (as_of_date ='''+ @as_of_date+''') AND term_month = '+case when @term_month is null then 'term_month' else ''''+@term_month+'''' end +'
	group by link_id, term_month ) rmv LEFT OUTER JOIN
	#aoci_released r ON r.link_id = rmv.link_id AND r.term_start = rmv.term_month
	group by rmv.link_id, rmv.Item, rmv.term_month
	
	) xx where [Realized Revenue (Expense)] <> 0
	order by [Contract Month]

'

--print @st
exec(@st)



