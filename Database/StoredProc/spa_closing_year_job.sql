IF OBJECT_ID('[dbo].[spa_closing_Year_job]') IS NOT NULL
DROP PROC [dbo].[spa_closing_Year_job]
go
create proc [dbo].[spa_closing_Year_job]
@close_status varchar(1)='y',@aod_from datetime,
@job_name varchar(100),
@user_login_id varchar(50),
@process_id varchar(100)=null
as
--select * from process_table_location

--declare @close_status varchar(1),@aod_from datetime,@job_name varchar(100),@user_login_id varchar(50),@process_id varchar(100)
--
--set @close_status='n'
--set @aod_from='2001-12-31'
--set @job_name='zsetnerzgd'
--set @user_login_id='farrms_admin'
--set @process_id='zzeergntds'


declare @sql_stmt varchar(8000)
Declare @url varchar(500)
declare @desc varchar(500)
declare @desc1 varchar(500)

Declare @tbl_location varchar(50)

declare @errorcode varchar(200)
DECLARE @month_1st_date1 datetime
DECLARE @month_last_date datetime
declare @tbl_name varchar(30)
EXEC spa_print  @close_status

set @month_1st_date1=cast(cast(year(@aod_from) as varchar)+'-01-01' as datetime)
set @month_last_date=dateadd(d,-1,dateadd(year,1,@month_1st_date1))
set @desc=''
SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
	'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

DECLARE @begin_time DATETIME
set @begin_time = getdate()

begin try
	if @close_status='y'
	BEGIN
		EXEC spa_print 'yyyyy'
	
		if not exists(select * from ems_close_archived_year where year(as_of_date)=year(@aod_from)) --and month(as_of_date)=month(cast(@aod_from as datetime)))
			return

		begin TRAN
		
		set @tbl_location=ISNULL(dbo.[FNAGetProcessTableName] (@month_1st_date1,'ems_calc_detail_value'),'ems_calc_detail_value')
		--select @tbl_location
		if @tbl_location='ems_calc_detail_value' OR @tbl_location='dbo.ems_calc_detail_value'
			exec spa_ems_archive_data_job 'ems_calc_detail_value',@month_1st_date1,@month_last_date,'','_arch1',1,'yearclosing',@user_login_id,@process_id
		
--		set @tbl_location=ISNULL(dbo.[FNAGetProcessTableName] (@month_1st_date1,'emissions_inventory'),'emissions_inventory')
--		--select @tbl_location
--		if @tbl_location='emissions_inventory' OR @tbl_location='dbo.emissions_inventory'
--			exec spa_ems_archive_data_job 'emissions_inventory',@month_1st_date1,@month_last_date,'','_arch1',1,'yearclosing',@user_login_id,@process_id
		
		set @tbl_location=ISNULL(dbo.[FNAGetProcessTableName] (@month_1st_date1,'edr_raw_data'),'edr_raw_data')
		--select @tbl_location
		if @tbl_location='edr_raw_data' OR @tbl_location='dbo.edr_raw_data'
			exec spa_ems_archive_data_job 'edr_raw_data',@month_1st_date1,@month_last_date,'','_arch1',1,'yearclosing',@user_login_id,@process_id

		commit tran

		set @errorcode = 's'
		set @desc ='Accounting period closing process for '+dbo.FNAUserDateFormat(@month_last_date, @user_login_id)+' is completed on ' + dbo.FNAUserDateFormat(getdate(), @user_login_id)+'. Data has been successfully archived. '
				+ ' (Elapse time: ' + cast(datediff(ss,@begin_time,getdate()) as varchar) + ' seconds)'
		select @desc = '<a target="_blank" href="' + @url + '">' + 
					@desc + 
				case when (@errorcode = 'e') then ' (ERRORS found).  Please contact support. ' +
						'(Elapse time: ' + cast(datediff(ss,@begin_time,getdate()) as varchar) + ' seconds)' else '' end +
				'</a>'

		EXEC  spa_message_board 'i', @user_login_id,
					NULL, 'Year.closing',@desc, '', '', 's', @job_name,null,@process_id
		insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
			select @process_id,'Success','Year Closing','Year Closing','Closing Success','Successfully closed the year for the '++dbo.FNAUserDateFormat(@month_last_date, @user_login_id)+' on the as of date: '+dbo.FNAUserDateFormat(getdate(), @user_login_id)+'.',
			''
	end
	else   -----------------------------------------unclosing month
	BEGIN
		begin TRAN
