IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARFXGenerateReportItemsCombined]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARFXGenerateReportItemsCombined]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Create date: 2013-04-12 2:40PM
-- Description:	Generates report page items (tablix, chart, gauge) in name:id in csv. 
-- Used while running query for each component.

-- Params:
--	@report_page_id - Report page id
-- returns VARCHAR(8000) - report page name:id in csv
-- ========================================================================
CREATE FUNCTION [dbo].[FNARFXGenerateReportItemsCombined](
	@report_page_id INT
)
RETURNS VARCHAR(8000)
AS
BEGIN
/**********************TEST CODE START****************/
	--DECLARE @report_page_id INT = 234

/**********************TEST CODE START****************/

	DECLARE @items_combined VARCHAR(8000)
	SELECT @items_combined = 
		STUFF(
				( 
					--TODO: For now only space is removed, later all other special characters	 
					SELECT ',ITEM_' + REPLACE(page_rd.name, ' ', '') + ':' + CAST(page_rd.component_id AS VARCHAR(10))
					FROM (
						SELECT rpt.report_page_tablix_id component_id, rpt.name FROM report_page_tablix rpt WHERE rpt.page_id = @report_page_id						
						UNION 
						SELECT rpc.report_page_chart_id component_id, rpc.name FROM report_page_chart rpc WHERE rpc.page_id  = @report_page_id
						UNION 
						SELECT rpg.report_page_gauge_id component_id, rpg.name FROM report_page_gauge rpg WHERE rpg.page_id  = @report_page_id
					) page_rd
					FOR XML PATH(''), TYPE
				).value('.[1]', 'VARCHAR(8000)'), 1, 1, '') 
				
	RETURN @items_combined
END

GO


