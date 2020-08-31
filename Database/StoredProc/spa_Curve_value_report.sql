

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Curve_value_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Curve_value_report]
 

GO
CREATE PROC [dbo].[spa_Curve_value_report]
	@report_type char(1), -- 'c' curve report,'m' missing report,'c' Contract charge type report
	@subsidiary_id varchar(MAX),
	@strategy_id VARCHAR(MAX) = null,
	@book_id VARCHAR(MAX) = null,
	@curve_id varchar (MAX),
	@curve_type int,
	@from_date varchar(20)=null,
	@to_date varchar(20)=null,
	@granularity int=null,
	@role_id int=null	
AS
SET NOCOUNT ON 
BEGIN
DECLARE @sql_select varchar(5000)	

if @granularity is null
set @granularity=980


set @to_date = case when @to_date is not null then @to_date else @from_date end

create table #temp(CurveId int,Name varchar(100) COLLATE DATABASE_DEFAULT ,Description varchar(200) COLLATE DATABASE_DEFAULT )

	--select if the passed id is strategy id	
set @sql_select='
insert into #temp

	SELECT spcd.source_curve_def_id As CurveId, spcd.curve_name As Name, spcd.curve_des As Description 
	FROM  source_price_curve_def spcd 
	inner join  source_price_curve_def_privilege spcdf
	on  spcd.source_curve_def_id = spcdf.source_curve_def_id and spcdf.sub_entity_id IS NULL and spcdf.role_id IS NULL
where 
	
	(source_curve_type_value_id = isnull('+cast(@curve_type as varchar)+', source_curve_type_value_id))'
	+case when @role_id is not null then ' AND spcdf.role_id = '+cast(@role_id as varchar) else '' end+'
	UNION 

  SELECT spcd.source_curve_def_id As CurveId, spcd.curve_name As Name, spcd.curve_des As Description 
	FROM  source_price_curve_def spcd 
	inner join source_price_curve_def_privilege spcdf
	on  spcd.source_curve_def_id = spcdf.source_curve_def_id 
	and spcdf.sub_entity_id in('+@subsidiary_id+') 
	left join application_role_user ar on ar.role_id=spcdf.role_id
	and ar.user_login_id=dbo.FNADBUser()
	where 
 	(source_curve_type_value_id = isnull('+cast(@curve_type as varchar)+', source_curve_type_value_id))'
	+case when @role_id is not null then ' AND spcdf.role_id = '+cast(@role_id as varchar) else '' end+'

	UNION 

	SELECT spcd.source_curve_def_id As CurveId, spcd.curve_name As Name, spcd.curve_des As Description 
	FROM  source_price_curve_def spcd 
	inner join source_price_curve_def_privilege spcdf
	on  spcd.source_curve_def_id = spcdf.source_curve_def_id 
	and spcdf.sub_entity_id IS NULL
	left join application_role_user ar on ar.role_id=spcdf.role_id
	and ar.user_login_id=dbo.FNADBUser()
	where 
	(source_curve_type_value_id = isnull('+cast(@curve_type as varchar)+', source_curve_type_value_id))'
	+case when @role_id is not null then ' AND spcdf.role_id = '+cast(@role_id as varchar) else '' end+'
	UNION

	SELECT spcd.source_curve_def_id As CurveId, spcd.curve_name As Name, spcd.curve_des As Description 
	FROM  source_price_curve_def spcd 
	inner join source_price_curve_def_privilege spcdf
	on  spcd.source_curve_def_id = spcdf.source_curve_def_id 
	and spcdf.sub_entity_id in('+@subsidiary_id+') AND spcdf.role_id IS NULL
	where 
	(source_curve_type_value_id = isnull('+cast(@curve_type as varchar)+', source_curve_type_value_id))'
	+case when @role_id is not null then ' AND spcdf.role_id = '+cast(@role_id as varchar) else '' end+'
'

exec(@sql_select)




---#############################

if @report_type='c'
BEGIN

