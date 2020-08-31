
/****** Object:  StoredProcedure [dbo].[spa_Create_Reconciliation_Report]    Script Date: 05/05/2009 10:16:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Create_Reconciliation_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_Reconciliation_Report]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spa_Create_Reconciliation_Report] @as_of_date varchar(50), @subsidiary_id varchar(MAX), 
 	@strategy_id varchar(MAX) = NULL, 
	@book_id varchar(MAX) = NULL, @discount_option char(1), 
	@hedge_type char(1), 
	@report_type char(1),
	@prior_months int = NULL,
    @use_prior_month_setl_values varchar(1) = 'y',
	@round_value CHAR(1) = '0',
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL,
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
 AS

 SET NOCOUNT ON

------------------TO TEST UNCOMMENT THIS
/*
declare @as_of_date varchar(50), @subsidiary_id varchar(100), 
		@strategy_id varchar(100), 
		@book_id varchar(100), @discount_option char(1), 
		@report_type char(1), @hedge_type char(1), 
		@prior_months int, @use_prior_month_setl_values varchar(1) 

SET @as_of_date = '2009-03-31' --'2004-12-31'
set @subsidiary_id =NULL
set @strategy_id = null
set @book_id  = null --223
set @discount_option ='u'
set @report_type ='s'
set @hedge_type ='c'
set @prior_months = 1
set @use_prior_month_setl_values = 'y'

drop table #books
drop table #pre
drop table #cur
drop table #item1
drop table #item2
drop table #item3
drop table #item4
drop table #item5
*/

-------END OF TESTING SCRIPTS
/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR (8000)
 
DECLARE @user_login_id VARCHAR (50)
 
DECLARE @sql_paging VARCHAR (8000)
 
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
 
SET @user_login_id = dbo.FNADBUser() 
 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
BEGIN 
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id) 
END

IF @enable_paging = 1 --paging processing 
BEGIN 
	IF @batch_process_id IS NULL 
	BEGIN
 		SET @batch_process_id = dbo.FNAGetNewID()
	END

	SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no)	
 
	--retrieve data from paging table instead of main table
 
	IF @page_no IS NOT NULL  
	BEGIN 
		SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no)  
		EXEC (@sql_paging)  
		RETURN  
	END 
END
 
/*******************************************1st Paging Batch END**********************************************/
DECLARE @beginning_date VARCHAR(20)

--COLLECT BOOKS
DECLARE @Sql_SelectB VARCHAR(5000)        
DECLARE @Sql_WhereB VARCHAR(5000)        
DECLARE @assignment_type int        
declare @desc varchar(250)
 
       
SET @Sql_WhereB = ''        

CREATE TABLE #books (fas_subsidiary_id int, fas_strategy_id int, fas_book_id int, hedge_type_value_id int, legal_entity_id int) 

SET @Sql_SelectB=        
'INSERT INTO  #books       
SELECT distinct stra.parent_entity_id, stra.entity_id, book.entity_id, fs.hedge_type_value_id, legal_entity
FROM portfolio_hierarchy book (nolock) INNER JOIN
		Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
		source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id LEFT OUTER JOIN
		fas_strategy fs ON fs.fas_strategy_id = book.parent_entity_id LEFT OUTER JOIN
		fas_books fb ON fb.fas_book_id = ssbm.fas_book_id
WHERE (ssbm.fas_deal_type_value_id = 400 OR 
				--(fs.hedge_type_value_id = 151 AND ssbm.fas_deal_type_value_id = 401) OR 
				  (ssbm.fas_deal_type_value_id = 401) OR 
				ssbm.fas_deal_type_value_id = 407)
'   
              
IF @subsidiary_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( ' + @subsidiary_id + ') '         
 IF @strategy_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN(' + @strategy_id + ' ))'        
 IF @book_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN(' + @book_id + ')) '        
        
SET @Sql_SelectB=@Sql_SelectB+@Sql_WhereB        
            
EXEC (@Sql_SelectB)

if @prior_months is null
	set @prior_months = 1

--if beginning date is null used the last run date as the beginning date
if @beginning_date is null
begin
	If @prior_months <> 0	
		select @beginning_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from 
			measurement_run_dates where as_of_date <= dbo.FNALastDayInDate(dateadd(mm, -1 * @prior_months, @as_of_date))
	Else
		SET @beginning_date = NULL
	IF @beginning_date IS NULL
		SET @beginning_date = '1900-01-01'
end

CREATE TABLE #pre(
	[deal_value] [float] NULL,
	[deal_item_value] [float] NULL,
	[u_aoci] [float] NULL,
	[u_aoci_released] [float] NULL,
	[u_pnl_ineffectiveness] [float] NULL,
	[u_pnl_mtm] [float] NULL,
	[aoci_to_be_released] [float] NULL,
	[u_pnl_ineff_to_be_released] [float] NULL,
	[u_pnl_mtm_to_be_released] [float] NULL,
	[u_item_mtm_to_be_released] [float] NULL,	
	[u_item_mtm_released] [float] NULL,
	[as_of_date] [datetime] NULL,
	[Sub] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Strategy] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Book] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[link_id] [int] NULL,
	[link_type] [varchar](10) COLLATE DATABASE_DEFAULT NULL,
	[source_deal_header_id] [int] NULL,
	[deal_id] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[deal_date] [datetime] NULL,
	[link_effective_date] [datetime] NULL,
	[term_start] [datetime] NULL,
	[hedge_or_item] [varchar](10) COLLATE DATABASE_DEFAULT NULL,
	[rel_id] [int] NULL,
	[pnl_as_of_date] [datetime] NULL,
	[und_pnl] [float] NULL,
	[und_pnl_rel] [float] NULL,
	[und_intrinsic_pnl] [float] NULL,
	[und_pnl_intrinsic_rel] [float] NULL,
	[und_pnl_extrinsic_rel] [float] NULL,
	[hedge_type_value_id] [int] NULL,
	[u_earning] [float] NULL,
	[discount_factor] [float] NULL,
	[currency_name] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[percentage_included] [float] NULL
)


