/***********************************************
* Created By:Mukesh Singh
* Create date: 14-Sept-2009
* Description:Keep records of Template Reports
* *********************************************/
/****** Object:  StoredProcedure [dbo].[spa_dashboardReporttemplate]    Script Date: 09/14/2009 14:18:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_dashboardReporttemplate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_dashboardReporttemplate]
GO
/****** Object:  StoredProcedure [dbo].[spa_dashboardReportName]    Script Date: 09/14/2009 14:18:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_dashboardReportName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_dashboardReportName]
GO

CREATE PROCEDURE [dbo].[spa_dashboardReportName]
@flag char(1),
@template_id INT =null,
@report_name VARCHAR(100)=NULL,
@instance_name VARCHAR(200)=NULL,
@report_type VARCHAR(50)=null,
@module VARCHAR(50)=NULL --valid are 'trm', 'fas', 'ems'

AS
IF @flag='s'
BEGIN
	DECLARE @module_type TINYINT
	IF @module='trm'
		SET @module_type=1; --lowermost bit is for trm
	ELSE IF @module='ems'
		SET @module_type=2; --2nd lowermost bit is for ems
	ELSE IF @module='fas'
		SET @module_type=4; --3rd lowermost bit is for fas
	ELSE 
		SET @module_type=0; --no filter.


	DECLARE @sqlstmt AS VARCHAR(200)
	--Graphical only report will have report_type='p' in dashboardreportname table.
	--HTML only report will have report_type='h' in dashboardreportname table.
	--report_type='null' in dashboardreportname table means the report supports both html and graphical.
	SET @sqlstmt='
	SELECT * FROM dashboardreportname WHERE 1=1 '
	+CASE WHEN @report_type IS NOT NULL THEN ' AND ISNULL(report_type,'''+@report_type+''')='''+@report_type+'''' ELSE '' END
	+' AND module_type & '+CAST(@module_type AS VARCHAR(3))+' = '+ CAST(@module_type AS VARCHAR(3))
	--PRINT @sqlstmt
	EXEC (@sqlstmt)
	
END

ELSE IF @flag = 'a'
BEGIN
	SELECT * FROM dashboardReportName drn WHERE drn.template_id = @template_id
END
GO


--SELECT * FROM dashboardreportname
--ALTER TABLE dashboardreporttemplate ALTER COLUMN 

--EXEC spa_dashboardReportName 's'
--exec spa_dashboard_report_template 's',NULL,NULL
--exec spa_dashboard_report_template 'd',22,NULL
