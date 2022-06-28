IF OBJECT_ID (N'[dbo].[spa_deal_insert_update_jobs]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_insert_update_jobs]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 /**
	Executes after inserting or update any deals to call all the post deal save operations

	Parameters
	@insert_update_flag				:	Insert Update Flag (i -> For inserting the deal u -> For updating the deal).
	@process_table_name				:	Process Table Name containing the all the inserted/updated new deals.
	@exclude_post_deal_save_steps	:	The steps that are to be excluded.
 */

CREATE PROCEDURE [dbo].[spa_deal_insert_update_jobs]
    @insert_update_flag CHAR(1),
    @process_table_name NVARCHAR(300),
	@exclude_post_deal_save_steps VARCHAR(30) = NULL
AS

/*---------------------Debug Section-------------------------
DECLARE @insert_update_flag CHAR(1),
		@process_table_name VARCHAR(300),
		@exclude_post_deal_save_steps = NULL

-- EXEC spa_deal_insert_update_jobs 'i', 'adiha_process.dbo.after_insert_process_table_runaj_75C88029_9FB3_446A_992A_8840F696E1F4', '3'
-----------------------------------------------------------*/
SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX)
DECLARE @user_name NVARCHAR(100) = dbo.FNADBUSer()

IF OBJECT_ID('tempdb..#temp_affected_deals') IS NOT NULL
	DROP TABLE #temp_affected_deals

CREATE TABLE #temp_affected_deals (
	source_deal_header_id INT,
	[action] CHAR(1) COLLATE DATABASE_DEFAULT 
)

SET @sql = '
	INSERT INTO #temp_affected_deals (source_deal_header_id, [action])
	SELECT source_deal_header_id, ''' + @insert_update_flag + '''
	FROM ' + @process_table_name

EXEC(@sql)

IF OBJECT_ID ('tempdb..#sdh_params') IS NOT NULL
	DROP TABLE #sdh_params

CREATE TABLE #sdh_params (
	source_deal_header_id INT,
	detail_process_table NVARCHAR(200) COLLATE DATABASE_DEFAULT,
	complex_price_process_id NVARCHAR(200) COLLATE DATABASE_DEFAULT,
	provisional_price_detail_process_id NVARCHAR(200) COLLATE DATABASE_DEFAULT,
	is_gas_daily CHAR(1)  COLLATE DATABASE_DEFAULT
)

