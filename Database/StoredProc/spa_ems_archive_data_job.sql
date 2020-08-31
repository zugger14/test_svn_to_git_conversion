IF OBJECT_ID('[dbo].spa_ems_archive_data_job')  IS NOT NULL
DROP proc [dbo].[spa_ems_archive_data_job]
 GO 
--spa_archive_data_job @tbl_name='edr_raw_data'
--, @aod_from ='2007-01-01'
--,@aod_to='2007-12-30'
--,@tbl_from=''
--,@tbl_to='_arch1'
--,@call_from=2
--,@job_name='closing'
--,@user_login_id='farrms_admin'
--,@process_id='qq'


CREATE proc [dbo].[spa_ems_archive_data_job] 
@tbl_name varchar(50), 
@aod_from  varchar(30),
@aod_to varchar(30),
@tbl_from varchar(30)='',
@tbl_to varchar(30)='',
@call_from int,
@job_name varchar(100),
@user_login_id varchar(50),
@process_id varchar(100)=null
as
/*

SELECT * FROM process_table_archive_policy

select * from emissions_inventory  order by term_start
select * from emissions_inventory_arch1 order by term_start
select * from emissions_inventory_arch2 order by term_start
select year(term_start) yr,count(*) no_rec from emissions_inventory group by year(term_start) order by 1



alter table  ems_calc_detail_value_arch1 drop constraint FK_ems_calc_detail_value_arch1_emissions_inventory
alter table  ems_calc_detail_value_arch1 drop constraint FK_ems_calc_detail_value_arch2_emissions_inventory
--alter table  ems_calc_detail_value drop constraint FK_emissions_inventory_emissions_inventory

select * from ems_calc_detail_value order by term_start
select * from ems_calc_detail_value_arch1 order by term_start
select * from ems_calc_detail_value_arch2 order by term_start
select year(term_start) yr,count(*) no_rec from ems_calc_detail_value group by year(term_start) order by 1





select * from edr_raw_data order by edr_date
select * from edr_raw_data_arch1 order by edr_date
select * from edr_raw_data_arch2 order by edr_date

select year(edr_date) yr,count(*) no_rec from edr_raw_data group by year(edr_date)

select * from process_table_location
delete edr_raw_data_arch1 
delete emissions_inventory_arch1



delete process_table_location
delete emissions_inventory_arch2
select distinct pnl_as_of_date from source_deal_pnl
*/
--declare @tbl_name varchar(50),@aod_from  varchar(30),@aod_to varchar(30),@tbl_from varchar(30),@tbl_to varchar(30),@call_from int,@job_name varchar(100),@user_login_id varchar(50),@process_id varchar(100)
--
--set @tbl_name='ems_calc_detail_value'
--set @aod_from ='2000-01-01'
--set @aod_to='2000-12-30'
--set @tbl_from='_arch1'
--set @tbl_to=''
--set @call_from=2
--set @job_name='closing'
--set @user_login_id='farrms_admin'
--set @process_id='qq'




declare @sql_stmt varchar(8000)
Declare @url varchar(500)
declare @desc varchar(500)
declare @desc1 varchar(500)
declare @db_from varchar(100),@db_to varchar(100)
declare @no_month_pnl int
declare @errorcode varchar(200)
DECLARE @month_1st_date1 datetime
declare @tbl_next varchar(30)
declare @i int
declare @upto_month int
declare @min_date_to_arch datetime
declare @field_list varchar(8000)
DECLARE @month_last_date datetime
declare @month_for_priror datetime
set @month_1st_date1=cast(cast(year(cast(@aod_from as datetime)) as varchar)+'-'+cast(month(cast(@aod_from as datetime)) as varchar)+'-01' as datetime)
set @month_last_date=dateadd(d,-1,dateadd(m,1,cast(cast(year(cast(@aod_to as datetime)) as varchar)+'-'+cast(month(cast(@aod_to as datetime)) as varchar)+'-01' as datetime)))
set @desc=''



select @db_from=dbase_name from process_table_archive_policy where isnull([prefix_location_table],'')= isnull(@tbl_from,'') and [tbl_name]=@tbl_name
select @db_to=dbase_name from process_table_archive_policy where isnull([prefix_location_table],'')= isnull(@tbl_to,'') and [tbl_name]=@tbl_name

if isnull(@db_from,'')='' or @db_from='dbo'
	set @db_from='dbo'
else
	set @db_from=@db_from+'.dbo'
if isnull(@db_to,'')='' or @db_to='dbo'
	set @db_to='dbo'
else
	set @db_to=@db_to+'.dbo'
	
