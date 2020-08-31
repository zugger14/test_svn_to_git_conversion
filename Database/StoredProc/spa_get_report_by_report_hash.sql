IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_get_report_by_report_hash]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_get_report_by_report_hash]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
Author : vsshrestha@pioneersolutionsglobal.com
Dated  : 02/03/2013
Desc   : For obtaining report details from report_hash

*/
CREATE PROC [dbo].[spa_get_report_by_report_hash]
	
	@flag					CHAR(1)	    = NULL	,
	/* 
	   'm'-To get the report id
	   'n'-To get the report name
	   'p' - To get report by report name
	   */
	@report_hash VARCHAR(200) = NULL
	
AS	
SET NOCOUNT ON 	





IF @flag = 'm' 
BEGIN
SELECT report_id,name FROM report WHERE [name] LIKE '%Price Curve System Report%'
END
ELSE IF @flag = 'n' -- select report or a tab
BEGIN
    
    SELECT r.report_id,
           r.[name] + '_' + rp2.[name] AS [report_name],
           dbo.FNARFXGenerateReportItemsCombined(rp2.report_page_id) 
           [items_combined],
           rdp.paramset_id
    FROM   report r
           INNER JOIN report_page rp2
                ON  rp2.report_id = r.report_id
           INNER JOIN report_paramset rp
                ON  rp.page_id = rp2.report_page_id
           INNER JOIN report_dataset_paramset rdp
                ON  rdp.paramset_id = rp.report_paramset_id
    WHERE  r.report_hash = @report_hash
   
END
ELSE IF @flag = 'p' -- select report by report name.
BEGIN
    
    SELECT r.report_id,
           r.[name] + '_' + rp2.[name] AS [report_name],
           dbo.FNARFXGenerateReportItemsCombined(rp2.report_page_id) 
           [items_combined],
           rdp.paramset_id
    FROM   report r
           INNER JOIN report_page rp2
                ON  rp2.report_id = r.report_id
           INNER JOIN report_paramset rp
                ON  rp.page_id = rp2.report_page_id
           INNER JOIN report_dataset_paramset rdp
                ON  rdp.paramset_id = rp.report_paramset_id
    WHERE rp2.name = @report_hash
   
END
GO