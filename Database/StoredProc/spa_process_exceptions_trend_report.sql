

GO
/****** Object:  StoredProcedure [dbo].[spa_process_exceptions_trend_report]    Script Date: 11/20/2008 00:52:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_process_exceptions_trend_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_process_exceptions_trend_report]


GO
/****** Object:  StoredProcedure [dbo].[spa_process_exceptions_trend_report]    Script Date: 11/20/2008 00:52:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- exec spa_process_exceptions_trend_report 'farrms_admin','2006-01-01','2007-12-31','138,201,137,135,136',NULL,NULL,NULL,NULL,NULL,'A',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n',NULL,NULL,NULL

-- EXEC spa_process_exceptions_trend_report  NULL, '01/01/2004', '12/31/2006', '135', NULL, NULL, NULL, 'n'
-- exec spa_process_exceptions_trend_report 'farrms_admin','2006-01-01','2007-02-09','138,201,137,135,136',NULL,NULL,NULL,NULL,NULL,
-- 'A',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n',NULL,NULL,NULL
--Returns the number of assessment values that are either missing or done beyond the quarter
-- Report type 'c' means exceptions counts, 'd' means detail view by date
CREATE procedure [dbo].[spa_process_exceptions_trend_report] 
	@user_login_id As varchar(150),
	@as_of_date As varchar(20),
	@as_of_date_to As varchar(20),
	@sub_id As varchar(500)=NULL,
	@strategy_id varchar(500)=NULL,
	@book_id varchar(500)=NULL,	
	@run_frequency As varchar(20)=NULL,
	@risk_priority As varchar(200)=NULL,
	@role_id As varchar(200)=NULL,
	@unapporved_flag As varchar(1)='e',
	@process_number varchar(250) = NULL,
     	@risk_description_id int = null,
	@activity_category_id int=null,
	@who_for int=null,
	@where int=null,
	@why int=null,
	@activity_area int=null,
	@activity_sub_area int=null,
	@activity_action int=null,
	@activity_desc varchar(500)=null,
	@control_type int=null,
	@montetory_value_defined varchar(1)='n',
	@process_owner varchar(150)=NULL,
	@risk_owner varchar(150)=NULL,
	@risk_control_id int = null,

	@report_type int=1, -- 1->Line Graph 2-> Pie graph(By Subsidiary) 3-> Bar Graph (By Subsidiary)
	@option_type char(1)='c', -- c - show count m- show monetary values
	@period_frequency int=NULL, -- only used for line graph
	@threshold_value float=null,-- only used in Bar Graph
	@drill_down_level int=0, -- used in pie and bar graph
	@subsidiary_name varchar(500)=NULL,
	@strategy_name varchar(500)=NULL,
	@book_name varchar(500)=NULL
	
AS
SET NOCOUNT ON 

declare @a_Date as varchar(20)
declare @pre_days_count int
declare @next_item int
declare @process_id varchar(100)
declare @tempTable varchar(MAX)
declare @count_desc varchar(100)
declare @sql varchar(5000)

if @subsidiary_name is not null
	select @sub_id=entity_id from portfolio_hierarchy where entity_name=@subsidiary_name

if @strategy_name is not null
	select @strategy_id=entity_id from portfolio_hierarchy where entity_name=@strategy_name

if @book_name is not null
	select @book_id=entity_id from portfolio_hierarchy where entity_name=@book_name

--print @sub_id
--print @strategy_id


If @unapporved_flag IS NOT NULL
BEGIN
	--Reminders
	If upper(@unapporved_flag) = 'R'
		set @count_desc = ' [Count of Reminders]'
	--Not completed		
	Else If upper(@unapporved_flag) = 'N'
		set @count_desc = ' [Count of Not Completed Activity]'
	--Unapproved
	Else If  upper(@unapporved_flag) = 'U'
		set @count_desc = ' [Count of Not Approved Activity]'
	--Completed
	Else If  upper(@unapporved_flag) = 'C'
		set @count_desc = ' [Count of Completed Activity]'	
	--Exceptions only (the ones that have not been completed yet
	Else If  upper(@unapporved_flag) = 'E'
		set @count_desc = ' [Count of Exceptions]'	
	-- Completed but Exceeds threshold days 
	Else If  upper(@unapporved_flag) = 'T'
		set @count_desc = ' [Count of Completed with Activity]'	
	-- Exceeds threshold days and still not completed - ESCALATION
	Else If  upper(@unapporved_flag) = 'S'
		set @count_desc = ' [Count of Escalation]'	
	Else 
		set @count_desc = ' [Count]'	
END

  
 set @process_id=REPLACE(newid(),'-','_')  
 set @tempTable=dbo.FNAProcessTableName('risk_control', @user_login_id,@process_id)  

--drop table #temp
create table #temp
(
sub_name varchar(100) COLLATE DATABASE_DEFAULT,
stra_name varchar(100) COLLATE DATABASE_DEFAULT,
book_name varchar(100) COLLATE DATABASE_DEFAULT,
process_number varchar(100) COLLATE DATABASE_DEFAULT,
[Date] datetime,
exception_count float,
activity_status varchar(10) COLLATE DATABASE_DEFAULT,
exception_days int,
)


set @pre_days_count = datediff(mm, @as_of_date, @as_of_date_to) + 1

--declare @privilege_subs varchar(50)

--set @aDate = getdate()
set @a_Date = dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate(@as_of_date))
SET @next_item = 0

declare @process_table_insert_or_create varchar(1)
declare @get_counts int

if @option_type='c'
set @get_counts=1
else
set @get_counts=2

set @process_table_insert_or_create = 'c'

 		set @a_date = dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate(dateadd(mm, 1, @a_date)))

--select  @a_date '@a_date',  @as_of_date_to '@as_of_date_to'


	EXEC spa_Get_Risk_Control_Activities_Trend @user_login_id, @a_date, @sub_id, @run_frequency, @risk_priority, @role_id,
		 @unapporved_flag, 3, @get_counts, 
		@process_number, @risk_description_id, @activity_category_id, @who_for, @where,@why, @activity_area, 
		@activity_sub_area,
		@activity_action, @activity_desc, @control_type, @montetory_value_defined, @process_owner, @risk_owner, 
		NULL, @strategy_id, @book_id,@tempTable, @process_table_insert_or_create,@as_of_date_to

--exec ('select tempTable, * from ' + @tempTable)


--return

exec(' insert into #temp select * from '+@tempTable)


-- select * from #temp

-- exec ('select * from '+@tempTable)


if @option_type='m'
   set @count_desc='[Monetary Penalty]'


if @period_frequency is null
	set @period_frequency = 706

if @report_type=1 -- Line Graph
BEGIN
	set @sql='select case ' + cast(@period_frequency as varchar)  + ' when 703 then dbo.FNADateFormat(Date)
		   	 when 704 then cast(year(date) as varchar) + ''-Q'' + cast((month(date)/4)+1 as varchar) 
		 	 else cast(year(date) as varchar) end AS  
			['+ case cast(@period_frequency as varchar) when 703 then 'Date' when 704 then ' Quarter' else 'Year' end +'], 
		 cast(sum(exception_count) as int) ' + @count_desc + '
	from 
		#temp
	group by 
		case ' + cast(@period_frequency as varchar)  + ' when 703 then dbo.FNADateFormat(Date)
		when 704 then cast(year(date) as varchar) + ''-Q'' + cast((month(date)/4)+1 as varchar) 
		else cast(year(date) as varchar) end
	 '	
EXEC(@sql)
END

else if @report_type=2 -- Pie Graph
BEGIN

	
	if @drill_down_level=0
	BEGIN
		exec('select sub_name as Subsidiary, cast(sum(exception_count) as int) ' + @count_desc + '
		from #temp group by sub_name order by sub_name ')
	
	END
	else if @drill_down_level=1
	BEGIN
		exec('select  sub_name + '' / '' + stra_name as Strategy, cast(sum(exception_count) as int) ' + @count_desc + '
		from #temp group by sub_name, stra_name order by stra_name ')
	END
	else if @drill_down_level=2
	BEGIN
		exec('select sub_name + '' / '' + stra_name + '' / '' + book_name as Book, cast(sum(exception_count) as int) ' + @count_desc + '
		from #temp group by sub_name, stra_name, book_name order by book_name ')
	END
	else if @drill_down_level=3
	BEGIN
		exec('select sub_name + '' / '' + stra_name + '' / '' + book_name + '' / '' + process_Number as [Process Number], 
		cast(sum(exception_count) as int) ' + @count_desc + '
		from #temp group by sub_name, stra_name, book_name, process_Number order by process_Number ')
	END

END

else if @report_type=3 -- Bar graph
BEGIN

if @threshold_value is null
	set @threshold_value = 0
	
--select '#temp', dbo.FNADateFormat(getdate()), * from #temp where dbo.FNADateFormat([Date]) < dbo.FNADateFormat(getdate())
--select '@threshold_value', @threshold_value

	if @drill_down_level=0
	BEGIN
		select sub_name as [Subsidiary],
			sum(case when exception_count<@threshold_value then exception_count else 0 end) * 10 as [Exception less than Threshold],
			sum(case when exception_count>@threshold_value then exception_count else 0 end) * 10 as [Exception greater than Threshold],
			sum(case when exception_count=@threshold_value then exception_count else 0 end) * 10 as [Exception equals to Threshold]
			
		from 
			#temp 
			where dbo.FNADateFormat([Date]) < dbo.FNADateFormat(getdate())
			group by sub_name
	END

	if @drill_down_level=1
	BEGIN
		select sub_name + ' / ' + stra_name  as [Strategy],
			sum(case when exception_count<@threshold_value then exception_count else 0 end) * 10 as [Exception less than Threshold],
			sum(case when exception_count>@threshold_value then exception_count else 0 end) * 10 as [Exception greater than Threshold],
			sum(case when exception_count=@threshold_value then exception_count else 0 end) * 10 as [Exception equals to Threshold]
		from 
			#temp where dbo.FNADateFormat([Date]) < dbo.FNADateFormat(getdate()) group by sub_name, stra_name
	END

	if @drill_down_level=2
	BEGIN
		select sub_name + ' / ' + stra_name + ' / ' + book_name as [Book],
			sum(case when exception_count<@threshold_value then exception_count else 0 end) * 10 as [Exception less than Threshold],
			sum(case when exception_count>@threshold_value then exception_count else 0 end) * 10 as [Exception greater than Threshold],
			sum(case when exception_count=@threshold_value then exception_count else 0 end) * 10 as [Exception equals to Threshold]
			
		from 
			#temp where dbo.FNADateFormat([Date]) < dbo.FNADateFormat(getdate()) group by sub_name, stra_name, book_name
	END
	if @drill_down_level=3
	BEGIN
 		select sub_name + ' / ' + stra_name + ' / ' + book_name + ' / ' + process_Number as [Process Number],
			sum(case when exception_count<@threshold_value then exception_count else 0 end) * 10 as [Exception less than Threshold],
			sum(case when exception_count>@threshold_value then exception_count else 0 end) * 10 as [Exception greater than Threshold],
			sum(case when exception_count=@threshold_value then exception_count else 0 end) * 10 as [Exception equals to Threshold]
			
		from 
			#temp where dbo.FNADateFormat([Date]) < dbo.FNADateFormat(getdate()) group by sub_name, stra_name, book_name, process_number

	END
END