CREATE TABLE #cur(
	[deal_value] [float] NULL,
	[deal_item_value] [float] NULL,
	[u_aoci] [float] NULL,
	[u_aoci_released] [float] NULL,
	[u_pnl_ineffectiveness] [float] NULL,
	[u_pnl_mtm] [float] NULL,
	[u_item_mtm_released] [float] NULL,
	[as_of_date] [datetime] NULL,
	[Sub] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Strategy] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Book] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[link_id] [int] NULL,
	[link_type] [varchar](10) COLLATE DATABASE_DEFAULT NULL,
	[source_deal_header_id] [int] NULL,
	[deal_id] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[deal_date] [datetime] NULL,
	[link_effective_date] [datetime] NULL,
	[term_start] [datetime] NULL,
	[hedge_or_item] [varchar](10) COLLATE DATABASE_DEFAULT NULL,
	[rel_id] [int] NULL,
	[pnl_as_of_date] [datetime] NULL,
	[und_pnl] [float] NULL,
	[und_pnl_rel] [float] NULL,
	[und_intrinsic_pnl] [float] NULL,
	[und_pnl_intrinsic_rel] [float] NULL,
	[und_pnl_extrinsic_rel] [float] NULL,
	[hedge_type_value_id] [int] NULL,
	[u_earning] [float] NULL,
	[discount_factor] [float] NULL,
	[currency_name] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[percentage_included] [float] NULL
) 

DECLARE @sql_str varchar(8000)

set @sql_str ='
insert into #pre
select 
	case when (hedge_or_item = ''h'') then
		u_aoci - isnull(ar.aoci_released, 0) + 
		case when(cd.term_start < ''' + @beginning_date + ''') then 0 else u_pnl_ineffectiveness + u_extrinsic_pnl + u_pnl_mtm end 
	else 0 end deal_value,
	case when (hedge_or_item = ''i'' AND cd.term_start > ''' + @beginning_date + ''') then final_und_pnl_remaining else 0 end deal_item_value,
	u_aoci - isnull(ar.aoci_released, 0) u_aoci,
	isnull(ar.aoci_released, 0) u_aoci_released,
	case when(cd.term_start < ''' + @beginning_date + ''') then 0 else u_pnl_ineffectiveness end u_pnl_ineffectiveness,
	case when(cd.term_start < ''' + @beginning_date + ''') then 0 else u_extrinsic_pnl + u_pnl_mtm end u_pnl_mtm, 

	-1*isnull(atbr.aoci_released, 0) aoci_to_be_released,
	case when(cd.term_start > ''' + @beginning_date + ''' AND cd.term_start <= ''' + @as_of_date + ''') then -1*u_pnl_ineffectiveness else 0 end u_pnl_ineff_to_be_released,
	case when(cd.term_start > ''' + @beginning_date + ''' AND cd.term_start <= ''' + @as_of_date + ''') then (-1*u_extrinsic_pnl) + (-1*u_pnl_mtm) else 0 end u_pnl_mtm_to_be_released,
	case when(cd.term_start > ''' + @beginning_date + ''' AND cd.term_start <= ''' + @as_of_date + ''') then final_und_pnl_remaining else 0 end u_item_mtm_to_be_released,
	case when(cd.term_start < ''' + @beginning_date + ''') then final_und_pnl_remaining else 0 end u_item_mtm_released,

	cd.as_of_date, sub.entity_name Sub, stra.entity_name Strategy, book.entity_name Book, 
	cd.link_id, cd.link_type, cd.source_deal_header_id, cd.deal_id, cd.deal_date deal_date, 
	cd.link_effective_date link_effective_date, cd.term_start term_start, 
	case when(hedge_or_item = ''h'') then ''Der'' else ''Item'' end hedge_or_item, 
	cd.link_id rel_id, pnl_as_of_date pnl_as_of_date, und_pnl, final_und_pnl_remaining und_pnl_rel, und_intrinsic_pnl, 
	final_und_pnl_intrinsic_remaining und_pnl_intrinsic_rel, final_und_pnl_extrinsic_remaining und_pnl_extrinsic_rel, 
	sdv_ht.value_id hedge_type_value_id,
	u_pnl_ineffectiveness u_earning, cd.discount_factor, scu.currency_name, cd.percentage_included
