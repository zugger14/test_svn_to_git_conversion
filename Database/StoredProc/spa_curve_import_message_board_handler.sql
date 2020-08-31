IF OBJECT_ID(N'[dbo].[spa_curve_import_message_board_handler]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_curve_import_message_board_handler]
    
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: ssingh@pioneersolutionsglobal.com
-- Create date: 2012-05-15
-- Description: flag 'i' , Updates the message board every time If no file is found when Import is done manually. 
--				flag 'a', Updates the message board the last time the scheduled job runs If no file is found
--                        during the specified time frame during a day when Import is done via a scheduled job.
--	Params:
-- @flag CHAR(1) - Operation flag 'i' : Manual import ,'a' : Automatic Import
-- @process_id VARCHAR(50)- Process ID
-- @user_login_id VARCHAR(50) - UserID

-- ===========================================================================================================

CREATE PROCEDURE [dbo].spa_curve_import_message_board_handler
	@flag CHAR(1),
	@process_id VARCHAR(50),
	@user_login_id VARCHAR(50)
	--@role_type_value_id INT = 2

AS 

/*----------------------------------------------TEST SCRIPT-----------------------------------------------------*/
/*
DECLARE	@flag CHAR(1),
	@process_id VARCHAR(50),
	@user_login_id VARCHAR(50)
	
SET @flag ='a'
SET @process_id = '20120516_122357'
SET @user_login_id = 'farrms_admin'

--*/
/*----------------------------------------------END OF TEST SCRIPT----------------------------------------------*/

DECLARE @job_name VARCHAR(500)
DECLARE @start_ts	DATETIME
DECLARE @elapsed_sec FLOAT
DECLARE @tablename VARCHAR(100)
DECLARE @errorcode CHAR(2)
Declare @url varchar(500)
DECLARE  @desc varchar(500)


SET @tablename = STUFF(
						(
							SELECT ',' + code
							FROM  static_data_value WHERE  value_id in (4008, 4026, 4027)
							FOR XML PATH(''), TYPE
						)
						.value('.[1]', 'VARCHAR(5000)'), 1, 1, ''
					)
SET @job_name = 'import_curve_data_' + @process_id
SET @errorcode='e'
SELECT  @start_ts = isnull(min(create_ts),GETDATE()) FROM  import_data_files_audit WHERE  process_id = @process_id
SET @elapsed_sec = DATEDIFF(second, @start_ts, GETDATE())

BEGIN
	IF @flag = 'e'
	BEGIN
		INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
		SELECT  @process_id,'Error','Import Data',@tablename,'Data Error','No data found.','Data may not be available in the source.Please check the data source.'
		INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
		SELECT  @process_id,@tablename,'Data Error','Data may not be available in the source.Please check the data source.'
		--set @errorcode='e'


		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

		select @desc = '<a target="_blank" href="' + @url + '">' + 
				'Import process Completed for as of date:' + dbo.FNAUserDateFormat(getdate(), @user_login_id) + 
			case when (@errorcode = 'e') then ' (ERRORS found)' else '' end +
			'.</a>'
		EXEC  spa_message_board 'i', @user_login_id,
		NULL, 'Import.Data',
		@desc, '', '', @errorcode, @job_name,null,@process_id
	END
END 