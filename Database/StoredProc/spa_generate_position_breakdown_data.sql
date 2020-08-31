if OBJECT_ID('spa_generate_position_breakdown_data') is not null
drop proc [dbo].[spa_generate_position_breakdown_data]
go

CREATE PROC dbo.spa_generate_position_breakdown_data @import_type INT,@tbl_name VARCHAR(100),@user_login_id VARCHAR(30)=null,@main_process_id VARCHAR(75)=null,@send_email		VARCHAR(1)='n'
AS
DECLARE @spa VARCHAR(150),@job_name VARCHAR(150),@i tinyint,@part_from INT,@part_to INT,@deal_detail_audit_log INT,@process_id VARCHAR(75)
declare @final_import_run_status varchar(200)
set @user_login_id=isnull(@user_login_id,dbo.fnadbuser())
set @process_id=dbo.FNAGetNewID()
set @main_process_id=ISNULL(@main_process_id,@process_id)

set @final_import_run_status=dbo.FNAProcessTableName('final_import_run_status', @user_login_id, @main_process_id)

--adiha_default_code = 44 was previously used to store no. of jobs to create for import, but it is now unused
--and the id 44 is taken by another code (DBA Email Alert).
--SELECT  @deal_detail_audit_log = var_value 	FROM    adiha_default_codes_values
--WHERE   (instance_no = '1') AND (default_code_id = 44) AND (seq_no = 1)
	
set @i=1

UPDATE dbo.log_partition SET process_id='spa_generate_position_breakdown_data',sp_end_time=null,sp_start_time=NULL,error_found_status=0,err_stage=null WHERE tbl_name=@tbl_name

--TODO: TRUNCATE was used, replaced with DELETE for solving privilege issue
DELETE FROM dbo.report_hourly_position_profile_blank
DELETE FROM dbo.deal_detail_hour_blank

if object_id(@final_import_run_status) is not null
exec('drop table '+@final_import_run_status)

exec('create table ' +@final_import_run_status+' (id int,process_id varchar(50), create_ts datetime)')
exec('create unique index uindex_final_import_run_status on ' +@final_import_run_status+' (id)')

set @deal_detail_audit_log=1
--return
WHILE @i<=isnull(@deal_detail_audit_log,1)
BEGIN
	
	set @spa='spa_generate_position_breakdown_data_job ' + cast(@import_type AS VARCHAR) + ',''' +@tbl_name+''','''+@user_login_id+''','''+@main_process_id+''','''+ @send_email+''''
	set @job_name='spa_generate_position_breakdown_data_job_'+RIGHT('0'+cast(@i as varchar),2)+ '_'+@process_id
	
	EXEC spa_run_sp_as_job @job_name,@spa , 'generating_position_breakdown',@user_login_id

	set @i=@i+1
END
