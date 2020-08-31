
IF OBJECT_ID(N'spa_Create_Cash_Flow_Report', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Create_Cash_Flow_Report]
 GO 
-- EXEC  spa_Create_Cash_Flow_Report '7/31/2003', NULL, NULL, NULL, 'u', 'q', 'c', 's', NULL
-- EXEC  spa_Create_Cash_Flow_Report '7/31/2003', NULL, NULL, NULL, 'u', 'q', 'c', 's'
-- EXEC  spa_Create_Cash_Flow_Report '7/31/2003', NULL, NULL, NULL, 'u', 'q', 'e', 'd'

-- grnaulirty_type m (month), q(quarter), s(semi-annual), a(annual)
-- report_type c(cash flow), e(earnings)
create PROC [dbo].[spa_Create_Cash_Flow_Report] 
	@as_of_date varchar(50), 
	@sub_entity_id varchar(100), 
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@discount_option char(1), 
	@granularity_type char(1), 
	@report_type char(1),
	@summary_option char(1),
	@called_from_db int = 0
AS
SET NOCOUNT ON

Declare @Sql_Select varchar(5000)

Declare @Sql_From varchar(5000)

Declare @Sql_Where varchar(5000)
Declare @Sql_Where1 varchar(5000)
Declare @Sql_Where2 varchar(5000)
Declare @Sql_Where3l varchar(5000)
Declare @Sql_Where3d varchar(5000)
Declare @earnings_term_month varchar(20)

Declare @Sql_GpBy varchar(5000)

Declare @Sql varchar(5000)

Declare @group_by varchar(5000)
set @group_by = ''
Declare @order_by varchar(5000)
set @order_by = ''


If @called_from_db IS NULL 
	set @called_from_db = 0

CREATE TABLE [#temp_CASH_FLOW] (
	[sub_entity_id] [int] NOT NULL ,
	[strategy_entity_id] [int] NOT NULL,
	[book_entity_id] [int] NOT NULL,
	[accounting_type] [varchar] (20) COLLATE DATABASE_DEFAULT NOT NULL,
	[term_month] [datetime] NOT NULL ,
	[term_group] [varchar] (20) COLLATE DATABASE_DEFAULT NOT NULL,
	[cfv] [float] NOT NULL
) 

--This procedure is called from netting logic... use all subs and exclude assets/liabilities
If @sub_entity_id IS NULL OR @sub_entity_id =  ''
BEGIN
	SET @sub_entity_id = 'select fas_subsidiary_id from fas_subsidiaries'
END

--print @sub_entity_id


SET @Sql_Where1 = ''
SET @Sql_Where2 = ''
SET @Sql_Where3d = ''
SET @Sql_Where3l = ''

