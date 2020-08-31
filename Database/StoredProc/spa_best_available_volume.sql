IF OBJECT_ID(N'[dbo].[spa_best_available_volume]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_best_available_volume]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: arai@pioneersolutionsglobal.com
-- Create date: 2018-01-24
-- Description: .
 
-- Params:
-- @flag CHAR(1)         - 
-- @deal_id VARCHAR(100) - 
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_best_available_volume]
	@flag CHAR(1),
	@process_id VARCHAR(64) = NULL,
	@deal_id INT = NULL,
	@deal_type CHAR(1) = NULL,
	@flow_date DATE = NULL
AS

SET NOCOUNT ON
/*

DECLARE @flag CHAR(1) = 't',
		@process_id VARCHAR(64) = 'S1517432347457',
		@deal_id INT = 57685,--57703
		@deal_type CHAR(1) = 'b',
		@flow_date DATE = '2018-02-01'
--*/

DECLARE @sql VARCHAR(4000),
		@user_name VARCHAR(64) = dbo.FNADBUser()
DECLARE @schedule_grid_process_table VARCHAR(256) = dbo.FNAProcessTableName('main_grid_process_table', @user_name, @process_id)

IF @flag = 'b'
BEGIN
	SET @sql = '
		SELECT	p.deal_id,
				p.flow_date,
				p.[rec location] [location_name],
				dbo.FNARemoveTrailingZeroes(COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.deal_volume)),
				dbo.FNARemoveTrailingZeroes(SUM(COALESCE(sdd.actual_volume, sdd.schedule_volume, od.volume_used))) [rec_volume],
				dbo.FNARemoveTrailingZeroes(COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.deal_volume) - SUM(COALESCE(sdd.actual_volume, sdd.schedule_volume, od.volume_used))) [net_volume]
		FROM ' + @schedule_grid_process_table + ' p
		INNER JOIN optimizer_detail od ON od.source_deal_header_id = p.deal_id AND od.flow_date = p.flow_date
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = od.source_deal_detail_id AND sdd.term_start = p.flow_date
		WHERE p.[type] = 1 AND od.up_down_stream = ''U''
		GROUP BY p.deal_id, p.[rec location], p.flow_date, sdd.deal_volume, sdd.actual_volume, sdd.schedule_volume
	'
	--PRINT @sql
	EXEC(@sql)
END
IF @flag = 's'
BEGIN
	SET @sql = '
		SELECT	p.deal_id,
				p.flow_date,
				p.[delivery location],
				dbo.FNARemoveTrailingZeroes(COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.deal_volume)),
				dbo.FNARemoveTrailingZeroes(MAX(COALESCE(sdd.actual_volume, sdd.schedule_volume, odd.deal_volume))) [del_volume],
				dbo.FNARemoveTrailingZeroes(COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.deal_volume) - MAX(COALESCE(sdd.actual_volume, sdd.schedule_volume, odd.deal_volume))) [net_volume]
		FROM ' + @schedule_grid_process_table + ' p
		INNER JOIN optimizer_detail_downstream odd ON odd.source_deal_header_id = p.deal_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = odd.source_deal_detail_id
		WHERE p.[type] = 3
		GROUP BY p.deal_id, p.[delivery location], sdd.deal_volume, p.flow_date, sdd.actual_volume, sdd.schedule_volume
	'
	--PRINT @sql
	EXEC(@sql)
END
ELSE IF @flag = 't'
BEGIN
	SET @sql = '
		SELECT DISTINCT
			od.transport_deal_id [deal_id],
			dbo.FNADateFormat(od.flow_date) [flow_date],
			leg1.Location_Name + ''/'' + leg2.Location_Name [path],
			leg1.Location_Name [rec_location],
			leg2.Location_Name [del_location], 
			dbo.FNARemoveTrailingZeroes(leg1.deal_volume) [rec_volume],
			dbo.FNARemoveTrailingZeroes(leg2.deal_volume) [del_volume]		   	
		FROM ' + IIF(@deal_type = 's', 'optimizer_detail_downstream', 'optimizer_detail') + ' od
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = od.source_deal_detail_id
			AND sdd.term_start = ''' + CAST(@flow_date AS VARCHAR) + '''
		OUTER APPLY (
			SELECT DISTINCT sml.Location_Name, COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.deal_volume) [deal_volume]
			FROM source_deal_detail sdd 
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
			WHERE sdd.source_deal_header_id = od.transport_deal_id AND sdd.term_start = od.flow_date
				AND sdd.leg = 1
		) leg1
		OUTER APPLY(
			SELECT DISTINCT sml.Location_Name, COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.deal_volume) [deal_volume]
			FROM source_deal_detail sdd 
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
			WHERE sdd.source_deal_header_id = od.transport_deal_id AND sdd.term_start = od.flow_date
				AND	sdd.leg = 2
		) leg2
		WHERE od.source_deal_header_id = ' + CAST(@deal_id AS VARCHAR(10)) + '
			AND od.flow_date = ''' + CAST(@flow_date AS VARCHAR) + '''
			' + IIF(@deal_type = 'b',' AND od.up_down_stream = ''U''','') + '
		ORDER BY od.transport_deal_id ASC
	'
	--PRINT @sql
	EXEC(@sql)
END