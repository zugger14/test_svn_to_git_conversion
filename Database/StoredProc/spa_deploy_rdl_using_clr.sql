IF OBJECT_ID(N'[dbo].spa_deploy_rdl_using_clr', N'P ') IS NOT NULL 
	DROP PROCEDURE [dbo].spa_deploy_rdl_using_clr
GO

/**
	Used to deploy report using CLR

	Parameters
	@report_name	:	report name
	@report_description	:	Report desctiption
	@customReportFolder	:	any dir that are part of report server data source eg. custom_reports
	@debug_mode	:	set debug mode to y for print
*/

CREATE PROCEDURE dbo.[spa_deploy_rdl_using_clr]
	@report_name VARCHAR(5000),
	@report_description VARCHAR(1024),
	@customReportFolder VARCHAR(1024) = '',
	@debug_mode CHAR(1) = 'n'
AS
SET NOCOUNT ON
BEGIN
	DECLARE @report_server_user_name         VARCHAR(100),
	        @report_server_password          VARCHAR(1000),
	        @report_server_domain            VARCHAR(200),
	        @report_server_url               VARCHAR(300),
	        @report_server_temp_folder       VARCHAR(300),
	        @report_server_target_folder     VARCHAR(300),
	        @report_server_datasource_name	 VARCHAR(400)
	
	
	SELECT @report_server_user_name			= cs.report_server_user_name,
	       @report_server_password          = dbo.FNADecrypt(cs.report_server_password),
	       @report_server_domain            = cs.report_server_domain,
	       @report_server_url               = cs.report_server_url,
	       @report_server_target_folder     = CASE WHEN @customReportFolder IS NOT NULL THEN cs.report_server_target_folder + @customReportFolder ELSE cs.report_server_target_folder END,
	       @report_server_datasource_name   = cs.report_server_datasource_name,
	       @report_server_temp_folder       = cs.document_path + '\temp_note'
	FROM   connection_string cs
	
	DECLARE @status VARCHAR(1024)
	
	EXEC spa_deploy_rdl @report_server_user_name,
	           @report_server_password,
	           @report_server_domain,
	           @report_server_url,
	           @report_server_temp_folder,
	           @report_server_target_folder,
	           @report_server_datasource_name,
	           @report_name,
	           @report_description,
	           @debug_mode,
	           @status OUTPUT

	 IF @status <> '1'
		THROW 51000, @status ,1
	 ELSE SELECT @status [status]
END

	

GO
