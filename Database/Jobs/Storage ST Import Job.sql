
DECLARE @job_db_name NVARCHAR(250) = DB_NAME()
DECLARE @job_owner NVARCHAR(100) = dbo.FNAAppAdminID()
DECLARE @job_category NVARCHAR(150) = N'Import'
DECLARE @job_name NVARCHAR(500) = @job_db_name + N' - ' + @job_category + N' - Storage ST'
DECLARE @db_single_user NVARCHAR(100) = SYSTEM_USER

DECLARE @command1 NVARCHAR(MAX) = CAST('' AS NVARCHAR(MAX)) +  ' DECLARE @contextinfo VARBINARY(128)
					  SELECT @contextinfo = CONVERT(VARBINARY(128), '''+ CAST(@job_owner AS NVARCHAR(MAX)) +''')
					  SET CONTEXT_INFO @contextinfo
					  '
					
SET @command1 += '	
					DECLARE @job_run_date DATETIME = GETDATE()	
					 SET @job_run_date = ''2020-09-11'' --SQL formatted date here

					IF OBJECT_ID(N''tempdb..#generic_mapping_values'') IS NOT NULL
					DROP TABLE #generic_mapping_values

					SELECT gmv.[mapping_table_id]	 
						   , gmv.[clm1_value]
						   , gmv.[clm2_value]		
						   , gmv.[clm3_value]		
						   , gmv.[clm4_value]		
						   , gmv.[clm5_value]		
						   , gmv.[clm6_value]		
						   , gmv.[clm7_value]		
						   , gmv.[clm8_value]		
						   , gmv.[clm9_value]		
						   , gmv.[clm10_value]		
						   , gmv.[clm11_value]		
						   , gmv.[clm12_value]		
						   , gmv.[clm13_value]		
						   , gmv.[clm14_value]		
						   , gmv.[clm15_value]		
						   , gmv.[clm16_value]		
						   , gmv.[clm17_value]		
						   , gmv.[clm18_value]		
						   , gmv.[clm19_value]		
						   , gmv.[clm20_value]	
					INTO #generic_mapping_values
					FROM  generic_mapping_header gmh
					INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id
					CROSS APPLY (
						SELECT clm1_value, MAX(clm2_value) clm2_value,clm3_value,clm12_value,clm13_value
						FROM generic_mapping_values gmv 
						WHERE gmv.mapping_table_id = gmh.mapping_table_id
						GROUP BY clm1_value,clm3_value,clm12_value,clm13_value
					) mx
					INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id 
						AND gmv.clm1_value = mx.clm1_value
						AND gmv.clm2_value = mx.clm2_value
						AND ISNULL(gmv.clm3_value, '''') = ISNULL(mx.clm3_value,'''')
						AND ISNULL(gmv.clm12_value, '''') = ISNULL(mx.clm12_value,'''')
						AND ISNULL(gmv.clm13_value,'''') = ISNULL(mx.clm13_value,'''')
					
					WHERE gmh.mapping_name = ''Transfer Volume Mapping''
						AND TRY_CAST(gmv.clm1_value AS INT) = 112707


					--Collect position 
					DECLARE @dst_group_value_id INT 
						, @aggregation_level INT = 980
						, @total_columns NVARCHAR(MAX)
						, @granularity int 
						, @min_term datetime 
						, @max_term datetime

					SELECT @dst_group_value_id = tz.dst_group_value_id	--102201
					FROM adiha_default_codes_values adcv
					INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
					WHERE adcv.default_code_id = 36

					DROP TABLE IF EXISTS #position_deals

					SELECT sdh.source_deal_header_id
						, sdd.source_deal_detail_id
						, sdd.term_start
						, sdd.term_end
						, sdd.curve_id
						, sdd.location_id
						, gmv.clm15_value deal_id_to_process
						, sdh.template_id
						, sdd.fixed_price sdd_fixed_price
						, sdh.internal_desk_id
					INTO #position_deals
					FROM source_deal_header sdh
					CROSS APPLY(SELECT sdd.source_deal_header_id, MIN(sdd.term_start) min_term_start 
						FROM source_deal_detail sdd 
						WHERE sdd.source_deal_header_id = sdh.source_deal_header_id
						GROUP BY sdd.source_deal_header_id
					) sdd_min
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN #generic_mapping_values gmv ON 1 = 1 
						AND gmv.clm3_value = sdh.sub_book	
						AND gmv.clm12_value = sdh.header_buy_sell_flag
						AND gmv.clm13_value = sdh.template_id						
					WHERE sdd.leg = 1
						AND sdd_min.min_term_start =  CAST(@job_run_date AS VARCHAR(20))
					
					--Collect deals to update pfc curve.
					DROP TABLE IF EXISTS #process_deals

					SELECT clm15_value deal_id
					INTO #process_deals
					FROM #generic_mapping_values

					SELECT @dst_group_value_id = tz.dst_group_value_id
					FROM adiha_default_codes_values adcv
					INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
					WHERE adcv.default_code_id = 36

					IF OBJECT_ID(N''tempdb..#mv90_dst'') IS NOT NULL
					DROP TABLE #mv90_dst

					SELECT [year]
						, [date]
						, [hour]
					INTO #mv90_dst
					FROM mv90_dst
					WHERE insert_delete = ''i''
						AND dst_group_value_id = @dst_group_value_id  '

SET @command1 += '
					DROP TABLE IF EXISTS  #temp_position

					SELECT source_deal_header_id
						, source_deal_detail_id
						, term_start
						, IIF(cast(substring(upv.hr,3,2) AS INT) = 25, dst.hour , cast(substring(upv.hr,3,2) AS INT)) Hr
						, [period]
						, IIF(cast(substring(upv.hr,3,2) AS INT) <> 25,0,1)  is_dst
						, val volume
						, granularity
						, deal_id_to_process
						, sdd_fixed_price
					INTO #temp_position
					FROM (
						SELECT rhpd.source_deal_header_id
							, d.source_deal_detail_id
 							, rhpd.term_start
							, hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25
							, rhpd.[period]
							, rhpd.granularity	
							, d.deal_id_to_process
							, d.sdd_fixed_price
						FROM #position_deals d
						INNER JOIN report_hourly_position_deal	rhpd ON rhpd.source_deal_header_id = d.source_deal_header_id
							AND rhpd.term_start BETWEEN d.term_start AND d.term_end
							AND ISNULL(rhpd.location_id, -1) = ISNULL(d.location_id, -1)
							AND rhpd.curve_id = d.curve_id
							) rs
						UNPIVOT
							(val for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)	
					) upv
					OUTER APPLY(SELECT dst.date,dst.[hour]
						FROM #mv90_dst dst 
						WHERE dst.date = upv.term_start
						GROUP BY dst.date,dst.[hour]
						) dst
					UNION
						SELECT source_deal_header_id
						, source_deal_detail_id
						, term_start
						, IIF(cast(substring(upv.hr,3,2) AS INT) = 25, dst.hour , cast(substring(upv.hr,3,2) AS INT)) Hr
						, [period]
						, IIF(cast(substring(upv.hr,3,2) AS INT) <> 25,0,1)  is_dst
						, val volume
						, granularity
						, deal_id_to_process
						, sdd_fixed_price
					FROM (
						SELECT rhpd.source_deal_header_id
							, d.source_deal_detail_id
 							, rhpd.term_start
							, hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25
							, rhpd.[period]
							, rhpd.granularity	
							, d.deal_id_to_process
							, d.sdd_fixed_price
					FROM #position_deals d
						INNER JOIN report_hourly_position_profile rhpd ON rhpd.source_deal_header_id = d.source_deal_header_id
							AND rhpd.term_start BETWEEN d.term_start AND d.term_end
							AND ISNULL(rhpd.location_id, -1) = ISNULL(d.location_id, -1)
							AND rhpd.curve_id = d.curve_id
							) rs
						UNPIVOT
							(val for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)	
					) upv
					OUTER APPLY(SELECT dst.date,dst.[hour]
						FROM #mv90_dst dst 
						WHERE dst.date = upv.term_start
						GROUP BY dst.date,dst.[hour]
						) dst
					CREATE INDEX indx_udt_tp ON #temp_position (source_deal_detail_id,term_start,hr,[period])
					'
SET @command1 +=
					'

					DROP TABLE IF EXISTS #source_deal_detail_hour
					CREATE TABLE #source_deal_detail_hour(source_deal_detail_id INT
						, term_date DATETIME
						, hr INT
						, [period] INT
						, is_dst BIT
						, volume NUMERIC(30,20)
						, sddh_price FLOAT
					)

					INSERT INTO #source_deal_detail_hour
					SELECT sddh.source_deal_detail_id
						,sddh.term_date
						, CAST(LEFT(sddh.hr,2) AS INT) hr
						, CAST(RIGHT(sddh.hr,2) AS INT) [period]
						, sddh.is_dst						
						, sddh.volume
						, sddh.price 					
					FROM #position_deals pd
					INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = pd.source_deal_detail_id
					WHERE pd.internal_desk_id = 17302
					
					DECLARE @process_id NVARCHAR(300) = dbo.FNAGetNewID()
						, @import_rule_id INT
						, @temp_process_table NVARCHAR(100)
						, @path NVARCHAR(1000)
						, @sql NVARCHAR(MAX)

					SELECT @path = document_path + ''\temp_Note\''  FROM connection_string
					SELECT @import_rule_id = ixp_rules_id FROM ixp_rules 
					WHERE ixp_rule_hash = ''89F7AE94_309B_4929_AF1A_E873D4BB6A1C''

					SET @temp_process_table = ''adiha_process.dbo.storage_st_position_'' + @process_id


					SET @sql = ''	
							SELECT pd.deal_id
								, tp.term_start
								, tp.hr
								, tp.period
								, tp.is_dst
								, 1 leg
								, tp.volume
								, ISNULL(sddh.sddh_price, tp.sdd_fixed_price) price
								, ABS(tp.volume) * ISNULL(sddh.sddh_price, tp.sdd_fixed_price) amount
							INTO #final_resultset
							FROM #temp_position tp
							INNER JOIN #process_deals pd ON pd.deal_id = tp.deal_id_to_process
							LEFT JOIN #source_deal_detail_hour sddh ON sddh.source_deal_detail_id = tp.source_deal_detail_id
								AND sddh.term_date = tp.term_start
								AND sddh.hr = tp.hr
								AND sddh.period = tp.period
								AND sddh.is_dst = tp.is_dst
							WHERE tp.hr IS NOT NULL

							CREATE TABLE '' + @temp_process_table + ''([Deal Ref ID] NVARCHAR(600),	[Term Date] NVARCHAR(20),	[Hour] NVARCHAR(2),	[Minute] NVARCHAR(2)
								,	[Is DST] NVARCHAR(1)
								,	[Leg] NVARCHAR(2)
								,	[Volume] FLOAT
								,	[Price] FLOAT
								,	[Actual Volume] FLOAT
								,	[Schedule Volume] FLOAT
							)
			
							INSERT INTO '' + @temp_process_table + ''([Deal Ref ID], [Term Date], [Hour], [Minute],[Is DST], [Leg], [Volume], [PRICE])
							SELECT deal_id
								, term_start
								, hr
								, period
								, is_dst
								, 1
								, ABS(SUM(volume)) volume
								, SUM(amount)/IIF(ABS(SUM(volume)) = 0 ,1, ABS(SUM(volume)))
							FROM #final_resultset 
							GROUP BY term_start
								, hr
								, period
								, is_dst
								, deal_id
							''
					
					EXEC(@sql)
							
					EXEC spa_ixp_rules  @flag=''t''
						, @process_id = @process_id
						, @ixp_rules_id = @import_rule_id
						, @run_table = @temp_process_table
						, @source = 21400
						, @execute_in_queue = 0

		'

	
DECLARE @command2 VARCHAR(4000) = 'EXEC ' + @job_db_name + '.dbo.spa_message_board ''i'', ''' + @job_owner + ''', NULL, ''ImportData'', ''Job ' + @job_name + ' failed.'', '''', '''', ''e'', NULL'

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
--delete job if already exists
IF EXISTS(SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @job_name)
	EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1

IF NOT EXISTS(SELECT [name] FROM msdb.dbo.syscategories WHERE [name] = @job_category AND category_class=1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=@job_category
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@job_name, 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Pick position of deals with subbook and template defined in mapping table.', 
		@category_name=@job_category, 
		@owner_login_name= @db_single_user,	--N'trm_enercity_db_user', 
		@job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step1]    Script Date: 9/10/2020 2:15:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run Import Rule', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@command1, 
	    @database_name=@job_db_name
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step2]    Script Date: 9/10/2020 2:15:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Notify on failure', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@command2, 
		@database_name=@job_db_name
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200910, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