BEGIN TRY
	EXEC ('
		INSERT INTO #sdh_params (source_deal_header_id, detail_process_table, complex_price_process_id, provisional_price_detail_process_id, is_gas_daily)
		SELECT * FROM ' + @process_table_name + '
	')
END TRY
BEGIN CATCH
	EXEC ('
		INSERT INTO #sdh_params (source_deal_header_id)
		SELECT * FROM ' + @process_table_name + '
	')
END CATCH

DECLARE @jobs_process_id NVARCHAR(200) = dbo.FNAGETNewID()
DECLARE @report_position_deals NVARCHAR(400) = dbo.FNAProcessTableName('report_position', @user_name, @jobs_process_id) 
DECLARE @search_table NVARCHAR(400) = dbo.FNAProcessTableName('search_table', @user_name, @jobs_process_id)
DECLARE @complex_pricing_step NVARCHAR(MAX)
DECLARE @gas_daily_step NVARCHAR(MAX)
DECLARE @position_breakdown_step NVARCHAR(MAX)
DECLARE @alert_register_event_step NVARCHAR(MAX)
DECLARE @alert_register_event_iu_step NVARCHAR(MAX)
DECLARE @insert_update_audit_step NVARCHAR(MAX)
DECLARE @master_deal_view_step NVARCHAR(MAX)
DECLARE @job_name NVARCHAR(200)
DECLARE @alert_process_table NVARCHAR(300)
DECLARE @affected_deals NVARCHAR(MAX)

IF EXISTS (SELECT 1 FROM #sdh_params WHERE NULLIF(complex_price_process_id, '') IS NOT NULL OR NULLIF(provisional_price_detail_process_id, '') IS NOT NULL)
BEGIN
	DECLARE @price_process_table NVARCHAR(2000)
		
	SELECT @price_process_table = 'adiha_process.dbo.pricing_xml_' + dbo.FNADBUser() + '_' + complex_price_process_id
	FROM #sdh_params
		
	SELECT @complex_pricing_step = '
		DECLARE @flag CHAR(1), @source_deal_detail_id INT, @xml_value NVARCHAR(MAX), @apply_to_xml NVARCHAR(MAX), @is_apply_to_all CHAR(1), @call_from NVARCHAR(50), @process_id NVARCHAR(200)

		DECLARE @get_source_deal_detail_id CURSOR
		SET @get_source_deal_detail_id = CURSOR FOR
				' + IIF (@insert_update_flag = 'u', '
				SELECT DISTINCT ''m'', sdd.source_deal_detail_id, p.xml_value, p.apply_to_xml, p.is_apply_to_all, p.call_from, p.process_id
				FROM ' + @price_process_table + ' p
				' + IIF(NULLIF(detail_process_table, '') IS NOT NULL, '
				LEFT JOIN ' + NULLIF(detail_process_table, '') + ' d 
					ON d.source_deal_detail_id = p.source_deal_detail_id ', 
					'') 
				+ '
				LEFT JOIN source_deal_detail sdd 
				ON ' + IIF (NULLIF(detail_process_table, '') IS NOT NULL, '
					(CONVERT(NVARCHAR(10), d.term_start, 120) <= CONVERT(NVARCHAR(10), sdd.term_start, 120)
						AND CONVERT(NVARCHAR(10), d.term_end, 120) >= CONVERT(NVARCHAR(10), sdd.term_end, 120)
						AND d.blotterleg = sdd.leg )
						OR (
							p.source_deal_detail_id = CAST(sdd.source_deal_detail_id AS NVARCHAR(50))
						)
						', 
						' sdd.source_deal_detail_id  = p.source_deal_detail_id '
					) + '
				WHERE sdd.source_deal_header_id = ' + CAST(source_deal_header_id AS NVARCHAR(10)) + '
				', '
				SELECT ''m'', sdd.source_deal_detail_id, p.xml_value, p.apply_to_xml, p.is_apply_to_all, p.call_from, p.process_id
				FROM ' + detail_process_table + ' d
				INNER JOIN ' + @price_process_table + ' p
					ON d.source_deal_detail_id = p.source_deal_detail_id
				INNER JOIN source_deal_detail sdd 
					ON CONVERT(NVARCHAR(10), d.term_start, 120) <= CONVERT(NVARCHAR(10), sdd.term_start, 120)
						AND CONVERT(NVARCHAR(10), d.term_end, 120) >= CONVERT(NVARCHAR(10), sdd.term_end, 120)
						AND d.blotterleg = sdd.leg
				WHERE sdd.source_deal_header_id = ' + CAST(source_deal_header_id AS NVARCHAR(10)) + '
				') + '
		OPEN @get_source_deal_detail_id
		FETCH NEXT
		FROM @get_source_deal_detail_id INTO @flag, @source_deal_detail_id, @xml_value, @apply_to_xml, @is_apply_to_all, @call_from, @process_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC [dbo].[spa_deal_pricing_detail] @flag = @flag, @source_deal_detail_id = @source_deal_detail_id, @xml = @xml_value, @apply_to_xml = @apply_to_xml, @is_apply_to_all = @is_apply_to_all, @call_from = @call_from, @process_id = @process_id, @mode = ''save'', @xml_process_id = NULL
		FETCH NEXT
		FROM @get_source_deal_detail_id INTO @flag, @source_deal_detail_id, @xml_value, @apply_to_xml, @is_apply_to_all, @call_from, @process_id
		END
		CLOSE @get_source_deal_detail_id
		DEALLOCATE @get_source_deal_detail_id;

	'		
	FROM #sdh_params
	
	IF EXISTS (SELECT 1 FROM #sdh_params WHERE NULLIF(provisional_price_detail_process_id, '') IS NOT NULL)
	BEGIN
		DECLARE @price_provisional_process_table NVARCHAR(2000)
		
		SELECT @price_provisional_process_table = 'adiha_process.dbo.provisional_pricing_xml_' + dbo.FNADBUser() + '_' + provisional_price_detail_process_id
		FROM #sdh_params

		SET @complex_pricing_step = ISNULL(@complex_pricing_step, '')

		SELECT @complex_pricing_step += '
			DECLARE @flag_p CHAR(1), @source_deal_detail_id_p INT, @xml_value_p NVARCHAR(MAX), @apply_to_xml_p NVARCHAR(MAX), @is_apply_to_all_p CHAR(1), @call_from_p NVARCHAR(50), @process_id_p NVARCHAR(2000)

			DECLARE @get_source_deal_detail_id_p CURSOR
			SET @get_source_deal_detail_id_p = CURSOR FOR
			' + IIF (@insert_update_flag = 'u', '
					SELECT DISTINCT ''m'', sdd.source_deal_detail_id, p.xml_value, p.apply_to_xml, p.is_apply_to_all, p.call_from, p.process_id
					FROM ' + @price_provisional_process_table + ' p
					' + IIF(NULLIF(detail_process_table, '') IS NOT NULL, '
					LEFT JOIN ' + NULLIF(detail_process_table, '') + ' d 
						ON d.source_deal_detail_id = p.source_deal_detail_id ', 
						'') 
					+ '
					LEFT JOIN source_deal_detail sdd 
					ON ' + IIF (detail_process_table IS NOT NULL, '
						(CONVERT(NVARCHAR(10), d.term_start, 120) <= CONVERT(NVARCHAR(10), sdd.term_start, 120)
							AND CONVERT(NVARCHAR(10), d.term_end, 120) >= CONVERT(NVARCHAR(10), sdd.term_end, 120)
							AND d.blotterleg = sdd.leg )
							OR (
								p.source_deal_detail_id = CAST(sdd.source_deal_detail_id AS NVARCHAR(50))
							)
							', 
							' sdd.source_deal_detail_id  = p.source_deal_detail_id '
						) + '
					WHERE sdd.source_deal_header_id = ' + CAST(source_deal_header_id AS NVARCHAR(10)) + '
					', '
					SELECT ''m'', sdd.source_deal_detail_id, p.xml_value, p.apply_to_xml, p.is_apply_to_all, p.call_from, p.process_id
					FROM ' + detail_process_table + ' d
					INNER JOIN ' + @price_provisional_process_table + ' p
						ON d.source_deal_detail_id = p.source_deal_detail_id
					INNER JOIN source_deal_detail sdd 
						ON CONVERT(NVARCHAR(10), d.term_start, 120) <= CONVERT(NVARCHAR(10), sdd.term_start, 120)
							AND CONVERT(NVARCHAR(10), d.term_end, 120) >= CONVERT(NVARCHAR(10), sdd.term_end, 120)
							AND d.blotterleg = sdd.leg
					WHERE sdd.source_deal_header_id = ' + CAST(source_deal_header_id AS NVARCHAR(10)) + '
					') + '
			OPEN @get_source_deal_detail_id_p
			FETCH NEXT
			FROM @get_source_deal_detail_id_p INTO @flag_p, @source_deal_detail_id_p, @xml_value_p, @apply_to_xml_p, @is_apply_to_all_p, @call_from_p, @process_id_p
			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC [dbo].[spa_deal_pricing_detail_provisional] @flag = @flag_p, @source_deal_detail_id = @source_deal_detail_id_p, @xml = @xml_value_p, @apply_to_xml = @apply_to_xml_p, @is_apply_to_all = @is_apply_to_all_p, @call_from = @call_from_p, @process_id = @process_id_p, @mode = ''save'', @xml_process_id = NULL
			FETCH NEXT
			FROM @get_source_deal_detail_id_p INTO @flag_p, @source_deal_detail_id_p, @xml_value_p, @apply_to_xml_p, @is_apply_to_all_p, @call_from_p, @process_id_p
			END
			CLOSE @get_source_deal_detail_id_p
			DEALLOCATE @get_source_deal_detail_id_p
		'
		FROM #sdh_params
	END		
