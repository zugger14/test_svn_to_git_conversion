IF OBJECT_ID(N'[dbo].[spa_rfx_report_pivot]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_pivot]
GO
 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
--Created by: navaraj@pioneersolutionsglobal.com
--Description: Check if Pivot rdl file exists or not
--Sample: EXEC [spa_rfx_report_paramset] 'p', '/Oil_Master_Demo/Latest MTM View Report_Latest MTM As of Day Report'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_pivot]
	@flag CHAR(1),
	@rdl_report_path VARCHAR(1000) = NULL
AS
SET NOCOUNT ON

DECLARE @sql	VARCHAR(1000)  

IF @flag = 'p'
BEGIN
	DECLARE @report_server_db  VARCHAR(50)

	SELECT @report_server_db = name FROM sys.databases d WHERE NAME LIKE 'ReportServer%' AND NAME NOT LIKE '%tempdb'

	SET @sql = 'IF EXISTS (SELECT 1 FROM [' + @report_server_db + '].dbo.Catalog WHERE Path = ''' + @rdl_report_path + '_pivot'')
				BEGIN
					SELECT Name FROM [' + @report_server_db + '].dbo.Catalog WHERE Path = ''' + @rdl_report_path + '_pivot''
				END
				ELSE
				BEGIN
					SELECT Name FROM [' + @report_server_db + '].dbo.Catalog WHERE Path = ''' + @rdl_report_path + '''
				END	'
	EXEC(@sql)
END
