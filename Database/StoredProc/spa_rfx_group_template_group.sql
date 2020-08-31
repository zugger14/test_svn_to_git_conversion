IF OBJECT_ID(N'[dbo].[spa_rfx_group_template_group]',N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_rfx_group_template_group]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC spa_rfx_group_template_group 's',NULL,NULL,NULL,NULL,-1,NULL

CREATE PROC [dbo].[spa_rfx_group_template_group]
	@flag						CHAR(1),
	@report_manager_group_id	INT = NULL,
	@report_template_name_id	INT = NULL,
	@group_name					VARCHAR(MAX) = NULL,
	@user_login_id				VARCHAR(50) = NULL,
	@tab_group					INT = NULL,
	@refresh_time				INT = 0
AS
IF @flag = 's'
BEGIN
	SELECT	[report_manager_group_id] AS [Report Manager Group ID],
			[report_template_name_id] AS [Report Template Name ID],
			[group_name] AS [Group Name],
			[user_login_id] AS [User],
			[tab_group] AS [Group],
			refresh_time AS [Refresh Time(in Min)]
	FROM report_manager_group
	WHERE [report_template_name_id] = @report_template_name_id
	ORDER BY tab_group ASC
END
ELSE IF @flag = 'a'
BEGIN
	SELECT	[report_manager_group_id],
			[report_template_name_id],
			[group_name],
			[user_login_id],
			[tab_group],
			[refresh_time] 
	FROM report_manager_group
	WHERE [report_manager_group_id] = @report_manager_group_id
END
ELSE IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT 1 FROM report_manager_group WHERE tab_group = @tab_group 
				AND [report_template_name_id] = @report_template_name_id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'Group Number Already exists.'
			, 'spa_rfx_group_template_group'
			, 'DB Error'
			, 'Group Number Already exists.'
			, ''
		RETURN 
	END
	DECLARE @count INT
	SELECT @count = COUNT(report_manager_group_id) FROM report_manager_group WHERE [report_template_name_id] = @report_manager_group_id
	IF @count = 5
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'Can not Insert More Than 5 Report Groups.'
			, 'spa_rfx_group_template_group'
			, 'DB Error'
			, 'Can not Insert More Than 5 Report Groups.'
			, ''
		RETURN 
	END
	
	INSERT INTO report_manager_group([report_template_name_id], [group_name], [user_login_id], [tab_group], [refresh_time])
	SELECT @report_template_name_id, @group_name , @user_login_id, @tab_group, @refresh_time
	
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler -1
			, 'Insert of Report Group Failed.'
			, 'spa_StaticDataValue'
			, 'DB Error'
			, 'Insert of  Report Group Failed.'
			, ''
	ELSE
		EXEC spa_ErrorHandler 0
			, 'Successfully  Report Group Group.'
			, 'spa_StaticDataValue'
			, 'Success'
			, 'Successfully  Report Group Group.'
			, ''
END
ELSE IF @flag = 'u'
BEGIN
	IF EXISTS (SELECT 1 FROM report_manager_group WHERE group_name = @group_name 
				AND [report_template_name_id] = @report_template_name_id 
				AND [report_manager_group_id] <> @report_manager_group_id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'Group Name already exists.'
			, 'spa_rfx_group_template_group'
			, 'DB Error'
			, 'Group Name already exists'
			, ''
		RETURN 
	END
	
	IF EXISTS (SELECT 1 FROM report_manager_group WHERE tab_group = @tab_group 
				AND [report_template_name_id] = @report_template_name_id 
				AND [report_manager_group_id] <> @report_manager_group_id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'Group Number Already exists.'
			, 'spa_rfx_group_template_group'
			, 'DB Error'
			, 'Group Number Already exists.'
			, ''
		RETURN 
	END
	UPDATE	report_manager_group 
		SET [group_name] = @group_name
			, [user_login_id] = @user_login_id
			, [tab_group] = @tab_group
			, [refresh_time] = @refresh_time
	WHERE [report_manager_group_id] = @report_manager_group_id
	
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler -1
			, 'Update of Report Group Failed.'
			, 'spa_StaticDataValue'
			, 'DB Error'
			, 'Update of  Report Group Failed.'
			, ''
	ELSE
		EXEC spa_ErrorHandler 0
			, 'Successfully updated  Report Group.'
			, 'spa_StaticDataValue'
			, 'Success'
			, 'Successfully updated Report Group.'
			, ''
END
ELSE IF @flag = 'd'
BEGIN
	IF EXISTS(SELECT 1 FROM report_group_parameters_criteria WHERE report_manager_group_id = @report_manager_group_id)
	BEGIN
		Exec spa_ErrorHandler -1
			, 'Report Parameter should be deleted first.'
			, 'spa_dashboard_report_template_header'
			, 'DB Error'
			, 'Report Parameter should be deleted first.'
			, ''
		return

	END
	DELETE FROM report_manager_group WHERE report_manager_group_id = @report_manager_group_id
	
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler -1
			, 'Insert of Dash Board Template Report Group Failed.'
			, 'spa_StaticDataValue'
			, 'DB Error'
			, 'Insert of Dash Board Template Group Failed.'
			, ''
	ELSE
		EXEC spa_ErrorHandler 0
			, 'Successfully Deleted Report Group.'
			, 'spa_StaticDataValue'
			, 'Success'
			, 'Successfully Deleted Report Group.'
			, ''
END
ELSE IF @flag = 'c' -- select report or a tab
BEGIN
	SELECT [report_group_parameters_criteria_id] AS [Report Group Parameter ID]
			, r.report_id
			, rgpc.criteria critetia
			, r.[name] + '_' + rp2.[name]  AS [Report Name]
			, rgpc.[report_manager_group_id] AS [Report Group Manger ID]
			, dbo.FNARFXGenerateReportItemsCombined(rp2.report_page_id) [items_combined]
			, rp.report_paramset_id
			, rgpc.paramset_hash
			, rmg.refresh_time
	FROM report_group_parameters_criteria rgpc
	INNER JOIN report_paramset rp ON rp.paramset_hash = rgpc.paramset_hash
	INNER JOIN report_page rp2 ON rp.page_id = rp2.report_page_id
	INNER JOIN report r ON rp2.report_id = r.report_id
	LEFT JOIN report_dataset_paramset rdp ON rdp.paramset_id = rp.report_paramset_id
	LEFT JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
	LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rpm.column_id
	LEFT JOIN report_manager_group rmg ON rmg.report_manager_group_id = rgpc.report_manager_group_id
    WHERE rgpc.report_manager_group_id = @report_manager_group_id
END
ELSE IF @flag = 'z'-- count report in a  tab
BEGIN
	SELECT	COUNT(*) AS [Count]
	FROM report_group_parameters_criteria WHERE report_manager_group_id = @report_manager_group_id
END

