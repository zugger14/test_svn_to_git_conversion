
IF OBJECT_ID('sp_ssis_agreement') IS NOT NULL
	DROP  PROCEDURE dbo.sp_ssis_agreement
GO

CREATE proc [dbo].[sp_ssis_agreement]
@process_id						varchar(200),
@source_system					varchar(200) = NULL,
@as_of_date						varchar(50) = NULL,
@import_status_temp_table_name	varchar(50) = NULL
As

declare @sql varchar(2000)
declare @errorcode varchar(200)
declare @url varchar(200)
declare @desc varchar(200)
declare @user_login_id varchar(100)
DECLARE @start_ts	datetime
set @user_login_id=dbo.FNADBUser()
--set @user_login_id='farrms_admin'
CREATE TABLE #import_status
	(
	temp_id int,
	process_id varchar(100) COLLATE DATABASE_DEFAULT,
	ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
	Module varchar(100) COLLATE DATABASE_DEFAULT,
	Source varchar(100) COLLATE DATABASE_DEFAULT,
	type varchar(100) COLLATE DATABASE_DEFAULT,
	[description] varchar(1000) COLLATE DATABASE_DEFAULT,
	[nextstep] varchar(250) COLLATE DATABASE_DEFAULT,
	type_error varchar(500) COLLATE DATABASE_DEFAULT,
	external_type_id varchar(100) COLLATE DATABASE_DEFAULT
	)

CREATE TABLE #tmp_erroneous_deal_agr 
	(
		deal_id				varchar(200) COLLATE DATABASE_DEFAULT NOT NULL,
		error_type_code		varchar(100) COLLATE DATABASE_DEFAULT NOT NULL,
		error_description	varchar(500) COLLATE DATABASE_DEFAULT
	)
	
declare @source_system_id int
select @source_system_id=source_system_id from source_system_description 
where source_system_Name=@source_system

--delete error logs from previous session
exec spa_print 'Deleting previous Agreement error logs'
DELETE source_deal_error_log 
FROM source_deal_error_log l
INNER JOIN (SELECT DISTINCT deal_tracking_num FROM ssis_agreement) a ON l.deal_id = a.deal_tracking_num
WHERE as_of_date = @as_of_date AND source IN ('Agreement')

declare @count int,@count_source int
exec('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) 
OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deal_agr
select a.tran_num,'''+ @process_id+''',''Error'',''Import Data'',''Agreement'',''Data Error'',
		''Data error for deal_id :''+ isnull(a.deal_tracking_num,''NULL'')+'' (Foreign Key legal_agreement ''+ISNULL(a.legal_agreement,''NULL'')+'' is not found)'',
		''Please check your data'',''Agreement  ''+ isnull(a.legal_agreement,''NULL'') + '' is invalid'',a.deal_tracking_num
		from ssis_agreement a left join contract_group c on 
		a.legal_agreement=c.source_contract_id
		where c.source_contract_id is null')

set @sql= 'insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) 
			OUTPUT INSERTED.external_type_id, ''MISSING_DEAL'', INSERTED.type_error INTO #tmp_erroneous_deal_agr
		select a.tran_num,'''+ @process_id+''',''Error'',''Import Data'',''Agreement'',''Data Error'',
		''Data error for deal_id :''+ isnull(a.deal_tracking_num,''NULL'')+'' (Deal ID not found ''+ISNULL(a.deal_tracking_num,''NULL'')+'' is not found)'',
		''Please check your data'',''Deal ID not found  ''+ isnull(a.deal_tracking_num,''NULL'') + '' is invalid'',a.deal_tracking_num
		from ssis_agreement a left join source_deal_header h on 
		a.deal_tracking_num=h.deal_id AND h.source_system_id = ' + CAST(@source_system_id AS VARCHAR) + '
		where h.deal_id is null'
exec(@sql)

set @sql='update source_deal_header
			set contract_id=c.contract_id
			from source_deal_header sdh, ssis_agreement a, contract_group c
			where a.legal_agreement=c.source_contract_id and a.deal_tracking_num=sdh.deal_id
			AND sdh.source_system_id = ' + CAST(@source_system_id AS VARCHAR)
exec(@sql)
set @count_source=@@rowcount
select @count=count(*) from ssis_agreement


if @count-@count_source=0
BEGIN
	set @errorcode='s'
end
else
BEGIN
	set @errorcode='e'
end

insert into source_system_data_import_status_detail(process_id,source,type,[description],type_error)
select @process_id,source,type,[description],type_error  from #import_status

insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
select @process_id,case when @count-@count_source>0 then 'Error' else 'Success' end,
'Import Data','Agreement',case when @count-@count_source>0 then 'Data Error' else 'Import Success' end,
cast(@count_source as varchar)+ ' Data imported Successfully out of '+cast(@count as varchar)+' rows.',
case when @count-@count_source>0 then 'Please Check your data' else 'N/A' end 

--delete ssis_agreement

--save all erroneous agreements
exec spa_print 'Saving erroneous deals (AGR) to table for process_id:', @process_id, ' STARTED.'
DECLARE @default_error_type_id	int

SET @start_ts = GETDATE()

SELECT @default_error_type_id = error_type_id FROM source_deal_error_types WHERE error_type_code = 'MISC'
	
INSERT INTO source_deal_error_log(as_of_date, deal_id, source, error_type_id, error_description)
SELECT @as_of_date, deal_id, 'Agreement', ISNULL(e.error_type_id, @default_error_type_id), MAX(error_description)
FROM #tmp_erroneous_deal_agr d
LEFT JOIN source_deal_error_types e ON d.error_type_code = e.error_type_code
GROUP BY deal_id, e.error_type_id

exec spa_print 'Saving erroneous deals (AGR) to table for process_id:', @process_id, ' FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

select @desc = '<a target="_blank" href="' + @url + '">' + 
			'Update process Completed for as of date:' + dbo.FNAUserDateFormat(getdate(), @user_login_id) + 			
		'.</a>'
EXEC  spa_message_board 'i', @user_login_id,
			NULL, 'Import.Data',
				@desc, '', '', @errorcode, null,null,@process_id


declare @error_count int

select @error_count=count(*) from source_system_data_import_status 
where process_id=@process_id and code='Error'

DECLARE @status_sql varchar(250)

If @error_count > 0
	SET @status_sql =  'EXEC spa_ErrorHandler -1, ''Interface_Agreement'', 
		''Interface_Agreement'', ''Not updated'', ''No rows updated.'', '''''
ELSE
	SET @status_sql =  'EXEC spa_ErrorHandler 0, ''Interface_Agreement'', 
		''Interface_Agreement'', ''Updated'', ''Update Successful.'', '''''

IF @import_status_temp_table_name IS NOT NULL
	EXEC('INSERT INTO ' + @import_status_temp_table_name + ' ' + @status_sql)
ELSE
	EXEC(@status_sql)







GO
