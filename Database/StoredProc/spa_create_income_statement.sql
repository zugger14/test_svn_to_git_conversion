
IF OBJECT_ID(N'spa_create_income_statement', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_create_income_statement]
 GO 






--EXEC spa_create_income_statement '2004-08-30','1',NULL,NULL,'d','a',1,'s',NULL,153
--EXEC spa_create_income_statement '2004-08-30','1',NULL,NULL,'d','m',1,'s'
--EXEC spa_create_income_statement '2004-08-30','1',NULL,NULL,'d','f',1,'s'

create procedure [dbo].[spa_create_income_statement] @as_of_date varchar(50), @sub_id varchar(100), 
	@strategy_id varchar(100) = NULL, 
	@book_id varchar(100) = NULL, @discount_option char(1), 
	@report_type char(1),
	@prior_months int = NULL,
	@summary_option char(1)=NULL,
	@netting_parent_group_id varchar(100)=NULL,
	@link_id varchar(100)=NULL

as

-- drop table #temp_sub
-- Declare @sub_id varchar(100) 
-- Declare	@strategy_id varchar(100)      
-- Declare	@book_id varchar(100)
-- Declare	@as_of_date varchar(100)
-- Declare	@discount_option varchar(100)
-- Declare	@report_type varchar(100)
-- Declare	@prior_months int
-- Declare	@summary_option varchar(100)
-- Declare	@netting_parent_group_id varchar(100)
-- Declare	@link_id varchar(100)
-- 
-- set @sub_id='1,20'
-- set @as_of_date='2004-09-30'
-- set @discount_option='d'
-- set @report_type='a'
-- set @prior_months=1
-- set @summary_option='s'
-- set @netting_parent_group_id=6
-- set @link_id=187

---===========================================================
Declare @beginning_date varchar(50)
Declare @Sql_Select varchar(8000)
Declare @Sql_From varchar(8000)
Declare @Sql_Where varchar(8000)
Declare @SqlSelect varchar(8000)
Declare @Sql1 varchar(8000)
Declare @Sql2 varchar(8000)
Declare @Sql3 varchar(8000)
Declare @Sql4 varchar(8000)
Declare @sql_into varchar(8000)
Declare @sql_real varchar(8000)
Declare @sql_group varchar(8000)
Declare @Sql10 varchar(8000)
Declare @sub_entity_id varchar(100) 
Declare	@strategy_entity_id varchar(100)
Declare	@book_entity_id varchar(100)
DECLARE @process_id varchar(100)
DECLARE @diagnostic int 

set @diagnostic = 0


