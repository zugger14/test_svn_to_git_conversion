
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_getAllMeter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getAllMeter]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[spa_getAllMeter]  
	@flag VARCHAR(1) = NULL,
	@group_id VARCHAR(1000) = NULL,
	@filter_value VARCHAR(1000) = NULL
AS
SET NOCOUNT ON
BEGIN
	DECLARE @sql VARCHAR(MAX)

	/**
	 * This block is added for the browser field selected values only
	 * There will be no need to check the privilege for this
	 * Performance enhancement
	 */
	IF @flag = 's' AND NULLIF(@filter_value, '<FILTER_VALUE>') IS NOT NULL
	BEGIN
		SELECT mi.meter_id [id],
				CASE WHEN mi.recorderid <> mi.description THEN mi.recorderid + ' - ' + mi.description ELSE mi.recorderid END [name],
				'Enable' [status]
		FROM meter_id mi
		INNER JOIN dbo.SplitCommaSeperatedValues(@filter_value) s
			ON s.item = mi.meter_id
		
		RETURN
	END

	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'meter'

	IF @flag = 's'
	BEGIN
		SET @sql = ' 
				SELECT DISTINCT mi.meter_id [id], CASE WHEN mi.recorderid <> mi.description THEN mi.recorderid + '' - '' + mi.description ELSE mi.recorderid END [name],
						MIN(fpl.is_enable) [status]
				FROM #final_privilege_list fpl
				' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
					meter_id mi ON mi.meter_id = fpl.value_id
				GROUP BY mi.meter_id, mi.recorderid, mi.description
				ORDER BY [name]'
		EXEC(@sql)
	END 
	IF @flag = 'a'
	BEGIN 
		
		SELECT meter_id [id], description [Meter Description]
		FROM meter_id
		--ORDER BY recorderid
	END 
	IF @flag = 'n'
	BEGIN
		SET @sql = 'SELECT	DISTINCT mi.meter_id [id], CASE WHEN mi.recorderid <> mi.description THEN mi.recorderid + '' - '' + mi.description ELSE mi.recorderid END [name],
						MIN(fpl.is_enable) [status]
				FROM #final_privilege_list fpl
				' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
					meter_id mi ON mi.meter_id = fpl.value_id
					INNER JOIN source_minor_location_meter smlm ON  smlm.meter_id = mi.meter_id
					INNER JOIN source_minor_location_nomination_group smlng ON  smlng.source_minor_location_id = smlm.source_minor_location_id
						AND smlng.info_type = ''n''
					WHERE  smlng.group_id IN (' + CAST(@group_id AS VARCHAR(1000)) + ')
					GROUP BY mi.meter_id, mi.recorderid, mi.description
					ORDER BY [name]'
		EXEC(@sql)
	END
END
