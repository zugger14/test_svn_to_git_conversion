IF OBJECT_ID(N'[dbo].[spa_setup_alert_remainder]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_setup_alert_remainder]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spa_setup_alert_remainder]
    @flag		VARCHAR(100),
	@module_id	INT,
	@source_id	INT
AS


IF @flag = 'grid'
BEGIN
	SELECT	ce.calendar_event_id				[Alert_Calendar_Id,
			ce.name								[Description],	
			ce.[start_date]						[Date],
			ce.reminder							[Remainder_Days],
			au.user_f_name + ' ' + user_l_name	[Create_User],
			wem.event_message_id					[Event_Message_ID]
	FROM calendar_events ce
	LEFT JOIN workflow_event_message wem ON ce.event_message_id = wem.event_message_id
	LEFT JOIN application_users au ON au.user_login_id = ce.create_user
	WHERE ce.module_id = @module_id AND ce.source_id = @source_id
END