from #books b inner join '
+ dbo.FNAGetProcessTableName(@beginning_date, 'calcprocess_deals') + ' cd ON cd.fas_book_id = b.fas_book_id inner join 
portfolio_hierarchy sub on sub.entity_id = cd.fas_subsidiary_id inner join 
portfolio_hierarchy stra on stra.entity_id = cd.fas_strategy_id inner join 
portfolio_hierarchy book on book.entity_id = cd.fas_book_id inner join 
fas_strategy fs ON fs.fas_strategy_id  = stra.entity_id inner join
source_counterparty sc on sc.source_counterparty_id = cd.source_counterparty_id left outer join 
source_counterparty nsc on nsc.source_counterparty_id = sc.netting_parent_counterparty_id left outer join 
static_data_value sdv_et on sdv_et.value_id = sc.type_of_entity left outer join 
source_uom su on su.source_uom_id = cd.deal_volume_uom_id left outer join source_deal_type sdt on sdt.source_deal_type_id = cd.deal_type left outer join 
source_deal_type sdts on sdt.source_deal_type_id = cd.deal_sub_type left outer join source_price_curve_def spcd on spcd.source_curve_def_id = cd.curve_id left outer join 
source_currency scu on scu.source_currency_id = cd.pnl_currency_id left outer join 
fas_eff_hedge_rel_type fehrt on fehrt.eff_test_profile_id = cd.eff_test_profile_id left outer join 
static_data_value sdv_lt on sdv_lt.value_id = cd.link_type_value_id left outer join 
static_data_value sdv_ht on sdv_ht.value_id = fs.hedge_type_value_id left outer join 
(select as_of_date, link_id, source_deal_header_id, h_term, 
sum(case when (rollout_per_type in (520, 522)) then isnull(aoci_allocation_vol, 0) else isnull(aoci_allocation_pnl, 0) end) aoci_released 
from ' + dbo.FNAGetProcessTableName(@beginning_date, 'calcprocess_aoci_release') + ' car 
where as_of_date = ''' + @beginning_date + ''' and i_term <= ''' + @beginning_date + ''' 
group by as_of_date, link_id, source_deal_header_id, h_term) ar ON 
ar.as_of_date = cd.as_of_date and ar.link_id = cd.link_id and cd.link_type = ''link'' and ar.source_deal_header_id = cd.source_deal_header_id and 
ar.h_term = cd.term_start LEFT OUTER JOIN
(select as_of_date, link_id, source_deal_header_id, h_term, 
sum(case when (rollout_per_type in (520, 522)) then isnull(aoci_allocation_vol, 0) else isnull(aoci_allocation_pnl, 0) end) aoci_released 
from ' + dbo.FNAGetProcessTableName(@beginning_date, 'calcprocess_aoci_release') + '  car 
where as_of_date = ''' + @beginning_date + ''' and i_term > ''' + @beginning_date + ''' AND i_term <= ''' + @as_of_date + ''' 
group by as_of_date, link_id, source_deal_header_id, h_term) atbr ON 
atbr.as_of_date = cd.as_of_date and atbr.link_id = cd.link_id and cd.link_type = ''link'' and atbr.source_deal_header_id = cd.source_deal_header_id and 
atbr.h_term = cd.term_start
where cd.calc_type = ''m'' AND cd.as_of_date = ''' + @beginning_date + ''' AND (cd.hedge_type_value_id = 151 OR (cd.hedge_or_item = ''h'' AND cd.hedge_type_value_id <> 151))
AND fs.hedge_type_value_id = case ''' + @hedge_type + ''' when ''c'' then 150 when ''f'' then 151 else 152 end
ORDER BY cd.source_deal_header_id, cd.term_start
'

exec(@sql_str)

set @sql_str ='
insert into #cur
select 
	case when (hedge_or_item = ''h'') then
		u_aoci - isnull(ar.aoci_released, 0) + 
		case when(cd.term_start < ''' + @as_of_date + ''') then 0 else u_pnl_ineffectiveness + u_extrinsic_pnl + u_pnl_mtm end 
	else 0 end deal_value,
	case when (hedge_or_item = ''i'' AND cd.term_start > ''' + @as_of_date + ''') then final_und_pnl_remaining else 0 end deal_item_value,
	u_aoci - isnull(ar.aoci_released, 0) u_aoci,
	isnull(ar.aoci_released, 0) u_aoci_released,
	case when(cd.term_start < ''' + @as_of_date + ''') then 0 else u_pnl_ineffectiveness end u_pnl_ineffectiveness,
	case when(cd.term_start < ''' + @as_of_date + ''') then 0 else u_extrinsic_pnl + u_pnl_mtm end u_pnl_mtm, 
	case when(cd.term_start < ''' + @as_of_date + ''') then final_und_pnl_remaining else 0 end u_item_mtm_released,

	cd.as_of_date, sub.entity_name Sub, stra.entity_name Strategy, book.entity_name Book, 
	cd.link_id, cd.link_type, cd.source_deal_header_id, cd.deal_id, cd.deal_date deal_date, 
	cd.deal_date link_effective_date, cd.term_start term_start, 
	case when(hedge_or_item = ''h'') then ''Der'' else ''Item'' end hedge_or_item, 
	cd.link_id rel_id, pnl_as_of_date pnl_as_of_date, und_pnl, final_und_pnl_remaining und_pnl_rel, und_intrinsic_pnl, 
	final_und_pnl_intrinsic_remaining und_pnl_intrinsic_rel, final_und_pnl_extrinsic_remaining und_pnl_extrinsic_rel, 
	sdv_ht.value_id hedge_type_value_id,
	u_pnl_ineffectiveness u_earning, cd.discount_factor, scu.currency_name, cd.percentage_included
