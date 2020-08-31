------Stored Procedure spa_archive_process_data_job
IF OBJECT_ID('[dbo].[spa_archive_process_data_job]') IS NOT NULL
    DROP PROC [dbo].[spa_archive_process_data_job]
GO

CREATE PROC [dbo].[spa_archive_process_data_job]
@close_status VARCHAR(1) = 'y'
,@aod_from DATETIME
,@archive_type_id INT
,@job_name VARCHAR(100)
,@user_login_id VARCHAR(50)
,@process_id VARCHAR(100) = NULL
AS

/*
DECLARE @close_status     VARCHAR(1),
        @archive_type_id  INT,
        @aod_from         DATETIME,
        @job_name         VARCHAR(100),
        @user_login_id    VARCHAR(50),
        @process_id       VARCHAR(100)

SET @close_status = 'y'
SET @aod_from = '2009-10-01'
SET @job_name = 'zsetnerzgd'
SET @user_login_id = 'farrms_admin'
SET @process_id = 'zzeekkrgntds'
SET @archive_type_id = 2150

*/

DECLARE @sql_stmt VARCHAR(8000)
DECLARE @url VARCHAR(500)
DECLARE @desc VARCHAR(500)
DECLARE @desc1 VARCHAR(500)

DECLARE @tbl_location VARCHAR(500)

DECLARE @errorcode VARCHAR(200)
DECLARE @tbl_name VARCHAR(100)

DECLARE @tableName VARCHAR(100)
DECLARE @no_month_pnl INT
DECLARE @close_month_pnl DATETIME	
DECLARE @jobName VARCHAR(100)
--DECLARE @tableFrom VARCHAR(100)
--DECLARE @tableTo VARCHAR(100)
--
SET @jobName = 'archivedata'
--SET @tableFrom = ''
--SET @tableTo = '_arch1'
		
EXEC spa_print  @close_status

