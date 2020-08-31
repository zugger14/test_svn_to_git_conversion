IF OBJECT_ID('[dbo].[spa_closing_Year]') IS NOT NULL
DROP PROC [dbo].[spa_closing_Year]
go


--spa_closing_Year 'y','2007-12-01','farrms_admin',0
create  proc [dbo].[spa_closing_Year] 
@close_status varchar(1)='y',@as_of_date varchar(30),
@user_login_id varchar(50),
@run_schedule int=null
as

--declare @close_status varchar(1),@as_of_date varchar(30),@user_login_id varchar(50)
--set @close_status ='y',@as_of_date varchar(30),@user_login_id varchar(50)





DECLARE @spa varchar(500)
DECLARE @job_name varchar(100)
declare @process_id varchar(100)
declare @msmt_run_schedule_time varchar(30)
declare @running_date varchar(30)
declare @min int
Declare @url varchar(500)
declare @desc varchar(500)
declare @desc1 varchar(500)

declare @errorcode varchar(200)
DECLARE @month_1st_date1 datetime
DECLARE @month_last_date datetime
declare @tbl_name varchar(30)
IF @close_status='y'
begin
	if not exists(select * from ems_close_archived_year where year(as_of_date)=year(cast(@as_of_date as datetime))) -- and month(as_of_date)=month(cast(@as_of_date as datetime)))
	begin
		EXEC spa_print 'jjjj'
		return
	END
end
set @month_1st_date1=cast(cast(year(cast(@as_of_date as datetime)) as varchar)+'-01-01' as datetime)
set @month_last_date=dateadd(d,-1,dateadd(year,1,@month_1st_date1))
SET @process_id = REPLACE(newid(),'-','_')
set @desc=''
SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
	'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

EXEC spa_print @url

if isnull(@run_schedule,0)=0
	set @min=-1
else
begin 
	select @msmt_run_schedule_time=msmt_run_schedule_time  from run_measurement_param
	if isnull(@msmt_run_schedule_time,'')=''
		set @min=-1
	else
	begin
		EXEC spa_print 'yyyyyyyyyyy'
		set @running_date=cast(year(getdate()) as varchar)+'-'+cast(month(getdate()) as varchar) +'-'+cast(day(getdate()) as varchar)+ ' '+@msmt_run_schedule_time
		EXEC spa_print @running_date
		--EXEC spa_print datediff(mi,getdate(),cast(@running_date as datetime))
		set @min=datediff(mi,getdate(),cast(@running_date as datetime))
		EXEC spa_print @min
	end

end

SET @process_id = REPLACE(newid(),'-','_')
if @user_login_id is null
	set @user_login_id=dbo.FNADBUser()
SET @job_name = 'closingYear_'+ @process_id
SET @spa = 'spa_closing_Year_job  ''' + @close_status  +''',''' +@as_of_date +''','''+
@job_name + ''','''+ @user_login_id+''', ''' +@process_id+ ''''

exec spa_print @spa
if @min=-1
	exec spa_run_sp_as_job @job_name, @spa,'ClosingYear' ,@user_login_id
else
	exec spa_run_sp_as_job_schedule @job_name, @spa,'ClosingYear' ,@user_login_id,@min

--Exec spa_ErrorHandler 0, 'ClosingYear', 'process run', 'Status', 
--			'Closing Year process has been run and will complete shortly.', 
--			'Please Check/Refresh your message board.'