from #books b inner join  '
+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + '  cd ON cd.fas_book_id = b.fas_book_id inner join 
portfolio_hierarchy sub on sub.entity_id = cd.fas_subsidiary_id inner join 
portfolio_hierarchy stra on stra.entity_id = cd.fas_strategy_id inner join 
portfolio_hierarchy book on book.entity_id = cd.fas_book_id inner join 
fas_strategy fs ON fs.fas_strategy_id  = stra.entity_id inner join
source_counterparty sc on sc.source_counterparty_id = cd.source_counterparty_id left outer join 
source_counterparty nsc on nsc.source_counterparty_id = sc.netting_parent_counterparty_id left outer join 
static_data_value sdv_et on sdv_et.value_id = sc.type_of_entity left outer join 
source_uom su on su.source_uom_id = cd.deal_volume_uom_id left outer join source_deal_type sdt on sdt.source_deal_type_id = cd.deal_type left outer join 
source_deal_type sdts on sdt.source_deal_type_id = cd.deal_sub_type left outer join source_price_curve_def spcd on spcd.source_curve_def_id = cd.curve_id left outer join 
source_currency scu on scu.source_currency_id = cd.pnl_currency_id left outer join 
fas_eff_hedge_rel_type fehrt on fehrt.eff_test_profile_id = cd.eff_test_profile_id left outer join 
static_data_value sdv_lt on sdv_lt.value_id = cd.link_type_value_id left outer join 
static_data_value sdv_ht on sdv_ht.value_id = fs.hedge_type_value_id left outer join 
(select as_of_date, link_id, source_deal_header_id, h_term, 
sum(case when (rollout_per_type in (520, 522)) then isnull(aoci_allocation_vol, 0) else isnull(aoci_allocation_pnl, 0) end) aoci_released 
from ' + dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_aoci_release') + '  car 
where as_of_date = ''' + @as_of_date + ''' and i_term <= ''' + @as_of_date + ''' 
group by as_of_date, link_id, source_deal_header_id, h_term) ar ON 
ar.as_of_date = cd.as_of_date and ar.link_id = cd.link_id and cd.link_type = ''link'' and ar.source_deal_header_id = cd.source_deal_header_id and 
ar.h_term = cd.term_start 

where cd.calc_type = ''m'' AND cd.as_of_date = ''' + @as_of_date + ''' AND (cd.hedge_type_value_id = 151 OR (cd.hedge_or_item = ''h'' AND cd.hedge_type_value_id <> 151))
AND fs.hedge_type_value_id = case ''' + @hedge_type + ''' when ''c'' then 150 when ''f'' then 151 else 152 end

ORDER BY cd.source_deal_header_id, cd.term_start
'

--print @sql_str
exec(@sql_str)

DECLARE @label1 varchar(250), @label2 varchar(250), @label3 varchar(250), @label4 varchar(250), @label5 varchar(250)
DECLARE @round int
set @round = 4
set @label1 = 'Beginning net positions at beginning date (' + dbo.FNADateFormat(@beginning_date) + '): ' 
set @label2 = 'Settlements of position included in the opening balance: '
set @label3 = 'New positions added during the period: '
set @label4 = 'Changes in value of existing positions during the period: '
set @label5 = 'Ending net positions at end date (' + dbo.FNADateFormat(@as_of_date) + '): ' 


select	1 No, @label1 Item,
		link_id, link_type, Sub, Strategy, Book, term_start, 
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * deal_value) [Hedge Value],
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * deal_item_value) [Item Value], 
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_aoci) AOCI,
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_ineffectiveness) [PNL Ineff], 
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_mtm) [PNL MTM], 
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_ineffectiveness) + 
			sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_mtm) [Total PNL]
into #item1
from #pre
group by link_id, link_type, Sub, Strategy, Book, term_start

CREATE TABLE #item2(
	[No] [int] NOT NULL,
	[Item] [varchar](250) COLLATE DATABASE_DEFAULT NULL,
	[link_id] [int] NULL,
	[link_type] [varchar](10) COLLATE DATABASE_DEFAULT NULL,
	[Sub] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Strategy] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Book] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[term_start] [datetime] NULL,
	[Hedge Value] [float] NULL,
	[Item Value] [float] NULL,
	[AOCI] [float] NULL,
	[PNL Ineff] [float] NULL,
	[PNL MTM] [float] NULL,
	[Total PNL] [float] NULL
)

IF @use_prior_month_setl_values = 'y'
BEGIN
	set @sql_str = 
	'
	insert into #item2
	select	2 No, ''' + @label2 + ''' Item,
			rmv.link_id, case when (rmv.link_deal_flag = ''d'') then ''deal'' else ''link'' end link_type, 
			sub.entity_name Sub, stra.entity_name Strategy, book.entity_name Book,
			rmv.term_month term_start, 
			-1 * (rmv.u_total_aoci + rmv.u_total_pnl) [Hedge Value],
			-1 * rmv.u_item_mtm [Item Value],
			-1 * rmv.u_total_aoci AOCI,
			-1 * rmv.u_pnl_ineffectiveness as [PNL Ineff],
			-1 * (rmv.u_total_pnl -  rmv.u_pnl_ineffectiveness) [PNL MTM],
			-1 * rmv.u_total_pnl [Total PNL]
	from #books b INNER JOIN
		 ' + dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + ' rmv ON rmv.book_entity_id = b.fas_book_id INNER JOIN
		 fas_strategy fs ON fs.fas_strategy_id  = rmv.strategy_entity_id INNER JOIN
		 portfolio_hierarchy sub on sub.entity_id = rmv.sub_entity_id INNER JOIN 
		 portfolio_hierarchy stra on stra.entity_id = rmv.strategy_entity_id INNER JOIN 
		 portfolio_hierarchy book on book.entity_id = rmv.book_entity_id 

	WHERE rmv.as_of_date = ''' + @beginning_date + '''
	AND fs.hedge_type_value_id = case ''' + @hedge_type + ''' when ''c'' then 150 when ''f'' then 151 else 152 end
	AND rmv.term_month > ''' + @beginning_date + ''' AND rmv.term_month <= ''' + @as_of_date + ''''

