
if OBJECT_ID('spa_generate_position_breakdown_data_job') is not null
	drop PROC dbo.spa_generate_position_breakdown_data_job
go

CREATE PROC [dbo].[spa_generate_position_breakdown_data_job] 
	@import_type int
	,@tbl_name VARCHAR(100)
	,@user_login_id VARCHAR(30)
	,@main_process_id varchar(100)
	,@send_email		VARCHAR(1)='n'
AS
/*

----INSERT INTO  stage_deal_detail_hour_001 (term_date, profile_id, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, partition_value, [file_name])
----SELECT term_date, profile_id, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, partition_value, [file_name] FROM deal_detail_hour
---- where profile_id =100

----INSERT INTO  stage_deal_detail_hour_002 (term_date, profile_id, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, partition_value, [file_name])
----SELECT term_date, profile_id, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, partition_value, [file_name] FROM deal_detail_hour
---- where profile_id =211

----SELECT * FROM deal_detail_hour
---- where profile_id =100

truncate table dbo.deal_detail_hour_blank
truncate table dbo.report_hourly_position_profile_blank
declare  @import_type int,@tbl_name VARCHAR(100),@user_login_id VARCHAR(30),@main_process_id varchar(100)
	,@send_email VARCHAR(1)
 
select @import_type=1,@tbl_name='deal_detail_hour',@user_login_id='farrms_admin',@main_process_id ='testingqqq'
	,@send_email ='n'

IF OBJECT_ID(N'tempdb..#tmp_partition', N'U') IS NOT NULL
	drop table #tmp_partition

set nocount off
UPDATE   dbo.log_partition set data_found_status=1
UPDATE dbo.log_partition set sp_start_time=null,sp_end_time=null,process_id=null,error_found_status=0
--	select * from dbo.log_partition
--  select count(*) from stage_deal_detail_hour_002
-- select count(*) from deal_detail_hour where partition_value between 1501 and 3000
--	select count(*) from deal_detail_hour_tmp where partition_value between 1501 and 3000
-- select * from stagne_deal_detail_hour_001
--delete dbo.log_partition where partition_id<>1

IF OBJECT_ID(N'tempdb..#tmp_location_profile_main', N'U') IS NOT NULL
	drop table #tmp_location_profile_main
--*/
--DELETE source_system_data_import_status
--DELETE source_system_data_import_status_detail
-- SELECT * FROM source_system_data_import_status

DECLARE @st VARCHAR(max),@part_id INT,@part_from INT,@part_to INT,@process_id VARCHAR(100)
DECLARE @deadlock_var NCHAR(3),@inserted_source_deal_detail varchar(200),@use_swith_method INT,@maintain_delta INT
declare @err_no int,@err_msg varchar(2000)	, @count int,@url varchar(max),@desc varchar(max),@errorcode varchar(1)
declare @start_time_load_forecast_import varchar(200),@final_import_run_status varchar(200),@err_stage INT
declare @start_time DATETIME

set @start_time_load_forecast_import=dbo.FNAProcessTableName('start_time_load_forecast_import', @user_login_id, @main_process_id)


select @start_time=isnull(min(start_time),GETDATE()) from log_partition where tbl_name=@tbl_name

SET @deadlock_var = N'LOW'; 
SET DEADLOCK_PRIORITY @deadlock_var; 

set @final_import_run_status=dbo.FNAProcessTableName('final_import_run_status', @user_login_id, @main_process_id)

/*
--TODO: create a new code for @maintain_delta and use that code to replace 32
SELECT  @maintain_delta = var_value 	FROM    adiha_default_codes_values
	WHERE   (instance_no = '1') AND (default_code_id = 32) AND (seq_no = 1)
*/	
SET @maintain_delta=1
/*
--TODO: create a new code for @use_swith_method and use that code to replace 32
SELECT  @use_swith_method = var_value 	FROM    adiha_default_codes_values
	WHERE   (instance_no = '1') AND (default_code_id = 42) AND (seq_no = 1)
*/	

	
select @process_id=dbo.FNAGetNewID()
set @use_swith_method=1

		
DECLARE @spa VARCHAR(1000)
DECLARE @report_position_process_id VARCHAR(500)
DECLARE @report_position_deals VARCHAR(150),@no_record int

SET @report_position_process_id = dbo.FNAGetNewID()
SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
EXEC ('CREATE TABLE ' + @report_position_deals + '(source_deal_header_id INT, action CHAR(1))')

--SELECT * FROM #tmp_import_profiles

