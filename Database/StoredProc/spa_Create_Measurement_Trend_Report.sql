
IF OBJECT_ID(N'spa_Create_Measurement_Trend_Report', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Create_Measurement_Trend_Report]
 GO 



--===========================================================================================
--This Procedure returns source system configuration for each strategy
--Input Parameters:
--@as_of_date - As of date
-- @sub_id - subsidiary Id (optional)
--@strategy_id - strategy Id (optional)
--@book_id - book Id (optional)
--@discount_flag - 'u' or 'd'
--@hedge_type = 'c' or 'f'

--===========================================================================================
-- EXEC spa_Create_Measurement_Trend_Report '7/31/2003', '1', '6', null, 'd', 'c'
-- EXEC spa_Create_Measurement_Trend_Report '7/31/2003', '1,2,20', null, null, 'd', 'c'
-- EXEC spa_Create_Measurement_Trend_Report '7/31/2003', '1,2,20', null, null, 'd', 'f'


CREATE PROC [dbo].[spa_Create_Measurement_Trend_Report] @as_of_date varchar (20),
						@sub_id varchar (100),
						@strategy_id varchar (100) = null,
						@book_id varchar (100) = null,
						@discount_flag char,
						@hedge_type char
	
AS

SET NOCOUNT ON


Declare @Sql_Select varchar(5000)
Declare @Sql_GroupBy varchar(1000)

CREATE TABLE #my_temp_cashflow
(sub Varchar(100) COLLATE DATABASE_DEFAULT,
strategy varchar(100) COLLATE DATABASE_DEFAULT, 
book varchar(100) COLLATE DATABASE_DEFAULT,
hedge float,
item float,
st_asset float,
st_liab float,
lt_asset float,
lt_liab float,
aoci float,
pnl float,
sett float,
inv float,
cash float)

CREATE TABLE #my_temp_fairvalue
(sub Varchar(100) COLLATE DATABASE_DEFAULT,
strategy varchar(100) COLLATE DATABASE_DEFAULT, 
book varchar(100) COLLATE DATABASE_DEFAULT,
hedge float,
item float,
st_asset_h float,
st_liab_h float,
lt_asset_h float,
lt_liab_h float,
st_asset_i float,
st_liab_i float,
lt_asset_i float,
lt_liab_i float,
pnl float,
sett float,
cash float)


If @as_of_date IS NULL 
	SELECT @as_of_date = dbo.FNAGetSQLStandardDate(MAX(as_of_date)) from report_measurement_values
--	SELECT @as_of_date = dbo.FNADateFormat(MAX(as_of_date)) from report_measurement_values

If (@sub_ID IS NOT NULL AND @strategy_ID IS NOT NULL AND @book_ID IS NOT NULL) OR
	@book_ID IS NOT NULL
BEGIN
	SET @Sql_GroupBy = ' GROUP BY sub, strategy, book'
	SET @Sql_Select = 'SELECT sub As Subsidiary, strategy As Strategy, book As Book'
END
If (@SUB_ID IS NOT NULL AND @strategy_ID IS NOT NULL AND @book_ID IS NULL) OR @strategy_ID IS NOT NULL
BEGIN
	SET @Sql_GroupBy = ' GROUP BY sub, strategy'
	SET @Sql_Select = 'SELECT sub As Subsidiary, strategy AS Strategy'
END
If @sub_ID IS NOT NULL AND @strategy_ID IS NULL AND @book_ID IS NULL 
BEGIN
	SET @Sql_GroupBy = ' GROUP BY sub'
	SET @Sql_Select = 'SELECT sub As Subsidiary'

END

--select @Sql_Select, @sub_ID, @strategy_ID, @book_ID

IF @hedge_type = 'c'
BEGIN
	
	INSERT #my_temp_cashflow EXEC 
	spa_Create_hedges_Measurement_Report @as_of_date, @sub_id, @strategy_id, @book_id, @discount_flag, 'f', 'c', 's'

	--select * from #my_temp_cashflow
--	SET @Sql_Select = @Sql_Select + ', cast(round(abs(sum(aoci)/sum(hedge)), 2) as varchar) As PercentageEffective  FROM  #my_temp_cashflow'
-- replace above line with the bewlo on 03/31/2004
	SET @Sql_Select = @Sql_Select + ', cast(round(abs(sum(aoci)/nullif(sum(st_asset + lt_asset - st_liab - lt_liab), 0)), 2) as varchar) As PercentageEffective  FROM  #my_temp_cashflow'

	--select @Sql_Select
END
ELSE
BEGIN
	INSERT #my_temp_fairvalue EXEC 
	spa_Create_hedges_Measurement_Report @as_of_date, @sub_id, @strategy_id, @book_id, @discount_flag, 'f', 'f', 's'

--	SET @Sql_Select = @Sql_Select + ', abs(sum(hedge - pnl)/sum(hedge))  As PercentageEffective FROM  #my_temp_fairvalue'
--	SET @Sql_Select = @Sql_Select + ', cast(round(case when (abs(sum(hedge)) >  abs(sum(item))) then (-1*sum(item)/sum(hedge)) else (-1*sum(hedge)/sum(item)) End , 2) as varchar) As PercentageEffective FROM  #my_temp_fairvalue'
-- replace above line with the bewlo on 03/31/2004
	SET @Sql_Select = @Sql_Select + ', cast(round(
			case when (abs(sum(st_asset_h + lt_asset_h - st_liab_h - lt_liab_h)) >  abs(sum(st_asset_i + lt_asset_i - st_liab_i - lt_liab_i))) then 
				(-1*sum(st_asset_i + lt_asset_i - st_liab_i - lt_liab_i)/nullif(sum(st_asset_h + lt_asset_h - st_liab_h - lt_liab_h),0)) 
			else (-1*sum(st_asset_h + lt_asset_h - st_liab_h - lt_liab_h)/nullif(sum(st_asset_i + lt_asset_i - st_liab_i - lt_liab_i), 0)) 
			End , 2) as varchar) As PercentageEffective FROM  #my_temp_fairvalue'
END
	
SET @Sql_Select = @Sql_Select + @Sql_GroupBy

--select @Sql_Select

Exec(@Sql_Select)













