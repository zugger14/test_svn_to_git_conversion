
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_ppa_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_ppa_data]
GO 
-- exec [spa_import_ppa_data] 'adiha_process.dbo.ppa_data_farrms_admin_C881BC54_3A32_4869_962F_875F79120BF6','as','asd','asdasdad','farrms_admin'
create proc [dbo].[spa_import_ppa_data]
@temp_table_name varchar(100),  
@table_id varchar(100),  
  
@job_name varchar(100),  
  
@process_id varchar(100),  
  
@user_login_id varchar(50)  
  
AS
BEGIN  
Declare @sql varchar(8000)
declare @errorCount int
declare @all_row_count int

set @errorCount = 0

 create table  #temp_ppa(
		[company][varchar] (255) COLLATE DATABASE_DEFAULT,
		[id][varchar](255) COLLATE DATABASE_DEFAULT,
		[unit][varchar](255) COLLATE DATABASE_DEFAULT,
		[counterparty][varchar](255) COLLATE DATABASE_DEFAULT,
		[production_month][varchar](255) COLLATE DATABASE_DEFAULT,
		[mw][varchar](255) COLLATE DATABASE_DEFAULT)


exec ('insert into #temp_ppa select * from ' + @temp_table_name)

set @sql = 'update #temp_ppa set 
	counterparty = replace(counterparty,''"'',''''),
	mw = cast(replace(replace(replace(replace(mw,''"'',''''),''('',''-''),'')'',''''),'','','''') as float )'


exec(@sql)

SET @process_id = REPLACE(newid(),'-','_')
CREATE TABLE #import_status_detail
(
	temp_id int identity(1,1),
	process_id varchar(100) COLLATE DATABASE_DEFAULT,
	ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
	Module varchar(100) COLLATE DATABASE_DEFAULT,
	Source varchar(100) COLLATE DATABASE_DEFAULT,
	type varchar(100) COLLATE DATABASE_DEFAULT,
	[description] varchar(250) COLLATE DATABASE_DEFAULT,
	[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #import_status
(
	temp_id int identity(1,1),
	process_id varchar(100) COLLATE DATABASE_DEFAULT,
	ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
	Module varchar(100) COLLATE DATABASE_DEFAULT,
	Source varchar(100) COLLATE DATABASE_DEFAULT,
	type varchar(100) COLLATE DATABASE_DEFAULT,
	[description] varchar(250) COLLATE DATABASE_DEFAULT,
	[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
)


select rg.generator_id,ssim.ems_source_input_id ,'r' as estimate_type,
	cast(ppa.production_month + '-01' as datetime) term_start,
	cast(ppa.production_month  + '-' +  cast(day(dateadd(month,1,ppa.production_month + '-01')-1) as varchar) as datetime) term_end,
	ssim.frequency,sum(cast(ppa.mw as float)) as input_value,ssim.uom_id,max(ssim.forecast_type) as forecast_type
into #temp_generator
from #temp_ppa ppa
join source_system_input_map ssim on ssim.source_system_id = 602
inner join rec_generator rg on isnull(rg.id,'') = isnull(ltrim(rtrim(ppa.id)),'') and 
	isnull(rg.id2,'') = isnull(ltrim(rtrim(ppa.unit)),'')
group by  rg.generator_id,ssim.ems_source_input_id,ppa.production_month,ssim.frequency,ssim.uom_id
	


-- first delete from ems_gen_input if data exists
delete	egi
from 
	ems_gen_input egi inner join 
	#temp_generator tg 	on egi.generator_id=tg.generator_id 
	and tg.ems_source_input_id = egi.ems_input_id and tg.term_start = egi.term_start 

insert into ems_gen_input (generator_id, ems_input_id, estimate_type, term_start, term_end, frequency, input_value,
							uom_id)
	select tg.generator_id,ems_source_input_id as ems_input_id,estimate_type,term_start, term_end, frequency,
			case when input_value<0 and esme.ems_source_model_id not in(134,135) then 0 else input_value end,uom_id
				from #temp_generator tg
					INNER JOIN dbo.ems_source_model_effective esme on esme.generator_id=tg.generator_id
					INNER JOIN (select max(isnull(effective_date,'1900-01-01')) effective_date,generator_id from 
					dbo.ems_source_model_effective where 1=1 group by generator_id) ab
					on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date
			

-------------##############################################################################
--- Now run the calc for 
declare @process_table varchar(128),@process_id1 varchar(100),@term_start datetime,@term_end datetime,@series_type_id int
SET @process_id1 = REPLACE(newid(),'-','_')
set @process_table=dbo.FNAProcessTableName('edr_process',@user_login_id,@process_id1)
select @term_start=min(term_start),@term_end=max(term_end),@series_type_id=max(forecast_type) from #temp_generator
exec(
'select 
	distinct generator_id,term_start,term_end
into '+@process_table+' from #temp_generator')

if @term_start is not null
	exec spa_calc_emissions_inventory NULL,@term_start,@term_end,NULL,NULL,NULL,NULL,@series_type_id,@process_table

--####################################################################################################


set @all_row_count=(select count(*) from #temp_generator)
--
insert into #import_status_detail(
	process_id,ErrorCode,Module,Source,	type,[description],[nextstep])
select distinct
	@process_id,'Error','Import Data','PPA','Data Error',
	'Source : '+ (tr.counterparty)+'('+cast(isnull(tr.id,'') as varchar)+')'+' not found in EmissionsTracker.','Please Check Source/Sink to verify' 
from
	#temp_ppa tr
	left join rec_generator rg  on  isnull(rg.id,'') =isnull(ltrim(rtrim(tr.id)),'')
	and  isnull(rg.id2,'') =isnull(ltrim(rtrim(tr.unit)),'')
where
	rg.generator_id is null



insert into #import_status(
	process_id,ErrorCode,Module,Source,	type,[description],[nextstep])
select 
	@process_id,'Success','Import Data','PPA','Generation Data',
	' Total ' + cast(sum(tg.input_value) as varchar) +' MWh of Source: ' + rg.[name] + ' Imported.','' 

from
	#temp_generator tg
	join rec_generator rg on rg.generator_id = tg.generator_id
group by rg.[name]


declare @detail_errorMsg varchar(1000),@msg_rec varchar(1000),@count int
declare @url varchar(5000), @desc varchar(5000),@errorcode varchar(10)
declare @count_temp int,@totalcount int
declare @noGenerator int


declare @sqlStmt varchar(5000), @tempTable varchar(200)
--set @user_login_id=dbo.FNADBUser()


insert into  #import_status(
	process_id,ErrorCode,Module,Source,	type,[description],[nextstep])
select distinct 
	process_id,ErrorCode,Module,Source,	type,
	'<a target="_blank" href="' + '../dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status_detail ''' + @process_id + '''">'+'Some Sources missing in EmissionsTracker' ,'Please check the Data'
from
	#import_status_detail

-----###########################################
insert into source_system_data_import_status(process_id,code,module,source,
		type,[description],recommendation) 
select 
	process_id,ErrorCode,Module,Source,	type,[description],[nextstep]
from
	#import_status


-----###########################################
insert into source_system_data_import_status_detail(process_id,source,type,[description]) 
select 
	process_id,source,type,[description]
from
	#import_status_detail



set @totalcount=(select count(*) from #temp_generator)
if @totalcount<=0
	set @msg_rec='No Data Found to Import.'
else
	set @msg_rec='Total '+ cast(@all_row_count as varchar) +' Data Imported.'



if exists(select ErrorCode from #import_status where ErrorCode='Error')
set @errorcode='e'
else
set @errorcode='s'

CREATE table #temp_user(user_login_id varchar(100) COLLATE DATABASE_DEFAULT)

if @noGenerator >0 
insert into #temp_user
select DISTINCT ISNULL(af.login_id,ar.user_login_id)
	from
		application_functional_users af
		RIGHT JOIN application_role_user ar
		on ar.role_id=af.role_id or af.login_id is not null
		where	af.function_id=2
ELSE
insert into #temp_user select @user_login_id 



	DECLARE curtemp CURSOR FOR
	SELECT 	user_login_id from #temp_user
	OPEN curtemp
	FETCH next from curtemp into @user_login_id
	WHILE @@FETCH_STATUS=0
	BEGIN	

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''
	
	select @desc = '<a target="_blank" href="' + @url + '">' + 
				'PPA Import process Completed:' + @msg_rec + 
			case when (@errorcode = 'e') then ' (ERRORS found)' else '' end +
			'.</a>'
	
	EXEC  spa_message_board 'i', @user_login_id,
				NULL, 'Import.PPA',
				@desc, '', '', @errorcode, 'PPA Import'
	
	FETCH next from curtemp into @user_login_id
	END
	CLOSE curtemp
	DEALLOCATE curtemp



END













