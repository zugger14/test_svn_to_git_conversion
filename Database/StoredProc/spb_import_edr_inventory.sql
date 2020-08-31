
IF OBJECT_ID(N'spb_import_edr_inventory', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spb_import_edr_inventory]
GO 

CREATE PROC [dbo].[spb_import_edr_inventory]
	@user_id VARCHAR(50),
	@table_name VARCHAR(100)
--set @user_id='farrms_admin'
--set @table_name='adiha_process.dbo.import_edr_farrms_admin_D0D5B59B_51BC_4514_A7CE_A3F5DF40A695'
AS
--drop table #temp_inv
--drop table #temp1
--drop table #import_status

create table #temp_inv(
temp_id int identity(1,1),
facility_id varchar(10) COLLATE DATABASE_DEFAULT,
as_of_date varchar(20) COLLATE DATABASE_DEFAULT,
volume varchar(50) COLLATE DATABASE_DEFAULT,
curve_id varchar(50) COLLATE DATABASE_DEFAULT,
uom_id varchar(50) COLLATE DATABASE_DEFAULT,
ems_hour varchar(50) COLLATE DATABASE_DEFAULT
)

create table #temp1(
facility_id varchar(10) COLLATE DATABASE_DEFAULT,
as_of_date varchar(20) COLLATE DATABASE_DEFAULT,
volume float,
curve_id int,
uom_id int,
fas_book_id int,
generator_id int
)

