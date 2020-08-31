IF OBJECT_ID(N'[dbo].[spa_get_db_measurement_trend]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_db_measurement_trend]
GO 

-- EXEC spa_get_db_measurement_trend  1,'c','30', NULL,'2004-12-31','2005-09-30','d','208','223',NULL
--EXEC spa_get_db_measurement_trend  1,'f','291,30,1,257,258,256', NULL,'2001-03-28','2008-06-28','u',NULL,NULL,NULL
--===========================================================================================
--This Procedure returns the measurement trend data for dashboard. It can be drilledown as well

--===========================================================================================
--The following are used in measurement trend report
--@as_of_date_to
-- @discount_option
--@strategy_entity_id
--@book_entity_id

-- example to run dashboard with drill down
-- EXEC spa_get_db_measurement_trend 1, 'c', '1,2,20', null, '1/1/2002', '12/31/2004'
-- EXEC spa_get_db_measurement_trend 1, 'f', '1,2,20'
-- EXEC spa_get_db_measurement_trend 2, 'c', '1,2,20', 'Marketing_Houston', '7/31/2003'
-- EXEC spa_get_db_measurement_trend 2, 'f', '1,2,20', 'Marketing_Houston', '7/31/2003'
-- EXEC spa_get_db_measurement_trend 3, 'c', '1,2,20', 'Power Plant (CF)', '7/31/2003'
-- EXEC spa_get_db_measurement_trend 3, 'f', '1,2,20', 'Producer 1 (FV)', '7/31/2003'

-- example to run measurement trend report
-- EXEC spa_get_db_measurement_trend 1, 'c', '1,2,20', NULL, '1/1/2001', '12/31/2004', 'd', NULL, NULL
-- EXEC spa_get_db_measurement_trend 1, 'f', '1,2,20', NULL, '1/1/2001', '4/30/2004', 'd', NULL, NULL

-- DROP PROC spa_get_db_measurement_trend

 create PROC [dbo].[spa_get_db_measurement_trend] 	
	@drill_down_level int = 1,
	@report_type varchar(1), 
	@sub_id varchar (100),
	@drill_down_param varchar(100)=NULL,
	@as_of_date varchar(100) = NULL,
	@as_of_date_to varchar(100) = NULL,
	@discount_option varchar(1) = NULL,
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL,
	@link_id varchar(500) = null											
AS

SET NOCOUNT ON

Declare @Sql_Select varchar(8000)

if @as_of_date_to is null
	set @as_of_date_to = @as_of_date
--set @qq=[dbo].[FNASelectProcessTableSql]('*','calcprocess_deals','')

if @report_type = 'c'
	set @Sql_Select =
	'
	select as_of_date [As Of Date], round(eff_per, 2) [Effectiveness %] from
	(
	select dbo.FNADateFormat(as_of_date) as_of_date, 
	round(sum(cfv_ratio * final_und_pnl_remaining ) / nullif(sum(final_und_pnl_remaining), 0), 2) eff_per
	from ('+ dbo.FNASelectProcessTableSql('*','calcprocess_deals','') + ') calcprocess_deals 
	where hedge_or_item = ''h'' AND hedge_type_value_id = 150 and 
	--WhatIf Changes
	(no_link is null OR no_link = ''n'') and
	as_of_date between ''' + @as_of_date + ''' and ''' + @as_of_date_to + ''' '

	+ case when (@sub_id is not null) then ' and fas_subsidiary_id in (' + @sub_id + ')' else '' end
	+ case when (@strategy_entity_id is not null) then ' and fas_strategy_id in (' + @strategy_entity_id + ')' else '' end
	+ case when (@book_entity_id is not null) then ' and fas_book_id in (' + @book_entity_id + ')' else '' end
	+ case when (@link_id is not null) then ' and link_id in (' + @link_id + ')' else '' end
	+
	' group by as_of_date 
	) xx where eff_per IS NOT NULL '
else
	set @Sql_Select =
	'
	select as_of_date [As Of Date], round(eff_per, 2) [Effectiveness %] from
	(
	select dbo.FNADateFormat(as_of_date) as_of_date, 
	(1 - sum(u_total_pnl)/nullif(sum(u_hedge_mtm), 0)) eff_per
	from ('+ dbo.FNASelectProcessTableSql('*','report_measurement_values','') + ') report_measurement_values
	where hedge_type_value_id = 151 and 
	as_of_date between ''' + @as_of_date + ''' and ''' + @as_of_date_to + ''' '

	+ case when (@sub_id is not null) then ' and sub_entity_id in (' + @sub_id + ')' else '' end
	+ case when (@strategy_entity_id is not null) then ' and strategy_entity_id in (' + @strategy_entity_id + ')' else '' end
	+ case when (@book_entity_id is not null) then ' and book_entity_id in (' + @book_entity_id + ')' else '' end
	+ case when (@link_id is not null) then ' and link_id in (' + @link_id + ')' else '' end
	+
	' group by as_of_date
	) xx where eff_per IS NOT NULL
	'
EXEC spa_print @Sql_Select
exec(@Sql_Select)

return







