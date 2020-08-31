/****** Object:  StoredProcedure [dbo].[spa_create_rec_margin_report]    Script Date: 06/25/2009 14:47:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_rec_margin_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_rec_margin_report]SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec spa_create_rec_margin_report '135',NULL,NULL,'2006-11-01','2006-11-30',NULL,NULL,NULL,NULL,'t'

-- exec spa_create_rec_margin_report '95',NULL,NULL,'2006-06-30',NULL,null,null,null, null, 's'
-- exec spa_create_rec_margin_report '95',NULL,NULL,'2006-06-30',NULL,null,null,null, null, 'd', 'PSCO',
-- 
-- exec spa_create_rec_margin_report '95',NULL,NULL,'2006-06-30',NULL,null,null,null, null, 't'
--exec spa_create_rec_margin_report '95',NULL,NULL,'2006-06-30',NULL,null,null,null, null, 'd'


CREATE  PROCEDURE [dbo].[spa_create_rec_margin_report]
		@sub_entity_id varchar(100)=null, 
		@strategy_entity_id varchar(100) = NULL, 
		@book_entity_id varchar(100) = NULL, 		
		@as_of_date_from varchar(20),
		@as_of_date_to varchar(20) = null,
		@counterparty_id int = null,
		@trader_id int = null,
		@technology int = null,
		@generator_id int = null,
		@summary_option varchar(1) = 's', --s summary, d detail, t for trader margin
		@drill_sub varchar(100)=null,
		@drill_as_of_date varchar(20)=null,
		@drill_production_month varchar(20)=null,
		@drill_counterparty varchar(100)=null,
		@trader varchar(100)=NULL,
		@round_value char(1) = '0'
					


AS
SET NOCOUNT ON 

---- beginning of test data

-- DECLARE		@sub_entity_id varchar(100)
-- DECLARE		@strategy_entity_id varchar(100)
-- DECLARE		@book_entity_id varchar(100)
-- DECLARE		@book_deal_type_map_id varchar(5000) 
-- DECLARE		@source_deal_header_id varchar(5000) 
-- DECLARE		@as_of_date_from varchar(20)
-- DECLARE		@as_of_date_to varchar(20)
-- DECLARE		@counterparty_id int
-- DECLARE 	@summary_option varchar(1)
-- DECLARE		@int_ext_flag varchar(1)
-- 
-- SET @sub_entity_id = '96'
-- SET @strategy_entity_id  = null
-- SET @book_entity_id = null
-- SET @book_deal_type_map_id = null
-- SET @source_deal_header_id = null
-- SET @as_of_date_from = '11/01/2005'
-- SET @as_of_date_to  = '12/01/2005'
-- SET @counterparty_id =  null
-- SET @summary_option = 's' 
-- SET @int_ext_flag = 'e' 
-- drop table #temp

----==========end of test data

If @as_of_date_to IS NULL
	set @as_of_date_to = @as_of_date_from

If @as_of_date_from IS NULL
	set @as_of_date_from = @as_of_date_to


--******************************************************
--CREATE source book map table and build index
--*********************************************************
DECLARE @Sql_Where VARCHAR(500)
DECLARE @Sql_Select VARCHAR(5000)

set @Sql_Where = ' 1 = 1 '
CREATE TABLE #ssbm(
	source_system_book_id1 int,
	source_system_book_id2 int,
	source_system_book_id3 int,
	source_system_book_id4 int,
	fas_deal_type_value_id int,
	book_deal_type_map_id int,
	fas_book_id int,
	stra_book_id int,
	sub_entity_id int
)
----------------------------------
SET @Sql_Select=
'INSERT INTO #ssbm
SELECT
	source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,fas_deal_type_value_id,
	book_deal_type_map_id,
	 book.entity_id fas_book_id, book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id 
FROM
	source_system_book_map ssbm 
INNER JOIN
	portfolio_hierarchy book (nolock) 
ON	
	 ssbm.fas_book_id = book.entity_id 
INNER JOIN
	Portfolio_hierarchy stra (nolock)
 ON
	 book.parent_entity_id = stra.entity_id 

WHERE '
IF @sub_entity_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') ' 
	IF @strategy_entity_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'
	IF @book_entity_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '
SET @Sql_Select=@Sql_Select+@Sql_Where

--print @Sql_Select
EXEC (@Sql_Select)

-- create table #tempS
-- (entity_id int)
-- 
-- create table #tempSt
-- (entity_id int)
-- 
-- create table #tempB
-- (entity_id int)

-- if @sub_entity_id is not null
-- 	exec ('insert into #tempS select entity_id from portfolio_hierarchy where entity_id in (' + @sub_entity_id + ')')
-- else
-- 	exec ('insert into #tempS select entity_id from portfolio_hierarchy where entity_type_value_id = 525')
-- 
-- if @strategy_entity_id is not null
-- 	exec ('insert into #tempSt select entity_id from portfolio_hierarchy where entity_id in (' + @strategy_entity_id + ')')
-- else
-- 	exec ('insert into #tempSt select entity_id from portfolio_hierarchy where entity_type_value_id = 526')
-- 
-- 
-- if @book_entity_id is not null
-- 	exec ('insert into #tempB select entity_id from portfolio_hierarchy where entity_id in (' + @book_entity_id + ')')
-- else
-- 	exec ('insert into #tempB select entity_id from portfolio_hierarchy where entity_type_value_id = 527')
-- 
-- select * from #tempS
-- select * from #tempSt
-- select * from #tempB
-- 
-- 
-- Return 


DECLARE @sql_stmt varchar(5000)

-- select 
-- 	dbo.FNADateFormat(revenue.as_of_date) [As Of Date],
-- 	revenue.Sub,
-- 	revenue.Strategy,
-- 	revenue.Book,
-- 	revenue.Counterparty,
-- -- 	dbo.FNAEmissionHyperlink(2,10131010, cast(sdh.source_deal_header_id as varchar), 
-- -- 		cast(sdh.source_deal_header_id as varchar),NULL) DealID,
-- 	revenue.sale_deal_id,
-- 	revenue.sale_from_deal_id,
-- 	revenue.structured_deal_id,	
-- 	dbo.FNADateFormat(revenue.DealDate) DealDate, 
-- 	dbo.FNADateFormat(revenue.GenDate) GenDate, 
-- 	revenue.Type,
-- 	revenue.Price,
-- 	revenue.Volume, 
-- 	revenue.Unit,
-- --	revenue.BuySell,
-- 	revenue.Settlement Revenue,
-- 	cost.Settlement Cost

-- from
-- (
	select 
	rmv.as_of_date,
	sub.entity_name Sub,
	stra.entity_name Strategy,
	book.entity_name Book,
	sc.counterparty_name Counterparty,
-- 	dbo.FNAEmissionHyperlink(2,10131010, cast(sdh.source_deal_header_id as varchar), 
-- 		cast(sdh.source_deal_header_id as varchar),NULL) DealID,
	sdh.source_deal_header_id sale_deal_id,
	sdh.ext_deal_id sale_from_deal_id,
	sdh.structured_deal_id,	
	dbo.FNADateFormat(sdh.deal_date) DealDate, 
	dbo.FNADateFormat(rmv.term_month) GenDate, 
	case when (dbo.FNAGetContractMonth(rmv.term_month) = dbo.FNAGetContractMonth(rmv.as_of_date)) then 'Cur' else 'Adj' end as Type,
	isnull(cast(rmv.u_hedge_mtm/deal_volume as varchar), '') Price,
	ROUND(deal_volume,CAST(@round_value AS INT))  Volume, 
	deal_volume_frequency Frequency, 
	su.uom_name Unit,
	case when (sdd.buy_sell_flag = 'b') then 'Buy' else 'Sell' end BuySell,
	rmv.u_hedge_st_asset as Settlement,
	rmv.u_inv_expense as Cost,

	spcd.curve_name,
	rg.code,
	st.trader_name Trader
	into #temp1
	from 
	 report_measurement_values_inventory rmv inner join
	 source_deal_detail sdd on sdd.source_deal_detail_id= rmv.link_id  inner join
	 source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id inner join

 	 #ssbm ssbm ON
		sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
        	sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
        	sdh.source_system_book_id4 = ssbm.source_system_book_id4 	LEFT OUTER JOIN	
-- 	source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
-- 	sdh.source_system_book_id2 = sbm.source_system_book_id2 AND 
-- 	sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
-- 	sdh.source_system_book_id4 = sbm.source_system_book_id4 INNER JOIN
	portfolio_hierarchy book ON ssbm.fas_book_id = book.entity_id INNER JOIN
	portfolio_hierarchy stra ON ssbm.stra_book_id = stra.entity_id INNER JOIN
	portfolio_hierarchy sub ON ssbm.sub_entity_id = sub.entity_id LEFT OUTER JOIN
	source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id LEFT OUTER JOIN
	source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id LEFT OUTER JOIN
	rec_generator rg on rg.generator_id = sdh.generator_id LEFT OUTER JOIN
	source_uom su on su.source_uom_id = sdd.deal_volume_uom_id LEFT OUTER JOIN
	source_traders st on st.source_trader_id = sdh.trader_id 

	where 	ssbm.fas_deal_type_value_id in(400,406) and 
		(sdd.buy_sell_flag = 's' and (sdh.assignment_type_value_id is null OR sdh.assignment_type_value_id = 5173))
		and dbo.FNAGetContractMonth(rmv.as_of_date) BETWEEN 
			dbo.FNAGetContractMonth(@as_of_date_from) AND dbo.FNAGetContractMonth(@as_of_date_to)		
		and sc.source_counterparty_id = isnull(@counterparty_id, sc.source_counterparty_id)
		and sdh.trader_id = isnull(@trader_id, sdh.trader_id )
-- 		and stra.parent_entity_id IN (select entity_id from #tempS) 
-- 		and stra.entity_id IN (select entity_id from #tempSt)
-- 		and book.entity_id IN (select entity_id from #tempB)
		and rg.technology = isnull(@technology, rg.technology)
		and rg.generator_id = isnull(@generator_id, rg.generator_id)



--order by sdh.source_deal_header_id
-- ) revenue inner join
-- (
-- 	select 
-- 	rmv.as_of_date,
-- 	sub.entity_name Sub,
-- 	stra.entity_name Strategy,
-- 	book.entity_name Book,
-- 	sc.counterparty_name Counterparty,
-- -- 	dbo.FNAEmissionHyperlink(2,10131010, cast(sdh.source_deal_header_id as varchar), 
-- -- 		cast(sdh.source_deal_header_id as varchar),NULL) DealID,
-- 	sdh.source_deal_header_id sale_from_deal_id,
-- 	sdh.structured_deal_id,	
-- 	dbo.FNADateFormat(sdh.deal_date) DealDate, 
-- 	dbo.FNADateFormat(rmv.term_month) GenDate, 
-- 	case when (dbo.FNAGetContractMonth(rmv.term_month) = dbo.FNAGetContractMonth(rmv.as_of_date)) then 'Cur' else 'Adj' end as Type,
-- 	isnull(cast(rmv.u_hedge_mtm/deal_volume as varchar), '') Price,
-- 	deal_volume  Volume,
-- 	su.uom_name Unit,
-- 	deal_volume_frequency Frequency, 
-- 	case when (sdd.buy_sell_flag = 'b') then 'Buy' else 'Sell' end BuySell,
-- 	rmv.u_pnl_inventory as Settlement,
-- 	spcd.curve_name,
-- 	rg.code,
-- 	st.trader_name Trader
-- 
-- 	into #temp2
-- 
-- 	from 
-- 	 report_measurement_values_inventory rmv inner join
-- 	 source_deal_detail sdd on sdd.source_deal_detail_id= rmv.link_id  inner join
-- 	 source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id inner join
--  	 #ssbm ssbm ON
-- 		sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
--         	sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
--         	sdh.source_system_book_id4 = ssbm.source_system_book_id4 LEFT OUTER JOIN	
-- 
-- -- 	source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
-- -- 	sdh.source_system_book_id2 = sbm.source_system_book_id2 AND 
-- -- 	sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
-- -- 	sdh.source_system_book_id4 = sbm.source_system_book_id4 INNER JOIN
-- 	portfolio_hierarchy book ON ssbm.fas_book_id = book.entity_id INNER JOIN
-- 	portfolio_hierarchy stra ON ssbm.stra_book_id = stra.entity_id INNER JOIN
-- 	portfolio_hierarchy sub ON ssbm.sub_entity_id = sub.entity_id LEFT OUTER JOIN
-- 	source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id LEFT OUTER JOIN
-- 	source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id LEFT OUTER JOIN
-- 	rec_generator rg on rg.generator_id = sdh.generator_id  LEFT OUTER JOIN
-- 	source_uom su on su.source_uom_id = sdd.deal_volume_uom_id LEFT OUTER JOIN
-- 	source_traders st on st.source_trader_id = sdh.trader_id
-- 								 
-- 	where 	ssbm.fas_deal_type_value_id in(400,406) and sdd.buy_sell_flag = 'b' 
-- 		and dbo.FNAGetContractMonth(rmv.as_of_date) BETWEEN 
-- 			dbo.FNAGetContractMonth(@as_of_date_from) AND dbo.FNAGetContractMonth(@as_of_date_to)		
-- 		--and sc.source_counterparty_id = isnull(@counterparty_id, sc.source_counterparty_id)
-- 		--and sdh.trader_id = isnull(@trader_id, sdh.trader_id )
-- -- 		and stra.parent_entity_id IN (select entity_id from #tempS) 
-- -- 		and stra.entity_id IN (select entity_id from #tempSt)
-- -- 		and book.entity_id IN (select entity_id from #tempB)
-- 		and u_pnl_inventory < 0

--order by sdh.source_deal_header_id

-- ) cost
-- 
-- ON revenue.sale_from_deal_id = cost.sale_from_deal_id

--EXEC (@sql_stmt )
	
--lect * from #temp


if @summary_option = 'd'
	select 
		revenue.Sub,
		revenue.Strategy,
		revenue.Book,
		dbo.FNADateFormat(revenue.as_of_date) [As Of Date],
		dbo.FNADateFormat(revenue.GenDate) [Production Month],
		revenue.Counterparty,
		revenue.Trader,
	 	dbo.FNAEmissionHyperlink(2,10131010, cast(revenue.sale_deal_id as varchar), 
	 		cast(revenue.sale_deal_id as varchar),NULL) [Sale Deal ID],
	 	dbo.FNAEmissionHyperlink(2,10131010, cast(revenue.sale_from_deal_id as varchar), 
	 		cast(revenue.sale_from_deal_id as varchar),NULL) [Cost Transaction ID],
		dbo.FNADateFormat(revenue.DealDate) [Deal Date], 
		dbo.FNADateFormat(revenue.GenDate) [Gen Date], 
		ROUND(revenue.Volume,CAST(@round_value AS INT)), 
		revenue.Unit,
		case 	when (revenue.Frequency = 'm') then 'Monthly' 
			when (revenue.Frequency = 'd') then 'Daily' 
			when (revenue.Frequency = 'y') then 'yearly' else 'Monthly' end Frequency,
		revenue.Settlement Revenue,
		revenue.Cost Cost,
		revenue.Settlement - revenue.Cost Margin
	
	from  	#temp1 revenue 
-- 		inner join #temp2 cost
-- 		on revenue.sale_from_deal_id = cost.sale_from_deal_id
	where   revenue.Sub = isnull(@drill_sub, revenue.Sub) and
		revenue.as_of_date = isnull(@drill_as_of_date, revenue.as_of_date) and
		revenue.GenDate = isnull(@drill_production_month, revenue.GenDate) and
		revenue.Counterparty = isnull(@drill_counterparty, revenue.Counterparty) and
		revenue.trader = isnull(@trader, revenue.trader)

	order by revenue.as_of_date,
		revenue.Sub,
		revenue.Strategy,
		revenue.Book,
		revenue.Counterparty,
		revenue.Trader,
		revenue.sale_deal_id 

else if @summary_option = 's'
	select 
		revenue.Sub,
		dbo.FNADateFormat(revenue.as_of_date) [As Of Date],
		dbo.FNADateFormat(revenue.GenDate) [Production Month],
		revenue.Counterparty,
		ROUND(sum(revenue.Volume),CAST(@round_value AS INT)) Volume, 
		revenue.Unit Unit,
		case 	when (revenue.Frequency = 'm') then 'Monthly' 
			when (revenue.Frequency = 'd') then 'Daily' 
			when (revenue.Frequency = 'y') then 'yearly' else 'Monthly' end Frequency,
		sum(revenue.Settlement) Revenue,
		sum(revenue.Cost) Cost,
		sum(revenue.Settlement - revenue.Cost) Margin
	
	from  	#temp1 revenue 
-- 		inner join #temp2 cost
-- 		on revenue.sale_from_deal_id = cost.sale_from_deal_id
	group by revenue.as_of_date, revenue.GenDate, revenue.Counterparty, revenue.Sub, revenue.Unit, revenue.Frequency

else if @summary_option = 't'
	select 
		revenue.Trader,
		revenue.Sub,
		revenue.Counterparty,		
		dbo.FNADateFormat(revenue.as_of_date) [As Of Date],
		ROUND(sum(revenue.Volume),CAST(@round_value AS INT)) Volume, 
		revenue.Unit Unit,
		case 	when (revenue.Frequency = 'm') then 'Monthly' 
			when (revenue.Frequency = 'd') then 'Daily' 
			when (revenue.Frequency = 'y') then 'yearly' else 'Monthly' end Frequency,
		sum(revenue.Settlement) Revenue,
		sum(revenue.Cost) Cost,
		sum(revenue.Settlement - revenue.Cost) Margin
	
	from  	#temp1 revenue 
-- 		inner join #temp2 cost
-- 		on revenue.sale_from_deal_id = cost.sale_from_deal_id
	group by revenue.Trader, revenue.as_of_date, revenue.Counterparty, revenue.Sub, revenue.Unit, revenue.Frequency










