IF OBJECT_ID(N'[dbo].spa_archive_data', N'P') IS NOT NULL
    DROP PROC [dbo].spa_archive_data
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Create date: 2011-03-02
-- Description:	Executes archival process. This process is called by a job.
-- Params:
--	@table_id - static data value for table participating in archiving (static type: Dump Data [2075])
-- 	@as_of_date - reference data for archiving.
-- 	@job_name - job name
-- 	@user_login_id - user login
-- 	@process_id - process id
-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_archive_data]
	@table_id		INT
	
	
AS 
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @tbl_name				VARCHAR(128)
	DECLARE @tbl_from				VARCHAR(100)
	DECLARE @tbl_to					VARCHAR(100)
	DECLARE @table_desc				VARCHAR(100)
	DECLARE @archive_where_field	VARCHAR(100)
	DECLARE @archive_table_name		VARCHAR(100)
	DECLARE @retention_period		INT
	DECLARE @staging_table_name		VARCHAR(250)
	DECLARE @archive_upto_prev		INT
	DECLARE @frequency_type			CHAR(1)
	DECLARE @archive_start_date 	VARCHAR(10)
	DECLARE @archive_end_date 		VARCHAR(10)
	DECLARE @url             		VARCHAR(1000)
	DECLARE @status					CHAR(1)
	DECLARE @db_to           		VARCHAR(100)
	DECLARE @is_external_db			BIT
	DECLARE @as_of_date				DATETIME
	DECLARE @job_name				VARCHAR(100)
	DECLARE @user_login_id			VARCHAR(50)
	DECLARE @process_id				VARCHAR(100) 
	