EXEC spa_print 'Start:', @tbl_name
if @tbl_name='edr_raw_data'
	set @field_list='
		[RECID],[stack_id],[stack_name],[facility_id],[unit_id],[record_type_code],[sub_type_id],[edr_date]
		,[edr_hour],[edr_value],[curve_id],[uom_id],[uom_id1],[create_ts]
		'
else if @tbl_name='ems_calc_detail_value'
	set @field_list='
		[detail_id],[inventory_id],[as_of_date],[term_start],[term_end],[generator_id]
		,[curve_id],[input_id],[formula_value],[volume],[uom_id],[frequency],[current_forecast]
		,[sequence_number],[formula_id],[formula_str],[formula_value_reduction],[formula_id_reduction]
		,[reduction],[output_id],[output_value],[output_uom_id],[heatcontent_value],[heatcontent_uom_id]
		,[formula_str_reduction],[formula_eval],[formula_eval_reduction],[char1],[char2],[char3],[char4]
		,[char5],[char6],[char7],[char8],[char9],[char10],[base_year_volume],[forecast_type],[fuel_type_value_id]
		,[formula_detail_id],[emissions_factor],fas_book_id
		'
--else if @tbl_name='emissions_inventory'
--	set @field_list='
--		[emissions_inventory_id],[as_of_date],[term_start],[term_end],[generator_id],[frequency],[curve_id]
--		,[volume],[uom_id],[calculated],[current_forecast],[fas_book_id],[reduction_volume]
--		,[reduction_uom_id],[base_year_volume],[forecast_type],[fuel_type_value_id]
--		,[create_user],[create_ts],[update_user],[update_ts]
--	'

