--Author: Tara Nath Subedi
--Issue Against: 2291
--Purpose: Dashboard Report Enhancement
--Dated: 2010-05-09
--spa_dashboard_report_template_group

IF OBJECT_ID(N'[dbo].[spa_dashboard_report_template_group]',N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_dashboard_report_template_group]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_dashboard_report_template_group]
	@flag CHAR(1),
	@report_template_group_id INT=NULL,
	@user_login_id VARCHAR(100)=NULL,
	@report_name VARCHAR(100)=NULL,
	@report_section INT=NULL,
	@report_template_header_id INT=NULL,
	@report_type CHAR(1)=NULL
AS
SET NOCOUNT ON 
BEGIN
DECLARE @sql VARCHAR(1000)
DECLARE @count FLOAT
DECLARE @errorCode VARCHAR(1000)
IF @flag='s'
BEGIN
	SET @sql='SELECT
		report_template_group_id [Report Template Group ID],
		user_login_id [User],
		report_section [Group],
		report_name [Group Name],
		CASE WHEN report_type=''p'' THEN ''Graphical'' ELSE ''HTML''END [Group Type]
	FROM
		dashboard_report_template_group
	WHERE 1=1'+
	CASE WHEN @user_login_id IS NOT NULL THEN ' AND user_login_id='''+@user_login_id+'''' ELSE '' END
	+CASE WHEN @report_name IS NOT NULL THEN ' AND report_name like''%'+@report_name+'%''' ELSE '' END
	+CASE WHEN @report_section IS NOT NULL THEN ' AND report_section='+CAST(@report_section AS VARCHAR) ELSE '' END
	+CASE WHEN @report_template_header_id IS NOT NULL THEN ' AND report_template_header_id='+CAST(@report_template_header_id AS VARCHAR) ELSE '' END
EXEC(@sql)

END

ELSE IF @flag='a'
	SELECT
		report_template_group_id,
		user_login_id,
		report_name,
		report_section,
		report_type

	FROM
		dashboard_report_template_group
WHERE report_template_group_id=@report_template_group_id

ELSE IF @flag='i'
BEGIN 
	if exists(select report_template_group_id from dashboard_report_template_group where 
			ISNULL(report_template_header_id,0) = ISNULL(@report_template_header_id,0) and
			ISNULL(report_section,0) = ISNULL(@report_section,0))	
		begin
			Exec spa_ErrorHandler -1, "Section must be unique.",
					"spa_dashboard_report_template_group", "DB Error", 
				"Section must be unique.", ''
			return
		end	

SELECT @count = count(report_template_group_id) from dashboard_report_template_group WHERE report_template_header_id=@report_template_header_id
IF @count =5
	BEGIN
		Exec spa_ErrorHandler -1, 'Can not Insert More Than 5 Report Groups.', 
				'spa_dashboard_report_template_group', 'DB Error', 
				'Can not Insert More Than 5 Report Groups.', ''
				return
	END
 
	INSERT INTO dashboard_report_template_group(
					user_login_id,
					report_name,
					report_section,
					report_template_header_id
			        ,report_type

				)
			select 
				@user_login_id,
				@report_name,
				@report_section,
				@report_template_header_id
				,@report_type
	Set @errorCode = @@ERROR
	If @errorCode <> 0
		Exec spa_ErrorHandler @errorCode, 'Insert of Dash Board Template Report Group Failed.', 
				'spa_StaticDataValue', 'DB Error', 
				'Insert of Dash Board Template Group Failed.', ''
	Else
		Exec spa_ErrorHandler 0, 'Successfully inserted Dash board Template Report Group.', 
				'spa_StaticDataValue', 'Success', 
				'Successfully inserted Dash board Template Report Group.', ''

		END

ELSE IF @flag='u'
BEGIN TRY
	UPDATE dashboard_report_template_group
	SET    user_login_id = @user_login_id,
	       report_name = @report_name,
	       report_section = @report_section,
	       report_type = @report_type
	WHERE  report_template_group_id = @report_template_group_id
	
	IF @@ERROR <> 0
	BEGIN
	    EXEC spa_ErrorHandler @@ERROR,
	         "Update Dash board Template Report Group Failed.",
	         "spa_dashboard_report_template_group",
	         "DB Error",
	         "Update Dash board Template Report Group Failed.",
	         ''
	    
	    RETURN
	END
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'Successfully Updated Dash board Template Report Group.',
	         'spa_dashboard_report_template_group',
	         'Success',
	         'Successfully Updated Dash board Template Report Group.',
	         ''
END TRY
BEGIN CATCH	
		EXEC spa_ErrorHandler -1,
				 "Section must be unique.",
				 "spa_dashboard_report_template_group",
				 "DB Error",
				 "Section must be unique.",
				 ''
	
END CATCH
/*BEGIN
	UPDATE dashboard_report_template_group
			SET
				user_login_id=@user_login_id,
				report_name=@report_name,
				report_section=@report_section,
				report_type =@report_type
			WHERE
				report_template_group_id=@report_template_group_id
			
			If @@ERROR <> 0
				begin
					Exec spa_ErrorHandler @@ERROR, "Update Dash board Template Report Group Failed.", 
							"spa_dashboard_report_template_group", "DB Error", 
							"Update Dash board Template Report Group Failed.", ''
					RETURN
				END 
			ELSE 
				Exec spa_ErrorHandler 0, 'Successfully Updated Dash board Template Report Group.', 
						'spa_dashboard_report_template_group', 'Success', 
						'Successfully Updated Dash board Template Report Group.', ''

END*/ 

ELSE IF @flag='d'
BEGIN
	IF EXISTS(SELECT 1 FROM dashboard_report_template WHERE report_template_group_id=@report_template_group_id)
		BEGIN
				Exec spa_ErrorHandler -1, "Report Parameter should be deleted first.",
						"spa_dashboard_report_template_header", "DB Error", 
					"Report Parameter should be deleted first.", ''
				return
		
		END
	DELETE FROM dashboard_report_template_group
	WHERE report_template_group_id=@report_template_group_id

END

ELSE IF @flag='g' -- lists group,groupname,grouptype, and number of reports in the group.
BEGIN

	SELECT  rtg.report_section AS [Group],
			rtg.report_name AS [Group Name],
			rtg.report_type AS [Type],
			COUNT(rt.report_template_group_id) AS [Report Count]
	FROM    dashboard_report_template_group rtg
			LEFT JOIN dashboard_report_template rt ON rtg.report_template_group_id = rt.report_template_group_id
	WHERE   rtg.report_template_header_id = @report_template_header_id
	GROUP BY rtg.report_section,
			rtg.report_name,
			rtg.report_type
	ORDER BY rtg.report_section

END


ELSE IF @flag='r' -- lists group and report n parameter in order.
BEGIN

	SELECT  rtg.report_section AS [Group],
			rt.report_section AS [Report Section],
			rt.report_parameter AS [Report Parameter]
	FROM    dashboard_report_template_group rtg
			INNER JOIN dashboard_report_template rt ON rtg.report_template_group_id = rt.report_template_group_id
	WHERE   rtg.report_template_header_id = @report_template_header_id
	ORDER BY rtg.report_section,
			rt.report_section

END


END


