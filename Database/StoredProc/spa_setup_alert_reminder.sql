IF OBJECT_ID(N'[dbo].[spa_setup_alert_reminder]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_setup_alert_reminder]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spa_setup_alert_reminder]
    @flag				VARCHAR(100),
	@module_id			INT = NULL,
	@source_id			INT = NULL,
	@event_message_id	VARCHAR(2000) = NULL,
	@start_date			DATETIME = NULL,
	@reminder_days		INT = NULL

AS

SET NOCOUNT ON

DECLARE @desc VARCHAR(2000), @err_no INT

IF @flag = 'grid'
BEGIN
	SELECT	ce.calendar_event_id				[Alert_Calendar_Id],
			ce.name								[Description],	
			ce.[start_date]						[Date],
			ce.reminder/1440					[Reminder_Days],
			au.user_f_name + ' ' + user_l_name	[Create_User],
			wem.event_message_id					[Event_Message_ID]
	FROM calendar_events ce
	LEFT JOIN workflow_event_message wem ON ce.event_message_id = wem.event_message_id
	LEFT JOIN application_users au ON au.user_login_id = ce.create_user
	WHERE ce.module_id = @module_id AND ce.source_id = @source_id
	ORDER BY ce.[start_date], ce.reminder/1440
END

ELSE IF @flag = 'delete_remainder'
BEGIN
	BEGIN TRY
		
		DELETE wa FROM workflow_activities wa
		INNER JOIN dbo.SplitCommaSeperatedValues(@event_message_id) msg ON msg.item = wa.event_message_id

		DELETE weur FROM workflow_event_user_role weur
		INNER JOIN workflow_event_message wem ON weur.event_message_id = wem.event_message_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@event_message_id) msg ON msg.item = wem.event_message_id
		
		DELETE ar FROM alert_reports ar
		INNER JOIN workflow_event_message wem ON ar.event_message_id = wem.event_message_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@event_message_id) msg ON msg.item = wem.event_message_id
		
		DELETE wemd 
		FROM workflow_event_message_details wemds
		INNER JOIN workflow_event_message_documents wemd ON wemds.event_message_document_id = wemd.message_document_id
		INNER JOIN workflow_event_message wem ON wem.event_message_id = wemd.event_message_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@event_message_id) msg ON msg.item = wem.event_message_id
		
		DELETE wemd 
		FROM workflow_event_message_documents wemd
		INNER JOIN workflow_event_message wem ON wem.event_message_id = wemd.event_message_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@event_message_id) msg ON msg.item = wem.event_message_id
		
		DELETE wem
		FROM workflow_event_message wem
		INNER JOIN dbo.SplitCommaSeperatedValues(@event_message_id) msg ON msg.item = wem.event_message_id
		
		DELETE ce
		FROM calendar_events ce
		INNER JOIN dbo.SplitCommaSeperatedValues(@event_message_id) msg ON msg.item = ce.event_message_id
		

		EXEC spa_ErrorHandler 0
				, 'Alert Remainder'
				, 'spa_setup_alert_remainder'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, ''
		
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK
	 
			SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
			SELECT @err_no = ERROR_NUMBER()
	 
			EXEC spa_ErrorHandler @err_no
			   , 'Alert Remainder'
			   , 'spa_setup_alert_remainder'
			   , 'Error'
			   , @desc
			   , ''
		END CATCH
END