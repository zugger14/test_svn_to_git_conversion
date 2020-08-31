IF OBJECT_ID(N'[dbo].[spa_eod_tech_error_log]', N'P') IS NOT NULL
    DROP PROC [dbo].[spa_eod_tech_error_log]
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-09 08:45PM
-- Description: Log EOD Process error messages into eod_process_status.
--              
-- Params:
-- @source - EOD Error Source
-- @log_status - Error Log Status
-- @message - Error Message
-- @master_process_id - EOD Master Process ID
-- @process_id - EOD Process ID
-- @as_of_date - Date
-- @detail_status - Detailed EOD Error Message
-- ============================================================================================================================
CREATE PROC [dbo].[spa_eod_tech_error_log]
	@source VARCHAR(100),
	@log_status VARCHAR(50),
	@message VARCHAR(8000),
	@master_process_id VARCHAR(120),
	@process_id VARCHAR(120),
	@as_of_date VARCHAR(10),
	@detail_status VARCHAR(5000)
AS
BEGIN
	
	DECLARE @user_login_id VARCHAR(200)
	SET @user_login_id = dbo.FNADBUser()
	
	
    INSERT INTO eod_process_status
	(
		[source],
		[status],
		[message],
		[master_process_id],
		[process_id],
		[as_of_date],
		message_detail
	)
	VALUES
	(
		@source,
		@log_status,
		@message,
		@master_process_id,
		@process_id,
		@as_of_date,
		ISNULL(@detail_status, '')
	)
	
	--EXEC spa_message_board
	--     @flag = 'i',
	--     @user_login_id = @user_login_id,
	--     @source = @source,
	--     @description = @log_status,
	--     @type = 'e',
	--     @as_of_date = @as_of_date,
	--     @process_id = @process_id
	     
	EXEC spa_message_board 'i',
	     @user_login_id,
	     NULL,
	     'EOD Process',
	     @message,
	     '',
	     '',
	     's'
	
END