if @granularity=982 --- Show hourly Data
	set @sql_select=
	' select 
			spcd.curve_name as Curve,curve_des as Description,
--			dbo.FNADateFormat(maturity_date)  [Date], 
--			(case when datepart(hh,maturity_date)=0 then curve_value else 0 end) as H1,
--			(case when datepart(hh,maturity_date)=1 then curve_value else 0 end) as H2,
--			(case when datepart(hh,maturity_date)=2 then curve_value else 0 end) as H3,
--			(case when datepart(hh,maturity_date)=3 then curve_value else 0 end) as H4,
--			(case when datepart(hh,maturity_date)=4 then curve_value else 0 end) as H5,
--			(case when datepart(hh,maturity_date)=5 then curve_value else 0 end) as H6,
--			(case when datepart(hh,maturity_date)=6 then curve_value else 0 end) as H7,
--			(case when datepart(hh,maturity_date)=7 then curve_value else 0 end) as H8,
--			(case when datepart(hh,maturity_date)=8 then curve_value else 0 end) as H9,
--			(case when datepart(hh,maturity_date)=9 then curve_value else 0 end) as H10,
--			(case when datepart(hh,maturity_date)=10 then curve_value else 0 end) as H11,
--			(case when datepart(hh,maturity_date)=11 then curve_value else 0 end) as H12,
--			(case when datepart(hh,maturity_date)=12 then curve_value else 0 end) as H13,
--			(case when datepart(hh,maturity_date)=13 then curve_value else 0 end) as H14,
--			(case when datepart(hh,maturity_date)=14 then curve_value else 0 end) as H15,
--			(case when datepart(hh,maturity_date)=15 then curve_value else 0 end) as H16,
--			(case when datepart(hh,maturity_date)=16 then curve_value else 0 end) as H17,
--			(case when datepart(hh,maturity_date)=17 then curve_value else 0 end) as H18,
--			(case when datepart(hh,maturity_date)=18 then curve_value else 0 end) as H19,
--			(case when datepart(hh,maturity_date)=19 then curve_value else 0 end) as H20,
--			(case when datepart(hh,maturity_date)=20 then curve_value else 0 end) as H21,
--			(case when datepart(hh,maturity_date)=21 then curve_value else 0 end) as H22,
--			(case when datepart(hh,maturity_date)=22 then curve_value else 0 end) as H23,
--			(case when datepart(hh,maturity_date)=23 then curve_value else 0 end) as H24
		dbo.FNADateFormat(maturity_date) + '' '' + cast(datepart(hh,maturity_date)+1 as varchar) [Date],
		curve_value as [Value]
		from source_price_curve spc
		inner join #temp tmp on tmp.curveid=spc.source_curve_def_id
		left join source_price_curve_def spcd on spc.source_curve_def_id=spcd.source_curve_def_id
		where 1=1 '+
		case when @curve_id is not null then ' AND spcd.source_curve_def_id in ('+@curve_id+')' else '' end+

		 ' AND source_curve_type_value_id = '+cast(@curve_type as varchar)+'  and
		case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth(as_of_date) else as_of_date end between 
			case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth('''+@from_date+''') else '''+@from_date+''' end AND
			case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth('''+@to_date+''') else '''+@to_date+''' end 
		order by as_of_date, maturity_date '

