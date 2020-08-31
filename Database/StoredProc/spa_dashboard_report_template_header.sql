
/****** Object:  StoredProcedure [dbo].[spa_dashboard_report_template_header]    Script Date: 06/15/2009 20:56:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_dashboard_report_template_header]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_dashboard_report_template_header]
/****** Object:  StoredProcedure [dbo].[spa_dashboard_report_template_header]    Script Date: 06/15/2009 20:56:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_dashboard_report_template_header]
	@flag CHAR(1),
	@report_template_header_id INT=NULL,
	@user_login_id VARCHAR(50)=NULL,
	@report_name VARCHAR(100)=NULL,
	@report_view_type CHAR(1) = NULL,
	@ispublic CHAR(1)=NULL  
AS
SET NOCOUNT ON 
BEGIN
DECLARE @sql VARCHAR(1000)

	IF @flag='s'
	BEGIN
		SET @sql='SELECT
			report_template_header_id [Report Template Header ID],
			user_login_id [User],
			report_name [Report Name],
			CASE WHEN ISNULL(ispublic,''n'')=''y'' THEN ''Yes'' ELSE ''No'' END [Public]
		FROM
			dashboard_report_template_header
		WHERE 1=1'+
		CASE WHEN @user_login_id IS NOT NULL THEN ' AND user_login_id='''+@user_login_id+''''  ELSE '' END
		--CASE WHEN @user_login_id IS NOT NULL THEN ' AND user_login_id='''+@user_login_id+''' OR user_login_id IS NULL ' ELSE '' END
		+CASE WHEN @report_name IS NOT NULL THEN ' AND report_name like''%'+@report_name+'%''' ELSE '' END
		
	EXEC(@sql)

	END
	
	ELSE IF @flag='l' --to list user own report and others' public report templates, for 'admin' user list all.
	BEGIN
		--determine if @user_login_id is 'admin' or not.
		--If the user have 10111000 function_id priviledge, its admin.
		--***************************************--
		DECLARE @admin CHAR(1) ;
		CREATE TABLE #admin_rights
			(
			  function_id VARCHAR(8) COLLATE DATABASE_DEFAULT,
			  have_rights VARCHAR(8) COLLATE DATABASE_DEFAULT
			)
		INSERT  INTO #admin_rights
				EXEC spa_haveMultipleSecurityRights 10111000

		SELECT  @admin = CASE WHEN function_id = have_rights THEN 'y'
							  ELSE 'n'
						 END
		FROM    #admin_rights
		--***************************************--

		SET @sql='SELECT distinct 
			report_template_header_id [Report Template Header ID],
			user_login_id [User],
			report_name [Report Name]
		FROM
			dashboard_report_template_header
		WHERE 1=1'+
		CASE WHEN @admin='n' THEN ' AND (user_login_id='''+dbo.FNAdbUser()+''' OR ISNULL(ispublic,''n'')=''y'')'  ELSE '' END
		
	EXEC(@sql)

	END


	ELSE IF @flag='a'
		SELECT
			report_template_header_id,
			user_login_id,
			report_name,
			ISNULL(ispublic,'n') [Public]
		FROM
			dashboard_report_template_header
		WHERE report_template_header_id=@report_template_header_id	

	ELSE IF @flag='i'
		BEGIN
			INSERT INTO dashboard_report_template_header(
					user_login_id,
					report_name,
					report_view_type,
					ispublic)
			SELECT
				@user_login_id,
				@report_name,
				@report_view_type,
				@ispublic 
				
			If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Template Header", 
				"spa_dashboard_report_template_header", "DB Error", 
				"Error Inserting Template Header.", ''
			else
				Exec spa_ErrorHandler 0, 'Template Header', 
				'spa_dashboard_report_template_header', 'Success', 
				'Template Header successfully inserted.',''
		END

	ELSE IF @flag='u'
		BEGIN
			UPDATE dashboard_report_template_header
				   SET user_login_id=@user_login_id,
					   report_name=@report_name,
						report_view_type = @report_view_type,
						ispublic=@ispublic
			WHERE
				report_template_header_id=@report_template_header_id
				
			If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Template Header", 
				"spa_dashboard_report_template_header", "DB Error", 
				"Error updating Template Header.", ''
			else
				Exec spa_ErrorHandler 0, 'Template Header', 
				'spa_dashboard_report_template_header', 'Success', 
				'Template Header successfully updated.',''

		END

	ELSE IF @flag='d'
	BEGIN 
	IF EXISTS(SELECT 1 FROM dashboard_report_template_group WHERE report_template_header_id=@report_template_header_id)
	BEGIN
			Exec spa_ErrorHandler -1, "Report Group should be deleted first.",
					"spa_dashboard_report_template_header", "DB Error", 
				"Report Group should be deleted first.", ''
			return
	
	END
		DELETE FROM dashboard_report_template_header
			WHERE
				report_template_header_id=@report_template_header_id
				
		If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Template Header", 
				"spa_dashboard_report_template_header", "DB Error", 
				"Error Deleting Template Header.", ''
			else
				Exec spa_ErrorHandler 0, 'Template Header', 
				'spa_dashboard_report_template_header', 'Success', 
				'Template Header successfully deleted.',''
	
	END 
END
