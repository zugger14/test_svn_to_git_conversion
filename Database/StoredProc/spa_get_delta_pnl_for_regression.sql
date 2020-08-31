IF OBJECT_ID(N'[dbo].[spa_get_delta_pnl_for_regression]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_delta_pnl_for_regression]
GO 


--select * from cum_pnl_series

-- exec spa_get_delta_pnl_for_regression -299, 2, 'o','u','2005-12-31' -- link_id, level 1
-- exec spa_get_delta_pnl_for_regression -300, 2, 'o','u','2005-12-31' -- link_id, level 1
-- exec spa_get_delta_pnl_for_regression -304, 2, 'o','u','2005-12-31' -- link_id, level 1
-- exec spa_get_delta_pnl_for_regression 509, 2, 'o','u','2005-12-31'  -- link_id, level 1
-- exec spa_get_delta_pnl_for_regression 94, 1, 'i' -- hedge rel type id, level 2
-- exec spa_get_delta_pnl_for_regression 622, 1, 'o','u','2007-12-31' -- hedge rel type id, level 2


--this procedure returns delta pnl for a link to run  regression analysis
-- @type default to 'p' means period, 'c' means cumulative etc. Right now only 'p' supported
-- @discount_option  'u' means undiscounted,  'd' means discounted
-- EXEC spa_get_delta_pnl_for_regression '538'
-- EXEC spa_get_delta_pnl_for_regression '98'
-- @link_id consists of a link or eff test profile, @calc_level 2 means link and 1 means eff test profile (strategy or book),
-- @discount option 'u' future value and 'd' discounted for future
-- EXEC spa_get_delta_pnl_for_regression 94, 1,i,'u','2006-03-31'

CREATE PROC [dbo].[spa_get_delta_pnl_for_regression]
		@link_id int, 
		@calc_level int = 2,
		@inception_ongoing varchar(1) = 'o', 
		@discount_option varchar(1)= 'u',
		@as_of_date varchar(20) = NULL

AS
-- need to handle this when run for one eff test profile id... it runs for the whole strategy?
-- find out what series it is... cum vs period

---======= uncomment this for testing
-- declare @link_id int
-- declare @calc_level int
-- declare @discount_option varchar(1)
-- 
-- set @link_id = 592 --96
-- set @calc_level = 2 --1
-- set @discount_option = 'u'
-- 
-- drop table #temp
-- drop table #cum_pnl
-- drop table #ssbm
-- drop table #links
---======= uncomment this for testing
-- 
-- select distinct pnl_as_of_date from source_deal_pnl 
-- where source_deal_header_id in (select source_deal_header_id from fas_link_detail where
-- (fas_link_detail.link_id in  (@link_id)) AND (fas_link_detail.hedge_or_item = 'h'))
-- order by pnl_as_of_date
declare @type varchar(1)
declare @on_assmt_curve_type_value_id int
declare @mes_gran_value_id int
declare @strategy_id int
declare @book_id int
declare @curve_points int
declare @sql_Where varchar(500)
declare @Sql_select varchar(8000)
declare @Sql_select1 varchar(8000)
-- select * from fas_eff_hedge_rel_type

if @discount_option is null
	set @discount_option = 'u'

set @curve_points=10

If @calc_level = 2 AND @link_id > 0 -- link id level 
BEGIN
	select 	@on_assmt_curve_type_value_id = case when(@inception_ongoing = 'o') then on_assmt_curve_type_value_id else init_assmt_curve_type_value_id end, 
		@mes_gran_value_id = fs.mes_gran_value_id, 
		@strategy_id = stra.entity_id, 
		@book_id = book.entity_id,
		@curve_points = case when(@inception_ongoing = 'o') then on_number_of_curve_points else init_number_of_curve_points end
	from fas_link_header flh inner join 
	fas_eff_hedge_rel_type fehrt on fehrt.eff_test_profile_id = flh.eff_test_profile_id inner join
	portfolio_hierarchy book on book.entity_id = flh.fas_book_id inner join
	portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id inner join
	fas_strategy fs on fs.fas_strategy_id = stra.entity_id
	where flh.link_id = @link_id and
	on_assmt_curve_type_value_id in (79,85)
END
Else If @calc_level = 2 AND @link_id < 0 -- Book or Strategy Level at Link level
BEGIN	
	--print @link_id 
	select 	@on_assmt_curve_type_value_id = case when(@inception_ongoing = 'o') then
					max(coalesce(rtype_book.on_assmt_curve_type_value_id, rtype_strat.on_assmt_curve_type_value_id)) 
				else max(coalesce(rtype_book.init_assmt_curve_type_value_id, rtype_strat.init_assmt_curve_type_value_id)) end , 
		@mes_gran_value_id = max(fs.mes_gran_value_id), 
		@strategy_id = max(stra.entity_id), 
		@book_id = max(book.entity_id),
		@curve_points = case when(@inception_ongoing = 'o') then
					max(isnull(rtype_book.on_number_of_curve_points, rtype_strat.on_number_of_curve_points)) 
				else max(coalesce(rtype_book.init_number_of_curve_points, rtype_strat.init_number_of_curve_points)) end

from	 portfolio_hierarchy book INNER JOIN
		 portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id INNER JOIN
		 fas_strategy fs on fs.fas_strategy_id = stra.entity_id INNER JOIN
		 fas_books fb on fb.fas_book_id = book.entity_id LEFT OUTER JOIN
		 fas_eff_hedge_rel_type rtype_book on rtype_book.eff_test_profile_id = fb.no_links_fas_eff_test_profile_id LEFT OUTER JOIN
		 fas_eff_hedge_rel_type rtype_strat on rtype_strat.eff_test_profile_id = fs.no_links_fas_eff_test_profile_id 
	where (-1*fs.fas_strategy_id = @link_id OR -1*fb.fas_book_id = @link_id)
		AND coalesce(rtype_book.on_assmt_curve_type_value_id, rtype_strat.on_assmt_curve_type_value_id, -1) in (79, 85) 


END
Else -- 1 which is hedging relationship type meaning it wil be at strategy or book level
BEGIN
	select 	@on_assmt_curve_type_value_id = case when(@inception_ongoing = 'o') then on_assmt_curve_type_value_id else init_assmt_curve_type_value_id end, 
		@mes_gran_value_id = fs.mes_gran_value_id, 
		@strategy_id = stra.entity_id, 
		@book_id = book.entity_id,
		@curve_points = case when(@inception_ongoing = 'o') then on_number_of_curve_points else init_number_of_curve_points end

	from fas_eff_hedge_rel_type fehrt inner join
	portfolio_hierarchy book on book.entity_id = fehrt.fas_book_id inner join
	portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id inner join
	fas_strategy fs on fs.fas_strategy_id = stra.entity_id
	where fehrt.eff_test_profile_id  = @link_id and
	on_assmt_curve_type_value_id in (79,85)
END

set @type = 'c'
if @on_assmt_curve_type_value_id = 79
BEGIN
	set @type = 'p'
	set @curve_points = @curve_points + 1
END

create table #cum_pnl
(
seq_no int identity,
price_date datetime,
delta_pnl_h float,
delta_pnl_i float
)

If @calc_level = 2 AND @link_id < 0 -- Book or Strategy Level at Link level
BEGIN
	set @Sql_select1='insert into #cum_pnl (price_date,delta_pnl_h,delta_pnl_i) 
	select top '+cast(@curve_points as varchar)+' cps.as_of_date, SUM(cps.' + @discount_option + '_h_mtm) u_hedge_mtm, 
		SUM(cps.' + @discount_option + '_i_mtm) u_item_mtm
	from	 portfolio_hierarchy book INNER JOIN
			 portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id INNER JOIN
			 fas_strategy fs on fs.fas_strategy_id = stra.entity_id INNER JOIN
			 fas_books fb on fb.fas_book_id = book.entity_id INNER JOIN
			 cum_pnl_series cps ON cps.link_id = -1*fb.fas_book_id
	where (-1*fb.fas_book_id = ' + cast(@link_id as varchar) + ' OR -1*fs.fas_strategy_id = ' + cast(@link_id as varchar) + ') AND
	as_of_date < '''+ @as_of_date + '''' +
	' group by  cps.as_of_date order by cps.as_of_date desc '
END
ELSE
BEGIN
	set @Sql_select1='insert into #cum_pnl (price_date,delta_pnl_h,delta_pnl_i) 
	select top '+cast(@curve_points as varchar)+' cps.as_of_date, SUM(cps.' + @discount_option + '_h_mtm) u_hedge_mtm, 
		SUM(cps.' + @discount_option + '_i_mtm) u_item_mtm
	from cum_pnl_series cps 
	where as_of_date < '''+ @as_of_date + '''' +
	' and link_id = ' + cast(@link_id as varchar) +
	' group by  cps.as_of_date order by cps.as_of_date desc '
END

--PRINT @Sql_select1

--print(@Sql_select1)
exec(@Sql_select1)

IF @type = 'c'
BEGIN
	select dbo.FNAGetSQLStandardDate(price_date) price_date, (delta_pnl_h) delta_pnl_h, (delta_pnl_i) delta_pnl_i
	from #cum_pnl
	order by seq_no
	RETURN
END
ELSE
BEGIN
	create table #delta_pnl
	(
	seq_no int identity,
	price_date datetime,
	delta_pnl_h float,
	delta_pnl_i float
	)


	DECLARE @price_date datetime
	DECLARE @price_date_c datetime
	DECLARE @delta_pnl_h_p float
	DECLARE @delta_pnl_i_p float
	DECLARE @delta_pnl_h_c float
	DECLARE @delta_pnl_i_c float
	DECLARE @total_count int
	
	select @total_count = count(*) from #cum_pnl	
	
	DECLARE a_cursor CURSOR FOR
	select price_date, delta_pnl_h, delta_pnl_i from #cum_pnl order by seq_no
	
	OPEN a_cursor
	
	FETCH NEXT FROM a_cursor INTO @price_date, @delta_pnl_h_p, @delta_pnl_i_p

	set @price_date_c = @price_date

	WHILE @@FETCH_STATUS = 0   
	BEGIN 


		FETCH NEXT FROM a_cursor INTO @price_date, @delta_pnl_h_c, @delta_pnl_i_c
		
		insert into #delta_pnl(price_date, delta_pnl_h, delta_pnl_i)
		values(@price_date_c, @delta_pnl_h_p - @delta_pnl_h_c, @delta_pnl_i_p - @delta_pnl_i_c)
--		values(@price_date, @delta_pnl_h_c - @delta_pnl_h_p, @delta_pnl_i_c - @delta_pnl_i_p)
		
		set @delta_pnl_h_p = @delta_pnl_h_c
		set @delta_pnl_i_p = @delta_pnl_i_c
		set @price_date_c = @price_date
	END
	
	CLOSE a_cursor
	DEALLOCATE  a_cursor
	select dbo.FNAGetSQLStandardDate(price_date) price_date, (delta_pnl_h) delta_pnl_h, (delta_pnl_i) delta_pnl_i
	from #delta_pnl
	where seq_no < @total_count
	order by seq_no
	RETURN
END














