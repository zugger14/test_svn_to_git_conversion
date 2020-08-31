
IF OBJECT_ID(N'[dbo].[spa_eod_process]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_eod_process]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-09 08:45PM
-- Description: EOD Process.
--              
-- Params:
-- @run_type INT, --Steps
-- @master_process_id VARCHAR(120),
-- @process_id VARCHAR(120),
-- @status VARCHAR(50) , -- 1 for success, 0 for failure
-- @date VARCHAR(10) Date
-- @exec_only_this_step INT = 0 -- 1 for single step execution, default 0 for serial execution
-- ============================================================================================================================
CREATE PROCEDURE [dbo].[spa_eod_process]
	@run_type INT,
	@master_process_id VARCHAR(120) = NULL,
	@process_id VARCHAR(120) = NULL,
	@status VARCHAR(50) = NULL, -- 1 for success, 0 for failure
	@date VARCHAR(10) = NULL,
	@exec_only_this_step INT = 0, -- 1 for single step execution, default 0 for serial execution    
	@manual_intervention CHAR(1) = NULL
AS

DECLARE @sql                            VARCHAR(MAX),
        @user_login_id                  VARCHAR(50),
        @job_name                       VARCHAR(150),
        @next_run_type                  INT,
        @ssis_path                      VARCHAR(1000),
        @root                           VARCHAR(1000),
        @proc_desc                      VARCHAR(1000),
        @spa                            VARCHAR(MAX),
        @as_of_date                     VARCHAR(10),
        @source                         VARCHAR(100),
        @label                          VARCHAR(500),
        @log_status                     VARCHAR(50),
        @term_start                     VARCHAR(10),
        @term_end                       VARCHAR(10),
        @cma_start                      INT,
        @cma_response_start             INT,
        @cma_settlement_start           INT,
        @cma_settlement_response_start  INT,
        @root_rdb                       VARCHAR(1000),
        @hol_group_value_id             INT,
        @is_weekend                     CHAR(1),
        @is_holiday                     CHAR(1),
        @run_date                       VARCHAR(10),
        @curve_id						VARCHAR(MAX),
        @cnt							INT,
        @message						VARCHAR(MAX),
        @today							DATETIME,
        @pos_table						VARCHAR(100),
        @rdb_process_id					VARCHAR(100),
        @mtm_table						VARCHAR(100),
		@mtm_status						VARCHAR(10),
		@mtm_detail_status				VARCHAR(5000),
		@wacog_status					VARCHAR(10),
		@BOM_start						INT,	
		@hour							INT,
		@detail_status					VARCHAR(5000),
		@params							VARCHAR(8000)		


--IF @date IS NOT NULL
--	SET @as_of_date = @date

SET @mtm_detail_status = ''
SET @user_login_id = dbo.FNADBUser()

IF @as_of_date IS NULL
BEGIN
    SET @hour = DATEPART(hour, GETDATE())
    IF @hour >= 0 AND @hour <= 11
        SET @as_of_date = CONVERT(VARCHAR(10), GETDATE() -1, 120)
    ELSE
        SET @as_of_date = CONVERT(VARCHAR(10), GETDATE(), 120)
END

SET @next_run_type = CONVERT(VARCHAR(10), GETDATE(), 112)

-- Term Start Should be begining of as of date month and term end should be end of as of date month
SET @term_start = dbo.FNAGetContractMonth(GETDATE())
SET @term_end = CONVERT(VARCHAR(10), dbo.[FNAGetTermEndDate]('m', GETDATE(), 0), 120)

--SET @cma_settlement_start =  REPLACE(CONVERT(VARCHAR(10),DATEADD(mi,1,GETDATE()),108),':','')
--SET @cma_settlement_response_start =  REPLACE(CONVERT(VARCHAR(10),DATEADD(mi,5,GETDATE()),108),':','')
--SET @cma_start =  REPLACE(CONVERT(VARCHAR(10),DATEADD(mi,10,GETDATE()),108),':','')
--SET @cma_response_start =  REPLACE(CONVERT(VARCHAR(10),DATEADD(mi,15,GETDATE()),108),':','')

IF @manual_intervention <> 'y'
BEGIN
	SET @cma_settlement_start = 163500
	SET @cma_settlement_response_start = 170000
	SET @cma_start = 200500
	SET @cma_response_start = 203000
END
ELSE
BEGIN

	SELECT @cma_settlement_start = RIGHT('0'+ CONVERT(VARCHAR,DATEPART(hh,DATEADD(mi,10, GETDATE()))),2)
				+ RIGHT('0'+ CONVERT(VARCHAR,DATEPART(mi,DATEADD(mi,10, GETDATE()))),2)
				+ '00'
		
	SELECT @cma_settlement_response_start = RIGHT('0'+ CONVERT(VARCHAR,DATEPART(hh,DATEADD(mi,15, GETDATE()))),2)
				+ RIGHT('0'+ CONVERT(VARCHAR,DATEPART(mi,DATEADD(mi,15, GETDATE()))),2)
				+ '00'
			
	SELECT @cma_start = RIGHT('0'+ CONVERT(VARCHAR,DATEPART(hh,DATEADD(mi,35, GETDATE()))),2)
				+ RIGHT('0'+ CONVERT(VARCHAR,DATEPART(mi,DATEADD(mi,35, GETDATE()))),2)
				+ '00'
			
	SELECT @cma_response_start = RIGHT('0'+ CONVERT(VARCHAR,DATEPART(hh,DATEADD(mi,45, GETDATE()))),2)
				+ RIGHT('0'+ CONVERT(VARCHAR,DATEPART(mi,DATEADD(mi,45, GETDATE()))),2)
				+ '00'
	
END

SELECT @root_rdb = dbo.FNAGetSSISPkgFullPath('PRJ_RDBInterface', 'User::PS_PackageSubDir') --RDB Package Path
SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_CMAInterface', 'User::PS_PackageSubDir') -- CMA Package Path

SET @ssis_path = @root + 'RequestPackage.dtsx'

IF @status IS NOT NULL
BEGIN
	SET @log_status = @status
	
	/** CMA spot price import **/
	IF @run_type = 19701 
	BEGIN		
		SET @source = 'CMA spot price import request'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SELECT @message = [description] FROM message_board 
			WHERE process_id = @process_id--'CMA Request for Settlement for as of ' + @date
			
			IF @message IS NULL
				SET @message = 'No Files Found for CMA Import Request'				
		END		
	END
	
	/**  CMA spot price import **/
	ELSE IF @run_type = 19702 
	BEGIN
		SET @source = 'CMA spot price import'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SELECT @message = [description] FROM message_board WHERE process_id = @process_id
			
			IF @message IS NULL
				SET @message = 'No Files Found for CMA Import'
		
			/** Check Error or Warning **/
			IF EXISTS(SELECT 'X' FROM source_system_data_import_status WHERE Process_id LIKE @process_id + '%' AND [type] = 'CMA Price Curve' AND [code] = 'Error') 
			BEGIN
				SET @log_status = 'Error'			
			END
			ELSE IF EXISTS(SELECT 'X' FROM source_system_data_import_status WHERE Process_id LIKE @process_id + '%' AND [type] = 'CMA Price Curve' AND [code] = 'Warning')
			BEGIN
				SET @log_status = 'Warning'
			END	
		END
	END
		
	/**  Pratos staging tables processing **/
	ELSE IF @run_type = 19703
	BEGIN
		SET @source = 'Pratos staging tables processing'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SET @message = 'Disabled Pratos staging tables' 				
		END			
	END
		
	/**  Load Forecast Files **/
	ELSE IF @run_type = 19704
	BEGIN 
		SET @source = 'Load Forecast Files'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SELECT @message = [description] FROM message_board 
			WHERE process_id = @process_id	
			
			IF @message IS NULL
				SET @message = 'No Files Found for Load Forecast'			
		END	
	END
	
	/** Run Deals Position Calc **/
	ELSE IF @run_type = 19705
	BEGIN
		SET @source = 'Run Deals Position Calc'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SET @message = 'Deals Position Calculated'  				
		END		
	END
	
	/** Recalculate Position for deals **/
	ELSE IF @run_type = 19706
	BEGIN
		SET @source = 'Recalculate Position for deals'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SET @message = 'Position for deals Recalculated'				
		END	
	END
		
	/** Check Deals with zero or NULL position **/
	ELSE IF @run_type = 19707
	BEGIN
		SET @source = 'Check Deals with zero or NULL position'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SET @message = 'Checked Deals with zero or NULL position'				
		END	
	END
		
	/** Import Forward prices from CMA **/
	ELSE IF @run_type = 19708 
	BEGIN
		SET @source = 'Import Forward prices from CMA Request'
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @label = 'Price Import from CMA for as of ' + @as_of_date
			SELECT @message = [description] FROM message_board WHERE process_id = @process_id
			
			IF @message IS NULL
				SET @message = 'No files found for CMA Forward data import request'
				
			/** Check Error or Warning **/
			IF EXISTS(SELECT 'X' FROM source_system_data_import_status WHERE Process_id = @process_id AND [type] = 'CMA Price Curve' AND [code] = 'Error') 
			BEGIN
				SET @log_status = 'Error'
			END
			ELSE IF EXISTS(SELECT 'X' FROM source_system_data_import_status WHERE Process_id = @process_id AND [type] = 'CMA Price Curve' AND [code] = 'Warning')
			BEGIN
				SET @log_status = 'Warning'
			END			
		END			
	END
	
	/** Import Forward prices from CMA **/
	ELSE IF @run_type = 19709 
	BEGIN
		SET @source = 'Import Forward prices from CMA Response'
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @label = 'Price Import from CMA for as of ' + @as_of_date
			SELECT @message = [description] FROM message_board WHERE process_id = @process_id
			
			IF @message IS NULL
				SET @message = 'No files found for CMA Forward data import'
			
			/** Check Error or Warning **/
			IF EXISTS(SELECT 'X' FROM source_system_data_import_status WHERE Process_id = @process_id AND [type] = 'CMA Price Curve' AND [code] = 'Error') 
			BEGIN
				SET @log_status = 'Error'
			END
			ELSE IF EXISTS(SELECT 'X' FROM source_system_data_import_status WHERE Process_id = @process_id AND [type] = 'CMA Price Curve' AND [code] = 'Warning')
			BEGIN
				SET @log_status = 'Warning'
			END			
		END			
	END
	
	/** Copy Missing Prices **/
	ELSE IF @run_type = 19710
	BEGIN
		SET @source = 'Copy Missing Prices'
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SELECT @message = 'Price Copied for missing as of date: '+ 
				'<a target="_blank" href="' +  './spa_html.php?__user_name__=' + @user_login_id + 
				'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+'''' + '">' + @as_of_date +'.</a>'
			
			/** Check Error or Warning **/
			IF EXISTS(SELECT 'X' FROM source_system_data_import_status WHERE Process_id = @process_id AND [type] = 'Copy data for missing as_of_date' AND [code] = 'Error') 
			BEGIN
				SET @log_status = 'Error'
			END
			ELSE IF EXISTS(SELECT 'X' FROM source_system_data_import_status WHERE Process_id = @process_id AND [type] = 'Copy data for missing as_of_date' AND [code] = 'Warning')
			BEGIN
				SET @log_status = 'Warning'
			END	
		END	
	END		
		
	/**  Check all price curves exist for cache curves **/
	ELSE IF @run_type = 19711
	BEGIN 
		SET @source = 'Check all price curves exist for cache curves'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SET @message = 'Checked all price curves exist for cache curves'
		END		
	END
	
	/** Copy best available Prices **/
	ELSE IF @run_type = 19712
	BEGIN 
		SET @source = 'Copy Best available Prices'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SELECT @message = [description] FROM message_board 
			WHERE process_id = @process_id	
			
			IF @message IS NULL
				SET @message = 'Copy Prices found to copy'			
		END			
	END
	
	/** Run Cache Curves **/
	ELSE IF @run_type = 19713
	BEGIN
		SET @source = 'Run Cache Curves'
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SELECT @message = [description] FROM message_board WHERE job_name = 'cache_curve_'+@process_id
			/** Delete data in message board for steps in EOD Process **/
			DELETE FROM message_board WHERE job_name = 'cache_curve_'+@process_id
		END		
	END
	
	/** Copy Best available prices cache curves **/
	ELSE IF @run_type = 19714
	BEGIN 
		SET @source = 'Copy Best available prices cache curves'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SELECT @message = [description] FROM message_board 
			WHERE process_id = @process_id
			
			IF @message IS NULL
				SET @message = 'Copy Best available prices cache curves copied'	
				
		END					
	END
	
	/** Calculate Storage WACOG Price **/
	ELSE IF @run_type = 19715
	BEGIN		
		SET @source = 'Calculate Storage WACOG Price'
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SELECT @message = [description], @wacog_status = [type] FROM message_board WHERE job_name = 'Inv_Calc_'+@process_id
			/** Delete data in message board for steps in EOD Process **/
			DELETE FROM message_board WHERE job_name = 'Inv_Calc_'+@process_id
			/** Check Error or Warning **/	
			IF @wacog_status = 'e'
				SET @log_status = 'Error'		
		END	
	END
			
	/** Run MTM Process **/
	ELSE IF @run_type = 19716
	BEGIN		
		SET @source = 'Run MTM Process'
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SELECT @message = [description], @mtm_status = [type] FROM message_board WHERE job_name = @process_id
			/** Delete data in message board for steps in EOD Process **/
			DELETE FROM message_board WHERE job_name = @process_id
			/** Check Error or Warning **/
			
			SELECT @mtm_detail_status = REPLACE(SUBSTRING(@message,CHARINDEX('exec',@message,1),CHARINDEX('">',@message,1)-CHARINDEX('exec',@message,1)),'exec','exec '+DB_NAME()+'.dbo.') 
			IF @mtm_status = 'e'
				SET @log_status = 'Error'		
		END
	END
	
	 /** Run Deal Settlement **/
	ELSE IF @run_type = 19717
	BEGIN
		SET @source = 'Run Deal Settlement'
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SELECT @message = [description], @mtm_status = [type] FROM message_board WHERE job_name = @process_id
			/** Delete data in message board for steps in EOD Process **/
			DELETE FROM message_board WHERE job_name = @process_id
			/** Check Error or Warning **/
		
			IF @mtm_status = 'e'
				SET @log_status = 'Error'	
		END
	END	
	
	/** Run FX Exposure Calculation **/
	ELSE IF @run_type = 19718
	BEGIN
		SET @source = 'Run FX Exposure Calculation'
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SELECT @message = [description] FROM message_board WHERE job_name = 'report_batch_'+@process_id
			/** Delete data in message board for steps in EOD Process **/
			DELETE FROM message_board WHERE job_name = 'report_batch_'+@process_id
			/** Check Error or Warning **/
			IF EXISTS(SELECT 'X' FROM mtm_test_run_log WHERE Process_id = @process_id AND [module] = 'FX Calc' AND [code] LIKE '%Error%') 
			BEGIN
				SET @log_status = 'Error'
			END
			ELSE
				SET @log_status = 'Success'		
		END
	END
	
	/** Run Hedge Deferral Calculation **/
	ELSE IF @run_type = 19719
	BEGIN
		SET @source = 'Run Hedge Deferral Calculation'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SET @message = 'Hedge Deferral Calculation'
		END	
	END
	
	/** Functional check **/
	ELSE IF @run_type = 19720
	BEGIN
		SET @source = 'Functional check'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SET @message = 'Functional check'
		END	
	END	
	
	/** Generate cube **/
	ELSE IF @run_type = 19721
	BEGIN
		SET @source = 'Generate cube'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SET @message = 'Generate Cube'
			
		END
	END	
	
	/** Check if all required cube data are populated in CUBES **/
	ELSE IF @run_type = 19722
	BEGIN
		SET @source = 'Check if all required cube data are populated in CUBES'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SET @message = 'Check if all required cube data are populated in CUBES'
		END
	END
	
	/** Send EoD status Email **/
	ELSE IF @run_type = 19723
	BEGIN
		SET @source = 'Send EoD status Email'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SET @message = 'Sent EoD status Email'
		END
	END	
	
	/** Process/Enable processing from Pratos Staging Tables **/
	ELSE IF @run_type = 19724
	BEGIN
		SET @source = 'Process/Enable processing from Pratos Staging Tables'		
		IF @log_status = 'TechError'
		BEGIN			
			SET @label = 'EOD Process Stoped for run date ' + dbo.FNADateFormat(@as_of_date) + ' (Technical Errors Found).'
			SET @label = @label + 'Mannualy Start The Jobs at Error Step: ' + @source
			SET @message = '<font color=#0000ff><u>' + @label +'</u></font>'			
			
			EXEC spa_eod_tech_error_log @source, @log_status, @message, @master_process_id, @process_id, @as_of_date, @detail_status
			EXEC spa_eod_send_tech_error_email @params, @detail_status			
			RETURN
		END
		ELSE
		BEGIN
			SET @log_status = 'Success'
			SET @message = 'Enable processing from Pratos Staging Tables'
		END
	END	
	
		
	/** Delete data in message board for steps in EOD Process **/
	DELETE FROM message_board WHERE process_id = @process_id
	
	/** Insert status of EOD Process steps in eod process status table **/
	INSERT INTO eod_process_status ([source], [status], [message], [master_process_id], [process_id], [as_of_date],message_detail)
	VALUES (@source, @log_status, @message, @master_process_id, @process_id, @as_of_date,ISNULL(@mtm_detail_status,''))			
		
	/** set flag to next step of eod process **/
	IF @status = 'Success'
	BEGIN
		IF @run_type < 19725
		BEGIN
			SET @run_type = @run_type + 1
		END
	END
	ELSE
	BEGIN
		SET @run_type = 19725
	END
	--SELECT @run_type
END

/** CMA spot price import **/
IF @run_type = 19701 
BEGIN
	SET @master_process_id = dbo.FNAGetNewID()
	
	/** check holiday or weekend **/
	SET @today = GETDATE()
	SET @hol_group_value_id = 291898
	SET @is_holiday = 'n'

	SELECT @is_weekend = CASE WHEN DATEPART(dw, @today) IN (1, 7) THEN 'y' ELSE 'n' END
	SELECT @is_holiday = CASE WHEN hol_date IS NOT NULL THEN 'y' ELSE 'n' END
	FROM   holiday_group
	WHERE  hol_date = @today
		   AND hol_group_value_id = @hol_group_value_id

	IF @is_weekend = 'y' OR @is_holiday = 'y'
	BEGIN
		RETURN
	END
	ELSE
	BEGIN
		/** Get as_of_date for 10 days in temporary table START **/
		CREATE TABLE #tmp_as_of_date ( as_of_date VARCHAR(10) COLLATE DATABASE_DEFAULT )
		;WITH
		nbrs_1(n) AS ( SELECT 1 UNION SELECT 0 ), --2^1 --generate auto numbers
		nbrs_0(n) AS ( SELECT 1	FROM nbrs_1 n1 CROSS JOIN nbrs_1 n2 ), --2^8
		nbrs(n) AS ( SELECT 1 FROM nbrs_0 n1 CROSS JOIN nbrs_0 n2 ) --2^16
	    
		INSERT INTO #tmp_as_of_date
		SELECT TOP 9 CONVERT(VARCHAR(10), date_breakdown.[as_of_date], 120)
		FROM   (
				   SELECT ROW_NUMBER() OVER(ORDER BY n) [ROW],
				          DATEADD(DAY, -1 * ROW_NUMBER() OVER(ORDER BY n), @today) [as_of_date],
				          DATEPART(dw, DATEADD(DAY, -1 * ROW_NUMBER() OVER(ORDER BY n), @today)) [weekday]
				   FROM   nbrs
			   ) date_breakdown
		--	   LEFT JOIN holiday_group hg
		--			ON  hg.[hol_date] = date_breakdown.[as_of_date]
		--			AND hg.[hol_group_value_id] = @hol_group_value_id
		--WHERE  hg.[hol_group_id] IS NULL
		--	   AND date_breakdown.[weekday] NOT IN (1, 7)
		ORDER BY [as_of_date] DESC
		/** Get as_of_date for 10 days in temporary table END **/
	    
		/** Get settlement curve id **/
		--SELECT @curve_id = SUBSTRING((SELECT DISTINCT ',' + CAST(settlement_curve_id AS VARCHAR)  FROM source_price_curve_def WHERE settlement_curve_id  IS NOT NULL FOR XML PATH('')),2,200000)
		
		--- Hardcode 
		SET @curve_id= '82,133,134,135,132,139,140,141,142,23,168,161,197,143,83,84,107,93,95,156,145,155'
		
		/** Add schedular job for all as_of_date **/
		DECLARE As_of_date_Cursor CURSOR  
		FOR SELECT [as_of_date] FROM   #tmp_as_of_date
	    
		OPEN As_of_date_Cursor;
		FETCH NEXT FROM As_of_date_Cursor INTO @run_date;
		
		SET @cnt = 1
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @process_id = dbo.FNAGetNewID()
			SET @ssis_path = @root + 'RequestPackage.dtsx'
			SET @spa = N'/FILE "' + @ssis_path + 
				'" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_AsOfDate].Properties[Value]";"' + @run_date + 
				'"  /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id + 
				'" /SET "\Package.Variables[User::PS_CurveIdCsv].Properties[Value]";"' + @curve_id + 
				'" /SET "\Package.Variables[User::PS_ProcessId].Properties[Value]";"' + @process_id + '"'
	        
			SET @proc_desc = 'request_cma_data_for_settlement_' + CAST(@cnt AS VARCHAR)
			SET @job_name = @proc_desc + '_' + @process_id
	        
			EXEC spa_eod_process_as_job_schedule 
			     @job_name,
			     @spa,
			     @proc_desc,
			     @user_login_id,
			     'SSIS',
			     @run_type,
			     @master_process_id,
			     @process_id,
			     @run_date,
			     @next_run_type,
			     @cma_settlement_start,
			     NULL,
			     NULL,
			     NULL,
			     NULL,
			     NULL,
			     NULL,
			     NULL,
			     NULL,
			     @exec_only_this_step
				 
	        
	        SET @cnt = @cnt + 1
			--SET @cma_settlement_start = @cma_settlement_start + 10
			DECLARE @datetime DATETIME
			SET @datetime = DATEADD(ss, 10, CONVERT(VARCHAR(10),GETDATE(),120) + ' ' + STUFF(STUFF(@cma_settlement_start,3,0,':'), 6, 0,':'))
			SET @cma_settlement_start = cast(REPLACE(CONVERT(VARCHAR(20), @datetime,108),':','') AS INT)
			FETCH NEXT FROM As_of_date_Cursor INTO @run_date;
		END;
		
		CLOSE As_of_date_Cursor;
		
		DEALLOCATE As_of_date_Cursor;
		/** Add schedular job for all as_of_date END **/
		
		/** Add schedular job to import data for settlement **/
		SET @process_id = dbo.FNAGetNewID()
		SET @ssis_path = @root + 'ResponsePackage.dtsx'
		SET @spa = N'/FILE "' + @ssis_path + 
		    '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessId].Properties[Value]";"' + @process_id + 
		    '"  /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'

		/** Audit table log **/
		IF NOT EXISTS(SELECT 1 FROM   import_data_files_audit WHERE  process_id = @process_id)
		BEGIN
		    EXEC spa_import_data_files_audit 'i',
		         @as_of_date,
		         NULL,
		         @process_id,
		         'Import CMA Data ',
		         'CMA Data upload (Table No.:4008)',
		         @as_of_date,
		         'p',
		         NULL,
		         NULL,
		         NULL,
		         2
		END		
		
		SET @proc_desc = 'import_cma_data_settlement'
		SET @job_name = @proc_desc + '_' + @process_id
		
		SET @run_type = @run_type + 1
		
		EXEC spa_eod_process_as_job_schedule 
		     @job_name,
		     @spa,
		     @proc_desc,
		     @user_login_id,
		     'SSIS',
		     @run_type,
		     @master_process_id,
		     @process_id,
		     NULL,
		     @next_run_type,
		     @cma_settlement_response_start,
		     NULL,
		     NULL,
		     NULL,
		     NULL,
		     NULL,
		     NULL,
		     NULL,
		     NULL,
		     @exec_only_this_step
		
		/** Add schedular job to import data for settlement End **/
		

	END
END

/** CMA spot price import **/
IF @run_type = 19702
BEGIN
	/** Continue with @run_type = 19701, Import Procedure is handled in @run_type = 19701  */
	
	/* Previous Error Code */
	--SET @process_id = dbo.FNAGetNewID()
	--SET @proc_desc = 'report_batch'
	--SET @job_name = @proc_desc + '_' + @process_id
	--SET @spa = 'SELECT 1'
		
	--EXEC spa_eod_process_as_job
	--     @job_name,
	--     @spa,
	--     @proc_desc,
	--     @user_login_id,
	--     'TSQL',
	--     @run_type,
	--     @master_process_id,
	--     @process_id,
	--     NULL,
	--     @exec_only_this_step	
	/* Previous Error Code */
	
	SELECT 1
		
END

/** Pratos staging tables processing **/
IF @run_type = 19703
BEGIN
	-- Disable Pratos Processing from staging table
	-- UPDATE pratos_bulk_import_config SET bulk_import = 'y'
	
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'report_batch'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'UPDATE pratos_bulk_import_config SET bulk_import = ''n'''
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step	
END

/** Load Forecast Files **/
IF @run_type = 19704
BEGIN
	
	DECLARE @root_load VARCHAR(1000)
	SET @root_load = dbo.FNAGetSSISPkgFullPath('PRJ_LoadForecastDataImportIS', 'User::PS_PackageSubDir')		
	SET @process_id = dbo.FNAGetNewID()
	SET @ssis_path = @root_load + 'LoadForecastDataParse.dtsx'
	SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + 
				'" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'

	SET @proc_desc = 'import_load_forecastdata'
	SET @job_name = @proc_desc + '_' + @process_id
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'SSIS',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step	
			
END

/** Run Deals Position Calc **/
IF @run_type = 19705
BEGIN
	--Profile Swaps
	--Run targeted Script	
	--Run Grid Loss calculations	
	--Run B2b Power metered and Profiled CV calculation

	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'report_batch'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'EXEC spa_eod_profile_swap_calc
				GO
				EXEC spa_trageted_syv_calc
				GO
				EXEC spa_gridloss_calc
				GO
				EXEC spa_update_contract_volume
				'
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
	
END

/** Recalculate Position for deals **/
IF @run_type = 19706
BEGIN 
	-- Deals  having Total Volume 0
	-- Deals having position update timestamp < deal update timestamp.
	-- Deals having position update timestamp < forecast update timestamp.
		
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'report_batch'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'EXEC spa_eod_run_calc_position_for_deals
				GO
				EXEC spa_eod_calc_remnant_position_after_forecast_update
				GO
				EXEC spa_eod_calc_remnant_position_after_deal_update			
				'
	
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step	
END

/** Check Deals with zero or NULL position **/
IF @run_type = 19707
BEGIN
	
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'report_batch'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'SELECT COUNT(*)
				FROM   source_deal_detail
				WHERE  ISNULL(total_volume, 0) = 0'
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
END

/** Import Forward prices from CMA Request **/
IF @run_type = 19708 
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	SET @spa = N'/FILE "' + @ssis_path + 
		'" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_AsOfDate].Properties[Value]";"' + @as_of_date + 
		'"  /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id + 
		'" /SET \Package.Variables[User::PS_ProcessId].Properties[Value];"' + @process_id + '"'				
	SET @proc_desc = 'request_cma_data'
	SET @job_name = @proc_desc + '_' + @process_id

	EXEC spa_eod_process_as_job_schedule 
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'SSIS',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @next_run_type,
	     @cma_start,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     @exec_only_this_step

END

/** Import Forward prices from CMA Response**/
IF @run_type = 19709 
BEGIN

	SET @process_id = dbo.FNAGetNewID()
	SET @ssis_path = @root + 'ResponsePackage.dtsx'
	SET @spa = N'/FILE "' + @ssis_path + 
		'" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessId].Properties[Value]";"' + @process_id + 
		'"  /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id + '"'

	/** Audit table log **/
	IF NOT EXISTS(SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
	BEGIN
		EXEC spa_import_data_files_audit 'i',
		     @as_of_date,
		     NULL,
		     @process_id,
		     'Import CMA Data',
		     'CMA Data upload (Table No.:4008)',
		     @as_of_date,
		     'p',
		     NULL,
		     NULL,
		     NULL,
		     2
	END

	SET @proc_desc = 'import_cma_data'
	SET @job_name = @proc_desc + '_' + @process_id
	
	EXEC spa_eod_process_as_job_schedule 
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'SSIS',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @next_run_type,
	     @cma_response_start,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     @exec_only_this_step	
END

--/** CMA Import Forward Price data **/
--IF @run_type = 19709 
--BEGIN
--	SELECT 1
--END 

/** Copy Missing Prices **/
/** Copy Prices that do not/did not come from CMA and run script for derived prices **/
IF @run_type = 19710 /** calculate BOM(Balance of Month) Price **/
BEGIN
	
	SET @exec_only_this_step = 1
	
	-- Sub Step 1
	/** Copy missing curve **/
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'Copy_missing_curve'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'EXEC spa_post_import_process_cma ''' + @as_of_date + ''', ''' + @process_id + ''', 2'
	
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
	
	-- Sub Step 2
	-- Run the script to generate price Curves
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'gen_price_curve'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'EXEC spa_eod_price_copy'
	
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
	
	
	SET @exec_only_this_step = 0
	-- Sub Step 3
	--TODO : Calculate Derived Curves 
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'calc_derived_curve_'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'EXEC spa_derive_bom_prices ''' + @as_of_date + ''', ''' + @process_id + ''''
	
	SET @BOM_start = CAST(REPLACE(CONVERT(VARCHAR(10),DATEADD(mi,15,getdate()),108),':','') AS INT)	     
	EXEC spa_eod_process_as_job 
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step		
    	     
END

/** Check all price curves exist for cache curves. **/
IF @run_type = 19711
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'check_price_curve'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'SELECT COUNT(*)
				FROM   source_deal_header sdh
					   INNER JOIN source_deal_detail sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id
					   INNER JOIN formula_editor fe ON  sdd.formula_id = fe.formula_id
					   LEFT JOIN cached_curves cc ON  cc.curve_id = sdd.curve_id
					   LEFT JOIN cached_curves_value ccv ON  ccv.Master_ROWID = cc.ROWID
							AND ccv.as_of_date = CONVERT(VARCHAR(10), GETDATE(), 120)
				WHERE  fe.formula LIKE ''%LagCurve%''
				AND sdd.term_start <> ISNULL(ccv.term, ''1999-01-01'')'
	
	SET @BOM_start = CAST(REPLACE(CONVERT(VARCHAR(10),DATEADD(mi,15,getdate()),108),':','') AS INT)	     
	EXEC spa_eod_process_as_job 
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
END

/** Copy Best available prices. **/
IF @run_type = 19712
BEGIN

	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'copy_best_prices_'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'INSERT INTO cached_curves_value
				  (
				 Master_ROWID,
				 value_type,
				 term,
				 pricing_option,
				 curve_value,
				 org_mid_value,
				 org_ask_value,
				 org_bid_value,
				 org_fx_value,
				 as_of_date,
				 curve_source_id,
				 bid_ask_curve_value
				  )
				SELECT ccv.Master_ROWID,
					ccv.value_type,
					ccv.term,
					ccv.pricing_option,
					ccv.curve_value,
					ccv.org_mid_value,
					ccv.org_ask_value,
					ccv.org_bid_value,
					ccv.org_fx_value,
					CONVERT(VARCHAR(10), GETDATE(), 120),
					ccv.curve_source_id,
					ccv.bid_ask_curve_value
				FROM   cached_curves_value ccv
					INNER JOIN (
					SELECT MAX(as_of_date) as_of_date
					FROM   cached_curves_value ccv
					WHERE  as_of_date < GETDATE()
				  ) ccv1 ON  ccv.as_of_date = ccv1.as_of_date
					LEFT JOIN cached_curves_value ccv2 ON  ccv.Master_ROWID = ccv2.Master_ROWID
				   AND ccv2.as_of_date = CONVERT(VARCHAR(10), GETDATE(), 120)
				   AND ccv2.term = ccv.term
				WHERE  1 = 1
					AND ccv2.term IS NULL '
	
	SET @BOM_start = CAST(REPLACE(CONVERT(VARCHAR(10),DATEADD(mi,15,getdate()),108),':','') AS INT)
	EXEC spa_eod_process_as_job 
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
END

/** Run Cache Curves **/
IF @run_type = 19713 
BEGIN
	----######### Run the script to generate price Curves
	--EXEC spa_eod_derive_curve
	----------###########
	
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'cache_curve'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @term_start = dbo.FNAGETContractMonth(DATEADD(m,-1,@as_of_date))
	SET @spa = '
	EXEC spa_eod_derive_curve
	GO 
	EXEC spa_calc_cache_curve ''' + @term_start + ''',NULL,'''+@as_of_date+''',4500,0,NULL,NULL,0,NULL, ''' + @process_id + ''''
	
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step

END

/** Missing Cache curves **/
/** Copy Best available prices cache curves. **/
IF @run_type = 19714
BEGIN
	
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'Missing_Cache_Curve_'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'SELECT COUNT(*)
				FROM   source_deal_header sdh
					   INNER JOIN source_deal_detail sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id
					   INNER JOIN formula_editor fe ON  sdd.formula_id = fe.formula_id
					   LEFT JOIN cached_curves cc ON  cc.curve_id = sdd.curve_id
					   LEFT JOIN cached_curves_value ccv ON  ccv.Master_ROWID = cc.ROWID
							AND ccv.as_of_date = CONVERT(VARCHAR(10), GETDATE(), 120)
				WHERE  fe.formula LIKE ''%LagCurve%''
				AND sdd.term_start <> ISNULL(ccv.term, ''1999-01-01'')
				
				GO
				
				INSERT INTO cached_curves_value
				  (
				 Master_ROWID,
				 value_type,
				 term,
				 pricing_option,
				 curve_value,
				 org_mid_value,
				 org_ask_value,
				 org_bid_value,
				 org_fx_value,
				 as_of_date,
				 curve_source_id,
				 bid_ask_curve_value
				  )
				SELECT ccv.Master_ROWID,
					ccv.value_type,
					ccv.term,
					ccv.pricing_option,
					ccv.curve_value,
					ccv.org_mid_value,
					ccv.org_ask_value,
					ccv.org_bid_value,
					ccv.org_fx_value,
					CONVERT(VARCHAR(10), GETDATE(), 120),
					ccv.curve_source_id,
					ccv.bid_ask_curve_value
				FROM   cached_curves_value ccv
					INNER JOIN (
					SELECT MAX(as_of_date) as_of_date
					FROM   cached_curves_value ccv
					WHERE  as_of_date < GETDATE()
				  ) ccv1 ON  ccv.as_of_date = ccv1.as_of_date
					LEFT JOIN cached_curves_value ccv2 ON  ccv.Master_ROWID = ccv2.Master_ROWID
				   AND ccv2.as_of_date = CONVERT(VARCHAR(10), GETDATE(), 120)
				   AND ccv2.term = ccv.term
				WHERE  1 = 1
					AND ccv2.term IS NULL '
		     
	EXEC spa_eod_process_as_job 
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
END

--/** Copy Best available prices cache curves. **/
--IF @run_type = 19714
--BEGIN
--	SELECT 1
--	--######## new script
--END

/** Calculate Storage WACOG Price **/
IF @run_type = 19715
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'Inv_Calc'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = ' EXEC spa_calc_inventory_accounting_entries_job ''' + @as_of_date + ''',''' + @as_of_date + ''',2,''' + @process_id + ''','''+@job_name+''',''farrms_admin'',''n'' 
				 GO 
				 EXEC spa_calc_inventory_accounting_entries_job ''' + @as_of_date + ''',''' + @as_of_date + ''',2,''' + @process_id + ''','''+@job_name+''',''farrms_admin'',''y'''

	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
END

/** Run MTM Process **/
IF @run_type = 19716 
BEGIN

	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'MTM_Report'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'EXEC spa_run_sp_with_dynamic_params ''spa_calc_mtm_job ''''149,148'''',NULL,NULL,NULL,NULL,''''' + @as_of_date + ''''',4500,NULL,''''b'''',NULL,''''' + @process_id + ''''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''''n'''',''''' + @term_start +''''',''''' + @term_end +''''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,''''' + @process_id + ''''',''''spa_calc_mtm_job ''''''''149,148'''''''',NULL,NULL,NULL,NULL,''''''''' + @as_of_date +''''''''',4500,NULL,''''''''b'''''''',NULL,''''''''' + @process_id +''''''''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''''''''n'''''''',''''''''' + @term_end + ''''''''',''''''''' + @term_start + ''''''''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,''''''''' + @process_id + ''''''''''''''''
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
END

/** Run Deal Settlement **/
IF @run_type = 19717
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'Settlement_Report'
	SET @job_name = @proc_desc + '_' + @process_id
	
	-- If as of date is Month End
	IF @as_of_date = CONVERT(VARCHAR(10),dbo.[FNAGetTermEndDate]('m',GETDATE(),0),120)
		SET @term_start = dbo.FNAGETContractMonth(DATEADD(m,-1,@as_of_date))
	
	SET @spa = 'EXEC spa_run_sp_with_dynamic_params ''spa_calc_mtm_job ''''149,148'''',NULL,NULL,NULL,NULL,''''' + @as_of_date + ''''',4500,NULL,''''b'''',NULL,''''' + @process_id + ''''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''''n'''',''''' + @term_start +''''',''''' + @as_of_date +''''',''''s'''',NULL,NULL,NULL,NULL,NULL,NULL,''''' + @process_id + ''''',''''spa_calc_mtm_job ''''''''149,148'''''''',NULL,NULL,NULL,NULL,''''''''' + @as_of_date +''''''''',4500,NULL,''''''''b'''''''',NULL,''''''''' + @process_id +''''''''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''''''''n'''''''',''''''''' + @term_start + ''''''''',''''''''' + @as_of_date + ''''''''',''''''''s'''''''',NULL,NULL,NULL,NULL,NULL,NULL,''''''''' + @process_id + ''''''''''''''''
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step	
END

/** Run FX Exposure Calculation **/
IF @run_type = 19718 
BEGIN
	--######### calc hedge deferral
	EXEC spa_Calc_Hedge_Deferral_Values @as_of_date, '148', '150', '203,162,157,158', NULL, 1, '1,10,12,11,9,33', NULL
	---#########

	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'fx_exp_calc_'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'EXEC spa_create_fx_exposure_report ''' + @as_of_date + ''',NULL,NULL,NULL,4500,NULL,NULL,NULL,NULL,2,1,''' + @process_id + ''''
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
END

/** Run Hedge Deferral Calculation. **/
IF @run_type = 19719
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'hedge_def_calc_'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'EXEC spa_Calc_Hedge_Deferral_Values ''' + @as_of_date + ''', ''148'', ''150'', ''203,162,157,158'', NULL, 1, ''1,10,12,11,9,33'', NULL'
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
END

/** Functional check **/
IF @run_type = 19720
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'func_check_'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'EXEC spa_eod_functional_check ''' + @process_id + ''',''' + @as_of_date + ''''
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
END

/** Generate Cube. **/
IF @run_type = 19721
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'generate_cube_'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'SELECT 1'
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
END

/** Check if all required cube data are populated in CUBES. **/
IF @run_type = 19722
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'check_cubes_'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'SELECT 1'
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
END

/** Send EoD status Email **/
IF @run_type = 19723
BEGIN
	SET @label = 'EOD Process completed for run date ' + dbo.FNADateFormat(@as_of_date)
	
	IF EXISTS(SELECT 'X' FROM eod_process_status WHERE master_process_id = @master_process_id AND [status] = 'Error') 
	BEGIN
		SET @label = @label + ' (ERROR Found)'		
	END
	ELSE IF EXISTS(SELECT 'X' FROM eod_process_status WHERE master_process_id = @master_process_id AND [status] = 'Warning')
	BEGIN
		SET @label = @label + ' (Warning Found)'
	END
	
	SET @label = @label + '.'
	SET @spa = 'EXEC spa_eod_process_status_log  ''' + @master_process_id + ''', ''' + @as_of_date + ''''
	SET @message = '<a target="_blank" href="./dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=' + @spa + '"><font color=#0000ff><u>' + @label +'</u></font></a>'
	
	
	
	DECLARE list_user CURSOR FOR 
		SELECT application_users.user_login_id
		FROM   dbo.application_role_user
		       INNER JOIN dbo.application_security_role ON  dbo.application_role_user.role_id = dbo.application_security_role.role_id
		       INNER JOIN dbo.application_users ON  dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
		WHERE  (dbo.application_users.user_active = 'y')
		       AND (dbo.application_security_role.role_type_value_id = 6)
		       AND dbo.application_users.user_emal_add IS NOT NULL
		GROUP BY dbo.application_users.user_login_id, dbo.application_users.user_emal_add
		
		OPEN list_user
		FETCH NEXT FROM list_user INTO 	@user_login_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
	
			EXEC spa_message_board 'i',
				 @user_login_id,
				 NULL,
				 'EOD Process',
				 @message,
				 '',
				 '',
				 's'
		FETCH NEXT FROM list_user INTO 	@user_login_id
		END
		CLOSE list_user
		DEALLOCATE list_user	
		
			 
	
	/** Send email to user if error in EOD Process **/
	--IF @status = 'Error'
	BEGIN
		DECLARE @template_params  VARCHAR(MAX),
		        @string   VARCHAR(MAX)
		
		SET @string = '<table border=1>' 

		SELECT @string = @string + '
			<tr>
				<td>' + [source] + '</td>
				<td>' + [status] + '</td>
				<td>' + [message] + '</td>
			</tr>' , 
			 @mtm_detail_status = @mtm_detail_status + ISNULL(message_detail,'')
		FROM eod_process_status WHERE master_process_id = @master_process_id
			AND [message] IS NOT NULL
		ORDER BY Create_ts	
		
		SET @string = @string + '</table>' 		

		SET @template_params = ''
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<EOD_RUN_DATE>', [dbo].FNADateFormat(@as_of_date))      --replace template fields
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<EOD_STATUS>', @string) --replace template fields


		EXEC spa_email_notes 
		     @flag = 'b',
		     @role_type_value_id = 6,
		     @email_module_type_value_id = 17802,
		     @send_status = 'n',
		     @active_flag = 'y',
		     @template_params = @template_params,
		     @attachment_file_name = @mtm_detail_status
	END	
	
	SET @process_id = dbo.FNAGetNewID()
	SET @proc_desc = 'send_email_'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'SELECT 1'
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step
	
END
/************************************* Object: 'spa_eod_process' END *************************************/

/** Process/Enable processing from Pratos Staging Tables **/
IF @run_type = 19724
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	
	CREATE TABLE #deal_status([message] VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
	INSERT INTO #deal_status EXEC spa_pratos_deal_report 's',@as_of_date
	
	SELECT @message = [message] FROM #deal_status
	
	INSERT INTO eod_process_status(	master_process_id, process_id, source, [status], [message], as_of_date)
	VALUES( @master_process_id, @process_id, 'Summary report of all the deals processed', 'Success', @message, @as_of_date)
	
	SET @proc_desc = 'pratos_staging_'
	SET @job_name = @proc_desc + '_' + @process_id
	SET @spa = 'UPDATE pratos_bulk_import_config SET bulk_import = ''y'''
		
	EXEC spa_eod_process_as_job
	     @job_name,
	     @spa,
	     @proc_desc,
	     @user_login_id,
	     'TSQL',
	     @run_type,
	     @master_process_id,
	     @process_id,
	     NULL,
	     @exec_only_this_step	
END