CREATE TABLE #import_status
	(
	temp_id int,
	process_id varchar(100) COLLATE DATABASE_DEFAULT,
	ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
	Module varchar(100) COLLATE DATABASE_DEFAULT,
	Source varchar(100) COLLATE DATABASE_DEFAULT,
	type varchar(100) COLLATE DATABASE_DEFAULT,
	[description] varchar(250) COLLATE DATABASE_DEFAULT,
	[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
)
declare @process_id varchar(100)
declare @tot_source int
declare @tot_source_import int

SET @process_id = REPLACE(newid(),'-','_')
declare @sql_stmt varchar(5000)
set @sql_stmt='insert #temp_inv(facility_id,as_of_date,volume,curve_id,uom_id,ems_hour)
select facility_id,as_of_date,ems_volume,curve_id,uom_id,ems_hour from '+@table_name
exec (@sql_stmt)
select @tot_source=count(*) from #temp_inv
exec('insert into #import_status select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@table_name+''',''Data Error'',
''Data error for Facility ID is NULL '',''Please check your data'' 
from #temp_inv a where a.facility_id is null ')

exec('insert into #import_status select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@table_name+''',''Data Error'',
''Data error for Facility id:''+ isnull(a.facility_id,''NULL'') +'' Not found'',''Please check your data'' 
from #temp_inv a left outer join rec_generator b on a.facility_id=b.id where id is null')

exec('insert into #import_status select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@table_name+''',''Data Error'',
''Data error for As of Date.( As of Date:''+a.as_of_date+'' Hour:''+a.ems_hour+'' Volume: ''+ a.volume+'' Curve id: ''+a.curve_id+'' UOM ID:''+uom_id+''
 Facility Id  ''+isnull(a.facility_id,''NULL'')+'')'',''Please check your data'' 
from #temp_inv a where isdate(a.as_of_date)=0')
exec('insert into #import_status select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@table_name+''',''Data Error'',
''Data error for Volume.( As of Date:''+a.as_of_date+'' Hour:''+a.ems_hour+'' Volume: ''+a.volume+'' Curve id: ''+a.curve_id+'' UOM ID:''+uom_id+''
.Facility Id  ''+isnull(a.facility_id,''NULL'')+'')'',''Please check your data'' 
from #temp_inv a where isnumeric(a.volume)=0 and (not isnull(a.volume,'''')='''')')

exec('delete #temp_inv from #import_status inner join #temp_inv a on
		#import_status.temp_id=a.temp_id')
select @tot_source_import=count(*) from #temp_inv
set @sql_stmt='
insert #temp1(facility_id,as_of_date,volume,curve_id,uom_id,generator_id,fas_book_id)
select facility_id,left(as_of_date,8)+''01'',sum(cast(isnull(volume,0) as float)),curve_id,uom_id,generator_id,r.fas_book_id
		from #temp_inv t join rec_generator r on r.id=t.facility_id
	 group by facility_id,left(as_of_date,8)+''01'',curve_id,uom_id,generator_id,r.fas_book_id'

exec(@sql_stmt)

exec('insert into #import_status select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@table_name+''',''Data Error'',
''Data Warning for Empty Volume.( As of Date:''+a.as_of_date+'' Hour:''+a.ems_hour+'' Curve id: ''+a.curve_id+'' UOM ID:''+uom_id+''
.Facility Id  ''+isnull(a.facility_id,''NULL'')+'')'',''Please check your data'' 
from #temp_inv a where isnull(cast(a.volume as float),0)=0 or isnull(a.volume,'''')=''''')

exec('insert into #import_status select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@table_name+''',''Data Error'',
''Data warning for missing Book ID .(Facility id ''+ isnull(a.facility_id,''NULL'')+'' Generator ID:''+
cast(b.generator_id as varchar(20))+'' Generator Code:''+b.code+'' As of date:''+a.as_of_date+'' Hour:''+a.ems_hour+'' Curve id: ''+a.curve_id+'' UOM ID:''+uom_id+'')'',''Please check your data'' 
from #temp_inv a inner join rec_generator b on a.facility_id=b.id where fas_book_id is null')

declare @update_row int,@insert_row int

update emissions_inventory set 
	 volume=t.volume	 
from emissions_inventory e join #temp1 t on e.generator_id=t.generator_id 
	and e.as_of_date=t.as_of_date and e.curve_id=t.curve_id and e.uom_id=t.uom_id and e.frequency=703 and e.calculated='n' and e.current_forecast='r'
set @update_row=@@rowcount

insert into emissions_inventory (as_of_date, term_start, term_end, generator_id, frequency, curve_id, volume, uom_id, calculated, current_forecast,fas_book_id)
select t.as_of_date,t.as_of_date,dbo.FNAContractMonthFormat(t.as_of_date)+'-'+cast(dbo.FNALastDayInMonth(t.as_of_date) as varchar) term_end,t.generator_id, 703,t.curve_id,t.volume,t.uom_id,'n','r',t.fas_book_id
from #temp1 t left join emissions_inventory e on t.as_of_date=e.as_of_date and t.generator_id=e.generator_id and t.curve_id=e.curve_id and t.uom_id=e.uom_id  and t.fas_book_id=e.fas_book_id
	 and e.frequency=703  and e.calculated='n' and e.current_forecast='r'
where e.emissions_inventory_id is null
set @insert_row=@@rowcount


declare @counts_process int,@table_desc varchar(100)

declare @errorMsg varchar(200)
declare @errorcode varchar(200)
declare @detail_errorMsg varchar(200)
declare @error int
declare @id int
declare @count int
declare @totalcount int
Declare @url varchar(500)
declare @desc varchar(500)
declare @desc1 varchar(500)
declare @Er_desc1 varchar(500)
set @Er_desc1='(Some ERRORS found)'
if @insert_row<>0
	if @update_row<>0
		set @desc1='Total '+cast(@update_row as varchar) +' records updated and '+cast(@insert_row as varchar) + ' records inserted.'
	else
		set @desc1='Total '+cast(@insert_row as varchar) + ' records inserted.'
	
else
	if @update_row<>0
		set @desc1='Total '+cast(@update_row as varchar) +' records updated'
	else
		begin
		set @Er_desc1='(ERRORS found)'
		set @desc1='None of records neither inserted nor updated '
		end
select @desc1 = @desc1 +' in emission inventory.'

FinalStep:

set @count=(select count(distinct temp_id) from #import_status)
set @totalcount=(select count(*) from #temp1)


	set @table_desc='EDR.Import'
	select @detail_errorMsg = cast(@tot_source_import as varchar(100))+' Data proceeded Successfully out of '+cast(@tot_source as varchar(100))
	if @count >0
			begin
				set @errorMsg='Error found while importing data'
				set @errorcode='e'
				--if @totalcount>0
					set @detail_errorMsg=@detail_errorMsg+'('+@desc1+'). Some Error found while importing. Please review Errors'
				--else
					--select @detail_errorMsg = cast(@totalcount as varchar(100))+' Data imported Successfully. Some Error found while importing. Please review Errors'

				insert into source_system_data_import_status(process_id,code,module,source,
				type,[description],recommendation) 
				select @process_id,'Error','Import Data',@table_desc,'Data Error',@detail_errorMsg,'Please Check your data'

				
				insert into source_system_data_import_status_detail(process_id,source,
				type,[description]) 
				select distinct @process_id,@table_desc,type,[description]  from #import_status where process_id=@process_id
			

			End
		else
			begin
				set @errorMsg=@detail_errorMsg+'('+@desc1+').'
				--set @errorMsg=cast(@totalcount-@count as varchar(100))+' Data imported Successfully out of '+cast(@totalcount as varchar(100))
				set @errorcode='s'
				insert into source_system_data_import_status(process_id,code,module,source,
				type,[description],recommendation) 
				values(@process_id,'Success','Import Data',@table_desc,'Successful',@errorMsg,'')
			end

SET @sql_stmt = dbo.FNAProcessDeleteTableSql(@table_name)
--exec (@sql)

SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + 
	'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_id+''''

select @desc = '<a target="_blank" href="' + @url + '">' + 
			'Import process Completed for as of date:' + dbo.FNAUserDateFormat(getdate(), @user_id) + 
		case when (@errorcode = 'e') then @Er_desc1+'['+@desc1+']' else '('+@desc1+')' end +
		'.</a>'



EXEC  spa_message_board 'i', @user_id,
			NULL, 'Import.Data',
			@desc, '', '', @errorcode, 'Edr.Import'


 
set @errorcode='s'
 
 Exec spa_ErrorHandler 0, 'Emission Inventory', 
 			'Emission Inventory', 'Status', 
 			'Emission Inventory has been scheduled and will complete shortly.', 
 			'Please check/refresh your message board.'