CREATE TABLE #tmp_location_profile_main(
	  location_id INT NULL,
	  profile_id INT NULL,
	  profile_type INT,                                       
	  external_id VARCHAR(50) COLLATE DATABASE_DEFAULT
)
--set nocount on

--EXEC spa_print '************[Start Elapse time:'+ convert(varchar(8),dateadd(ss,DATEDIFF(ss,@start_time,GETDATE()),'00:00:00'),108) +']'
create table #tmp_partition (partition_id int,part_from INT,part_to INT,err_stage int)
--create table #data_exists_check (data bit)
--SET @inserted_source_deal_detail = dbo.FNAProcessTableName('inserted_source_deal_detail','trigger', @process_id)
BEGIN TRY 
	WHILE 1=1
	BEGIN
		log_start:
		UPDATE top(1) dbo.log_partition with (ROWLOCK) SET sp_start_time=GETDATE(),process_id = @process_id 
		output inserted.partition_id,inserted.partition_from,inserted.partition_to,INSERTED.err_stage into #tmp_partition  
		 WHERE sp_start_time IS NULL AND tbl_name =@tbl_name AND data_found_status=1

		IF @@rowcount<1
			BREAK

		select @part_id=partition_id,@part_from=part_from,@part_to=part_to,@err_stage=err_stage from #tmp_partition		
		
		EXEC spa_print 'log_start:', @part_id
		set @st='select top(1) 1 dt into #data_exists_check from dbo.stage_deal_detail_hour_'+RIGHT('00'+CAST(@part_id AS VARCHAR),3)
		exec(@st)
		if @@ROWCOUNT<1
		BEGIN 
			UPDATE dbo.log_partition SET sp_end_time=GETDATE(),process_id='Data not found' WHERE partition_id=@part_id AND tbl_name =@tbl_name
			truncate table #tmp_partition
			goto log_start
		END
		
		EXEC ('truncate table ' + @report_position_deals )

		----validating Data---------------------------------------------------------------------
		--begin try
		
		--	set @st='if exists(select 1 from sys.check_constraints where [name]=''hour_check_'+right('00'+CAST(@part_id AS VARCHAR),3) +''')
		--		ALTER TABLE dbo.stage_deal_detail_hour_'+right('00'+CAST(@part_id AS VARCHAR),3) +' Drop CONSTRAINT hour_check_'+right('00'+CAST(@part_id AS VARCHAR),3) +'
		--		ALTER TABLE dbo.stage_deal_detail_hour_'+right('00'+CAST(@part_id AS VARCHAR),3) +' ADD CONSTRAINT hour_check_'+right('00'+CAST(@part_id AS VARCHAR),3) +' CHECK (partition_value between  '+cast(@part_from as varchar) +' and '+cast(@part_to as varchar) +' AND partition_value IS NOT NULL)'
		--	exec spa_print @st
		--	EXEC(@st)
			
		--end try
		--begin catch
		--	EXEC spa_print 'Partition_id:'+CAST(@part_id AS VARCHAR)+'(Invalid Range:'+cast(@part_from as varchar) + ' to '+ cast(@part_to as varchar)+ ' in table dbo.stage_deal_detail_hour_'+right('00'+CAST(@part_id AS VARCHAR),3)+').'
			
		--	insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation,create_user,create_ts) 
		--		select @main_process_id,'Error','Import Deal Hourly Data','violation_partition_range','Error','Violation partition range:'+cast(@part_from as varchar) + ' to '+ cast(@part_to as varchar)+ ' found for the partition number:' + right('00'+CAST(@part_id AS VARCHAR),3),'Please check data.',dbo.fnadbuser() usr,GETDATE() dt
		--	insert into source_system_data_import_status_detail(process_id,source,type,[description],create_user,create_ts) 
		--		select @main_process_id,'violation_partition_range','import_hourly_load_data','Violation partition range:'+cast(@part_from as varchar) + ' to '+ cast(@part_to as varchar)+ ' found for the partition number:' + right('00'+CAST(@part_id AS VARCHAR),3),dbo.fnadbuser() usr,GETDATE() dt
			
		--	update dbo.log_partition  with (ROWLOCK) set error_found_status=1 where partition_id=@part_id
		--	goto log_start
		--end catch
		-----end validating Data---------------------------------------------------------
		
--start messaging FOR status

		set @st='insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation,create_user,create_ts) 
				select '''+ @main_process_id+''' process_id,''Success'' code,''Import Deal Hourly Data'' module,FILE_NAME source,''Success'' type
				,''Data imported successfully for '' + cast(n.no_rows as varchar)+ '' days for EAN: '' + p.external_id +''.'' [description],''Please verify.'' recommendation,dbo.fnadbuser() usr,GETDATE() dt  
				from forecast_profile p cross apply (select s.FILE_NAME,s.profile_id, count(1) no_rows from dbo.stage_deal_detail_hour_'+right('00'+CAST(@part_id AS VARCHAR),3) +' s 
						   where s.profile_id =p.profile_id group by FILE_NAME,profile_id) n'
			
		exec spa_print @st
		EXEC(@st)

		
		-- Import load forecast data
		BEGIN TRAN 
				
			set @st='delete b from  dbo.deal_detail_hour b inner join dbo.stage_deal_detail_hour_'+right('00'+CAST(@part_id AS VARCHAR),3) +' s
					on b.partition_value=s.partition_value and b.term_date= s.term_date and b.profile_id=s.profile_id'
			exec spa_print @st
			EXEC(@st)

			set @st='insert into dbo.deal_detail_hour (term_date, profile_id, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, partition_value, [file_name],create_ts) 
			select r.term_date, profile_id, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, r.partition_value, [file_name],getdate() create_ts from 
			(
				SELECT DISTINCT partition_value,term_date FROM dbo.stage_deal_detail_hour_'+right('00'+CAST(@part_id AS VARCHAR),3)+'
			) s
			 cross APPLY (
				SELECT TOP 1 * FROM dbo.stage_deal_detail_hour_'+right('00'+CAST(@part_id AS VARCHAR),3) +' m 
				 WHERE s.partition_value=m.partition_value AND s.term_date=m.term_date
			 ) r'
				
			exec spa_print @st
			EXEC(@st)
			
		IF @@TRANCOUNT>0  
			COMMIT TRAN 

		-- Update data availavle status
		set @st='
		UPDATE forecast_profile SET available = 1
		FROM forecast_profile fp
		INNER JOIN dbo.stage_deal_detail_hour_'+right('00'+CAST(@part_id AS VARCHAR),3)+' ip ON fp.profile_id = ip.profile_id'
		
		exec spa_print @st
		EXEC(@st)
		
		-- Taking location that mapped to imported profile

		set @st='
				INSERT INTO #tmp_location_profile_main
				  (   location_id, profile_id, profile_type, external_id  )
				SELECT sml.source_minor_location_id,
					   ISNULL(fp.profile_id, fp1.profile_id) profile_id,
					   ISNULL(fp.profile_type, fp1.profile_type) profile_type,
					   ISNULL(fp.external_id, fp1.external_id) external_id
				FROM   source_minor_location sml(NOLOCK)
					   LEFT JOIN [forecast_profile] fp(NOLOCK)
							ON  fp.profile_id = sml.profile_id
							AND ISNULL(fp.available, 0) = 1
					   LEFT JOIN [forecast_profile] fp1(NOLOCK)
							ON  fp1.profile_id = sml.proxy_profile_id
							AND ISNULL(fp1.available, 0) = 1
					   INNER JOIN dbo.stage_deal_detail_hour_'+RIGHT('00'+CAST(@part_id AS VARCHAR),3) +' ip (nolock)
							ON  ip.profile_id = ISNULL(fp.profile_id, fp1.profile_id)
				WHERE  ISNULL(fp.profile_id, fp1.profile_id) IS NOT NULL 
			'
		EXEC spa_print @st
		exec(@st)

		-- Taking deals that mapped to imported profile through location.

		EXEC('INSERT INTO ' + @report_position_deals + '(source_deal_header_id, action)
				SELECT DISTINCT source_deal_header_id, ''i'' FROM source_deal_detail sdd (nolock)
				INNER JOIN #tmp_location_profile_main tmp ON sdd.location_id = tmp.location_id')
		set @no_record=@@ROWCOUNT 
		EXEC spa_print 'no of records:', @no_record
				
		IF @no_record>0
			EXEC dbo.spa_update_deal_total_volume NULL, @process_id, 12

		UPDATE dbo.log_partition  SET sp_end_time=GETDATE(),process_id=@final_import_run_status WHERE partition_id=@part_id AND tbl_name =@tbl_name
		truncate table #tmp_partition
		truncate table #tmp_location_profile_main
	--	commit tran
	END --While loop
	
END TRY
BEGIN CATCH
	--if @@trancount>0
	--	rollback		
	
	SELECT @err_no=ERROR_NUMBER(),@err_msg =ERROR_MESSAGE()


		
	EXEC spa_print '##############Error Catch#############################################'
	EXEC spa_print 'ERROR Stage:', @err_stage, '; Error#:', @err_no, ' Message:', @err_msg
	EXEC spa_print '######################################################################'

	insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation,create_user,create_ts) 
		select @main_process_id,'Error','Import deal hourly data','Import deal hourly data','Error','Error #:' + cast(@err_no as varchar) +'; Message:'+ @err_msg+' (Partition range:'+cast(@part_from as varchar) + ' to '+ cast(@part_to as varchar)+ ' found for the partition number:' + right('00'+CAST(@part_id AS VARCHAR),3)+').','Please check data.',dbo.fnadbuser() usr,GETDATE() dt
	
	insert into source_system_data_import_status_detail(process_id,source,type,[description],create_user,create_ts) 
		select @main_process_id,'Import deal hourly data','Error','Error #:' + cast(@err_no as varchar) +'; Message:'+ @err_msg+' (Partition range:'+cast(@part_from as varchar) + ' to '+ cast(@part_to as varchar)+ ' found for the partition number:' + right('00'+CAST(@part_id AS VARCHAR),3)+').',dbo.fnadbuser() usr,GETDATE() dt

	UPDATE dbo.log_partition with (rowLOCK) SET sp_end_time=GETDATE(),process_id=left(cast(@err_no as varchar) +': ' + @err_msg,200) WHERE partition_id=@part_id AND tbl_name =@tbl_name

END CATCH

messaging:

	SELECT @user_login_id=CASE WHEN @user_login_id='sa' THEN 'farrms_admin' ELSE @user_login_id end
	SELECT @count=COUNT(*) FROM source_system_data_import_status WHERE process_id=@main_process_id AND code='Error' 
	if @count>0							
		set @errorcode='e'
	else 
		set @errorcode='s'
		
	select @start_time=isnull(min(create_ts),GETDATE()) from import_data_files_audit where process_id=@main_process_id
	
	DECLARE @elapse_time int
	SET @elapse_time=DATEDIFF(ss,@start_time,getdate())

	EXEC spa_import_data_files_audit 'u',null,NULL,@main_process_id,NULL,null,null,@errorcode,@elapse_time

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @main_process_id + ''','''+ @user_login_id+''''

	SELECT @desc = '<a target="_blank" href="' + @url + '">Load forecasted data import completed on as of date:'+ dbo.FNADateFormat(getdate())
												+' completed.'+CASE WHEN @errorcode='e' THEN ' (ERRORS found)' ELSE '' END +
				'[Elapse time:'+ convert(varchar(8),dateadd(ss,DATEDIFF(ss,@start_time,GETDATE()),'00:00:00'),108) +'].</a>'   
	set @desc=ISNULL(@desc,'no message')

	IF @send_email='y'
	BEGIN
		IF NOT EXISTS(SELECT 'x' FROM message_board WHERE process_id=@main_process_id)
		BEGIN
			declare @user varchar(30)
			DECLARE list_user CURSOR FOR 
					SELECT application_users.user_login_id	
							FROM dbo.application_role_user 
								INNER JOIN dbo.application_security_role 
									ON dbo.application_role_user.role_id = dbo.application_security_role.role_id 
								INNER JOIN dbo.application_users 
									ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
					WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id =2) 
							--AND  dbo.application_users.user_emal_add  IS NOT NULL
					GROUP BY dbo.application_users.user_login_id,  dbo.application_users.user_emal_add

			OPEN list_user

			FETCH NEXT FROM list_user INTO 	@user

			WHILE @@FETCH_STATUS = 0
			BEGIN				
				EXEC  spa_message_board 'i', @user,NULL, 'Load Forecast Import',@desc, '', '', @errorcode, 'Load forecasted import',null,@main_process_id
				FETCH NEXT FROM list_user INTO 	@user
			END

			CLOSE list_user
			DEALLOCATE list_user
		END
	END
	ELSE
	BEGIN
		IF  NOT EXISTS(SELECT 'x' FROM message_board WHERE process_id=@main_process_id)
			EXEC  spa_message_board 'u', @user_login_id,NULL, 'Load Forecast Import',@desc, '', '', @errorcode, NULL, NULL,@main_process_id, DEFAULT, DEFAULT, DEFAULT, 'y'
			-- can't use 'i' flag since the block terminates with 'return'		
			-- job name is evaluated with respective processId				
	END
	
	

