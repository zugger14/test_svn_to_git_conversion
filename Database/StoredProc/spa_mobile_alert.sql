

IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_mobile_alert]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_mobile_alert]
GO

/****** Object:  StoredProcedure [dbo].[spa_mobile_alert]    Script Date: 11/5/2014 9:31:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Author: Navaraj Shrestha
-- Create date: 2016
-- Description: Check Alerts and Aprrovals From Mobile Application
--              
-- Params:
-- ============================================================================================================================
CREATE PROCEDURE [dbo].[spa_mobile_alert]
	@flag			CHAR(1),
	@user_name		VARCHAR(300) = NULL,
	@message_id		VARCHAR(300) = NULL

AS

SET NOCOUNT ON

IF ISNULL(@user_name, '') <> '' AND @user_name <> dbo.FNADBUser()   
BEGIN
	--EXECUTE AS USER = @user_name;
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), @user_name)
	SET CONTEXT_INFO @contextinfo
	SET @user_name = dbo.FNADBUser()
END

IF @flag = 'a'
BEGIN
	--Get Alerts
	--EXEC spa_message_board @flag='l',@user_login_id='farrms_admin'
	SELECT  
		message_id,
		CASE WHEN CHARINDEX('<',[description]) = 1 THEN
			dbo.FNAStripHTML(SUBSTRING(mb.[description], 0, CHARINDEX('<a',mb.[description]))) + SUBSTRING(mb.[description], CHARINDEX('<a',mb.[description]), LEN(mb.[description]))
		ELSE [description] END [description],
		
		dbo.FNADateTimeFormat(ISNULL(mb.update_ts, mb.create_ts), 0) [create_ts],
		dbo.FNADateTimeFormat(ISNULL(mb.update_ts, mb.create_ts), 0) [update_ts],
		delActive,	
		is_alert,
		is_read,
		workflow_activity_id
	FROM   message_board mb
	WHERE  mb.is_alert = 'y' AND mb.[type] <> 'r'
	       AND mb.is_alert_processed = 'n'
	       AND mb.user_login_id = dbo.FNADBUser()
	ORDER BY mb.create_ts DESC
END

IF @flag = 'w'
BEGIN
	--Get Approval List
	--EXEC spa_message_board @flag='n',@user_login_id = 'farrms_admin'
	SELECT	
			CASE WHEN CHARINDEX('<a',MAX(wa.message)) = 1 THEN
				dbo.FNAStripHTML(SUBSTRING(MAX(wa.message), 0, CHARINDEX('<a',MAX(wa.message)))) + SUBSTRING(MAX(wa.message), CHARINDEX('<a',MAX(wa.message)), LEN(MAX(wa.message)))
				WHEN CHARINDEX('<span',MAX(wa.message)) = 1 THEN
					dbo.FNAStripHTML(SUBSTRING(MAX(wa.message), 0, CHARINDEX('</span>',MAX(wa.message)))) + SUBSTRING(MAX(wa.message), CHARINDEX('</span>',MAX(wa.message)) + 7, LEN(MAX(wa.message))) + SUBSTRING(MAX(wa.message), CHARINDEX('<span>',MAX(wa.message)), CHARINDEX('</span>',MAX(wa.message)))
			ELSE MAX(wa.message) END [message],
			wa.workflow_activity_id [activity_id],
			MAX(wa.control_status) [control_status],
			ISNULL(mb.is_read, 1) [is_read],
			dbo.FNADateTimeFormat(MAX(ISNULL(wa.update_ts, wa.create_ts)), 0) [create_ts]
	FROM workflow_activities wa
	INNER JOIN message_board mb ON mb.workflow_activity_id = wa.workflow_activity_id AND mb.user_login_id = dbo.FNADBUser()
	LEFT JOIN event_trigger et ON et.event_trigger_id = wa.workflow_trigger_id
	LEFT JOIN module_events me ON me.module_events_id = et.modules_event_id
	LEFT JOIN workflow_event_user_role weur ON wa.event_message_id = weur.event_message_id
	LEFT JOIN application_role_user aru ON aru.role_id = weur.role_id
	OUTER APPLY(SELECT MAX(user_login_id) user_login_id FROM application_role_user WHERE role_id = weur.role_id AND user_login_id = dbo.FNADBUser()) ars
	LEFT JOIN delete_source_deal_header dsdh ON dsdh.source_deal_header_id = wa.source_id AND me.modules_id = 20601
	WHERE (COALESCE(ars.user_login_id,NULLIF(wa.user_login_id,''),mb.user_login_id) = dbo.FNADBUser() OR (weur.user_login_id = dbo.FNADBUser() AND NULLIF(wa.user_login_id, '') IS NULL)) -- Filter User -- Filter User
	AND dsdh.source_deal_header_id IS NULL -- Filter Deleted Deal
	ANd (wa.control_status IS NULL OR wa.control_status = 725)
	--AND wa.source_column <> 'calendar_event_id' -- Filter Calendar
	GROUP BY wa.workflow_activity_id, mb.is_read
	ORDER BY [create_ts], wa.workflow_activity_id DESC
END

IF @flag = 'd'
BEGIN
	--DELETE query
	--EXEC spa_message_board @flag='d',@user_login_id= @user_name , @message_id = @message_id, @message_filter = '1''
	EXEC spa_setup_rule_workflow @flag = 'y', @activity_id = @message_id
	
END

IF @flag = 'e'
BEGIN
	--DELETE query
	EXEC spa_message_board @flag='e',@user_login_id=@user_name , @message_id = @message_id
	
END


IF @flag = 'v'
BEGIN
	--DELETE query
	EXEC spa_message_board @flag= 'v', @user_login_id=@user_name, @message_id = @message_id
	
END

IF @flag = 'x'
BEGIN
	--approve query
	--CREATE TABLE #temp_workflow_status (
 -- 		[ErrorCode] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
 -- 		[Module] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
 -- 		[Area] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
 -- 		[Status] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
 -- 		[Message] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
 -- 		[Recommendation] VARCHAR(500) COLLATE DATABASE_DEFAULT 	
 -- 	)
  
 -- 	INSERT #temp_workflow_status
	EXEC spa_setup_rule_workflow  @flag='c', @activity_id = @message_id, @approved='1',@comments=''
	--EXEC spa_setup_rulfe_workflow  @flag='c',@activity_id='12133',@approved='1',@comments=''
	
	--SELECT * FROM #temp_workflow_status
	
END

IF @flag = 'y'
BEGIN
	--unapprove query
	EXEC spa_setup_rule_workflow  @flag='c', @activity_id=@message_id, @approved='0'
	
END

IF @flag = 'z'
BEGIN
	--complete query
	EXEC spa_setup_rule_workflow  @flag='c', @activity_id=@message_id, @approved='2'
	
END

IF @flag = 'f'
BEGIN
	--Update Alert as seen
	EXEC spa_message_board @flag = 'f', @message_id = @message_id, @message_filter = '1', @user_login_id = @user_name
END
IF @flag = 'g'
BEGIN
	--Update Alert as unseen
	EXEC spa_message_board @flag = 'g', @message_id = @message_id, @message_filter = '1', @user_login_id = @user_name
END
ELSE IF @flag = 's'
BEGIN
	--Update Workflow as seen
	UPDATE mb
		SET mb.is_read = 1
	FROM workflow_activities wa
	LEFT JOIN message_board mb ON mb.workflow_activity_id = wa.workflow_activity_id AND mb.user_login_id =  @user_name
	WHERE wa.workflow_activity_id IN (@message_id) 
		AND ISNULL(mb.is_alert, 'n') = 'n'
	
	EXEC spa_ErrorHandler 0
		, 'message_board' -- Name the tables used in the query.
		, 'spa_message_board' -- Name the stored proc.
		, 'Success' -- Operations status.
		, 'Workflow marked as Read Successfully.' -- Success message.
		, @message_id -- Processed messages id
	RETURN
END
ELSE IF @flag = 'u'
BEGIN
	--Update Workflow as unseen
	UPDATE mb
		SET mb.is_read = 0
	FROM workflow_activities wa
	LEFT JOIN message_board mb ON mb.workflow_activity_id = wa.workflow_activity_id AND mb.user_login_id =  @user_name
	WHERE wa.workflow_activity_id IN (@message_id) 
		AND ISNULL(mb.is_alert, 'n') = 'n'
	
	EXEC spa_ErrorHandler 0
		, 'message_board' -- Name the tables used in the query.
		, 'spa_message_board' -- Name the stored proc.
		, 'Success' -- Operations status.
		, 'Workflow marked as Unread Successfully.' -- Success message.
		, @message_id -- Processed messages id
	RETURN
END
GO


