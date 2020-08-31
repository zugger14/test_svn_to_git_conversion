IF OBJECT_ID(N'[dbo].[spa_deal_detail_actuals]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_detail_actuals]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2014-09-16
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_deal_detail_actuals]
    @flag CHAR(1),
    @source_deal_detail_id INT = NULL,
	@split_deal_actuals_id INT = NULL
AS

DECLARE @sql VARCHAR(MAX)

SET @source_deal_detail_id = ISNULL(@source_deal_detail_id, '') 

IF @flag = 's'
BEGIN
	SET @sql = 'SELECT event_type [Event Type], dbo.FNAUserDateFormat(event_date, dbo.FNAdbuser()) [Event Date], deal_actual_event_date_id FROM deal_actual_event_date WHERE source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(20)) 

	IF NOT EXISTS (SELECT 1 FROM deal_actual_event_date WHERE source_deal_detail_id = @source_deal_detail_id)
	SET @sql = @sql + ' UNION ALL SELECT NULL, NULL, NULL'
	
	exec spa_print @sql
	EXEC(@sql)	
	   
END

ELSE IF @flag = 't'
BEGIN
	SET @sql = 'SELECT quality [Quality], value [Value], deal_actual_quality_id FROM deal_actual_quality WHERE source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(20)) 

	IF NOT EXISTS (SELECT 1 FROM deal_actual_quality WHERE source_deal_detail_id = @source_deal_detail_id)
	SET @sql = @sql + ' UNION ALL SELECT NULL, NULL, NULL'
	
	exec spa_print @sql
	EXEC(@sql)	
	   
END
ELSE IF @flag = 'e'
BEGIN
	SELECT deal_actual_event_date_id, split_deal_actuals_id, e.event_type, event_date--,--dbo.FNADateFormat(event_date)  event_date  
	FROM deal_actual_event_date e
	WHERE e.split_deal_actuals_id = @split_deal_actuals_id
END
ELSE IF @flag = 'q'
BEGIN
	SELECT  deal_actual_id, split_deal_actuals_id, q.quality, 
			CASE
				WHEN sdv.category_id = 1 THEN 'Numeric'
				WHEN sdv.category_id = 2 THEN 'Percentage'
				WHEN sdv.category_id = 3 THEN 'Text'
				WHEN sdv.category_id = 4 THEN 'Range'
			END AS [type],
	 value, company, is_average     
	FROM deal_actual_quality q	
		LEFT JOIN static_data_value sdv 
			ON q.quality = sdv.value_id	
	WHERE q.split_deal_actuals_id = @split_deal_actuals_id

	UNION ALL
	SELECT NULL,NULL, cq.quality, 
		CASE
				WHEN sdv.category_id = 1 THEN 'Numeric'
				WHEN sdv.category_id = 2 THEN 'Percentage'
				WHEN sdv.category_id = 3 THEN 'Text'
				WHEN sdv.category_id = 4 THEN 'Range'
			END AS [type],
		NULL, NULL,NULL
	FROM commodity_quality cq
		INNER JOIN split_deal_actuals sda
			ON sda.product_commodity = cq.source_commodity_id
		LEFT JOIN static_data_value sdv 
			ON cq.quality = sdv.value_id	
		LEFT JOIN deal_actual_quality daq
			ON daq.split_deal_actuals_id = sda.split_deal_actuals_id
				AND daq.quality = cq.quality
	WHERE sda.split_deal_actuals_id = @split_deal_actuals_id
		AND daq.deal_actual_id is null
END
--SELECT * FROM deal_actual_quality 