END
ELSE
BEGIN
	set @sql_str = 
	'
	insert into #item2
	select	2 No, ''' + @label2 + ''' Item,
			coalesce(pset.link_id, cset.link_id) link_id, 
			coalesce(pset.link_type, cset.link_type) link_type, 
			coalesce(pset.Sub, cset.Sub) Sub, 
			coalesce(pset.Strategy, cset.Strategy) Strategy, 
			coalesce(pset.Book, cset.Book) Book, 
			coalesce(pset.term_start, cset.term_start) term_start, 
			-1 * (isnull(cset.[Hedge Value], 0) - isnull(pset.[Hedge Value], 0)) [Hedge Value],
			-1 * (isnull(cset.[Item Value], 0) - isnull(pset.[Item Value], 0)) [Item Value],
			-1 * (isnull(cset.[AOCI], 0) - isnull(pset.[AOCI], 0)) [AOCI],
			-1 * (isnull(cset.[PNL Ineff], 0) - isnull(pset.[PNL Ineff], 0)) [PNL Ineff],
			-1 * (isnull(cset.[PNL MTM], 0) - isnull(pset.[PNL MTM], 0)) [PNL MTM],
			-1 * (isnull(cset.[PNL MTM], 0) - isnull(pset.[PNL MTM], 0)) [Total PNL]
	FROM
	(
	select	rmv.link_id, case when (rmv.link_deal_flag = ''d'') then ''deal'' else ''link'' end link_type, 
			sub.entity_name Sub, stra.entity_name Strategy, book.entity_name Book,
			rmv.term_month term_start, 
			rmv.u_pnl_settlement [Hedge Value],
			rmv.u_item_mtm [Item Value],
			rmv.u_aoci_released AOCI,
			0 as [PNL Ineff],
			rmv.u_pnl_settlement - rmv.u_aoci_released [PNL MTM],
			rmv.u_pnl_settlement [Total PNL]
	from 
	(
	select rmv.* from 
	#books b INNER JOIN
	' + dbo.FNAGetProcessTableName(@beginning_date, 'report_measurement_values') + ' rmv ON rmv.book_entity_id = b.fas_book_id INNER JOIN
	fas_strategy fs ON fs.fas_strategy_id  = rmv.strategy_entity_id 
	WHERE rmv.as_of_date = ''' + @beginning_date + '''
	AND fs.hedge_type_value_id = case ''' + @hedge_type + ''' when ''c'' then 150 when ''f'' then 151 else 152 end
	UNION
	select rmv.* 
	from #books b INNER JOIN
	report_measurement_values_expired rmv ON rmv.book_entity_id = b.fas_book_id INNER JOIN
	fas_strategy fs ON fs.fas_strategy_id  = rmv.strategy_entity_id 
	WHERE rmv.as_of_date < ''' + @beginning_date + '''
	AND fs.hedge_type_value_id = case ''' + @hedge_type + ''' when ''c'' then 150 when ''f'' then 151 else 152 end
	) rmv INNER JOIN
	portfolio_hierarchy sub on sub.entity_id = rmv.sub_entity_id INNER JOIN 
	portfolio_hierarchy stra on stra.entity_id = rmv.strategy_entity_id INNER JOIN 
	portfolio_hierarchy book on book.entity_id = rmv.book_entity_id 
	 ) pset FULL OUTER JOIN ' + 
	'
	(
	select	rmv.link_id, case when (rmv.link_deal_flag = ''d'') then ''deal'' else ''link'' end link_type, 
			sub.entity_name Sub, stra.entity_name Strategy, book.entity_name Book,
			rmv.term_month term_start, 
			rmv.u_pnl_settlement [Hedge Value],
			rmv.u_item_mtm [Item Value],
			rmv.u_aoci_released AOCI,
			0 as [PNL Ineff],
			rmv.u_pnl_settlement - rmv.u_aoci_released [PNL MTM],
			rmv.u_pnl_settlement [Total PNL]
	from 
	(
	select rmv.* from 
	#books b INNER JOIN
	report_measurement_values rmv ON rmv.book_entity_id = b.fas_book_id INNER JOIN
	fas_strategy fs ON fs.fas_strategy_id  = rmv.strategy_entity_id 
	WHERE rmv.as_of_date = ''' + @as_of_date + '''
	AND fs.hedge_type_value_id = case ''' + @hedge_type + ''' when ''c'' then 150 when ''f'' then 151 else 152 end
	UNION
	select rmv.* 
	from #books b INNER JOIN
	report_measurement_values_expired rmv ON rmv.book_entity_id = b.fas_book_id INNER JOIN
	fas_strategy fs ON fs.fas_strategy_id  = rmv.strategy_entity_id 
	WHERE rmv.as_of_date < ''' + @as_of_date + '''
	AND fs.hedge_type_value_id = case ''' + @hedge_type + ''' when ''c'' then 150 when ''f'' then 151 else 152 end
	) rmv INNER JOIN
	portfolio_hierarchy sub on sub.entity_id = rmv.sub_entity_id INNER JOIN 
	portfolio_hierarchy stra on stra.entity_id = rmv.strategy_entity_id INNER JOIN 
	portfolio_hierarchy book on book.entity_id = rmv.book_entity_id 
	) cset ON pset.link_id = cset.link_id AND pset.link_type = cset.link_type AND pset.term_start = cset.term_start
	'