--		EXEC spa_print 'm1'
--		set @tbl_location=ISNULL(dbo.[FNAGetProcessTableName] (@month_1st_date1,'emissions_inventory'),'emissions_inventory')
--		--select @tbl_location
--		if @tbl_location='emissions_inventory_arch1' OR @tbl_location='dbo.emissions_inventory_arch1'
--			exec spa_ems_archive_data_job 'emissions_inventory',@month_1st_date1,@month_last_date,'_arch1','',1,'yearclosing',@user_login_id,@process_id
--		ELSE if @tbl_location='emissions_inventory_arch2' OR @tbl_location='dbo.emissions_inventory_arch2'
--			exec spa_ems_archive_data_job 'emissions_inventory',@month_1st_date1,@month_last_date,'_arch2','',1,'yearclosing',@user_login_id,@process_id
		EXEC spa_print 'm2'

		set @tbl_location=ISNULL(dbo.[FNAGetProcessTableName] (@month_1st_date1,'ems_calc_detail_value'),'ems_calc_detail_value')
		--select @tbl_location
		if @tbl_location='ems_calc_detail_value_arch1' OR @tbl_location='dbo.ems_calc_detail_value_arch1'
			exec spa_ems_archive_data_job 'ems_calc_detail_value',@month_1st_date1,@month_last_date,'_arch1','',1,'yearclosing',@user_login_id,@process_id
		ELSE if @tbl_location='ems_calc_detail_value_arch2' OR @tbl_location='dbo.ems_calc_detail_value_arch2'
			exec spa_ems_archive_data_job 'ems_calc_detail_value',@month_1st_date1,@month_last_date,'_arch2','',1,'yearclosing',@user_login_id,@process_id
	
				EXEC spa_print '31'

		set @tbl_location=ISNULL(dbo.[FNAGetProcessTableName] (@month_1st_date1,'edr_raw_data'),'edr_raw_data')
	--	select @tbl_location
		if @tbl_location='edr_raw_data_arch1' OR @tbl_location='dbo.edr_raw_data_arch1'
			exec spa_ems_archive_data_job 'edr_raw_data',@month_1st_date1,@month_last_date,'_arch1','',1,'yearclosing',@user_login_id,@process_id
		ELSE if @tbl_location='edr_raw_data_arch2' OR @tbl_location='dbo.edr_raw_data_arch2'
			exec spa_ems_archive_data_job 'edr_raw_data',@month_1st_date1,@month_last_date,'_arch2','',1,'yearclosing',@user_login_id,@process_id

		delete from ems_close_archived_year where year(as_of_date)=year(@month_1st_date1)
		commit tran
	--	exec spa_ems_archive_data_job @month_1st_date1,@month_last_date,'_arch1','',1,'monthclosing',@user_login_id,@process_id
		set @errorcode='s'

		set @desc ='Accounting period unclosing process for '+dbo.FNAUserDateFormat(@month_last_date, @user_login_id)+'is Completed on ' + dbo.FNAUserDateFormat(getdate(), @user_login_id)+'. Data has not been successfully archived.'
		select @desc = '<a target="_blank" href="' + @url + '">' + 
					@desc + 
				case when (@errorcode = 'e') then ' (ERRORS found).  Please contact support.' else '.' end +
				'.</a>'
		EXEC  spa_message_board 'i', @user_login_id,
					NULL, 'Year.unclosing',@desc, '', '', 's', @job_name,null,@process_id
		insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
			select @process_id,'Success','Year unclosing','Year unclosing','Unclosing Success','Successfully unclosed the Year for the '++dbo.FNAUserDateFormat(@month_last_date, @user_login_id)+' on the as of date: '+dbo.FNAUserDateFormat(getdate(), @user_login_id)+'.',
			''
	end

end try
begin catch
	--EXEC spa_print ERROR_number()
	EXEC spa_print @@TRANCOUNT
	--EXEC spa_print ERROR_number()
	if @@TRANCOUNT>0
	begin
		--EXEC spa_print 'Error:['+ERROR_MESSAGE()+'].'
		rollback TRAN
		if @close_status='y'
			delete from ems_close_archived_year where  year(as_of_date)=year(@month_1st_date1)
	end
	set @errorcode='e'
	set @desc ='Year closing process for '+dbo.FNAUserDateFormat(@month_last_date, @user_login_id)+' failed to complete on ' + dbo.FNAUserDateFormat(getdate(), @user_login_id)
	select @desc = '<a target="_blank" href="' + @url + '">' + 
					@desc + 
				case when (@errorcode = 'e') then ' (ERRORS found).  Please contact support.' else '' end +
				'.</a>'

	EXEC  spa_message_board 'i', @user_login_id,
				NULL, 'Year.Closing',
				@desc, '', '', @errorcode, @job_name,null,@process_id
	if ERROR_number()<>266
	begin

		insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
				select @process_id,'Error','Year Cloosing','Year Cloosing','Closing Error','Closing for the year '+dbo.FNAUserDateFormat(@month_last_date, @user_login_id)+' is failed ['+ERROR_MESSAGE()+'].',
				'Please Check your data'
		insert into source_system_data_import_status_detail(process_id,source,type,[description]) select @process_id,'Year Cloosing','Year Cloosing',
				'Closing Year for '+ +dbo.FNAUserDateFormat(@month_last_date, @user_login_id)+ ' is failed  ['+ERROR_MESSAGE()+'].'
	end
	ELSE
	begin
		if @close_status='y'
			delete from ems_close_archived_year where year(as_of_date)=year(@month_1st_date1)
	end
end catch