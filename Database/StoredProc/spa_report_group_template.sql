/****** Object:  StoredProcedure [dbo].[spa_report_group_template]    Script Date: 06/15/2009 20:55:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_report_group_template]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_report_group_template]
/****** Object:  StoredProcedure [dbo].[spa_report_group_template]    Script Date: 06/15/2009 20:55:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_report_group_template]
	@flag CHAR(1),
	@report_template_id INT=NULL,
	@user_login_id VARCHAR(100)=NULL,
	@report_section INT=NULL,
	@report_parameter VARCHAR(1000)=NULL,
	@report_template_group_id INT=NULL,
	@report_template_name INT=NULL
AS
SET NOCOUNT ON 
BEGIN
DECLARE @sql VARCHAR(1000)
DECLARE @count FLOAT
DECLARE @errorCode VARCHAR(1000)
IF @flag='s'
BEGIN
	SET @sql='SELECT
		report_template_id,
		user_login_id [User],
		report_section [ReportSection],
		report_parameter [ReportParameter]

	FROM
		dashboard_report_template
	WHERE 1=1'+
	CASE WHEN @user_login_id IS NOT NULL THEN ' AND user_login_id='''+@user_login_id+'''' ELSE '' END
	+CASE WHEN @report_section IS NOT NULL THEN ' AND report_section='+CAST(@report_section AS VARCHAR) ELSE '' END
	+CASE WHEN @report_template_group_id IS NOT NULL THEN ' AND report_template_group_id='+CAST(@report_template_group_id AS VARCHAR) ELSE '' END
EXEC(@sql)

END

ELSE IF @flag='a'
	SELECT
		report_template_id,
		user_login_id,
		report_section,
		report_parameter,
		report_template_name

	FROM
		dashboard_report_template
WHERE report_template_id=@report_template_id

ELSE IF @flag='i'
BEGIN 
	if exists(select report_template_id from dashboard_report_template where 
			ISNULL(report_template_group_id,0) = ISNULL(@report_template_group_id,0) and
			ISNULL(report_section,0) = ISNULL(@report_section,0))	
		begin
			Exec spa_ErrorHandler -1, "Section must be unique.",
					"spa_report_group_template", "DB Error", 
				"Section must be unique.", ''
			return
		end	

SELECT @count = count(report_template_id) from dashboard_report_template WHERE report_template_group_id=@report_template_group_id
IF @count =6
	BEGIN
		Exec spa_ErrorHandler -1, 'Can not Insert More Than 6 Reports.', 
				'spa_report_group_template', 'DB Error', 
				'Can not Insert More Than 5 Reports.', ''
				return
	END
 
	INSERT INTO dashboard_report_template(
					user_login_id,
					report_section,
					report_parameter,
					report_template_group_id
			        ,report_template_name

				)
			select 
				@user_login_id,
				@report_section,
				@report_parameter,
				@report_template_group_id
				,@report_template_name
	Set @errorCode = @@ERROR
	If @errorCode <> 0
		Exec spa_ErrorHandler @errorCode, 'Insert of Dash Board Template Failed.', 
				'spa_StaticDataValue', 'DB Error', 
				'Insert of Dash Board Template Failed.', ''
	Else
		Exec spa_ErrorHandler 0, 'Successfully inserted Dash board Template.', 
				'spa_StaticDataValue', 'Success', 
				'Successfully inserted Dash board Template.', ''

		END

ELSE IF @flag='u'

BEGIN TRY
	UPDATE dashboard_report_template
	SET    user_login_id = @user_login_id,
	       report_section = @report_section,
	       report_parameter = @report_parameter,
	       report_template_name = @report_template_name
	WHERE  report_template_id = @report_template_id
	
	IF @@ERROR <> 0
	BEGIN
	    EXEC spa_ErrorHandler @@ERROR,
	         "Update Dash board Template Failed.",
	         "spa_report_group_template",
	         "DB Error",
	         "Update Dash board Template Failed.",
	         ''
	    
	    RETURN
	END
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'Successfully Updated Dash board Template.',
	         'spa_report_group_template',
	         'Success',
	         'Successfully Updated Dash board Template.',
	         ''
END TRY
BEGIN CATCH
	EXEC spa_ErrorHandler -1,
				 "Section must be unique.",
				 "spa_report_group_template_group",
				 "DB Error",
				 "Section must be unique.",
				 ''
END CATCH

/*

BEGIN 
	UPDATE dashboard_report_template
	SET
			user_login_id=@user_login_id,
			report_section=@report_section,
			report_parameter=@report_parameter,
			report_template_name =@report_template_name 
	WHERE
		report_template_id=@report_template_id
		
		If @@ERROR <> 0
		begin
			Exec spa_ErrorHandler @@ERROR, "Update Dash board Template Failed.", 
					"spa_report_group_template", "DB Error", 
					"Update Dash board Template Failed.", ''
			RETURN
		END 

			ELSE Exec spa_ErrorHandler 0, 'Successfully Updated Dash board Template.', 
					'spa_report_group_template', 'Success', 
					'Successfully Updated Dash board Template.', ''
END 
*/
ELSE IF @flag='d'
	DELETE FROM dashboard_report_template
WHERE
	report_template_id=@report_template_id

END