SET @desc=''
SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
				'&spa=exec spa_get_import_process_status ''' + @process_id + ''', '''+@user_login_id+''''

DECLARE @begin_time              DATETIME,
        @prefix_location_table   VARCHAR(20),
        @upto                    INT,
        @i                       INT,
        @frequency_type          VARCHAR(1)

DECLARE @month_move_data         DATETIME,
        @tbl_next                VARCHAR(200),
        @archive_at_link_server  VARCHAR(1)

IF EXISTS(SELECT 1 FROM   process_table_archive_policy ptap WHERE  ISNULL(CHARINDEX('.', ptap.dbase_name), 0) <> 0)
    SET @archive_at_link_server = 'y'
ELSE
    SET @archive_at_link_server = 'n'

SET @begin_time = GETDATE()

BEGIN TRY
	IF @archive_at_link_server = 'y'
	BEGIN
	    EXEC spa_print 'SET XACT_ABORT ON'
	    SET XACT_ABORT ON
	    BEGIN DISTRIBUTED TRAN
	END
	ELSE
	    
	BEGIN TRAN

	DECLARE @getTableName  CURSOR 
	SET @getTableName =  CURSOR FOR

	SELECT tbl_name,
	       prefix_location_table,
	       upto,
	       frequency_type
	FROM   process_table_archive_policy ptap
	WHERE  ptap.archieve_type_id = @archive_type_id
	ORDER BY
	       tbl_name,
	       prefix_location_table

	OPEN @getTableName

	FETCH NEXT
	FROM @getTableName INTO @tableName,@prefix_location_table,@upto ,@frequency_type
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC spa_print '#######################', @tablename, @prefix_location_table, '###################'
		
		
		IF @tableName = 'source_deal_pnl'
		BEGIN
			SELECT @no_month_pnl=no_month_pnl FROM run_measurement_param
			--month for data transfer
			SET @close_month_pnl = dateadd(m, -1*isnull(@no_month_pnl, 0), @aod_from)
		END
		ELSE
		BEGIN
			SET @close_month_pnl = @aod_from
		END
		set @tbl_next=''
		SET @tbl_location=dbo.[FNAGetProcessTableName] (@close_month_pnl, @tableName)
		SET @errorcode='s'
		
		if @close_status='y'
		BEGIN
			IF isnull(@upto,0)=0 AND isnull(@prefix_location_table,'')='' --when master table 
				set @tbl_next='_arch1'
			ELSE -- when other than master table.
			BEGIN
				IF isnull(@upto,0)<>0 -- when other than master and last archived table.
				BEGIN
					SELECT @i = COUNT(*)
						FROM   process_table_location
					WHERE  prefix_location_table = @prefix_location_table
					       AND [tbl_name] = @tablename
					EXEC spa_print 'process_table_location:', @i
					EXEC spa_print '[process_table_archive_policy]:', @upto
													
					IF @i > @upto * ( CASE @frequency_type	WHEN 'a' THEN 12 WHEN 's' THEN 6 WHEN 'q' THEN 3 WHEN 'm' THEN 1  END ) --convert into month
					BEGIN
						
						SELECT @tbl_next = MIN([prefix_location_table])	FROM   [process_table_archive_policy]
							WHERE  ISNULL([prefix_location_table], '') > ISNULL(@prefix_location_table, '') AND [tbl_name] = @tablename

						EXEC spa_print 'Start Data tranfer @tbl_name:', @tablename,'  from ', @prefix_location_table, ' to ', @tbl_next
						
						SELECT @close_month_pnl = MIN(as_of_date) FROM   process_table_location
							WHERE  ISNULL(prefix_location_table, '') = ISNULL(@prefix_location_table, '') AND [tbl_name] = @tablename
						SET @tbl_location=dbo.[FNAGetProcessTableName] (@close_month_pnl, @tableName)

					END
					ELSE 
						set @tbl_next=''
				END
			END
			EXEC spa_print '@tablename:',@tablename
			EXEC spa_print '@tbl_location:',@tbl_location
			EXEC spa_print '@prefix_location_table:',@prefix_location_table
			EXEC spa_print '@tbl_next:',@tbl_next
			EXEC spa_print '@close_month_pnl:', @close_month_pnl
			IF isnull(@prefix_location_table,'')=''
			BEGIN
				set @prefix_location_table = isnull(@prefix_location_table, '')
				IF (@tbl_location = @tableName  OR @tbl_location = 'dbo.'+@tableName ) AND @tbl_next<>''
					EXEC spa_archive_core_process @tableName, @close_month_pnl, @prefix_location_table, @tbl_next, 1, @jobName, @user_login_id, @process_id
			END
			ELSE
			BEGIN
				IF isnull(CHARINDEX(@prefix_location_table,@tbl_location,1),0)<>0  AND @tbl_next<>''
					EXEC spa_archive_core_process @tableName, @close_month_pnl, @prefix_location_table, @tbl_next, 1, @jobName, @user_login_id, @process_id
			END
		END
		ELSE --unclose
		BEGIN
			if isnull(@prefix_location_table,'')<>'' AND isnull(CHARINDEX(@prefix_location_table,@tableName,1),0)<>0
				EXEC spa_archive_core_process @tableName, @close_month_pnl, @prefix_location_table, '', 1, @jobName, @user_login_id, @process_id
		END	
		EXEC spa_print '******************************************************************************', @tablename, @prefix_location_table, '********************************'
		FETCH NEXT
		FROM @getTableName INTO @tableName,@prefix_location_table,@upto ,@frequency_type

			
	END
	CLOSE @getTableName
	DEALLOCATE @getTableName
	
	if @close_status='y'
	BEGIN
		INSERT INTO close_measurement_books (as_of_date,archive_type_id,create_user,create_ts) values (@aod_from,@archive_type_id,@user_login_id,GETDATE())
		
		SET @desc ='Archive data process for '+dbo.FNAUserDateFormat(@aod_from, @user_login_id)+' is completed on ' 
					+ dbo.FNAUserDateFormat(getdate(), @user_login_id)+'. Data has been successfully archived. '
					+ ' (Elapse time: ' + cast(datediff(ss,@begin_time,getdate()) as varchar) + ' seconds)'
		
		SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc 
					+ CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found).  Please contact support. ' 
					+ '(Elapse time: ' + CAST(DATEDIFF(ss,@begin_time,GETDATE()) AS VARCHAR) + ' seconds)' ELSE '' END + '</a>'

		EXEC  spa_message_board 'i', @user_login_id, NULL, 'Archive.Data', @desc, '', '', 's', @job_name, null, @process_id
		
		INSERT INTO source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
			SELECT @process_id, 'Success', 'Archive Data', 'Archive Data', 'Archive Success', 
						'Successfully Archive data for the '+dbo.FNAUserDateFormat(@aod_from, @user_login_id)+' on the as of date: '+dbo.FNAUserDateFormat(getdate(),
						 @user_login_id)+'.', ''	
		
	END
	ELSE
	BEGIN
		DELETE FROM close_measurement_books WHERE as_of_date=@aod_from AND ISNULL(archive_type_id, 2150) = @archive_type_id
		SET @desc ='Retrieve Data process for '+dbo.FNAUserDateFormat(@aod_from, @user_login_id)+' is completed on ' 
					+ dbo.FNAUserDateFormat(getdate(), @user_login_id)+'. Data has not been successfully archived.'
		
		SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc 
					+ CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found).  Please contact support.' ELSE '.' END + '.</a>'
		
		EXEC  spa_message_board 'i', @user_login_id, NULL, 'Retrieve.Data', @desc, '', '', 's', @job_name, NULL, @process_id
		
		INSERT INTO source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
			SELECT @process_id, 'Success', 'Year unclosing', 'Year unclosing','Unclosing Success',
					'Successfully unclosed the Year for the '+dbo.FNAUserDateFormat(@aod_from, @user_login_id)+' on the as of date: '+dbo.FNAUserDateFormat(getdate(),
					 @user_login_id)+'.', ''
		
		
	END
--ROLLBACK TRANSACTION
--return
	IF (XACT_STATE()) = -1
	    ROLLBACK TRANSACTION
	ELSE 	    --active and valid transaction
	IF (XACT_STATE()) = 1
	    COMMIT TRANSACTION 
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
	BEGIN
		--EXEC spa_print 'ERROR:['+ERROR_MESSAGE()+'].'
		ROLLBACK TRAN
	END
	
	SET @errorcode='e'
	SET @desc = 'Archive Data for the period '+dbo.FNAUserDateFormat(@aod_from, @user_login_id)+' failed to complete on ' + dbo.FNAUserDateFormat(getdate(), @user_login_id)
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc 
				+ CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found).  Please contact support.' ELSE '' END + '.</a>'

	EXEC  spa_message_board 'i', @user_login_id, NULL, 'Archive.Data', @desc, '', '', @errorcode, @job_name, NULL, @process_id
	
	IF ERROR_number()<>266
	BEGIN
		INSERT INTO source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
			SELECT @process_id, 'Error', 'Archive Data', 'Archive Data', 'Closing Error',
				'Closing for the year '+dbo.FNAUserDateFormat(@aod_from, @user_login_id)+' is failed ['+ERROR_MESSAGE()+'].','Please Check your data'
				
		INSERT INTO source_system_data_import_status_detail(process_id,source,type,[description]) 
			SELECT @process_id,'Archive Data','Archive Data',
				'Archive Data for the Period '+ +dbo.FNAUserDateFormat(@aod_from, @user_login_id)+ ' is failed  ['+ERROR_MESSAGE()+'].'
	END
END CATCH

GO
-----------------
