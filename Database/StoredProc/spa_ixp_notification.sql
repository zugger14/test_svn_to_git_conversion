IF OBJECT_ID(N'[dbo].[spa_ixp_notification]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_notification]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	Data import/Export Notification
 
	Parameters:
	@process_id : Import process unique identifier.	
	@ixp_rules_id : Rules id				 
	@notification_msg : Import notification message.
	@job_name : Import process job name.
 */

CREATE PROCEDURE [dbo].[spa_ixp_notification]
	@process_id				VARCHAR(300)
	, @ixp_rules_id			INT
	, @notification_msg		NVARCHAR(MAX) = NULL
	, @job_name				VARCHAR(MAX) = NULL
    
AS

SET NOCOUNT ON
/*
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
EXEC spa_print 'In debug mode important informations are printed through spa_print statement instead of PRINT. Any PRINT statement if found should be replaced with spa_print.'
EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'farrms_admin';

DECLARE @process_id VARCHAR(300) = '2D179B43_19DB_4BEF_B068_2F18A1309B05'
	, @ixp_rules_id VARCHAR(MAX) = 14411
	, @notification_msg		VARCHAR(MAX) = NULL
	, @job_name				VARCHAR(MAX) = NULL

SELECT  @process_id = '2D179B43_19DB_4BEF_B068_2F18A1309B05' 
	, @ixp_rules_id='12586'
	, @notification_msg='import notification test'

--*/

DECLARE @ixp_notification_status_id INT
	, @ixp_notification_status VARCHAR(50)
	, @ixp_notification_message_id INT
	, @ixp_notification_error_message_id INT
	, @user_name VARCHAR(100) 

SELECT @notification_msg = ISNULL(@notification_msg, 'Import description is not available'),
		@user_name = dbo.FNADBUser() 

SELECT @ixp_notification_status =  IIF(code = 'Error', 'e', 's'),
		@ixp_notification_status_id = status_id
FROM source_system_data_import_status
WHERE process_id = @process_id

SELECT @ixp_notification_message_id = message_id 
	, @ixp_notification_error_message_id = error_message_id
FROM ixp_import_data_source where rules_id = @ixp_rules_id

EXEC  spa_message_board 'u', @user_name,NULL, 'ImportData', @notification_msg, '', '', @ixp_notification_status , @job_name, NULL, @process_id, '', '', '', 'y'


--Notification for batch import is auto handled by spa_message_board.for skip notification through alert.
IF NOT EXISTS(
		SELECT 1
		FROM batch_process_notifications bpn
		WHERE  bpn.process_id = RIGHT(ISNULL(@job_name,@process_id), 13)
) AND @ixp_notification_message_id IS NOT NULL
BEGIN
	EXEC spa_run_alert_message @module_id = 20634, @source_id = @ixp_notification_status_id, @event_message_id = @ixp_notification_message_id
END

--Nofify to error reporting group as per defined in rule definition. If not defined in rule definition then notify to data integration group. 
IF @ixp_notification_status = 'e'
BEGIN
	--Notify data intergration group.
	IF @ixp_notification_error_message_id IS NULL
	BEGIN
		EXEC spa_NotificationUserByRole 2, @process_id, 'ImportData', @notification_msg , 'e', @job_name, 0,1
	END
	ELSE
	BEGIN
		EXEC spa_run_alert_message @module_id = 20634, @source_id = @ixp_notification_status_id, @event_message_id = @ixp_notification_error_message_id	
	END
END