END

SELECT @affected_deals = COALESCE(@affected_deals + ',', '') + CAST(source_deal_header_id AS NVARCHAR(10))
FROM #temp_affected_deals

IF EXISTS (SELECT 1 FROM #sdh_params WHERE is_gas_daily = 'y')
BEGIN
	IF @insert_update_flag = 'u'
	BEGIN
		SELECT @gas_daily_step = 'EXEC spa_update_prorated_volume ''u'', ''' + CAST(source_deal_header_id AS NVARCHAR(20)) + ''''
		FROM #sdh_params
	END
	ELSE
	BEGIN
		SET @gas_daily_step = 'EXEC spa_update_prorated_volume ''u'', ''' + @affected_deals + ''''
	END
END

SET @position_breakdown_step = 'EXEC spa_calc_deal_position_breakdown NULL,''' + CAST(@jobs_process_id AS NVARCHAR(50)) + ''''

IF OBJECT_ID(@report_position_deals) IS NOT NULL
BEGIN
	EXEC('DROP TABLE ' + @report_position_deals)
END
			
IF OBJECT_ID(@search_table) IS NOT NULL
BEGIN
	EXEC('DROP TABLE ' + @search_table)
END

EXEC('SELECT source_deal_header_id, [action] INTO ' + @report_position_deals + ' FROM #temp_affected_deals')
EXEC('SELECT source_deal_header_id, [action] INTO ' + @search_table + ' FROM #temp_affected_deals')	

SET @alert_process_table = 'adiha_process.dbo.alert_deal_' + @jobs_process_id + '_ad'
			
EXEC ('
	CREATE TABLE ' + @alert_process_table + '(
		source_deal_header_id NVARCHAR(1000),
		deal_date DATETIME,
		term_start DATETIME,
		counterparty_id NVARCHAR(1000),
		confirm_status_id INT,
		hyperlink1 NVARCHAR(MAX),
		hyperlink2 NVARCHAR(MAX),
		hyperlink3 NVARCHAR(MAX),
		hyperlink4 NVARCHAR(MAX),
		hyperlink5 NVARCHAR(MAX),
		trader_id NVARCHAR(250)
	)
')
 			   
SET @sql = '
	INSERT INTO ' + @alert_process_table + ' (source_deal_header_id, deal_date, term_start, counterparty_id, hyperlink1, hyperlink2, trader_id)
 	SELECT st.source_deal_header_id, sdh.deal_date, sdh.entire_term_start, sdh.counterparty_id,
 		   dbo.FNATrmWinHyperlink(''i'', 10131010, ''Deal #'' + CAST(st.source_deal_header_id AS NVARCHAR(20)), st.source_deal_header_id, ''n'',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,0),
 		   dbo.FNATrmWinHyperlink(''i'',10131020,''Review Trade Ticket'',st.source_deal_header_id,DEFAULT,''n'',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,0),
		   stt.user_login_id
 	FROM #temp_affected_deals st
 	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = st.source_deal_header_id
	LEFT JOIN source_traders stt ON sdh.trader_id = stt.source_trader_id
'

EXEC(@sql)

IF @insert_update_flag = 'i'
BEGIN
	SET @alert_register_event_step = 'EXEC spa_register_event 20601, 20502, ''' + @alert_process_table + ''', 1, ''' + @jobs_process_id + ''''
END 	
ELSE IF @insert_update_flag = 'u'
BEGIN
	SET @alert_register_event_step = 'EXEC spa_register_event 20601, 20504, ''' + @alert_process_table + ''', 1, ''' + @jobs_process_id + ''''
	SET @alert_register_event_step += '; EXEC spa_register_event 20601, 20502, ''' + @alert_process_table + ''', 1, ''' + @jobs_process_id + ''''
END		

SET @alert_register_event_iu_step = 'EXEC spa_register_event 20601, 20537, ''' + @alert_process_table + ''', 1, ''' + @jobs_process_id + ''''
 			
SET @alert_register_event_step += '; ' + @alert_register_event_iu_step

IF EXISTS(SELECT 1 FROM #temp_affected_deals)
BEGIN
 	SET @insert_update_audit_step = 'spa_insert_update_audit ''' + @insert_update_flag + ''','''',''Inserted from Blotter.'',''' + @search_table + ''''
END
 			
SET @master_deal_view_step = 'spa_master_deal_view ''' + @insert_update_flag + ''',NULL, ''' + @search_table + ''''

DECLARE @step1 NVARCHAR(MAX), @step2 NVARCHAR(MAX), @step3 NVARCHAR(MAX), @step4 NVARCHAR(MAX), @step5 NVARCHAR(MAX), @step6 NVARCHAR(MAX)

--update prorated volume setp 1
--insert/update complex pricing step 2
--calculate deal position step 3
--alert register event step 4
--insert/update master deal view step 5
--insert/update audit step 6
--SET @job_name = 'Post_Deal_Save_Operations'
SET @job_name = 'Post_Deal_Save_Operations_' +  @jobs_process_id

DECLARE @par1 VARCHAR(8000), @par2 VARCHAR(8000), @par3 VARCHAR(8000), @par4 VARCHAR(8000), @par5 VARCHAR(8000), @par6 VARCHAR(8000)

SET @step1 = '
	DECLARE @job_id UNIQUEIDENTIFIER = CONVERT(UNIQUEIDENTIFIER, $(ESCAPE_NONE(JOBID)));
	EXEC msdb.dbo.sp_update_jobstep @job_id = @job_id, @step_id = $(ESCAPE_NONE(STEPID)), @step_name = ''Gas Daily'' ;
	GO
' + ISNULL(@gas_daily_step,'')

SET @step2 = '
	DECLARE @job_id UNIQUEIDENTIFIER = CONVERT(UNIQUEIDENTIFIER, $(ESCAPE_NONE(JOBID)));
	EXEC msdb.dbo.sp_update_jobstep @job_id = @job_id, @step_id = $(ESCAPE_NONE(STEPID)), @step_name = ''Complex Pricing'' ;
	GO
' + ISNULL(@complex_pricing_step,'')
SET @step3 = '
	DECLARE @job_id UNIQUEIDENTIFIER = CONVERT(UNIQUEIDENTIFIER, $(ESCAPE_NONE(JOBID)));
	EXEC msdb.dbo.sp_update_jobstep @job_id = @job_id, @step_id = $(ESCAPE_NONE(STEPID)), @step_name = ''Position Breakdown'' ;
	GO
' + ISNULL(@position_breakdown_step,'')
SET @step4 = '
	DECLARE @job_id UNIQUEIDENTIFIER = CONVERT(UNIQUEIDENTIFIER, $(ESCAPE_NONE(JOBID)));
	EXEC msdb.dbo.sp_update_jobstep @job_id = @job_id, @step_id = $(ESCAPE_NONE(STEPID)), @step_name = ''Deal Audit'' ;
	GO
' + ISNULL(@insert_update_audit_step,'')

SET @step5 = '
	DECLARE @job_id UNIQUEIDENTIFIER = CONVERT(UNIQUEIDENTIFIER, $(ESCAPE_NONE(JOBID)));
	EXEC msdb.dbo.sp_update_jobstep @job_id = @job_id, @step_id = $(ESCAPE_NONE(STEPID)), @step_name = ''Alert Register Event'' ;
	GO
' + ISNULL(@alert_register_event_step,'')

SET @step6 = '
	DECLARE @job_id UNIQUEIDENTIFIER = CONVERT(UNIQUEIDENTIFIER, $(ESCAPE_NONE(JOBID)));
	EXEC msdb.dbo.sp_update_jobstep @job_id = @job_id, @step_id = $(ESCAPE_NONE(STEPID)), @step_name = ''Master Deal View'' ;
	GO
' + ISNULL(@master_deal_view_step, '')

SET @job_name = 'Post_Deal_Save_Operations'
--PRINT @job_name; PRINT @step1; PRINT @step2; PRINT @step3; PRINT @step4; PRINT @step5; PRINT @step6
--RETURN

--IF @step1 IS NOT NULL AND @step2 IS NOT NULL AND @step3 IS NOT NULL AND @step4 IS NOT NULL AND @step5 IS NOT NULL AND @step6 IS NOT NULL
--	EXEC spa_run_multi_step_job @job_name = @job_name, 
--								@job_description  = 'Post deal save operations',
--								@step1 = @step1,
--								@step2 = @step2,
--								@step3 = @step3,
--								@step4 = @step4,
--								@step5 = @step5,
--								@step6 = @step6,
--								@process_id = @jobs_process_id
--IF @step1 IS NULL AND @step2 IS NOT NULL AND @step3 IS NOT NULL AND @step4 IS NOT NULL AND @step5 IS NOT NULL AND @step6 IS NOT NULL
--	EXEC spa_run_multi_step_job @job_name = @job_name, 
--								@job_description  = 'Post deal save operations',
--								@step1 = @step2,
--								@step2 = @step3,
--								@step3 = @step4,
--								@step4 = @step5,
--								@step5 = @step6,
--								@process_id = @jobs_process_id
--IF @step1 IS NULL AND @step2 IS NULL AND @step3 IS NOT NULL AND @step4 IS NOT NULL AND @step5 IS NOT NULL AND @step6 IS NOT NULL
--	EXEC spa_run_multi_step_job @job_name = @job_name, 
--								@job_description  = 'Post deal save operations',
--								@step1 = @step3,
--								@step2 = @step4,
--								@step3 = @step5,
--								@step4 = @step6,								
--								@process_id = @jobs_process_id

SELECT ROW_NUMBER() OVER (ORDER BY CAST(a.item AS INT)) rowid,
	CAST(a.item AS INT) item
INTO #include_steps
FROM dbo.FNASplit('1,2,3,4,5,6', ',') a
LEFT JOIN dbo.FNASplit(@exclude_post_deal_save_steps, ',') e
	ON a.item = e.item
WHERE e.item IS NULL

IF EXISTS(SELECT 1 FROM #include_steps) -- do not create job in case of no step
BEGIN
	SELECT @par1 = CHOOSE(item, @step1, @step2, @step3, @step4, @step5, @step6)
	FROM #include_steps
	WHERE rowid = 1

	SELECT @par2 = CHOOSE(item, @step1, @step2, @step3, @step4, @step5, @step6)
	FROM #include_steps
	WHERE rowid = 2

	SELECT @par3 = CHOOSE(item, @step1, @step2, @step3, @step4, @step5, @step6)
	FROM #include_steps
	WHERE rowid = 3

	SELECT @par4 = CHOOSE(item, @step1, @step2, @step3, @step4, @step5, @step6)
	FROM #include_steps
	WHERE rowid = 4

	SELECT @par5 = CHOOSE(item, @step1, @step2, @step3, @step4, @step5, @step6)
	FROM #include_steps
	WHERE rowid = 5

	SELECT @par6 = CHOOSE(item, @step1, @step2, @step3, @step4, @step5, @step6)
	FROM #include_steps
	WHERE rowid = 6

	EXEC spa_run_multi_step_job @job_name, 'Post deal save operations',
		@par1,
		@par2,
		@par3,
		@par4,
		@par5,
		@par6,
		@jobs_process_id
END

GO