--If @link_id is not null and sub_id is not  pased
If @sub_id IS NULL AND @link_id IS NOT NULL
BEGIN
	create table #tmpS
	(
	  sub_entity_id varchar(100) COLLATE DATABASE_DEFAULT
	)
	
	EXEC('insert into #tmpS 
	select cast(min(sub.entity_id) as varchar) from portfolio_hierarchy sub inner join
		portfolio_hierarchy stra on stra.parent_entity_id = sub.entity_id inner join
		portfolio_hierarchy book on book.parent_entity_id = stra.entity_id inner join
		fas_link_header flh on flh.fas_book_id = book.entity_id 
	where flh.link_id in (' + @link_id + ')')

	select @sub_id = sub_entity_id from  #tmpS
	--print '****' + @sub_entity_id + '***'
END


set @process_id=replace(newid(),'-','')

if @prior_months is null
	set @prior_months = 1

--if beginning date is null used the last run date as the beginning date
if @beginning_date is null
begin
	If @prior_months <> 0	
		select @beginning_date = 
		dbo.FNAGetSQLStandardDate(dateadd(mm, -1 * @prior_months, @as_of_date))	Else
		SET @beginning_date = NULL
	IF @beginning_date IS NULL
		SET @beginning_date = '1900-01-01'

End


--Declare @NettingDealProcessTableName varchar(100)
Declare @NettingProcessTableFinalName varchar(128)
--Declare @NettingDealProcessTableUnrealizeOneName varchar(100)
--Declare @NettingDealProcessTableUnrealizeTwoName varchar(100)
Declare @temp_curve varchar(100)

--SET @NettingDealProcessTableName = dbo.FNAProcessTableName('calcprocess_netting_deals', dbo.FNADBUser(), @process_id)
--SET @NettingDealProcessTableUnrealizeOneName = dbo.FNAProcessTableName('calcprocess_unrealizeone_deals', dbo.FNADBUser(), @process_id)
--SET @NettingDealProcessTableUnrealizeTwoName = dbo.FNAProcessTableName('calcprocess_unrealizetwo_deals', dbo.FNADBUser(), @process_id)
SET @NettingProcessTableFinalName = dbo.FNAProcessTableName('calcprocess_netting_final', dbo.FNADBUser(), @process_id)


-----------------------------------------********************************---------------------------------------
-----------------------------------------*********COLLECT DEALS*********-------------------------------------------
-- SET @sql_select = 	'select deal.source_deal_header_id,
-- 			deal.item_match_term_month,
-- 			deal.fas_subsidiary_id,
-- 			deal.fas_strategy_id,
-- 			deal.fas_book_id,
-- 			deal.link_id, 
-- 			deal.link_type,
-- 			deal.physical_financial_flag,
-- 			deal.deal_type,
-- 			deal.deal_sub_type,
-- 			deal.hedge_type_value_id,
-- 			deal.hedge_or_item,
-- 			deal.source_counterparty_id,
-- 			deal.Final_Und_Pnl + ISNULL(u_unlinked_aoci, 0) + ISNULL(u_unlinked_pnl_ineffectiveness, 0) + 
-- 				ISNULL(u_unlinked_dedesignation, 0) AS Final_Und_Pnl,
-- 			deal.Final_Dis_Pnl + ((ISNULL(u_unlinked_aoci, 0) + ISNULL(u_unlinked_pnl_ineffectiveness, 0) + 
-- 				ISNULL(u_unlinked_dedesignation, 0)) * discount_factor) AS Final_Dis_Pnl,
-- 			deal.long_term_months,
-- 			deal.curve_id'
-- set @sql_into=		' INTO ' + @NettingDealProcessTableName 
-- 
-- set @sql_from=		' from  (SELECT calcprocess_deals.source_deal_header_id,
-- 			calcprocess_deals.item_match_term_month,
-- 			calcprocess_deals.term_start,
-- 			calcprocess_deals.term_end,
-- 			fas_subsidiary_id,
-- 			fas_strategy_id,
-- 			fas_book_id,
-- 			calcprocess_deals.link_id, 
-- 				calcprocess_deals.link_type,
-- 			physical_financial_flag,
-- 			deal_type,
-- 			deal_sub_type,
-- 			hedge_type_value_id,
-- 			hedge_or_item,
-- 			COALESCE(sc.netting_parent_counterparty_id, calcprocess_deals.source_counterparty_id) as source_counterparty_id,
-- 			CASE WHEN(hedge_type_value_id = 150 AND hedge_or_item = ''i'') THEN 0 
-- 		 WHEN(hedge_type_value_id = 151 AND hedge_or_item = ''i'') THEN 
-- 				 	SUM(ISNULL(u_current_item_mtm, 0))
-- 				 ELSE 
-- 					SUM(CASE WHEN(hedge_type_value_id <> 152) THEN
-- 							final_und_pnl_remaining
-- 					ELSE
-- 							final_und_pnl
-- 					END) - SUM(ISNULL(u_hedge_rolfor_fix_settled, 0))			
-- 			END AS [Final_Und_Pnl],
-- 			CASE WHEN(hedge_type_value_id = 150 AND hedge_or_item = ''i'') THEN 0
-- 				 WHEN(hedge_type_value_id = 151 AND hedge_or_item = ''i'') THEN 
-- 				 	SUM(ISNULL(u_current_item_mtm, 0))* max(discount_factor)
-- 				 ELSE 				
-- 					SUM(CASE WHEN(hedge_type_value_id <> 152) THEN
-- 						final_dis_pnl_remaining
-- 					ELSE
-- 						final_dis_pnl
-- 					END) - SUM(ISNULL(d_hedge_rolfor_fix_settled, 0))
-- 			END AS [Final_Dis_Pnl],
-- 			MAX(long_term_months) AS [Long_Term_Months],
-- 			MAX(curve_id) As curve_id,
-- 			MAX(fixed_price) as fixed_price,
-- 			MAX(discount_factor) as discount_factor
-- 		 FROM calcprocess_deals INNER JOIN
-- 			source_counterparty sc ON sc.source_counterparty_id = calcprocess_deals.source_counterparty_id
-- 		WHERE calc_type = ''m'' AND '
-- set @sql_real=	' calcprocess_deals.as_of_date = CONVERT(DATETIME, ''' + @as_of_date + ''', 102) 
-- 		and include = ''y'' and deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''', 102) AND
-- 		calcprocess_deals.item_match_term_month<= CONVERT(DATETIME, ''' + @as_of_date + ''', 102) 
-- 		AND calcprocess_deals.item_match_term_month> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) 
-- 		AND NOT (hedge_type_value_id = 150 AND hedge_or_item = ''i'') '
-- 
-- set @sql_where=	' AND (hedge_type_value_id IN('+
-- 		case when @report_type='c' then '150)'
-- 		when @report_type='f' then '151)'
-- 		when @report_type='m' then '152)'
-- 		else '150,151,152)' end +') '
-- 		
-- 		if @sub_id IS NOT NULL
-- 			SET @sql_where = @sql_where+' AND fas_subsidiary_id in(' + @sub_id + ')' 
-- 		if @strategy_id IS NOT NULL
-- 			SET @sql_where = @sql_where+' AND fas_strategy_id in ('+ @strategy_id + ')'
-- 		if @book_id IS NOT NULL
-- 			SET @sql_where = @sql_where+' AND fas_book_id in(' + @book_id + ')' 
-- 		if @link_id IS NOT NULL
-- 			SET @sql_where = @sql_where+' AND link_type = ''link'' AND link_id in (' + @link_id + ')' 
-- 		
-- SET @sql_group = '		
-- 		GROUP BY calcprocess_deals.source_deal_header_id,
-- 			calcprocess_deals.item_match_term_month,

