

/****** Object:  StoredProcedure [dbo].[spa_manual_archive_data]    Script Date: 08/24/2012 13:43:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_manual_archive_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_manual_archive_data]
GO


/****** Object:  StoredProcedure [dbo].[spa_manual_archive_data]    Script Date: 08/24/2012 13:43:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
Performs manual archival from setup>> archive data as per new archival approach

Parameters:

@archive_type_value_id : Archive table type, static data type 2150
@as_of_date : reference data for archiving.
@from_sequence : From table sequence Number, 1 - Main table, 2 - Archive table
@to_sequence : Destination table sequence number , 1 - Main table, 2 - Archive table
@batch_process_id : Unique batch identifer of archive process.
@batch_report_param : Paramater to run through batch

*/

CREATE PROCEDURE [dbo].[spa_manual_archive_data]
	@archive_type_value_id	INT, 
	@as_of_date				DATETIME, 
	@from_sequence			INT,
	@to_sequence			INT,
	@batch_process_id VARCHAR(50)=NULL,
	@batch_report_param VARCHAR(1000)=NULL
	
AS

SET NOCOUNT ON;
DECLARE @archive_data_policy_id	INT
DECLARE @main_table_name		VARCHAR(100)
DECLARE @wherer_field			VARCHAR(100)
DECLARE @frequency				VARCHAR(1)
DECLARE @user_login_id			VARCHAR(100)
DECLARE @process_id				VARCHAR(100)
DECLARE @tbl_from				VARCHAR(100)
DECLARE @tbl_to					VARCHAR(100)
DECLARE @status					VARCHAR(1)
DECLARE @desc					VARCHAR(150)
DECLARE @frm_message			VARCHAR (100)
DECLARE @to_message				VARCHAR (100)
SET XACT_ABORT ON

IF @from_sequence = 1 
	SET @frm_message = 'Main'
ELSE 
	SET @frm_message = 'Archive ' + CAST(@from_sequence - 1  AS VARCHAR(2))
IF @to_sequence = 1 
	SET @to_message = 'Main'
ELSE 
	SET @to_message = 'Archive ' + CAST(@to_sequence - 1  AS VARCHAR(2))


CREATE TABLE #tmp_status 
	(
	error_code		VARCHAR(10) COLLATE DATABASE_DEFAULT, 
	module			VARCHAR(100) COLLATE DATABASE_DEFAULT, 
	area			VARCHAR(100) COLLATE DATABASE_DEFAULT, 
	[status]		VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[message]		VARCHAR(500) COLLATE DATABASE_DEFAULT, 
	recommendation	VARCHAR(500) COLLATE DATABASE_DEFAULT	
	)
IF @user_login_id IS NULL
	SET @user_login_id = dbo.FNADBUser()
	
IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()
		
BEGIN TRY

	SET XACT_ABORT ON
	IF EXISTS( SELECT 1 FROM archive_data_policy_detail adpd
		INNER JOIN archive_data_policy adp ON adp.archive_data_policy_id = adpd.archive_data_policy_id
		WHERE adp.archive_type_value_id = @archive_type_value_id AND ISNULL(CHARINDEX('.', adpd.archive_db), 0) <> 0 )
		BEGIN 
			BEGIN DISTRIBUTED TRAN
		END
	ELSE
		BEGIN	
			BEGIN TRAN
		END

	DECLARE tbl_main_cursor CURSOR LOCAL FOR
	SELECT  archive_data_policy_id, main_table_name, where_field, archive_frequency 
	FROM archive_data_policy adp
	WHERE archive_type_value_id = @archive_type_value_id
	ORDER BY adp.sequence
	
	OPEN tbl_main_cursor

	FETCH NEXT FROM tbl_main_cursor INTO  @archive_data_policy_id, @main_table_name, @wherer_field, @frequency
	WHILE @@FETCH_STATUS = 0
	
		BEGIN 
			--SELECT @tbl_from = ISNULL(adpd.archive_db + '.dbo.', '') + adpd.table_name
			SELECT @tbl_from =  adpd.table_name
			FROM archive_data_policy_detail adpd 
			INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id 
				AND adpd.sequence = @from_sequence
				AND adpd.archive_data_policy_id = @archive_data_policy_id
			ORDER BY adpd.sequence 
			
--					SELECT @tbl_to = ISNULL(adpd.archive_db + '.dbo.', '') + adpd.table_name
			SELECT @tbl_to =  adpd.table_name
			FROM archive_data_policy_detail adpd 
			INNER JOIN archive_data_policy adp ON adpd.archive_data_policy_id = adp.archive_data_policy_id 
				AND adpd.sequence = @to_sequence
				AND adpd.archive_data_policy_id = @archive_data_policy_id
			ORDER BY adpd.sequence 
			
			INSERT INTO #tmp_status (error_code, module, area, [status], [message],	recommendation)
			EXEC spa_archive_core_process --make sure every possible path returns spa_ErrorHandler output
						@main_table_name, 
						@as_of_date,
						@tbl_from,
						@tbl_to,
						3, --call_from 
						'Manual_archive_data',
						@user_login_id,
						@process_id,
						NULL
			
			IF EXISTS (SELECT 1 FROM #tmp_status WHERE status = 'Error')
			BEGIN
				IF @@TRANCOUNT > 0 ROLLBACK
					SET @status = 'e'
				BREAK
			END
			FETCH NEXT FROM tbl_main_cursor INTO  @archive_data_policy_id, @main_table_name, @wherer_field, @frequency
		END
		
	IF NOT EXISTS (SELECT 1 FROM #tmp_status WHERE status = 'Error') AND @@TRANCOUNT > 0
	BEGIN
		COMMIT TRAN
		EXEC spa_print 'End Data tranfer'-- from source(' + @tbl_from + ') to destination(' + @tbl_to + ')'
		SET @desc = 'Successfully archived the data from "' + @frm_message  + '" to "' + @to_message + '".'
		--SELECT 'Saved' AS ErrorCode, 'Archive Data' Module, 'spa_archive_core_process' Area, 'Success' [Status], @desc [Message], '' Recommendation
		EXEC spa_print 'End:' --+ @main_table_name	
	END
	
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK
		SET @status = 'e'
	
	EXEC spa_print 'Error while archiving data:' --+ ERROR_MESSAGE()
	IF CURSOR_STATUS('local', 'tbl_main_cursor') > = 0 
	BEGIN
		CLOSE tbl_main_cursor
		DEALLOCATE tbl_main_cursor
	END
END CATCH
				
			
IF @status = 'e'
BEGIN
--	error handler
	SET @desc = 'Archive Data Failed from "' + @frm_message + '" to "' + @to_message + '".'
	--SELECT 'Error' AS ErrorCode, 'Archive Data' Module, 'spa_archive_core_process' Area, 'Error' [Status], @desc [Message], '' Recommendation
	EXEC spa_print 'End:'				--recommendation
END


Update message_board SET [description] = @desc WHERE process_id = @batch_process_id
--select * from message_board order by update_ts desc
GO


