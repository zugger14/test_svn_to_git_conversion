
IF OBJECT_ID('spa_clean_jobs') IS NOT NULL
DROP proc dbo.spa_clean_jobs
GO

CREATE proc dbo.spa_clean_jobs @prior_no_days_delete INT=1
AS
	
--EXEC spa_print CONVERT(VARCHAR(100),GETDATE(),120)

DECLARE @j_id VARCHAR(120)
DECLARE tblCursor CURSOR FOR
	select distinct j.job_id
		from msdb.dbo.sysjobs j
		left join msdb.dbo.sysjobschedules s on j.job_id = s.job_id
		left join msdb.dbo.sysjobhistory   h on j.job_id = h.job_id
		where  
			 ISNULL([h].[run_status],0) IN (0,1,3,5) AND h.run_status IS NOT NULL
			 AND  [enabled]=1 and
				cast (
					case isnull(next_run_date,'1') 
					  when '0' then '9999-jan-01'
					  WHEN '1' THEN '1900-jan-01'
					  else ltrim(str(next_run_date))+' '+stuff(stuff(right('000000'+ltrim(str(next_run_time)), 6) , 3, 0, ':'), 6, 0, ':')  
					end 
				as datetime)<GETDATE()-@prior_no_days_delete
OPEN tblCursor
FETCH NEXT FROM tblCursor into @j_id
WHILE @@FETCH_STATUS = 0
BEGIN
	--EXEC spa_print @j_id+':' +CONVERT(VARCHAR(100),GETDATE(),120)
	EXEC msdb.dbo.sp_delete_job @job_id=@j_id, @delete_unused_schedule=1
	FETCH NEXT FROM tblCursor into @j_id

END
close tblCursor
DEALLOCATE tblCursor

/*


exec spa_clean_jobs

	select s.job_id,[name] as 'Job Name',
		case [enabled] when 1 then 'Enabled' else 'Disabled' end as 'Enabled',
		cast (ltrim(str(run_date))+' '+stuff(stuff(right('000000'+ltrim(str(run_time)), 6) , 3, 0, ':'), 6, 0, ':') as datetime) as 'Job Run',
		step_id as Step,
		case [h].[run_status] 
			when 0 then 'Failed' else 'Success'
			end as 'Status' , 
		STUFF(STUFF(REPLACE(STR(run_duration,6),' ','0'),5,0,':'),3,0,':') as 'Duration', 
		case next_run_date 
			  when '0' then '9999-jan-01'
			  else cast (ltrim(str(next_run_date))+' '+stuff(stuff(right('000000'+ltrim(str(next_run_time)), 6) , 3, 0, ':'), 6, 0, ':') as datetime) 
				end as 'Next Run' 
	from msdb.dbo.sysjobs         j
	left join msdb.dbo.sysjobschedules s on j.job_id = s.job_id
	left join msdb.dbo.sysjobhistory   h on j.job_id = h.job_id
	--where  step_id = 0
    order by 3 desc

    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, '61157828-B869-4DA3-8BE2-109575A1B81E'


EXEC sp_MS_marksystemobject 'sp_dba_GetSqlJobExecutionStatus'




*/