begin try
	if @call_from<>1
		begin tran
	set @sql_stmt='
	if exists(select * from '+@db_from+'.'+@tbl_name+@tbl_from+' where ' + case when @tbl_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ' between '''+cast(@month_1st_date1 as varchar)+''' and '''+CAST(@month_last_date AS VARCHAR)+''')
		delete '+@db_to+'.'+@tbl_name+@tbl_to+' where ' + case when @tbl_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ' between '''+cast(@month_1st_date1 as varchar)+''' and '''+CAST(@month_last_date AS VARCHAR)+''''

	exec spa_print @sql_stmt

	exec(@sql_stmt)
	
	set @sql_stmt='
	if exists(select * from sys.objects where OBJECTPROPERTY(object_id,''TableHasIdentity'')=1 and name='''+@tbl_name+@tbl_to+''')
		set identity_insert '+@tbl_name+@tbl_to+' on;
	insert into '+@db_to+'.'+@tbl_name+@tbl_to+' ('+@field_list+')	select '+@field_list+
			' from '+@db_from+'.'+@tbl_name+@tbl_from+' where ' + case when @tbl_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ' between '''+cast(@month_1st_date1 as varchar)+''' and '''+CAST(@month_last_date AS VARCHAR)+''';
			
	if exists(select * from sys.objects where OBJECTPROPERTY(object_id,''TableHasIdentity'')=1 and name='''+@tbl_name+@tbl_to+''')
		set identity_insert '+@tbl_name+@tbl_to+' off;'

	EXEC spa_print @sql_stmt
	exec(@sql_stmt)
	set @sql_stmt='delete '+@db_from+'.'+@tbl_name+@tbl_from+' where ' + case when @tbl_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ' between '''+cast(@month_1st_date1 as varchar)+''' and '''+CAST(@month_last_date AS VARCHAR)+''''
	EXEC spa_print @sql_stmt
	exec(@sql_stmt)
	set @sql_stmt='update process_table_location set prefix_location_table='''+@tbl_to+''',dbase_name='''+ @db_to+ ''' where  as_of_date = '''+cast(@month_1st_date1 as varchar)+''' and tbl_name='''+@tbl_name+''''
	exec(@sql_stmt)
	if @@rowcount<=0
	insert into process_table_location (as_of_date, prefix_location_table,dbase_name,tbl_name)
		values (@month_1st_date1,@tbl_to,@db_to,@tbl_name)
	IF @tbl_to<>'' -- ONLY  while transfering to Archive table
	begin
		declare @month_move_data datetime
		select @i=count(*) from process_table_location where isnull(prefix_location_table,'')=isnull(@tbl_to,'') and [tbl_name]=@tbl_name
		--SELECT @upto_month=upto_month FROM [process_table_archive_policy] where isnull([prefix_location_table],'')= isnull(@tbl_to,'') and tbl_name=@tbl_name
		--For Yearly
		SELECT @upto_month=upto/12 FROM [process_table_archive_policy] where isnull([prefix_location_table],'')= isnull(@tbl_to,'') and tbl_name=@tbl_name
		EXEC spa_print 'process_table_location:', @i
		EXEC spa_print '[process_table_archive_policy]:', @upto_month
		if isnull(@upto_month,0)<>0
		begin
			if @i>@upto_month
			begin
				set @db_from=@db_to
				set @tbl_from=@tbl_to
				SELECT @tbl_next=min([prefix_location_table]) FROM [process_table_archive_policy] where isnull([prefix_location_table],'')> isnull(@tbl_to,'') and [tbl_name]=@tbl_name
				select @month_move_data=min(as_of_date) from process_table_location where isnull(prefix_location_table,'')=isnull(@tbl_to,'') and [tbl_name]=@tbl_name
				select @db_to=dbase_name from [process_table_archive_policy] where isnull([prefix_location_table],'')= isnull(@tbl_next,'') and [tbl_name]=@tbl_name
				if isnull(@db_to,'')='' or @db_to='dbo'
					set @db_to='dbo'
				else
					set @db_to=@db_to+'.dbo'

				set @sql_stmt='delete '+@db_to+'.'+@tbl_name+@tbl_next+' 
					where year(' + case when @tbl_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ')='+cast(year(@month_move_data) as varchar)
					--+' and month(' + case when @tbl_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ')='+cast(month(@month_move_data) as varchar)
				EXEC spa_print @sql_stmt
				exec(@sql_stmt)
				set @sql_stmt='insert into '+@db_to+'.'+@tbl_name+@tbl_next+' ('+@field_list+')	select '+@field_list+
						' from '+@db_from+'.'+@tbl_name+@tbl_from+
						' where year(' + case when @tbl_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ')='+cast(year(@month_move_data) as varchar)
						--+' and month(' + case when @tbl_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ')='+cast(month(@month_move_data) as varchar)
				EXEC spa_print @sql_stmt
				exec(@sql_stmt)
				set @sql_stmt='delete '+@db_from+'.'+@tbl_name+@tbl_from+' 
				 where year(' + case when @tbl_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ')='+cast(year(@month_move_data) as varchar)
			--	 +'  and month(' + case when @tbl_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ')='+cast(month(@month_move_data) as varchar)

				EXEC spa_print @sql_stmt 
				exec(@sql_stmt)
				set @sql_stmt='update process_table_location set prefix_location_table='''+@tbl_next+''',dbase_name='''+ @db_to+ ''' 
				where year(as_of_date)='+cast(year(@month_move_data) as varchar)+
				'  and tbl_name='''+@tbl_name+''''
				exec(@sql_stmt)
				if @@rowcount<=0
				insert into process_table_location (as_of_date, prefix_location_table,dbase_name,tbl_name)
					values (@month_move_data,@tbl_next,@db_to,@tbl_name)
			end
		END
	end
	if @call_from<>1
		commit tran

	set @errorcode='s'
	if @call_from=2 --from archive (1 from monthclosing)
	begin
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
			'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

		select @desc = '<a target="_blank" href="' + @url + '">' + 
					'Archive process is Completed for as of date:' + dbo.FNAUserDateFormat(getdate(), @user_login_id) +	'.</a>'
			EXEC  spa_message_board 'i', @user_login_id,
					NULL, 'Archive.Data',@desc, '', '', 's', @job_name,null,@process_id
		insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
			select @process_id,'Success','Archive Data','Archive Data','Archive Success','Successfully archived the data from '+dbo.FNAUserDateFormat(@aod_from, @user_login_id)+ ' to '+dbo.FNAUserDateFormat(@aod_to, @user_login_id)+'.',
			''
	end
	EXEC spa_print 'End:', @tbl_name
end try
begin catch
	--EXEC spa_print 'archive:'+ERROR_MESSAGE()
	rollback tran
	set @errorcode='e'
--	EXEC  spa_message_board 'i', @user_login_id,
--				NULL, 'Archive.Data',
--				@desc, '', '', @errorcode, @job_name,null,@process_id
	insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
			select @process_id,'Error','Archive Data','Archive Data','Archive Error','Archival of data failed (From:'+dbo.FNAUserDateFormat(@aod_from, @user_login_id)+ ' To: '+dbo.FNAUserDateFormat(@aod_to, @user_login_id)+') ['+ERROR_MESSAGE()+'].',
			'Please contact support'
	insert into source_system_data_import_status_detail(process_id,source,type,[description]) select @process_id,'Archive Data','Archive Data',
			'Archival of data failed (From:'+dbo.FNAUserDateFormat(@aod_from, @user_login_id)+ ' To: '+dbo.FNAUserDateFormat(@aod_to, @user_login_id)+') ['+ERROR_MESSAGE()+'].'
	declare @msg varchar(1000)
	select @msg =ERROR_MESSAGE()
	RAISERROR (@msg, -- Message id.
						   11, -- Severity,
						   1, -- State,
						   'Failed to transfer data')
end catch



