IF OBJECT_ID(N'spa_getAllSystemCommodities', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getAllSystemCommodities]
GO 

--This procedure gets all commodities by all systems

-- EXEC spa_getAllSystemCommodities
-- drop proc spa_getAllSystemCommodities

CREATE PROCEDURE [dbo].[spa_getAllSystemCommodities] 
	@source_system_id INT = NULL,
	@flag CHAR(1) = 's'
AS
SET NOCOUNT ON
DECLARE @sql AS VARCHAR(1000)
SET @sql = 
		'SELECT
			sc.source_commodity_id source_commodity_id
			,sc.commodity_name + CASE WHEN ssd.source_system_name=''farrms'' THEN '''' ELSE ''.'' + ssd.source_system_name END AS commodity_name
			' 
			+ CASE WHEN @flag <> 'c' THEN ',ssd.source_system_name' ELSE '' END +
		' FROM source_commodity sc
			INNER JOIN source_system_description ssd ON sc.source_system_id = ssd.source_system_id
			WHERE 1 = 1 ' + CASE WHEN @source_system_id IS NOT NULL THEN ' AND ssd.source_system_id = ' + CAST(@source_system_id AS VARCHAR) ELSE '' END
			+ ' ORDER BY sc.commodity_name '
		
--PRINT @sql
EXEC (@sql)