END

--print @sql_str
exec (@sql_str)

select	3 No, @label3 Item,
		link_id, link_type, Sub, Strategy, Book, term_start, 
		isnull(sum(case when (@discount_option = 'u') then 1 else discount_factor end * deal_value), 0) [Hedge Value], 
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * deal_item_value) [Item Value], 
		isnull(sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_aoci), 0) AOCI,
		isnull(sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_ineffectiveness), 0) [PNL Ineff], 
		isnull(sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_mtm), 0) [PNL MTM], 
		isnull(sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_ineffectiveness), @round) + 
			isnull(sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_mtm), 0) [Total PNL]
into #item3
from #cur
WHERE link_effective_date > @beginning_date
group by link_id, link_type, Sub, Strategy, Book, term_start

select	5 No, @label5 Item,
		link_id, link_type, Sub, Strategy, Book, term_start, 
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * deal_value) [Hedge Value], 
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * deal_item_value) [Item Value], 
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_aoci) AOCI,
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_ineffectiveness) [PNL Ineff], 
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_mtm) [PNL MTM], 
		sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_ineffectiveness) +  
			sum(case when (@discount_option = 'u') then 1 else discount_factor end * u_pnl_mtm) [Total PNL]
into #item5
from #cur
group by link_id, link_type, Sub, Strategy, Book, term_start


SELECT	4 No, @label4 Item, 
		coalesce(i5.link_id, i1.link_id, i2.link_id, i3.link_id) link_id, 
		coalesce(i5.link_type, i1.link_type, i2.link_type, i3.link_type) link_type, 
		coalesce(i5.Sub, i1.Sub, i2.Sub, i3.Sub) Sub, 
		coalesce(i5.Strategy, i1.Strategy, i2.Strategy, i3.Strategy) Strategy, 
		coalesce(i5.Book, i1.Book, i2.Book, i3.Book) Book, 
		coalesce(i5.term_start, i1.term_start, i2.term_start, i3.term_start) term_start, 
		isnull(i5.[Hedge Value], 0) - (isnull(i1.[Hedge Value], 0) + isnull(i2.[Hedge Value], 0) + isnull(i3.[Hedge Value], 0)) [Hedge Value],	
		isnull(i5.[Item Value], 0) - (isnull(i1.[Item Value], 0) + isnull(i2.[Item Value], 0) + isnull(i3.[Item Value], 0)) [Item Value],	
		isnull(i5.[AOCI], 0) - (isnull(i1.[AOCI], 0) + isnull(i2.[AOCI], 0) + isnull(i3.[AOCI], 0)) [AOCI],	
		isnull(i5.[PNL Ineff], 0) - (isnull(i1.[PNL Ineff], 0) + isnull(i2.[PNL Ineff], 0) + isnull(i3.[PNL Ineff], 0)) [PNL Ineff],
		isnull(i5.[PNL MTM], 0) - (isnull(i1.[PNL MTM], 0) + isnull(i2.[PNL MTM], 0) + isnull(i3.[PNL MTM], 0)) [PNL MTM],	
		isnull(i5.[Total PNL], 0) - (isnull(i1.[Total PNL], 0) + isnull(i2.[Total PNL], 0) + isnull(i3.[Total PNL], 0)) [Total PNL]	
into #item4
FROM #item5 i5 FULL OUTER JOIN
	 #item1 i1 ON i5.link_id = i1.link_id AND i5.link_type = i1.link_type AND i5.term_start = i1.term_start FULL OUTER JOIN	
	 #item2 i2 ON i5.link_id = i2.link_id AND i5.link_type = i2.link_type AND i5.term_start = i2.term_start FULL OUTER JOIN	
	 #item3 i3 ON i5.link_id = i3.link_id AND i5.link_type = i3.link_type AND i5.term_start = i3.term_start

DECLARE @select_sql varchar(1000)
DECLARE @group_sql varchar(1000)

DECLARE @final_sql varchar(8000)