--get only forward months
SET @Sql_Where1 = @Sql_Where1 + ' and term_month > ''' +  cast(@as_of_date as char) + ''''

SET @Sql_Where2 = @Sql_Where2 + ' and FS.hedge_type_value_id in (150, 151, 152)'


SET @Sql_From = ' FROM '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'report_measurement_values') + '  RMV INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id'	 				

-- select sub_entity_id, strategy_entity_id, book_entity_id, min(term_month) term_month from report_measurement_values
-- where as_of_date = '1/31/2003' 
-- group by sub_entity_id, strategy_entity_id, book_entity_id
DECLARE @next_month datetime
SET @next_month = dateadd(mm, 1, @as_of_date)
set @earnings_term_month = cast(Month(@next_month) as varchar)+ '/1/' + 
				cast(Year(@next_month) as varchar)

--select @earnings_term_month

SET @Sql_Select = '
insert INTO #temp_CASH_FLOW
SELECT   sub_entity_id, strategy_entity_id, book_entity_id, 
	CASE WHEN (FS.hedge_type_value_id = 152) THEN ''MTM'' ELSE ''Accrual'' END as accounting_type, '

set @Sql_Select = @Sql_Select + 	
			' CASE WHEN (''' + @report_type + ''' = ''e'' AND FS.hedge_type_value_id = 152) THEN
				 	CONVERT(DATETIME, ''' + @earnings_term_month  + ''', 102)
				ELSE term_month END AS term_month,
			  CASE WHEN (''' + @report_type + ''' = ''e'' AND FS.hedge_type_value_id = 152) THEN
				 	dbo.FNAGetTermGrouping(CONVERT(DATETIME, ''' + @earnings_term_month  + ''', 102), ''' + @granularity_type + ''')
				ELSE dbo.FNAGetTermGrouping(term_month, ''' + @granularity_type + ''') END AS term_group, '

--CONVERT(DATETIME, ''' + @earnings_term_month  + ''', 102)
--print @sql_select

If @discount_option = 'u'
	set @Sql_Select = @Sql_Select + 
                ' (ISNULL(u_hedge_st_asset, 0) + ISNULL(u_hedge_lt_asset, 0) - 
			ISNULL(u_hedge_st_liability, 0) - ISNULL(u_hedge_lt_liability, 0) +
		ISNULL(u_item_st_asset, 0) + ISNULL(u_item_lt_asset, 0) - 
			ISNULL(u_item_st_liability, 0) - ISNULL(u_item_lt_liability, 0)) as cfv'
ELSE
	set @Sql_Select = @Sql_Select + 
		' (ISNULL(d_hedge_st_asset, 0) + ISNULL(d_hedge_lt_asset, 0) - 
			ISNULL(d_hedge_st_liability, 0) - ISNULL(d_hedge_lt_liability, 0) +
		ISNULL(d_item_st_asset, 0) + ISNULL(d_item_lt_asset, 0) - 
			ISNULL(d_item_st_liability, 0) - ISNULL(d_item_lt_liability, 0))  as cfv'


SET @Sql_Where = ' WHERE    
		 	(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND   
	                 (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '

IF @strategy_entity_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
IF @book_entity_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '

	

EXEC (@Sql_Select + @Sql_From + @Sql_Where + @Sql_Where1 +  @Sql_Where2 )


If @summary_option = 'd' 
BEGIN
	set @Sql_Select = 'SELECT max(term_month) term_month, term_group Term, sub_entity_id Subsidiary, accounting_type Accounting, sum(cfv) value'
	set @group_by = 'term_group, sub_entity_id, accounting_type'
	set @order_by = 'max(term_month), sub_entity_id, accounting_type'
END
else
BEGIN
	set @Sql_Select = 'SELECT max(term_month) term_month, term_group Term, sub_entity_id Subsidiary, sum(cfv) value'
	set @group_by = 'term_group, sub_entity_id'
	set @order_by = 'max(term_month), sub_entity_id'
END

-- If @report_type = 'c' 
-- 	set @Sql_Select = @Sql_Select + ' Cashflow'
-- Else
-- 	set @Sql_Select = @Sql_Select + ' Earnings'

set @Sql_Select = 	@Sql_Select + 
			' FROM #temp_CASH_FLOW ' + 			
			' GROUP BY ' + @group_by 
-- 			+ 
-- 			' ORDER BY ' + @order_by

If @summary_option = 'd' 
	set @Sql_Select = 'SELECT v.Term, ph.entity_name Subsidiary, v.Accounting, v.value ' + 
		case when (@called_from_db = 1) then ', v.term_month ' else '' end + 
		case when (@report_type = 'e') then 'Earnings' else 'Cashflow' end
		+ ' from (' + @Sql_Select + ') v INNER JOIN portfolio_hierarchy ph ON ph.entity_id = v.Subsidiary' + 
		' order by v.term_month, v.Accounting, ph.entity_name' 
Else
	set @Sql_Select = 'SELECT v.Term, ph.entity_name Subsidiary, v.value ' + 
		case when (@called_from_db = 1) then ', v.term_month ' else '' end + 
		case when (@report_type = 'e') then 'Earnings' else 'Cashflow' end
		+ ' from (' + @Sql_Select + ') v INNER JOIN portfolio_hierarchy ph ON ph.entity_id = v.Subsidiary ' + 
		' order by v.term_month, ph.entity_name'

--print @Sql_Select
exec (@Sql_Select)

--select sum(cfv) from #temp_CASH_FLOW





