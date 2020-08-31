

IF OBJECT_ID(N'[dbo].[spa_get_report_param_id]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_get_report_param_id
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: CRUD operations for table time_zone
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_get_report_param_id
    @flag CHAR(1),
	@report_name VARCHAR(MAX)
AS
 
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
	DECLARE @items_combined VARCHAR(1000), @paramset_id VARCHAR(10)
	SELECT @paramset_id = rpm.report_paramset_id, @items_combined = dbo.FNARFXGenerateReportItemsCombined(rpg.report_page_id)
	FROM report_paramset rpm 
	INNER JOIN report_page rpg on rpg.report_page_id = rpm.page_id
	WHERE rpm.name = @report_name

	SELECT @items_combined items_combined, @paramset_id paramset_id
END
 
GO

