
IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_rfx_group_template_header]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_rfx_group_template_header]
    
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_rfx_group_template_header]
	@flag CHAR(1),
	@report_template_name_id INT = NULL,
	@user_login_id VARCHAR(50) = NULL,
	@report_name VARCHAR(100) = NULL,
	@ispublic CHAR(1) = NULL  
AS

DECLARE @sql VARCHAR(1000)

IF @flag = 's'
BEGIN
    SET @sql = 'SELECT	report_template_name_id as [Report ID],
						user_login_id [User],
						report_name [Report Name],
						CASE WHEN ISNULL(ispublic, ''n'') = ''y'' THEN ''Yes'' ELSE ''No'' END [Public]
                 FROM report_template_name
				 WHERE 1 = 1' +	
				 CASE 
					 WHEN @user_login_id IS NOT NULL THEN ' AND user_login_id = ''' + @user_login_id
						  + ''''
					 ELSE ''
				 END
    EXEC spa_print @sql	
    EXEC (@sql)
END
ELSE 
IF @flag = 'l' --to list user own report and others' public report templates, for 'admin' user list all.
BEGIN
    DECLARE @admin CHAR(1)
    CREATE TABLE #admin_rights(function_id  VARCHAR(8) COLLATE DATABASE_DEFAULT, have_rights  VARCHAR(8) COLLATE DATABASE_DEFAULT)
    INSERT INTO #admin_rights
    EXEC spa_haveMultipleSecurityRights 10111000
    
    SELECT @admin = CASE WHEN function_id = have_rights THEN 'y' ELSE 'n' END
    FROM   #admin_rights
    
    SET @sql = 'SELECT	distinct report_template_name_id,
						user_login_id [User],
						report_name [ReportName]
                FROM report_template_name
				WHERE 1 = 1' +
				CASE 
					 WHEN @admin = 'n' THEN ' AND (user_login_id=''' + dbo.FNAdbUser() + ''' OR ISNULL(ispublic,''n'')=''y'')'
					 ELSE ''
				END
    EXEC (@sql)
END

ELSE IF @flag = 'a'
BEGIN
	SELECT report_template_name_id,
           user_login_id,
           report_name,
           ISNULL(ispublic, 'n') [Public]
    FROM   report_template_name
    WHERE  report_template_name_id = @report_template_name_id
END
    
ELSE IF @flag = 'i'
BEGIN
    DECLARE @dashboard_id INT
    DECLARE @dashboard_group_id INT
    DECLARE @column_order INT
    INSERT INTO report_template_name(user_login_id, report_name, ispublic)    
    SELECT @user_login_id, @report_name, @ispublic 
    
    SET @dashboard_id = SCOPE_IDENTITY()
	
	IF NOT EXISTS (SELECT 1 FROM my_report_group mrg WHERE mrg.my_report_group_name = 'Auto My Reports Dashboard Group' AND mrg.group_owner = dbo.FNADBUser() AND mrg.role_id = 0 AND mrg.report_dashboard_flag = 'd')
	BEGIN
		INSERT INTO my_report_group (my_report_group_name, report_dashboard_flag, role_id, group_owner, group_order)
		VALUES ('Auto My Reports Dashboard Group', 'd', 0, dbo.FNADBUser(), 1)
		SET @dashboard_group_id = SCOPE_IDENTITY()
		SET @column_order = 1
	END
	ELSE
	BEGIN
		SELECT @dashboard_group_id = mrg.my_report_group_id FROM my_report_group mrg WHERE mrg.my_report_group_name = 'Auto My Reports Dashboard Group' AND mrg.group_owner = dbo.FNADBUser() AND mrg.role_id = 0 AND mrg.report_dashboard_flag = 'd'
		SELECT @column_order = ISNULL(MAX(mr.column_order), 0) + 1 FROM my_report mr WHERE mr.role_id = 0 AND mr.group_id = @dashboard_group_id
	END
	
	INSERT INTO my_report (my_report_name, dashboard_report_flag, dashboard_id, tooltip, my_report_owner, role_id, column_order, group_id)
	SELECT @report_name, 'd', @dashboard_id, @report_name, dbo.FNADBUser(), 0 , @column_order, @dashboard_group_id
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
             'Template Header',
             'spa_rfx_group_template_header',
             'DB Error',
             'Error Inserting Template Header.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Template Header',
             'spa_rfx_group_template_header',
             'Success',
             'Template Header successfully inserted.',
             ''
END
ELSE IF @flag = 'u'
BEGIN
    UPDATE report_template_name
    SET    user_login_id = @user_login_id,
           report_name = @report_name,
           ispublic = @ispublic
    WHERE  report_template_name_id = @report_template_name_id
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
             'Template Header',
             'spa_rfx_group_template_header',
             'DB Error',
             'Error updating Template Header.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Template Header',
             'spa_rfx_group_template_header',
             'Success',
             'Template Header successfully updated.',
             ''
END
ELSE IF @flag = 'd'
BEGIN
	IF EXISTS(SELECT 1 FROM report_manager_group WHERE  report_template_name_id = @report_template_name_id)
    BEGIN
        EXEC spa_ErrorHandler -1
			, 'Report Group should be deleted first.'
			, 'spa_rfx_group_template_header'
			, 'DB Error'
			, 'Report Group should be deleted first.'
			, ''
        RETURN
    END
    
    DELETE FROM report_template_name WHERE report_template_name_id = @report_template_name_id
    DELETE FROM my_report WHERE dashboard_id =  @report_template_name_id
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR
			, 'Template Header'
			, 'spa_rfx_group_template_header'
			, 'DB Error'
			, 'Error Deleting Template Header.'
			, ''
    ELSE
        EXEC spa_ErrorHandler 0
			, 'Template Header'
			, 'spa_rfx_group_template_header'
			, 'Success'
			, 'Template Header successfully deleted.'
			, ''
END
ELSE IF @flag = 'g' --select group tab
BEGIN
	SELECT  report_manager_group_id
			, group_name
			, tab_group 
			, report_template_name_id
			, refresh_time
	FROM report_manager_group WHERE [report_template_name_id] = @report_template_name_id
END
ELSE IF @flag = 'c' --count group tab
BEGIN
	SELECT COUNT(*) AS [Total Tabs] FROM report_manager_group WHERE [report_template_name_id] = @report_template_name_id
END
IF @flag = 'r'
BEGIN
    SELECT report_template_name_id,
           report_name
    FROM   report_template_name
    WHERE  user_login_id = @user_login_id OR  ispublic = 'y'
END

