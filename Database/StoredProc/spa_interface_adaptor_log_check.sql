
IF OBJECT_ID(N'spa_interface_adaptor_log_check', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_interface_adaptor_log_check]
GO 
CREATE PROCEDURE [dbo].[spa_interface_adaptor_log_check]
	@source VARCHAR(50),
	@log_table VARCHAR(100),
	@run_from VARCHAR(1) = 'y',
	@start_time DATETIME = NULL
AS
DECLARE @last_time  VARCHAR(5)
DECLARE @max_time   DATETIME 
SET @start_time = ISNULL(@start_time, GETDATE())
DECLARE @sql_where VARCHAR(1000)
create table #log (log_date datetime,log_source varchar(100) COLLATE DATABASE_DEFAULT,log_start varchar(10) COLLATE DATABASE_DEFAULT,log_end varchar(10) COLLATE DATABASE_DEFAULT,log_status varchar(1) COLLATE DATABASE_DEFAULT)
if @run_from='y' --y:schedule             n:ad-hoc
	begin
		if datepart(hh,@start_time)<8  --new script
		--if datepart(hh,@start_time)<6    --old script
			set @sql_where='(cast(cast(C2_STARTDATE as datetime) as int)='+cast(floor(cast(@start_time as float))-1 as varchar)+' and C3_START>=''20:00'') or (cast(cast(C2_STARTDATE as datetime) as int)='+cast(floor(cast(@start_time as float)) as varchar)+
				' and C3_START<=''07:50'')' --new script

		--	set @sql_where='(cast(cast(C2_STARTDATE as datetime) as int)='+cast(floor(cast(@start_time as float))-1 as varchar)+' and C3_START>=''20:00'') or (cast(cast(C2_STARTDATE as datetime) as int)='+cast(floor(cast(@start_time as float)) as varchar)+
		--		' and C3_START<=''04:30'')'    --old script
		else
			set @sql_where='(cast(cast(C2_STARTDATE as datetime) as int)>= '+cast(floor(cast(@start_time as float)) as varchar)+' and C3_START>=''20:00'')'
	end
else
	begin
			set @sql_where='cast(cast(C2_STARTDATE as datetime) as int)>='+cast(floor(cast(@start_time as float)) as varchar)+' and C3_START>='''+right('0'+cast(datepart(hh,@start_time) as varchar),2) +':'+right('0'+cast(datepart(mi,@start_time) as varchar),2)+''''
	end
	exec spa_print 'insert into #log (log_date,log_source,log_start,log_end,log_status) select C2_STARTDATE,C0_INTERFACE_TYPE,C3_START,C4_END,C5_COMPLETED from ', @log_table, ' where ', @sql_where
	EXEC ('insert into #log (log_date,log_source,log_start,log_end,log_status) select C2_STARTDATE,C0_INTERFACE_TYPE,C3_START,C4_END,C5_COMPLETED from '+@log_table+' where '+@sql_where)

	select @max_time=max(log_date+log_start) from #log where log_source=@source

	IF exists(select * from #log where log_source=@source )
	begin
		IF exists(select * from #log where log_source=@source and log_date+log_start=@max_time and isnull(log_end,'')='')
			select -1
		else
			select 0
	end
	else
	begin
		select -2
	end
EXEC spa_print 'end log'



