/*
Author		: Manju Singh
Dated		: 27 April.2016
Description : Open report in spa_html.
*/
--select [dbo].[FNAStandardReportHyperlink](NULL, 'EXEC spa_staticValues ''s'',800', NULL,NULL,NULL)

IF OBJECT_ID ('[dbo].[FNAStandardReportHyperlink]','FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAStandardReportHyperlink]
GO
CREATE FUNCTION [dbo].[FNAStandardReportHyperlink]
(
	@report_name	 VARCHAR(50),
	@query		 VARCHAR(4000),
	@label		 VARCHAR(250),
	@height		 FLOAT,
	@width		 FLOAT
)
RETURNS VARCHAR(4000) AS
BEGIN	

	DECLARE @hyper_text VARCHAR(4000)
	
	IF @label IS NULL
		SET @label = '......'
	/* 
	added parent on function call 'open_spa_html_window' as it was opening window inside scope of report viewer that gave issues: hidden scroll bars on report plotted,link window top cut when open from scrolled down link.
	*/
	SELECT @hyper_text = '<a  onClick=parent.open_spa_html_window("' + dbo.FNAURLEncode(ISNULL(@report_name, 'Standard Report')) + '","' + dbo.FNAURLEncode(@query) + '","' + CAST(ISNULL(@height,800) AS VARCHAR(8)) + '","' + CAST(ISNULL(@width,800) AS VARCHAR(8)) + '") href=javascript:void(0) >' + @label + '</a>'
			
	
	RETURN @hyper_text
END	


