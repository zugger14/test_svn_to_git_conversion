
IF OBJECT_ID(N'[dbo].[spa_Get_Price_Curves]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_Get_Price_Curves] 
GO 


CREATE PROC [dbo].[spa_Get_Price_Curves]  
	@curve_id varchar (50),
	@curve_type int,				
	@curve_source int,
	@from_date varchar(20),
	@to_date varchar(20),
	@tenor_from varchar(20) = null,
	@tenor_to varchar(20) = null,
	@ind_con_month varchar(1) = null
	
AS

SET NOCOUNT ON

--uncomment the following to test
-- -- declare @curve_id varchar (50),
-- -- 	@curve_type int,				
-- -- 	@curve_source int,
-- -- 	@from_date varchar(20),
-- -- 	@to_date varchar(20),
-- -- 	@tenor_from varchar(20) ,
-- -- 	@tenor_to varchar(20) 
-- -- 
-- -- 
-- -- set @curve_id ='12'
-- -- set @curve_type = 77
-- -- set @curve_source = 5029
-- -- set @from_date ='8/1/2002'
-- -- set @to_date ='2/1/2004'
-- -- set @tenor_from  = null
-- -- set @tenor_to  = null

-----------------------------

create table #formula_count
(total_count int)

exec('
insert into #formula_count
select count(*) from source_price_curve_def
where formula_id is not null and
source_curve_def_id in (' + @curve_id + ')')

if @curve_type=78 and @ind_con_month='h'
begin
	select 	dbo.FNADateFormat(maturity_date) + ' ' + cast(datepart(hh,maturity_date)+1 as varchar) AsOfDate , curve_value Value
	from source_price_curve
	where source_curve_def_id in (@curve_id) and
	Assessment_curve_type_value_id = @curve_type and 
	as_of_date between @from_date AND @to_date
	order by maturity_date

	return
end
if (select total_count from #formula_count) > 0
BEGIN

	declare @formula_curve_ids varchar(100)
	create table #formula_prices
	(
	curve_id int, 
	as_of_date datetime,
	maturity_date datetime,
	formula varchar(8000) COLLATE DATABASE_DEFAULT,
	formula_value float
	)

	select 	@formula_curve_ids = dbo.FNAFormulaCurves(fe.formula)
	from source_price_curve_def spcd inner join
	formula_editor fe on fe.formula_id = spcd.formula_id
	where spcd.source_curve_def_id in (@curve_id)

	declare @sql_formula varchar(8000)
	set @sql_formula = 
	'
	insert into #formula_prices
	select 	dl.curve_id, dl.as_of_date, dl.maturity_date, 
		dbo.FNAFormulaValueText(dl.as_of_date, dl.maturity_date, ' + cast(@curve_type as varchar) + ' , ' + cast(@curve_source as varchar) + ' ,fe.formula) formula, null
	from source_price_curve_def spcd inner join
	(select distinct cast(' + @curve_id + ' as int) curve_id,	 
		as_of_date, maturity_date
	from source_price_curve
	where 	source_curve_def_id IN (' + @formula_curve_ids + ') and
		assessment_curve_type_value_id = ' + cast(@curve_type as varchar) + ' and 
		as_of_date between dbo.FNAGetSQLStandardDate(''' + @from_date + ''') AND dbo.FNAGetSQLStandardDate(''' + @to_date + ''') 
	) dl on
  	dl.curve_id = spcd.source_curve_def_id inner join
	formula_editor fe on fe.formula_id = spcd.formula_id
	where spcd.source_curve_def_id in (' + @curve_id +')'
	
	--print @sql_formula

	exec(@sql_formula)

	--update #formula_prices set formula_value = formula

	--select * from #formula_prices

	declare @id int
	declare @as_date datetime
	declare @mat_date datetime
	declare @formula varchar(8000)
	declare @stmt varchar(8000)

	DECLARE formula_cursor CURSOR FOR 
	select curve_id, as_of_date, maturity_date, formula
	from #formula_prices

	OPEN formula_cursor
	
	FETCH NEXT FROM formula_cursor  
	INTO 	@id, @as_date, @mat_date, @formula

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @stmt = 'update #formula_prices set formula_value = ' + @formula +
				' where curve_id in (' + @curve_id + ') and
				as_of_date = ''' + dbo.FNAGetSQLStandardDate(@as_date) + ''' and 
				maturity_date = ''' +  dbo.FNAGetSQLStandardDate(@mat_date) + ''''

		exec (@stmt)	
	
		FETCH NEXT FROM formula_cursor  
		INTO 	@id, @as_date, @mat_date, @formula

	END
	
	CLOSE formula_cursor
	DEALLOCATE  formula_cursor
	

	select dbo.FNADateFormat(as_of_date) + ' ' + dbo.FNADateTimeFormat(maturity_date, 1) Maturity, formula_value  Value from #formula_prices

	Return

END




if @curve_id IN ('96', '97', '98') 
begin
	select 	dbo.FNADateFormat(as_of_date) + ' ' + dbo.FNAContractMonthFormat(maturity_date) Maturity, curve_value Value
	from source_price_curve
	where source_curve_def_id in (@curve_id) and
	Assessment_curve_type_value_id = @curve_type and 
	case when (@curve_type = 75) then dbo.FNAGetContractMonth(as_of_date) else as_of_date end between 
		case when (@curve_type = 75) then dbo.FNAGetContractMonth(@from_date) else @from_date end AND
		case when (@curve_type = 75) then dbo.FNAGetContractMonth(@to_date) else @to_date end 
	order by as_of_date, maturity_date


	--print @curve_id

	Return
end

if @curve_type = 75	
BEGIN
	select 	dbo.FNADateTimeFormat(maturity_date, 1) Maturity, curve_value Value
	from source_price_curve
	where 	source_curve_def_id in (@curve_id) and
		assessment_curve_type_value_id = @curve_type and 
		as_of_date between dbo.FNAGetSQLStandardDate(@from_date) AND dbo.FNAGetSQLStandardDate(@to_date)
	order by maturity_date 

	Return

END


-- if @curve_id IN ('96', '97', '98') 
-- begin
-- 
-- 
-- select 	dbo.FNAContractMonthFormat(maturity_date) Expiration, 
-- 	case when(as_of_date = '11/01/2005') then sum(curve_value) else 0 end [11/01/2005],
-- 	case when(as_of_date = '12/01/2005') then sum(curve_value) else 0 end [12/01/2005],
-- 	case when(as_of_date = '1/1/2006') then sum(curve_value) else 0 end [01/01/2006],
-- 	case when(as_of_date = '2/1/2006') then sum(curve_value) else 0 end [02/01/2006]
-- 
-- 	
-- 	--cast(round(curve_value, 2) as varchar)  Price,
-- 	--as_of_date
-- 	into #rec_temp
-- 
-- 	from source_price_curve
-- 	where source_curve_def_id = @curve_id and
-- 	Assessment_curve_type_value_id = @curve_type and 
-- 	as_of_date between @from_date and @to_date
-- 	group by dbo.FNAContractMonthFormat(maturity_date), as_of_date
-- 
-- 	declare @clm1 float
-- 	declare @clm2 float
-- 	declare @clm3 float
-- 	declare @clm4 float
-- 
-- 	select  @clm1 = sum([11/01/2005]) from #rec_temp
-- 	select  @clm2 =  sum([12/01/2005]) from #rec_temp
-- 	select  @clm3 =  sum([01/01/2006]) from #rec_temp
-- 	select  @clm4 =  sum([02/01/2006]) from #rec_temp
-- 
-- 	declare @rec_stmt varchar(5000)
-- 	
-- 	set @rec_stmt = 
-- 	'select Expiration ' 	+ case 	when (@clm1 <> 0) 
-- 			 		then ' ,[11/01/2005]' else '' end 
-- 				+ case 	when (@clm2 <> 0) 
-- 			 		then ' ,[12/01/2005]' else '' end 
-- 				+ case 	when (@clm3 <> 0) 
-- 			 		then ' ,[01/01/2006]' else '' end 
-- 				+ case 	when (@clm4 <> 0) 
-- 			 		then ' ,[02/01/2006]' else '' end 
-- 
-- 	+ ' from #rec_temp'
-- 	
-- 	exec(@rec_stmt)
-- 
-- 	Return
-- end



If @ind_con_month = 'y' AND @curve_type = 77
BEGIN

	CREATE TABLE #AllCurves
	(source_curve_def_id int)
	
-- 	EXEC spa_print 'insert into #AllCurves select distinct source_curve_def_id 
-- 	from source_price_curve_def where source_curve_def_id IN (' + @curve_id + ')'

	exec('insert into #AllCurves select distinct source_curve_def_id 
	from source_price_curve_def where source_curve_def_id IN (' + @curve_id + ')')
	
	DECLARE @maturity_date datetime, @clm_name varchar(10), @sql1 varchar(8000), @sql2 varchar(8000), @sql3 varchar(8000)
	DECLARE a_cursor CURSOR FOR
		select distinct maturity_date, --dbo.FNAContractMonthFormat(maturity_date) ConMonth 
			dbo.FNAGetSQLStandardDate(maturity_date) ConMonth
		from source_price_curve where as_of_date between CONVERT(DATETIME, @from_date , 102) and 
			CONVERT(DATETIME, @to_date , 102) 
		and source_curve_def_id IN (select source_curve_def_id from #AllCurves)
		and maturity_date  between CONVERT(DATETIME, isnull(@tenor_from, '1900-01-01') , 102) and 
			CONVERT(DATETIME, isnull(@tenor_to, '3990-01-01') , 102) and 
		assessment_curve_type_value_id = 77 AND curve_source_value_id = @curve_source
		order by maturity_date 
	
	set @sql1 = 'select dbo.FNADateFormat(as_of_date) AS [AsOfDate] '
	set @sql2 = 'select as_of_date '


	OPEN a_cursor
	FETCH NEXT FROM a_cursor INTO @maturity_date, @clm_name
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		set @sql1 = @sql1 + ', cast(sum([' + @clm_name + ']) as varchar) AS [' + @clm_name + ']' 
--		set @sql2 = @sql2 + ', case when (maturity_date = ''' + @clm_name + '-01' + ''' ) then sum(curve_value) else 0 end AS [' + @clm_name + ']' 
		set @sql2 = @sql2 + ', case when (maturity_date = ''' + @clm_name + ''' ) then sum(curve_value) else 0 end AS [' + @clm_name + ']' 
		
		FETCH NEXT FROM a_cursor INTO @maturity_date, @clm_name
	END 
	CLOSE a_cursor
	DEALLOCATE  a_cursor
	
-- 	EXEC spa_print len(@sql1)
-- 	EXEC spa_print len(@sql2)

	set @sql3 =  ' from( ' + @sql2 + ' from source_price_curve where ' +
		'as_of_date BETWEEN CONVERT(DATETIME, ''' + @from_date + ''' , 102) AND 
							CONVERT(DATETIME, ''' + @to_date + ''' , 102) ' +
		' and source_curve_def_id  IN (select source_curve_def_id from #AllCurves) ' + 
		' and maturity_date BETWEEN CONVERT(DATETIME, ''' + isnull(@tenor_from, '1900-01-01') + ''' , 102) AND 
							CONVERT(DATETIME, ''' + isnull(@tenor_to, '3990-01-01') + ''' , 102) ' +
		' AND curve_source_value_id = ' + cast(@curve_source as varchar) + 
		' and assessment_curve_type_value_id = 77
			group by as_of_date, maturity_date) xx group by as_of_date order by as_of_date'
	
	 --print @sql1
	exec (@sql1 + @sql3)

	RETURN
	-- EXEC spa_print @sql1
	-- 
	-- select as_of_date, sum(c112005) [2005-01],  sum(c212005) [2005-02], sum(c312005) [2005-03]
	-- from(
	-- select as_of_date,
	--        case when (maturity_date = '1/1/2005') then sum(curve_value) else 0 end as 'c112005',
	--        case when (maturity_date = '2/1/2005') then sum(curve_value) else 0 end as 'c212005',
	--        case when (maturity_date = '3/1/2005') then sum(curve_value) else 0 end as 'c312005'
	-- from source_price_curve where as_of_date in ('9/1/2004', '9/2/2004', '9/3/2004') and source_curve_def_id = 21
	-- and maturity_date  between '1/1/2005' and '3/1/2005' and assessment_curve_type_value_id = 77
	-- group by as_of_date, maturity_date
	-- ) xx group by as_of_date 
END

------------------------------------- logic to return  individual contract month for forward only


Declare @Sql_Select varchar(5000)
Declare @Curve_Name varchar(100)
Declare @Sql_Insert varchar(5000)
Declare @tot_Curves int
Declare @tot_Tables int

Declare @Final_Sql_Select varchar(5000)

-- select * from #tempPriceCurves

--drop table #tempPriceCurves

CREATE TABLE #tempPriceCurves
	(PCurveID int identity(1,1),
	Curve_Id int,
	Curve_Name varchar(50) COLLATE DATABASE_DEFAULT)

SET @Sql_Insert = 'INSERT INTO #tempPriceCurves Select source_curve_def_id,curve_name from source_price_curve_def where source_curve_def_id IN(' 
				+ @curve_id + ')'

EXEC (@Sql_Insert)

--select * from #tempPriceCurves

SET @tot_Curves = @@RowCount
SET @tot_Tables = @@RowCount

-- SELECT * from #tempPriceCurvesResult
-- drop table #tempPriceCurvesResult

CREATE TABLE #tempPriceCurvesResult
	(AsOfDate DateTime)
--	(AsOfDate varchar (15))


SET @Final_Sql_Select = 'select dbo.FNADateFormat(AsOfDate) as AsOfDate '
--To add the first curve

SET @curve_id = (select Curve_Id from #tempPriceCurves where PCurveID = 1)



SET @curve_Name = (select  dbo.FNAReplaceSpecialChars(curve_name, '_') 
			from #tempPriceCurves where PCurveID = 1)


-- SET @curve_Name = (select  CASE WHEN (CHARINDEX('-',curve_name)<>0) THEN REPLACE ( curve_name , '-' , '_' )
-- 				 WHEN (CHARINDEX(':',curve_name)<>0) THEN REPLACE ( curve_name , ':' , '_' ) 
-- 					WHEN (CHARINDEX(' ',curve_name)<>0) THEN REPLACE ( curve_name , ' ' , '_' ) 
-- 				ELSE curve_name END 
-- 			from #tempPriceCurves where PCurveID = 1)

set @sql_select = 'ALTER TABLE #tempPriceCurvesResult ADD [' + @curve_Name + '] float NULL'
exec (@sql_select)

SET @Final_Sql_Select = @Final_Sql_Select + ', cast([' + @curve_Name + '] as varchar) as [' + @curve_Name +']'

SET @Sql_Select = 'INSERT INTO #tempPriceCurvesResult select  dbo.FNAGetSQLStandardDate(as_of_date), avg(curve_value) as curve_value '
		 + ' FROM source_price_curve WHERE assessment_curve_type_value_id = ' + CAST(@curve_type As Char)
		 + ' AND source_curve_def_id in ( ' + @curve_id
		 + ') AND as_of_date BETWEEN CONVERT(DATETIME, ''' + @from_date + ''' , 102) AND 
						CONVERT(DATETIME, ''' + @to_date + ''' , 102)'
		 + ' AND curve_source_value_id = ' + CAST(@curve_source As Char)

if @tenor_from IS NOT NULL AND @tenor_to IS NOT NULL
	SET @Sql_Select = @Sql_Select + ' AND maturity_date BETWEEN CONVERT(DATETIME, ''' + @tenor_from + ''' , 102) AND CONVERT(DATETIME, ''' + @tenor_to + ''' , 102)'

SET @Sql_Select = @Sql_Select + ' GROUP by as_of_date ORDER by as_of_date'

EXEC (@Sql_Select)


If @@Rowcount = 0 
	BEGIN	
	Exec spa_ErrorHandler 1, 'CreatePriceCurves', 
			'spa_Get_Price_Curves', 'Selection Error', 
			'One or all of the Curve IDs do not have data.', ''
	RETURN
	END

Declare @counter int
SET @counter = 2

While @counter < = @tot_Curves 
	BEGIN
	SET @curve_id = (select Curve_Id from #tempPriceCurves where PCurveID = @counter)
-- 	SET @curve_Name = (select CASE WHEN (CHARINDEX('-',curve_name)<>0) THEN REPLACE ( curve_name , '-' , '_' )
-- 				 WHEN (CHARINDEX(':',curve_name)<>0) THEN REPLACE ( curve_name , ':' , '_' ) 
-- 					WHEN (CHARINDEX(' ',curve_name)<>0) THEN REPLACE ( curve_name , ' ' , '_' ) 
-- 				ELSE curve_name END
-- 				 from #tempPriceCurves where PCurveID = @counter)

	SET @curve_Name = (select  dbo.FNAReplaceSpecialChars(curve_name, '_') 
			from #tempPriceCurves where PCurveID = @counter)


	set @sql_select = 'ALTER TABLE #tempPriceCurvesResult ADD [' + @curve_Name + '] float NULL'
	exec (@sql_select)

	SET @Final_Sql_Select = @Final_Sql_Select + ', cast([' + @curve_Name + '] as varchar) as [' + @curve_Name+']'

	SET @Sql_Select = 'UPDATE #tempPriceCurvesResult 
				SET ' + @curve_Name + '= A.curve_value
				FROM #tempPriceCurvesResult, (select  dbo.FNAGetSQLStandardDate(as_of_date) as as_of_date , 
					avg(curve_value) as curve_value'
				 	+ ' FROM source_price_curve WHERE assessment_curve_type_value_id = ' + CAST(@curve_type As Char)
				 	+ ' AND source_curve_def_id in (' + @curve_id
				 	+ ') AND as_of_date BETWEEN CONVERT(DATETIME, ''' + @from_date + ''' , 102) AND 
								CONVERT(DATETIME, ''' + @to_date + ''' , 102)'
					+ ' AND curve_source_value_id = ' + CAST(@curve_source As Char)
		
		if @tenor_from IS NOT NULL AND @tenor_to IS NOT NULL
			SET @Sql_Select = @Sql_Select + ' AND maturity_date BETWEEN CONVERT(DATETIME, ''' + @tenor_from + ''' , 102) 
				AND CONVERT(DATETIME, ''' + @tenor_to + ''' , 102)'
	
	SET @Sql_Select = @Sql_Select + ' GROUP by as_of_date  ) As A
				WHERE #tempPriceCurvesResult.AsOfDate = A.as_of_date'
	
	EXEC (@Sql_Select)

	SET @counter = @counter + 1
END





SET @Final_Sql_Select = @Final_Sql_Select + ' from #tempPriceCurvesResult'

EXEC spa_print @Final_Sql_Select

exec (@Final_Sql_Select)

