if @hedge_type = 'c'
begin
		IF @report_type = 'a'
		BEGIN
			EXEC('SELECT [S.N.], Sub as Subsidiary, Items, CAST(CAST ([Hedge Value] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Hedge Value], CAST(CAST (AOCI AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AOCI, CAST (CAST ([PNL Ineff] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [PNL Ineff],CAST(CAST ([PNL MTM] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [PNL MTM],CAST(CAST ([Total PNL] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [Total PNL] ' + @str_batch_table + ' FROM (
			select  Sub, No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item1
			group by No, Sub
			UNION
			select Sub, No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item2
			group by No, Sub
			UNION
			select Sub, No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item3
			group by No, Sub
			UNION
			select Sub, No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item4
			group by No, Sub
			UNION
			select Sub, No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item5
			group by No, Sub) a ')
		END
		ELSE IF @report_type = 'b'
		BEGIN			
			EXEC('SELECT [S.N.], Sub as Subsidiary, Items, CAST(CAST ([Hedge Value] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Hedge Value], CAST(CAST (AOCI AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AOCI, CAST (CAST ([PNL Ineff] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [PNL Ineff],CAST(CAST ([PNL MTM] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [PNL MTM],CAST(CAST ([Total PNL] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [Total PNL] ' + @str_batch_table + ' FROM (
			select Sub, Strategy, No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item1
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item2
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item3
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item4
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item5
			group by No, Sub, Strategy) a')

		END
		ELSE IF @report_type = 'c'
		BEGIN
			EXEC('SELECT [S.N.], Sub as Subsidiary, Strategy, Book, Items, CAST(CAST ([Hedge Value] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Hedge Value], CAST(CAST (AOCI AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AOCI, CAST (CAST ([PNL Ineff] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [PNL Ineff],CAST(CAST ([PNL MTM] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [PNL MTM],CAST(CAST ([Total PNL] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [Total PNL] ' + @str_batch_table + ' FROM (
			select Sub, Strategy, Book, No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item1
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item2
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item3
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item4
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item5
			group by No, Sub, Strategy, Book) a')

		END
		ELSE IF @report_type = 'd'
		BEGIN
			EXEC ('SELECT [S.N.], Subsidiary, Strategy, Book, Items, ID, [Group], Term, CAST(CAST ([Hedge Value] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Hedge Value], CAST(CAST (AOCI AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AOCI, CAST (CAST ([PNL Ineff] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [PNL Ineff],CAST(CAST ([PNL MTM] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [PNL MTM],CAST(CAST ([Total PNL] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [Total PNL] ' + @str_batch_table + ' FROM (
			select No as [S.N.], Sub as Subsidiary, Strategy, Book, ''' + @label1 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item1
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select No, Sub, Strategy, Book, ''' + @label2 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item2
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select No, Sub, Strategy, Book, ''' + @label3 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item3
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select No, Sub, Strategy, Book, ''' + @label4 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item4
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select No, Sub, Strategy, Book, ''' + @label5 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item5
			group by No, Sub, Strategy, Book, link_id, link_type, term_start) a')
		END
		ELSE
		BEGIN
			EXEC('SELECT [S.N.], Items , CAST(CAST ([Hedge Value] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Hedge Value], CAST(CAST (AOCI AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AOCI, CAST (CAST ([PNL Ineff] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [PNL Ineff],CAST(CAST ([PNL MTM] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [PNL MTM],CAST(CAST ([Total PNL] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [Total PNL] ' + @str_batch_table + ' FROM (
			select No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item1
			group by No
			UNION
			select No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item2
			group by No
			UNION
			select No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item3
			group by No
			UNION
			select No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item4
			group by No
			UNION
			select No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Hedge Value], sum(AOCI) AOCI, sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item5
			group by No) a')
		END
end
else if @hedge_type = 'f'
begin

		IF @report_type = 'a'
		BEGIN
			EXEC('SELECT [S.N.], Sub as Subsidiary, Items, CAST(CAST ([Hedge Value] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Hedge Value], CAST ([Item Value] AS NUMERIC(38,' + @round_value + ')) [Item Value], CAST (CAST ([PNL Ineff] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [PNL Ineff],CAST(CAST ([PNL MTM] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [PNL MTM],CAST(CAST ([Total PNL] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [Total PNL] ' + @str_batch_table + ' FROM (
			select Sub, No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item1
			group by No, Sub
			UNION
			select Sub, No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item2
			group by No, Sub
			UNION
			select Sub, No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item3
			group by No, Sub
			UNION
			select Sub, No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item4
			group by No, Sub
			UNION
			select Sub, No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item5
			group by No, Sub) a')
		END
		ELSE IF @report_type = 'b'
		BEGIN
			EXEC('SELECT [S.N.] , Sub as Subsidiary, Strategy, Items, CAST(CAST ([Hedge Value] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Hedge Value], CAST ([Item Value] AS NUMERIC(38,' + @round_value + ')) [Item Value], CAST (CAST ([PNL Ineff] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [PNL Ineff],CAST(CAST ([PNL MTM] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [PNL MTM],CAST(CAST ([Total PNL] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [Total PNL] ' + @str_batch_table + ' FROM (
			select Sub, Strategy, No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item1
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item2
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item3
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item4
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item5
			group by No, Sub, Strategy) a')
		END
		ELSE IF @report_type = 'c'
		BEGIN
			EXEC('SELECT [S.N.], Sub as Subsidiary, Strategy, Book, Items, CAST(CAST ([Hedge Value] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Hedge Value], CAST ([Item Value] AS NUMERIC(38,' + @round_value + ')) [Item Value], CAST (CAST ([PNL Ineff] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [PNL Ineff],CAST(CAST ([PNL MTM] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [PNL MTM],CAST(CAST ([Total PNL] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [Total PNL] ' + @str_batch_table + ' FROM (
			select Sub, Strategy, Book, No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item1
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item2
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item3
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item4
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item5
			group by No, Sub, Strategy, Book) a')
		END
		ELSE IF @report_type = 'd'
		BEGIN
			EXEC('SELECT [S.N.], Sub as Subsidiary, Strategy, Book, Items, ID, [Group], Term, CAST(CAST ([Hedge Value] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Hedge Value], CAST ([Item Value] AS NUMERIC(38,' + @round_value + ')) [Item Value], CAST (CAST ([PNL Ineff] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [PNL Ineff],CAST(CAST ([PNL MTM] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [PNL MTM],CAST(CAST ([Total PNL] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [Total PNL] ' + @str_batch_table + ' FROM (
			select No as [S.N.], Sub, Strategy, Book, ''' + @label1 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item1
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select No, Sub, Strategy, Book, ''' + @label2 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item2
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select No, Sub, Strategy, Book, ''' + @label3 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item3
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select No, Sub, Strategy, Book, ''' + @label4 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item4
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select No, Sub, Strategy, Book, ''' + @label5 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item5
			group by No, Sub, Strategy, Book, link_id, link_type, term_start) a')
		END
		ELSE
		BEGIN
			EXEC('SELECT [S.N.], Items, CAST(CAST ([Hedge Value] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Hedge Value], CAST ([Item Value] AS NUMERIC(38,' + @round_value + ')) [Item Value], CAST (CAST ([PNL Ineff] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [PNL Ineff],CAST(CAST ([PNL MTM] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [PNL MTM],CAST(CAST ([Total PNL] AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100))  [Total PNL] ' + @str_batch_table + ' FROM (
			select No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item1
			group by No
			UNION
			select No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item2
			group by No
			UNION
			select No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item3
			group by No
			UNION
			select No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item4
			group by No
			UNION
			select No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Hedge Value], sum([Item Value]) [Item Value], sum([PNL Ineff]) [PNL Ineff], sum([PNL MTM]) [PNL MTM], sum([Total PNL]) [Total PNL]
			from #item5
			group by No) a')
		END