else
	set @sql_select=
	' select spcd.curve_name as Curve,curve_des as Description,
		'+ case when @granularity=980 then ' dbo.FNAContractMonthFormat(maturity_date) as [Month]' 
		   when  @granularity=986 then ' Year(maturity_date) as [Year] '	
		else ' dbo.FNADateFormat(maturity_date)  [Date]' end +'
		, max(curve_value) Value

		from source_price_curve spc
		inner join #temp tmp on tmp.curveid=spc.source_curve_def_id
		left join source_price_curve_def spcd on spc.source_curve_def_id=spcd.source_curve_def_id
		where 1=1 '+
		case when @curve_id is not null then ' AND spcd.source_curve_def_id in ('+@curve_id+')' else '' end+

		 ' AND source_curve_type_value_id = '+cast(@curve_type as varchar)+'  and '
		+case when @granularity=986 then ' Year(as_of_date) between year('''+@from_date+''') and year('''+@to_date+''')' else
		' case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth(as_of_date) else as_of_date end between 
		  case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth('''+@from_date+''') else '''+@from_date+''' end AND
		  case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth('''+@to_date+''') else '''+@to_date+''' end '
		end+	
		' group by spcd.curve_name,curve_des,'+ case when @granularity=980 then ' dbo.FNAContractMonthFormat(maturity_date) '
		   when @granularity=986 then ' Year(maturity_date)'
		   else ' dbo.FNADateFormat(maturity_date)' end +
		' order by spcd.curve_name,'
		+case when @granularity=980 then ' dbo.FNAContractMonthFormat(maturity_date) '
		 when @granularity=986 then ' Year(maturity_date)'
		 else ' dbo.FNADateFormat(maturity_date)' end 
	--print @sql_select	
	EXEC(@sql_select)
END
ELSE if @report_type='m'
BEGIN
declare @count int
set @count=0
create table #temp_month(curve_id int,date datetime)

if @granularity is null 
begin
	while dateadd(year,@count,@from_date)<=@to_date
	BEGIN
		set @sql_select=
		' insert into #temp_month(curve_id,date)
		select source_curve_def_id,dateadd(year,'+cast(@count as varchar)+','''+@from_date+''')
			   from source_price_curve_def spcd inner join #temp tmp on tmp.curveid=spcd.source_curve_def_id
			where 1=1 '
				+case when @curve_id is not null then ' AND spcd.source_curve_def_id in ('+@curve_id+')' else '' end

		exec(@sql_select)
		set @count=@count+1
	END
end
else if @granularity=986 -- yearly
BEGIN
while dateadd(year,@count,@from_date)<=@to_date
BEGIN
	set @sql_select=
	' insert into #temp_month(curve_id,date)
	select source_curve_def_id,dateadd(year,'+cast(@count as varchar)+','''+@from_date+''')
		   from source_price_curve_def spcd inner join #temp tmp on tmp.curveid=spcd.source_curve_def_id
		where 1=1 '
			+case when @curve_id is not null then ' AND spcd.source_curve_def_id in ('+@curve_id+')' else '' end

	exec(@sql_select)
	set @count=@count+1
END
END
else if @granularity=980 -- Monthly
BEGIN
while dateadd(month,@count,@from_date)<=@to_date
BEGIN
	set @sql_select=
	' insert into #temp_month(curve_id,date)
	select source_curve_def_id,dateadd(month,'+cast(@count as varchar)+','''+@from_date+''')
		   from source_price_curve_def spcd inner join #temp tmp on tmp.curveid=spcd.source_curve_def_id
		where 1=1 '
			+case when @curve_id is not null then ' AND spcd.source_curve_def_id in ('+@curve_id+')' else '' end
--print @sql_select
	exec(@sql_select)
	set @count=@count+1
END
END
else if @granularity=981 -- Daily
BEGIN
while dateadd(day,@count,@from_date)<=@to_date
BEGIN
	set @sql_select=
	' insert into #temp_month(curve_id,date)
	select source_curve_def_id,dateadd(day,'+cast(@count as varchar)+','''+@from_date+''')
		   from source_price_curve_def spcd inner join #temp tmp on tmp.curveid=spcd.source_curve_def_id
		where 1=1 '
			+case when @curve_id is not null then ' AND spcd.source_curve_def_id in ('+@curve_id+')' else '' end

	exec(@sql_select)
	set @count=@count+1
END
END
else if @granularity=982 -- Daily
BEGIN
DECLARE @hr_count int


while dateadd(hh,@count,@from_date)<=@to_date
BEGIN


	set @sql_select=
	' insert into #temp_month(curve_id,date)
	select source_curve_def_id,dateadd(hh,'+cast(@count as varchar)+','''+@from_date+''')
		   from source_price_curve_def spcd inner join #temp tmp on tmp.curveid=spcd.source_curve_def_id
		where 1=1 '
			+case when @curve_id is not null then ' AND spcd.source_curve_def_id in ('+@curve_id+')' else '' end

	exec(@sql_select)
	set @count=@count+1
END
END


if @granularity=982 --- Show hourly Data
begin
	set @sql_select=
	' select 
			spcd.curve_name as Curve,curve_des as Description,
--			dbo.FNADateFormat(tmp.date)  [Date], 
--			(case when datepart(hh,maturity_date)=0 then curve_value else 0 end) as H1,
--			(case when datepart(hh,maturity_date)=1 then curve_value else 0 end) as H2,
--			(case when datepart(hh,maturity_date)=2 then curve_value else 0 end) as H3,
--			(case when datepart(hh,maturity_date)=3 then curve_value else 0 end) as H4,
--			(case when datepart(hh,maturity_date)=4 then curve_value else 0 end) as H5,
--			(case when datepart(hh,maturity_date)=5 then curve_value else 0 end) as H6,
--			(case when datepart(hh,maturity_date)=6 then curve_value else 0 end) as H7,
--			(case when datepart(hh,maturity_date)=7 then curve_value else 0 end) as H8,
--			(case when datepart(hh,maturity_date)=8 then curve_value else 0 end) as H9,
--			(case when datepart(hh,maturity_date)=9 then curve_value else 0 end) as H10,
--			(case when datepart(hh,maturity_date)=10 then curve_value else 0 end) as H11,
--			(case when datepart(hh,maturity_date)=11 then curve_value else 0 end) as H12,
--			(case when datepart(hh,maturity_date)=12 then curve_value else 0 end) as H13,
--			(case when datepart(hh,maturity_date)=13 then curve_value else 0 end) as H14,
--			(case when datepart(hh,maturity_date)=14 then curve_value else 0 end) as H15,
--			(case when datepart(hh,maturity_date)=15 then curve_value else 0 end) as H16,
--			(case when datepart(hh,maturity_date)=16 then curve_value else 0 end) as H17,
--			(case when datepart(hh,maturity_date)=17 then curve_value else 0 end) as H18,
--			(case when datepart(hh,maturity_date)=18 then curve_value else 0 end) as H19,
--			(case when datepart(hh,maturity_date)=19 then curve_value else 0 end) as H20,
--			(case when datepart(hh,maturity_date)=20 then curve_value else 0 end) as H21,
--			(case when datepart(hh,maturity_date)=21 then curve_value else 0 end) as H22,
--			(case when datepart(hh,maturity_date)=22 then curve_value else 0 end) as H23,
--			(case when datepart(hh,maturity_date)=23 then curve_value else 0 end) as H24
		dbo.FNADateFormat(tmp.date) + '' '' + cast(datepart(hh,tmp.date)+1 as varchar) [Date]
		from #temp_month tmp 
		left join source_price_curve_def spcd on tmp.curve_id=spcd.source_curve_def_id
		left join source_price_curve spc  on tmp.date=spc.maturity_date
		and spc.source_curve_def_id=spcd.source_curve_def_id
		AND source_curve_type_value_id = '+cast(@curve_type as varchar)+'  and
		case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth(as_of_date) else as_of_date end between 
			case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth('''+@from_date+''') else '''+@from_date+''' end AND
			case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth('''+@to_date+''') else '''+@to_date+''' end 

		where 1=1 AND spc.curve_value is null'+
		case when @curve_id is not null then ' AND spcd.source_curve_def_id in ('+@curve_id+')' else '' end+
		' order by spcd.curve_name,as_of_date, maturity_date '
end
else

	set @sql_select=
	' select spcd.curve_name as Curve,curve_des as Description,
			'+case  when @granularity=980 then ' dbo.FNAContractMonthFormat(tmp.date) as [Month] ' 
		   when  @granularity=986 then ' Year(tmp.date) as [Year] ' 	
		   else ' dbo.FNADateFormat(tmp.date)  [Date] ' end +'
--		, ''Missing'' Value


		from #temp_month tmp 
		left join source_price_curve_def spcd on tmp.curve_id=spcd.source_curve_def_id
		left join source_price_curve spc  on tmp.date=spc.as_of_date
		and spc.source_curve_def_id=spcd.source_curve_def_id
		AND source_curve_type_value_id = '+cast(@curve_type as varchar)+'  and '
		+case when @granularity=986 then ' Year(as_of_date) between year('''+@from_date+''') and year('''+@to_date+''')' else
		' case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth(as_of_date) else as_of_date end between 
			case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth('''+@from_date+''') else '''+@from_date+''' end AND
			case when ('+cast(@curve_type as varchar)+' = 75) then dbo.FNAGetContractMonth('''+@to_date+''') else '''+@to_date+''' end '
		end+
		' where 1=1 AND spc.curve_value is null'+
		case when @curve_id is not null then ' AND spcd.source_curve_def_id in ('+@curve_id+')' else '' end+
		' group by spcd.curve_name,curve_des, '
		+ case when @granularity=980 then '	dbo.FNAContractMonthFormat(tmp.date)'
		  when 	@granularity=986 then '	Year(tmp.date)'
	      else ' dbo.FNADateFormat(tmp.date)' end+
		' order by spcd.curve_name,' 
		+case when @granularity=980 then ' dbo.FNAContractMonthFormat(tmp.date) '
		 when @granularity=986 then ' Year(tmp.date)'
		 --else ' tmp.date' end 	
		 else ' dbo.FNADateFormat(tmp.date)' end 	
	--print @sql_select
	EXEC(@sql_select)

END
ELSE if @report_type='t' -- contract charge type report
BEGIN

----################# To find out all the curves used in contracts
create table #temp_curve_formula(
		--formula_id int,
		curve_id int,
		contract_name varchar(100) COLLATE DATABASE_DEFAULT ,
		contract_charge_type varchar(100) COLLATE DATABASE_DEFAULT ,
		curve_name varchar(100) COLLATE DATABASE_DEFAULT ,
		curve_desc varchar(100) COLLATE DATABASE_DEFAULT 		
)
--
insert into #temp_curve_formula
select 
	distinct
	--fe.formula_id,
	substring(substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))),charindex('(',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))))+1,len(substring(substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))),charindex('(',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))))+1,10))-1) as curve_id,
	max(cg.contract_name),
	max(sd.description),
	max(spcd.curve_name),
	max(spcd.curve_des)
from 
	formula_editor fe
	left join formula_nested fn on fe.formula_id=fn.formula_group_id
	left join formula_editor fe1 on fe1.formula_id=fn.formula_id
	inner join #temp tmp on tmp.CurveId=cast(substring(substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))),charindex('(',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))))+1,len(substring(substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))),charindex('(',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))))+1,10))-1) as int)
	inner join contract_group_detail cgd on cgd.formula_id=fe.formula_id
	inner join contract_group cg on cg.contract_id=cgd.contract_id
	inner join source_price_curve_def spcd on spcd.source_curve_def_id=tmp.CurveId
	left join static_data_value sd on sd.value_id=cgd.invoice_Line_item_id
	where ISNULL(fe1.formula,fe.formula) like '%dbo.FNAcurve%'
	group by substring(substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))),charindex('(',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))))+1,len(substring(substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))),charindex('(',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),charindex(')',substring(ISNULL(fe1.formula,fe.formula),charindex('dbo.FNACurve',ISNULL(fe1.formula,fe.formula)),len(ISNULL(fe1.formula,fe.formula))))))+1,10))-1)


	set @sql_select=
		'select 
		curve_name as [Curve],
		curve_desc  as [Curve Desc],
		contract_name as [Contract],
		contract_charge_type as [Charge Type]

	from
		#temp_curve_formula where 1=1 '+
	+case when @curve_id is not null then ' AND curve_id in ('+@curve_id+')' else '' end+
	'order by curve_name,contract_name,contract_charge_type
'

exec(@sql_select)
END

END