---- Modified script to execute archival job directly from this SP without using SPA_STAGE as we will be using getdate instead of min date of stage table 	
	--IF @user_login_id IS NULL
		SET @user_login_id = dbo.FNADBUser()
	--IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()
		SET @as_of_date = GETDATE()
		SET @job_name = 'AUTO_SLIDE_ARCHIVE'
		
		
	CREATE TABLE #tmp_status (
		error_code		VARCHAR(10), 
		module			VARCHAR(100), 
		area			VARCHAR(100), 
		[status]		VARCHAR(100),
		[message]		VARCHAR(500), 
		recommendation	VARCHAR(500)	
	)
	--get main table name
	--ASSUMPTIONS: All archived tables have same frequency, wherefield		
	--SELECT @tbl_name = ptap.tbl_name, @frequency_type = ptap.frequency_type, @archive_upto_prev = ptap.upto
	--	, @table_desc = sdv.[description], @archive_where_field = ptap.wherefield
	--FROM process_table_archive_policy ptap
	--INNER JOIN static_data_value sdv ON sdv.code = ptap.tbl_name AND sdv.value_id = @table_id
	--WHERE ISNULL(ptap.prefix_location_table, '') = ''
	
	---- NEW APPROACH 
	DECLARE tblCursor CURSOR FOR
	SELECT  main_table_name,  ISNULL(adp.staging_table_name, adpd.table_name),  archive_frequency,  retention_period, DESCRIPTION, where_field 
	FROM archive_data_policy_detail adpd 
		INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id 
		INNER JOIN static_data_value sdv  ON adp.archive_type_value_id = sdv.value_id 
		AND sdv.value_id = @table_id AND  is_arch_table = 0 --adp.sequence = 1 AND 
	ORDER BY adp.sequence 
	
	OPEN tblCursor
	FETCH NEXT FROM tblCursor into @tbl_name, @tbl_from, @frequency_type, @archive_upto_prev, @table_desc, @archive_where_field
		
	BEGIN TRY
		PRINT 'SET XACT_ABORT ON'
		SET XACT_ABORT ON
	--	PRINT 'SAN'
		IF EXISTS(SELECT 1 
				  FROM archive_data_policy_detail WHERE table_name = @tbl_name AND is_arch_table = 0
					AND ISNULL(CHARINDEX('.', archive_db), 0) <> 0)
		BEGIN 
			BEGIN DISTRIBUTED TRAN
		END
		ELSE
		BEGIN	
			BEGIN TRAN
		END
		
		WHILE @@FETCH_STATUS = 0
		BEGIN

			--loop over all archive tables
			DECLARE cur_arch_tables CURSOR LOCAL FOR
			--SELECT prefix_location_table, upto
			--FROM process_table_archive_policy
			--WHERE tbl_name = @tbl_name AND ISNULL(prefix_location_table, '') <> ''
			--ORDER BY ISNULL(prefix_location_table, '')
			
			SELECT table_name, retention_period, ISNULL(adp.staging_table_name, adp.main_table_name)
			FROM archive_data_policy_detail adpd 
				INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id 
				AND adp.main_table_name  = @tbl_name 
				AND adpd.is_arch_table = 1 
			ORDER BY adpd.sequence
			
			SET @tbl_to = ''
			
			OPEN cur_arch_tables;	
			FETCH NEXT FROM cur_arch_tables INTO @archive_table_name, @retention_period, @staging_table_name
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @tbl_to = @archive_table_name
				
				PRINT '@archive upto previous' + CAST(@archive_upto_prev AS VARCHAR(10))
				PRINT 'rete' + CAST(@retention_period AS VARCHAR(10))
				--calculate from & to date for archival
				PRINT 'spa_archive_data_frequency' + @frequency_type
				PRINT @as_of_date
				IF @frequency_type = 'd'
				BEGIN
					SET @archive_end_date = CONVERT(VARCHAR(10), DATEADD(dd, -@archive_upto_prev, @as_of_date), 120)
				END
				ELSE IF @frequency_type = 'm'
				BEGIN
					SET @archive_end_date = CONVERT(VARCHAR(10), DATEADD(mm, -@archive_upto_prev,  CONVERT(VARCHAR(25),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@as_of_date)+1,0)),101)), 120)
				END
				ELSE IF @frequency_type = 'y'
				BEGIN
					SET @archive_end_date = CONVERT(VARCHAR(10), DATEADD(yy, -@archive_upto_prev, @as_of_date), 120)
				END
				PRINT @archive_end_date
				PRINT 'Executing spa_archive_core_process with @archive_end_date: ' + @archive_end_date
				INSERT INTO #tmp_status (error_code, module, area, [status], [message],	recommendation)
				EXEC spa_archive_core_process --make sure every possible path returns spa_ErrorHandler output
						@tbl_name, 
						NULL,
						@tbl_from,
						@tbl_to,
						3, --call_from 
						@job_name,
						@user_login_id,
						@process_id,
						@archive_end_date
				
				--save info for the next loop
				SET @archive_upto_prev = @retention_period
				SET @tbl_from = @tbl_to
					
					
				FETCH NEXT FROM cur_arch_tables INTO @archive_table_name, @retention_period, @staging_table_name
			END;

			CLOSE cur_arch_tables;
			DEALLOCATE cur_arch_tables;
			
			--handle messaging
			INSERT INTO source_system_data_import_status(process_id, code, module, source, [type], [description], recommendation) 
			SELECT @process_id, ts.[status], ts.module, 'Archive Data', 'Archive Data', ts.[message], ts.recommendation
			FROM #tmp_status ts
			
			FETCH NEXT FROM tblCursor INTO @tbl_name, @tbl_from, @frequency_type, @archive_upto_prev, @table_desc, @archive_where_field
		END
		
		SET @status = 's'			
		COMMIT TRAN 
			
		CLOSE tblCursor;
		DEALLOCATE tblCursor;
			
	END TRY
	BEGIN CATCH
		IF CURSOR_STATUS('local', 'cur_arch_tables') > = 0 
		BEGIN
			CLOSE cur_arch_tables;
			DEALLOCATE cur_arch_tables;
		END
		IF CURSOR_STATUS('local', 'tblCursor') > = 0 
		BEGIN
			CLOSE tblCursor;
			DEALLOCATE tblCursor;
		END

		IF @@TRANCOUNT > 0 
		  ROLLBACK TRAN
		
		SET @status = 'e'
		
		PRINT 'Error while archiving data:' + ERROR_MESSAGE()
			
		DECLARE @template_params VARCHAR(5000)
		SET @template_params = ''
		
		--replace template fields
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_JOB_NAME>', @job_name)
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_ERROR>', ERROR_MESSAGE())
		
		EXEC spa_email_notes
				@flag = 'b',
				@role_type_value_id = 5,
				@email_module_type_value_id = 17801,
				@send_status = 'n',
				@active_flag = 'y',
				@template_params = @template_params
	END CATCH
	
	IF @status = 's'
	BEGIN
		IF EXISTS(SELECT 1 FROM #tmp_status WHERE [status] = 'Warning')
			SET @status = 'w'
		IF EXISTS(SELECT 1 FROM #tmp_status WHERE [status] = 'Error')
			SET @status = 'e'
	END
	
	--write status in message board
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
				'&spa=EXEC spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''
	SELECT @url = '<a target="_blank" href="' + @url + '">' 
				+ 'Archive process is completed for ' + @table_desc + ' for ' + @archive_where_field + ':' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) 
				+ (CASE @status WHEN 'e' THEN ' (ERRORS)' WHEN 'w' THEN ' (WARNING)' ELSE '' END) + '.</a>'
	
	EXEC  spa_message_board 'i', @user_login_id, 1, 'Archive.Data', @url, '', '', 's', @job_name, NULL, @process_id
			
END
GO


