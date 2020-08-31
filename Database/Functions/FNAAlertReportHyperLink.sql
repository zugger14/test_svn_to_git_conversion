/****** Object:  UserDefinedFunction [dbo].[FNAAlertReportHyperLink]    Script Date: 10/17/2012 19:26:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAAlertReportHyperLink]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAAlertReportHyperLink]
GO

/****** Object:  UserDefinedFunction [dbo].[FNAAlertReportHyperLink]    Script Date: 10/17/2012 16:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Updated by: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-11-20
-- Description: Hyperlink for alerts
 

-- Parameters:
-- alert_reports_id:  Report ID of Alerts
-- alert_id: Alert ID
-- @report_params: paramaters to run reports
-- @process_id : Process Id of Alert  
-- Returns NVARCHAR
-- ===========================================================================================================

CREATE FUNCTION [dbo].[FNAAlertReportHyperLink] (
	@alert_reports_id  INT,
	@alert_id          INT,
	@report_params	   NVARCHAR(MAX),
	@process_id NVARCHAR(200)
)
RETURNS NVARCHAR(2000)
AS
BEGIN
	DECLARE @hl                NVARCHAR(2000),
	        @report_writer     NVARCHAR(1),
	        @paramset_hash	   NVARCHAR(200),
	        @report_param      NVARCHAR(1000),
	        @report_desc       NVARCHAR(500)
	
	SELECT @report_writer = report_writer,
	       @paramset_hash = paramset_hash,
	       @report_param = report_param,
	       @report_desc = report_desc
	FROM   alert_reports
	WHERE  alert_reports_id = @alert_reports_id
	
	IF @report_writer = 'n' OR @report_writer = 'a'
	BEGIN
		SET @hl = '<a target="_blank" href="' + './dev/spa_html.php?__user_name__=' + dbo.FNADBUser() + 
				  '&spa=EXEC spa_get_alert_report_output ' + cast(@alert_reports_id as NVARCHAR) + ',' + CAST(@alert_id as NVARCHAR) + 
				  ',NULL' + ',' + CASE WHEN @report_writer = 'n' THEN '__source_id__' ELSE 'NULL' END + '">' + @report_desc + '</a>'
	END	
	ELSE IF @report_writer = 'y' 
	BEGIN
		DECLARE @paramset_id INT
		DECLARE @report_name NVARCHAR(1000)
		DECLARE @items_combined NVARCHAR(100)
		
		SELECT  
		DISTINCT @paramset_id = rps.report_paramset_id, 
				 @report_name = (MAX(r.name) + '_' +  MAX(rp.[name])),
				 @items_combined = dbo.FNARFXGenerateReportItemsCombined(MAX(rp.report_page_id)),
				 @report_param = ISNULL(@report_params, ar.report_param)
		FROM report r 
		LEFT JOIN report_page rp ON rp.report_id = r.report_id
		LEFT JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
		LEFT JOIN alert_reports ar ON ar.paramset_hash = rps.paramset_hash
		LEFT JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
		LEFT JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
		LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rpm.column_id
		WHERE rps.paramset_hash = @paramset_hash
		GROUP BY r.report_id, rps.report_paramset_id, ar.report_param
		
		
		SET @hl = '<a href="' + '../../adiha.html.forms/_reporting/report_manager_dhx/report.viewer.php?paramset_id=' + CAST(@paramset_id AS NVARCHAR(30))+ '&report_name=' + @report_name + '&report_filter=' + @report_param + '&items_combined=' + @items_combined + '&export_type=HTML4.0&__user_name__=' + dbo.FNADBUser() + 
				  '" target="_blank">' + ISNULL(@report_desc, @report_name) + '</a>'
	END
	RETURN @hl
	
END