end
else
begin

		IF @report_type = 'a'
		BEGIN
			EXEC('SELECT [S.N.],  Sub as Subsidiary, Items, CAST ([Total Amount] AS NUMERIC(38,' + @round_value + ')) [Total Amount] ' + @str_batch_table + ' FROM (
			select Sub, No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item1
			group by No, Sub
			UNION
			select Sub, No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item2
			group by No, Sub
			UNION
			select Sub, No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item3
			group by No, Sub
			UNION
			select Sub, No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item4
			group by No, Sub
			UNION
			select Sub, No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item5
			group by No, Sub) a')
		END
		ELSE IF @report_type = 'b'
		BEGIN
			EXEC('SELECT [S.N.], Sub as Subsidiary, Strategy, Items, CAST ([Total Amount] AS NUMERIC(38,' + @round_value + ')) [Total Amount] ' + @str_batch_table + ' FROM (
			select Sub, Strategy, No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item1
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item2
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item3
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item4
			group by No, Sub, Strategy
			UNION
			select Sub, Strategy, No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item5
			group by No, Sub, Strategy) a')
		END
		ELSE IF @report_type = 'c'
		BEGIN
			EXEC('SELECT [S.N.], Sub as Subsidiary, Strategy, Book, Items, CAST ([Total Amount] AS NUMERIC(38,' + @round_value + ')) [Total Amount] ' + @str_batch_table + ' FROM (
			select Sub, Strategy, Book, No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item1
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item2
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item3
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item4
			group by No, Sub, Strategy, Book
			UNION
			select Sub, Strategy, Book, No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Total Amount]
			from #item5
			group by No, Sub, Strategy, Book) a')
		END
		ELSE IF @report_type = 'd'
		BEGIN
			EXEC('SELECT [S.N.], Sub as Subsidiary, Strategy, Book, Items, ID, [Group], Term, CAST ([Total Amount] AS NUMERIC(38,' + @round_value + ')) [Total Amount] ' + @str_batch_table + ' FROM (
			select Sub, Strategy, Book, No as [S.N.], ''' + @label1 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Total Amount]
			from #item1
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select Sub, Strategy, Book, No, ''' + @label2 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Total Amount]
			from #item2
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select Sub, Strategy, Book, No, ''' + @label3 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Total Amount]
			from #item3
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select Sub, Strategy, Book, No, ''' + @label4 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Total Amount]
			from #item4
			group by No, Sub, Strategy, Book, link_id, link_type, term_start
			UNION
			select Sub, Strategy, Book, No, ''' + @label5 + ''' Items, link_id ID, link_type [Group], dbo.FNADateFormat(term_start) Term, sum([Hedge Value]) [Total Amount]
			from #item5
			group by No, Sub, Strategy, Book, link_id, link_type, term_start) a ')
		END
		ELSE
		BEGIN
			DECLARE @sql1 VARCHAR(MAX)
			SET @sql1 = 'SELECT [S.N.], Items, CAST ([Total Amount] AS NUMERIC(38,' + ISNULL(@round_value, 0) + ')) [Total Amount] ' + @str_batch_table + ' FROM (
							select No as [S.N.], ''' + @label1 + ''' Items, sum([Hedge Value]) [Total Amount]
							from #item1
							group by No
							UNION
							select No, ''' + @label2 + ''' Items, sum([Hedge Value]) [Total Amount]
							from #item2
							group by No
							UNION
							select No, ''' + @label3 + ''' Items, sum([Hedge Value]) [Total Amount]
							from #item3
							group by No
							UNION
							select No, ''' + @label4 + ''' Items, sum([Hedge Value]) [Total Amount]
							from #item4
							group by No
							UNION
							select No, ''' + @label5 + ''' Items, sum([Hedge Value]) [Total Amount]
							from #item5
							group by No) a'
			EXEC(@sql1)
		END
end

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
IF @is_batch = 1 
BEGIN 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)  
	EXEC (@str_batch_table) 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_Create_Reconciliation_Report', 'Period Change Values Report') --TODO: modify sp and report name 
	EXEC (@str_batch_table) 
	RETURN 
END

IF @enable_paging = 1 AND @page_no IS NULL 
BEGIN 
	SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no) 
	EXEC (@sql_paging) 
END

/*******************************************2nd Paging Batch END**********************************************/
 
GO