-- 			calcprocess_deals.term_start,
-- 			calcprocess_deals.term_end,
-- 			fas_subsidiary_id,
-- 			fas_strategy_id,
-- 			fas_book_id,
-- 			calcprocess_deals.link_id,
-- 			calcprocess_deals.link_type,
-- 			physical_financial_flag,
-- 			deal_type,
-- 			deal_sub_type,
-- 			hedge_type_value_id,
-- 			hedge_or_item,
-- 			COALESCE(sc.netting_parent_counterparty_id, calcprocess_deals.source_counterparty_id)
-- 			) deal LEFT OUTER JOIN
-- 			calcprocess_unlinked_locked_values unl
-- 			ON deal.source_deal_header_id = unl.source_deal_header_id AND
-- 	   			deal.item_match_term_month = unl.term_month AND deal.link_id = unl.link_id AND
-- 				deal.link_type = unl.link_type AND
-- 				unl.as_of_date = CONVERT(DATETIME, ''' + @as_of_date + ''', 102)
-- 			'
-- 
-- --Insert Realized into realized table @NettingDealProcessTableName
-- EXEC(@sql_select+@sql_into+@sql_from+@sql_real+@sql_where+@sql_group)
-- 
-- --print @sql_select+@sql_into+@sql_from+@sql_real+@sql_where+@sql_group
-- 
-- --This is unrealized
-- set @sql_into=' into '+@NettingDealProcessTableUnrealizeOneName
-- set @sql_real='calcprocess_deals.as_of_date = CONVERT(DATETIME, ''' + @as_of_date + ''', 102) 
-- 		and include = ''y'' and deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''', 102)
-- 		and calcprocess_deals.item_match_term_month > CONVERT(DATETIME, ''' + @as_of_date + ''', 102) '
-- 
-- EXEC(@sql_select+@sql_into+@sql_from+@sql_real+@sql_where+@sql_group)
-- 
-- set @sql_into=' into '+@NettingDealProcessTableUnrealizeTwoName
-- set @sql_real='calcprocess_deals.as_of_date = CONVERT(DATETIME, ''' + @beginning_date + ''', 102) 
-- 		and include = ''y'' and deal_date <= CONVERT(DATETIME, ''' + @beginning_date + ''', 102)
-- 		and calcprocess_deals.item_match_term_month > CONVERT(DATETIME, ''' + @as_of_date + ''', 102) '
-- 
-- EXEC(@sql_select+@sql_into+@sql_from+@sql_real+@sql_where+@sql_group)


-----------------------------------------------DELTA PNL-----------------------------------------------------------------
-- set @sql_select=' SELECT calcprocess_delta_pnl.link_id AS source_deal_header_id, 
-- 	CONVERT(DATETIME, calcprocess_delta_pnl.term_month, 102) AS item_match_term_month, 
-- 	calcprocess_delta_pnl.fas_subsidiary_id, 
-- 	calcprocess_delta_pnl.fas_strategy_id, 
-- 	calcprocess_delta_pnl.fas_book_id,
-- 	calcprocess_delta_pnl.link_id AS link_id, 
--         calcprocess_delta_pnl.link_type, 
-- 	''f'' AS physical_financial_flag, 	
-- 	source_deal_header.source_deal_type_id AS deal_type, 
--         source_deal_header.deal_sub_type_type_id AS deal_sub_type, 
-- 	calcprocess_delta_pnl.hedge_type_value_id, 
-- 	''h'' AS hedge_or_item, 
--         COALESCE(sc.netting_parent_counterparty_id, source_deal_header.counterparty_id) AS source_counterparty_id, 
-- 	calcprocess_delta_pnl.u_hedge_mtm as Final_Und_Pnl, 
-- 	calcprocess_delta_pnl.u_hedge_mtm * calcprocess_delta_pnl.discount_factor as Final_Dis_Pnl, 
-- 	calcprocess_delta_pnl.long_term_months,
-- 	sdd.curve_id 
-- FROM    calcprocess_delta_pnl INNER JOIN
--         source_deal_header ON calcprocess_delta_pnl.link_id = source_deal_header.source_deal_header_id INNER JOIN
-- 	source_counterparty sc ON sc.source_counterparty_id = source_deal_header.counterparty_id INNER JOIN
-- 	(select source_deal_header_id, max(curve_id) curve_id from source_deal_detail group by source_deal_header_id) sdd
-- 		ON sdd.source_deal_header_id =  calcprocess_delta_pnl.link_id '	
-- 
-- set @sql_where=' WHERE   calcprocess_delta_pnl.as_of_date = CONVERT(DATETIME, ''' + @as_of_date + ''', 102) AND ' 
-- 
-- set @sql_group='calcprocess_delta_pnl.term_month > CONVERT(DATETIME, ''' + @as_of_date + ''', 102) AND
-- 	(hedge_type_value_id IN('+
-- 		case when @report_type='c' then '150)'
-- 		when @report_type='f' then '151)'
-- 		when @report_type='m' then '152)'
-- 		else '150,151,152)' end +') and '
-- 
-- 		if @sub_id IS NOT NULL
-- 			SET @sql_group = @sql_group+' fas_subsidiary_id in(' + @sub_id + ')' 
-- 		if @strategy_id IS NOT NULL
-- 			SET @sql_group = @sql_group+' AND fas_strategy_id in ('+ @strategy_id + ')'
-- 		if @book_id IS NOT NULL
-- 			SET @sql_group = @sql_group+' AND fas_book_id in(' + @book_id + ')' 
-- 		if @link_id IS NOT NULL
-- 			SET @sql_group = @sql_group+' AND link_type = ''link'' AND link_id in(' + @link_id + ')' 
-- 		
-- 		SET @sql_group =@sql_group
-- EXEC('Insert into '+@NettingDealProcessTableUnrealizeOneName+@sql_select+@sql_where+@sql_group)
-- 
-- --print @sql_select+@sql_where+@sql_group
-- 
-- 
-- set @sql_where=' WHERE   calcprocess_delta_pnl.as_of_date = CONVERT(DATETIME, ''' + @beginning_date + ''', 102) AND '
-- EXEC('Insert into '+@NettingDealProcessTableUnrealizeTwoName+@sql_select+@sql_where+@sql_group)
-- 
-- -- exec ('select * from ' + @NettingDealProcessTableUnrealizeOneName)
-- -- exec ('select * from ' + @NettingDealProcessTableUnrealizeTwoName)
-- 
-- 
-- if @diagnostic = 1
-- 	EXEC spa_print 'End of collecting deals...'

-------------------------------------------------------------------------------------

EXEC('CREATE TABLE ' + @NettingProcessTableFinalName + '
	(
	[Item] [int] NULL,	
	[sub_entity_id] [int] NOT NULL ,
	[strategy_entity_id] [int]  NULL ,
	[book_entity_id] [int]  NULL ,
	[Amount] float NULL	
) ON [PRIMARY] ')

-----------------------------------********************************---------------------------------------------
-------------------------------*********END COLLECTING DEALS*********-------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------Revenue Net -------------------------------------------------------------------

set @sql_select='SELECT 2 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=2 and '+
	case when @netting_parent_group_id is null then ' netting_parent_group_id IS NULL '
	else 'netting_parent_group_id='+@netting_parent_group_id END+
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	' AND '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id'

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

--print @sql_select

--return
if @diagnostic = 1
	EXEC spa_print 'End of collecting Revenue Net...'
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------NET REVENUE FINANCIALS--------------------------------------
set @sql_select='SELECT 2 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=21 and ' + case when @netting_parent_group_id is null then ' netting_parent_group_id IS NULL '
	else ' netting_parent_group_id='+@netting_parent_group_id END+
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	' AND '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id'

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

if @diagnostic = 1
	EXEC spa_print 'End of Net Revenue Financial...'
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------GROSS REVENUE---------------------------------------------------
set @sql_select='SELECT 1 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=1 and ' + case when @netting_parent_group_id is null then ' netting_parent_group_id IS NULL '
	else ' netting_parent_group_id='+@netting_parent_group_id END+
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	' AND '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id'

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

if @diagnostic = 1
	EXEC spa_print 'End of collecting Gross Revenue...'
------------------------------------------------------------------------------------------------------------
-------------------------------------------------GROSS Cost of Revenue Physical-----------------------------
set @sql_select='SELECT 5 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=5 and ' + case when @netting_parent_group_id is null then ' netting_parent_group_id IS NULL '
	else ' netting_parent_group_id='+@netting_parent_group_id END+
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	' AND '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id'

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

if @diagnostic = 1
	EXEC spa_print 'End of collecting Cost of Revenue...'
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------COST OF REVENUE  FINANCIALS---------------------------------
set @sql_select='SELECT 5 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=51 and ' + case when @netting_parent_group_id is null then ' netting_parent_group_id IS NULL '
	else ' netting_parent_group_id='+@netting_parent_group_id END+
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	' AND '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id'

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

if @diagnostic = 1
	EXEC spa_print 'End of collecting cost or revenue financial...'
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------UNREALIZED GAIN/LOSS NET---------------------------------------------------
SET @sql_select = 
'select 3 as [NO], rmv.sub_entity_id, rmv.strategy_entity_id, rmv.book_entity_id, ' +
case when (@discount_option = 'u') then 
'	(isnull(rmv.u_total_pnl,0) - isnull(prmv.u_total_pnl,0)+
		isnull(rmv.u_total_aoci,0) - isnull(prmv.u_total_aoci,0)) AS [TotalAmount] ' else 
'	(isnull(rmv.d_total_pnl,0) - isnull(prmv.d_total_pnl,0)+
		isnull(rmv.d_total_aoci,0) - isnull(prmv.d_total_aoci,0)) AS [TotalAmount] ' end +
' from
(select sub_entity_id, strategy_entity_id, book_entity_id,
	sum(u_total_pnl) u_total_pnl, sum(d_total_pnl) d_total_pnl,
	sum(u_total_aoci) u_total_aoci, sum(d_total_aoci) d_total_aoci,
	link_id, link_deal_flag, hedge_type_value_id
from  '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'report_measurement_values') + ' report_measurement_values 
where as_of_date = CONVERT(DATETIME, ''' + @as_of_date+ ''', 102) and 
	term_month > = CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)
group by sub_entity_id, strategy_entity_id, book_entity_id, 
	link_id, link_deal_flag, hedge_type_value_id) rmv
LEFT OUTER JOIN
(select sum(u_total_pnl) u_total_pnl, sum(d_total_pnl) d_total_pnl, 
	sum(u_total_aoci) u_total_aoci, sum(d_total_aoci) d_total_aoci,
	link_id, link_deal_flag
from  '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'report_measurement_values') + ' report_measurement_values 
where as_of_date = CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	term_month > = CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)
group by link_id, link_deal_flag
) prmv ON
prmv.link_id = rmv.link_id and prmv.link_deal_flag= rmv.link_deal_flag ' +
' WHERE (hedge_type_value_id IN('+
case when @report_type='c' then '150)'
when @report_type='f' then '151)'
when @report_type='m' then '152)'
else '150,151,152)' end +') ' +
(CASE WHEN (@sub_id IS NOT NULL) THEN ' AND (sub_entity_id in(' + @sub_id + '))' ELSE '' END) +
(CASE WHEN (@strategy_id IS NOT NULL) THEN ' AND (strategy_entity_id in(' + @strategy_id + '))' ELSE '' END) + 
(CASE WHEN (@book_id IS NOT NULL) THEN ' AND (book_entity_id in(' + @book_id + '))' ELSE '' END) +
(CASE WHEN (@link_id IS NOT NULL) THEN ' AND rmv.link_deal_flag = ''l'' AND rmv.link_id = ' + cast(@link_id as varchar) ELSE '' END)


--print @sql_select
--exec(@sql_select)
EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

-- set @sql_select='select 3 as [NO],'+
-- 			'deal.fas_subsidiary_id as [sub_entity_id],
-- 			deal.fas_strategy_id as [strategy_entity_id],
-- 			deal.fas_book_id as [book_entity_id], round(('+
-- 			case when (@discount_option = 'u') then ' ISNULL(SUM(deal.Final_Und_Pnl),0)' 
-- 			else ' ISNULL(SUM(deal.Final_Dis_Pnl),0)), 0)' end +' AS [TotalAmount]
-- 			from '+@NettingDealProcessTableUnrealizeOneName+' deal
-- 			group by fas_subsidiary_id,fas_strategy_id,fas_book_id'
-- 
-- EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)
-- 
-- --exec (@sql_select)
-- 
-- set @sql_select='select 3 as [NO],'+
-- 			'deal.fas_subsidiary_id as [sub_entity_id],
-- 			deal.fas_strategy_id as [strategy_entity_id],
-- 			deal.fas_book_id as [book_entity_id], round((-1*'+
-- 			case when (@discount_option = 'u') then ' ISNULL(SUM(deal.Final_Und_Pnl),0)' 
-- 			else ' ISNULL(SUM(deal.Final_Dis_Pnl),0)), 0)' end +' AS [TotalAmount]
-- 			from '+@NettingDealProcessTableUnrealizeTwoName+' deal
-- 			group by fas_subsidiary_id,fas_strategy_id,fas_book_id'
-- 
-- EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

--exec (@sql_select)
if @diagnostic = 1
	EXEC spa_print 'End of collecting unrealized gain/loss net...'
-------------------------------------------------------------------------------------------------------------
------------------------------------------------AMORTIZATION AND INTEREST EXPENSE---------------------------
set @sql_select='SELECT 6 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=61  And '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id having sum(amount)<0  '

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

set @sql_select='SELECT 6 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=62  And '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id having sum(amount)<0 '

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

set @sql_select='SELECT 6 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=63   and '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id having sum(amount)<0 '

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

set @sql_select='SELECT 6 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=64  And '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id having sum(amount)<0 '

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

if @diagnostic = 1
	EXEC spa_print 'End of collecting amortization  int/expense...'
-------------------------------------------------------------------------------------------------------------------
---------------------------------------------------OTHER REVENUE----------------------------------------------------
set @sql_select='SELECT 4 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=41 And '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id having sum(amount)>0 '

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

set @sql_select='SELECT 4 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=42  And '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id having sum(amount)>0  '

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

set @sql_select='SELECT 4 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=43 And '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id having sum(amount)>0 '

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)

set @sql_select='SELECT 4 as Item,sub_entity_id,strategy_entity_id,book_entity_id,
	isnull(sum(Amount), 0) Value FROM report_netted_gross_net 
	where item=44  And '+
	case when @prior_months=1 then 'as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''', 102)'
	else  'as_of_date> CONVERT(DATETIME, ''' + @beginning_date + ''', 102) and 
	as_of_date<= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)' End +
	case when @link_id is not null then ' AND link_deal_flag = ''l'' AND link_id IN ('+ @link_id + ')' else ''End+
	(CASE WHEN (@sub_id IS NOT NULL) THEN ' And (sub_entity_id in(' + @sub_id + '))' ELSE '(sub_entity_id IS NULL OR sub_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@strategy_id IS NOT NULL) THEN ' (strategy_entity_id in(' + @strategy_id + '))' ELSE '(strategy_entity_id IS NULL OR strategy_entity_id IS NOT NULL)' END)
	+ ' AND ' +
	(CASE WHEN (@book_id IS NOT NULL) THEN ' (book_entity_id in(' + @book_id + '))' ELSE '(book_entity_id IS NULL OR book_entity_id IS NOT NULL)' END)+
	' AND (hedge_type_value_id IN('+
	case when @report_type='c' then '150)'
	when @report_type='f' then '151)'
	when @report_type='m' then '152)'
	else '150,151,152)' end +') 
	group by sub_entity_id,strategy_entity_id,book_entity_id having sum(amount)>0 '

EXEC('Insert into '+@NettingProcessTableFinalName+' '+ @sql_select)


if @diagnostic = 1
	EXEC spa_print 'End of collecting other  revenue...'
--EXEC('select * from '+@NettingProcessTableFinalName)
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
declare @counts int,@i int,@subname varchar(100),@item_name varchar(100),@strname varchar(100),@bookname varchar(100)
	create table #temp_sub([Sub] varchar(100) COLLATE DATABASE_DEFAULT,[Str] varchar(100) COLLATE DATABASE_DEFAULT,[Book] varchar(100) COLLATE DATABASE_DEFAULT,[NO] int,
	item_name varchar(100) COLLATE DATABASE_DEFAULT,[Amount] float)

	DECLARE a_cursor CURSOR FOR
		select distinct   sub_entity_id,strategy_entity_id,book_entity_id from report_netted_gross_net
		 order by sub_entity_id
		OPEN a_cursor
		FETCH NEXT FROM a_cursor INTO  @subname,@strname,@bookname
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			set @i=6
			while @i<>0
				Begin
					if @i=1
					set @item_name='Realized Revenue Gross'
					else if @i=2
					set @item_name='Realized Revenue Net'
					else if @i=3
					set @item_name='Unrealized Gain/Loss Net'
					else if @i=4
					set @item_name='Other Revenue (Interest)'
					else if @i=5
					set @item_name='Cost Of Revenue'
					else if @i=6
					set @item_name='Amortization and Interest Expense' 
					insert into #temp_sub values(@subname,@strname,@bookname,@i,@item_name,0)					
					set @i=@i-1
				End
			
			FETCH NEXT FROM a_cursor INTO  @subname,@strname,@bookname
		END 
		CLOSE a_cursor
		DEALLOCATE  a_cursor		
	--select * from #temp_sub2
	--return




if @summary_option='s'
	EXEC('select distinct b.no as No,b.item_name as Item,ISNULL(a.[Total Amount],0) as [Total Amount] from (
	select Item as No, ISNULL(SUM(Amount),0) as [Total Amount] from
	 ' +@NettingProcessTableFinalName+' group by item) a RIGHT OUTER JOIN
	#temp_sub b on a.no=b.no  order by b.[No],b.item_name')

else if @summary_option='a' 
	EXEC('select  distinct s.entity_name as [Subsidiary],b.no,b.item_name as Item,ISNULL(a.[Total Amount],0) as [Total Amount]
	 from (
	select Sub_entity_id,Item as No, SUM(ISNULL(Amount,0)) as [Total Amount] from 
	' +@NettingProcessTableFinalName+' group by Sub_entity_id,item ) a
	RIGHT OUTER JOIN #temp_sub b on a.no=b.no and a.sub_entity_id=b.sub
	INNER JOIN portfolio_hierarchy s ON s.entity_id = b.[Sub] where s.entity_id in(select sub_entity_id from
	'+@NettingProcessTableFinalName+')
	order by s.entity_name,b.no,b.item_name')

else if @summary_option='b'
	EXEC('select distinct s.entity_name as [Subsidiary],st.entity_name as [Strategy],b.no,b.item_name as Item,ISNULL(a.[Total Amount],0) as [Total Amount]
	from(select Sub_entity_id,strategy_entity_id,Item as No,SUM(Amount) as [Total Amount] 
	from ' +@NettingProcessTableFinalName+' a group by sub_entity_id,strategy_entity_id,item )a
	RIGHT OUTER JOIN #temp_sub b on a.no=b.no and a.sub_entity_id=b.sub and a.strategy_entity_id=b.str
	Inner JOIN portfolio_hierarchy s ON s.entity_id = b.[sub]
	INNER JOIN portfolio_hierarchy st ON st.entity_id = b.[str] 
        order by s.entity_name,st.entity_name,b.no,b.item_name')

else if @summary_option='c'
	EXEC('select s.entity_name as [Subsidiary],st.entity_name as [Strategy],
	b.entity_name as Book,[item] as No,
	case when item= 1 then ''Realized Revenue Gross''
	when item= 2 then ''Realized Revenue Net'' 
	when item= 3 then ''Unrealized Gain/Loss Net''
	when item= 4 then ''Other Revenue (Interest)''
	when item= 5 then ''Cost or Revenue''
	else ''Amortization and Interest Expense '' End as Items,
	SUM(Amount) as [Total Amount] from ' +@NettingProcessTableFinalName+' a
	LEFT OUTER JOIN portfolio_hierarchy s ON s.entity_id = a.Sub_entity_id
	LEFT OUTER JOIN portfolio_hierarchy st ON st.entity_id = a.strategy_entity_id
	LEFT OUTER JOIN portfolio_hierarchy b ON b.entity_id = a.book_entity_id
	group by s.entity_name,st.entity_name,b.entity_name,a.item order by 
	s.entity_name,st.entity_name,b.entity_name,a.[item]')

DECLARE @deleteStmt VARCHAR(500)

	
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@NettingProcessTableFinalName)
	exec (@deleteStmt)

-- 	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@NettingDealProcessTableName)
-- 	exec (@deleteStmt)







