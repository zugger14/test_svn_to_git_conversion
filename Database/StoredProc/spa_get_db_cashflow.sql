
IF OBJECT_ID(N'[dbo].[spa_get_db_cashflow]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_db_cashflow]
GO 

-- exec spa_get_db_cashflow 'c'


-- The following applies to both cash flow and Earnings plots.
-- '1,2,20' IS AN OUTPUT BASED ON exec spa_get_privileged_subs 107
-- 1st call is for dashboard. 2nd passes 2 as the second to last parameter and Term as the last param
-- 3rd drill down passes 3 as the second to last parameter and Term as the last param

-- exec spa_get_db_cashflow 'c', '1,2,20',  1
-- exec spa_get_db_cashflow 'c', '1,2,20',  2, 2005
-- exec spa_get_db_cashflow 'c', '1,2,20',  3, '2nd Q-2005'
-- exec spa_get_db_cashflow 'e', '1,2,20', 1
-- exec spa_get_db_cashflow 'e', '1,2,20', 2, 2003
-- exec spa_get_db_cashflow 'e', '1,2,20', 3, '3rd Q-2003'

-- EXEC spa_get_db_cashflow 'c','1,20,30,71,94,95,96', 3
-- drop table #temp


-- report_type c(cash flow), e(earnings)
create PROC [dbo].[spa_get_db_cashflow] 
	@report_type char, 
	@sub_entity_id varchar(100), 
	@drill_down_level int = 1, 
	@drill_param varchar(100) = NULL
	
AS

declare @as_of_date varchar(20)
declare @granularity_type char
select @as_of_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from report_measurement_values


--select dbo.FNAGetSQLStandardDate(max(as_of_date)) from report_measurement_values

If @drill_down_level in (1, 2)
BEGIN
	CREATE TABLE [#temp] (
		[term] [varchar] (20) COLLATE DATABASE_DEFAULT NOT NULL ,
--		[subsidiary] [int] NOT NULL,
		[subsidiary] [varchar] (100) COLLATE DATABASE_DEFAULT NOT NULL,
		[value] [float] NULL,
		[term_month] datetime NOT NULL
	) 

	set @granularity_type = case when (@drill_down_level = 1) then 'a' else 'q' end
	
	INSERT  #temp EXEC  spa_Create_Cash_Flow_Report @as_of_date, @sub_entity_id, NULL, NULL, 
				'd', @granularity_type, @report_type, 's', 1

	
	
	If @report_type = 'c'
		select v.Term, v.Cashflow from (select term as Term, cast(round(sum(value), 0) as varchar) As Cashflow, 
			max(term_month) term_month from  #temp 
			where Year(term_month) = case when (@drill_param IS NULL) then Year(term_month) else @drill_param end
			group by Term ) v 
			order by v.term_month
	Else

		select v.Term, v.Earnings from (select term as Term, cast(round(sum(value), 0) as varchar) As Earnings, 
			max(term_month) term_month  from  #temp 
			where Year(term_month) = case when (@drill_param IS NULL) then Year(term_month) else @drill_param end
			group by Term) v  
			order by v.term_month
		
END

If @drill_down_level in (3)
BEGIN
	CREATE TABLE [#temp1] (
		[term] [varchar] (20) COLLATE DATABASE_DEFAULT NOT NULL ,
-- 		[subsidiary] [int] NOT NULL,
		[subsidiary] [varchar] (100) COLLATE DATABASE_DEFAULT NOT NULL,
		[accounting] varchar (20) COLLATE DATABASE_DEFAULT not null,
		[value] [float] NULL,
		[term_month] datetime NOT NULL
	) 

	set @granularity_type = 'm'
	
	INSERT  #temp1 EXEC  spa_Create_Cash_Flow_Report @as_of_date, @sub_entity_id, NULL, NULL, 
				'd', @granularity_type, @report_type, 'd', 1


	--select * from #temp1
-- 	If @report_type = 'c'
		select dbo.FNAGetTermGrouping(val.term_month, 'm') Term, 
			sum(val.Accrual) Accrual, sum(val.MTM) MTM from (select v.Term, 
			case when (v.accounting = 'Accrual') then sum(cast(v.Cashflow as float)) else 0 end as Accrual,
			case when (v.accounting = 'MTM') then sum(cast(v.Cashflow as float)) else 0 end as MTM,
			max(term_month) as term_month 
			from (select term as Term, accounting accounting, cast(round(sum(value), 0) as varchar) As Cashflow, 
			max(term_month) term_month from  #temp1 
			where dbo.FNAGetTermGrouping(term_month, 'q') = case when (@drill_param IS NULL) then dbo.FNAGetTermGrouping(term_month, 'q') else @drill_param end
			group by Term, accounting) v 
			group by v.Term, v.accounting) val
			group by val.term_month

-- 	Else
-- 
-- 
-- 		select v.Term, v.Earnings from (select term as Term, cast(round(sum(value), 0) as varchar) As Earnings, 
-- 			max(term_month) term_month  from  #temp1 
-- 			where dbo.FNAGetTermGrouping(term_month, 'q') = case when (@drill_param IS NULL) then dbo.FNAGetTermGrouping(term_month, 'q') else @drill_param end
-- 			group by Term) v  
-- 			order by v.term_month
END








