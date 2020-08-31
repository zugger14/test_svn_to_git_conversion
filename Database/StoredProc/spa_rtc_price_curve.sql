IF OBJECT_ID(N'[dbo].[spa_rtc_price_curve]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rtc_price_curve]
GO
 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rabhusal@pioneersolutionsglobal.com
-- Create date: 2019-04-24
-- Description: Select Operation, Check RTC Curve Hour Sum
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @source_curve_def_id INT - used for getting value according to source_curve_def_id
-- @curve_ids VARCHAR(MAX) - used to get rtc curve hour sum
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_rtc_price_curve]
	@flag CHAR(1),
	@source_curve_def_id INT = NULL,
	@curve_ids VARCHAR(MAX) = NULL,
	@return_status INT = 0 OUTPUT
AS
SET NOCOUNT ON

/* ---------DEBUG----------
DECLARE @flag CHAR(1),
	@source_curve_def_id INT = NULL,
	@curve_ids VARCHAR(MAX) = NULL,
	@return_status INT = 0

SELECT @flag = 'c', @curve_ids = '7283,7282,7286'
--*/

DECLARE @sql VARCHAR(MAX)

/*
 * Select all data from "rtc_source_price_curve"
*/
IF @flag = 's'
BEGIN
	SET @sql = '
		SELECT rtc_curve_id, rtc_curve_def_id, rtc_curve
		FROM rtc_source_price_curve
		WHERE rtc_curve_def_id = ' + CAST(@source_curve_def_id AS VARCHAR(20)) + ''

	EXEC (@sql)
END

/*
 * Check RTC Curve Hour Sum
*/
IF @flag = 'c'
BEGIN
	DECLARE @block_val_id VARCHAR(MAX)
	DECLARE @baseload_val_id VARCHAR(20)
	DECLARE @final_sum INT

	SELECT @baseload_val_id = value_id FROM static_data_value WHERE code = 'Base Load' AND [type_id] = 10018

	IF (@curve_ids = '')
	BEGIN
		SELECT 1 AS [is_valid]
		RETURN
	END

	SELECT TOP 1 @block_val_id = STUFF(
			(
				SELECT ',' + CAST(ISNULL(a.block_define_id, @baseload_val_id) AS VARCHAR(20)) FROM source_price_curve_def a
				INNER JOIN dbo.FNASplit(@curve_ids, ',') ci ON ci.item = a.source_curve_def_id
				FOR XML PATH ('')
			), 1, 1, ''
		)
	FROM source_price_curve_def spcd
	INNER JOIN dbo.FNASplit(@curve_ids, ',') ci ON ci.item = spcd.source_curve_def_id

	IF OBJECT_ID('tempdb..#weekly_table') IS NOT NULL DROP TABLE #weekly_table

	--SELECT * FROM static_data_value WHERE value_id = @block_val_id
	SELECT block_value_id,
		week_day,
		SUM(hr1 + hr2 + Hr3 + Hr4 + Hr5 + Hr6 + Hr7 + Hr8 + Hr9 + Hr10 + hr11 + Hr12 + 
			Hr13 + Hr14 + Hr15 + Hr16 + Hr17 + Hr18 + Hr19 + Hr20 + Hr21 + Hr22 + Hr23 + Hr24
		) [all_hour_sum]
		--SUM(hr1), SUM(hr2), SUM(Hr3), SUM(hr4), SUM(hr5), SUM(hr6), SUM(hr7), SUM(hr8), SUM(hr9), SUM(hr10), SUM(hr11), SUM(hr12),
		--SUM(hr13), SUM(Hr14), SUM(hr15), SUM(hr16), SUM(hr17), SUM(hr18), SUM(hr19), SUM(hr20), SUM(hr21), SUM(hr22), SUM(hr23), SUM(hr24)
	INTO #weekly_table
	FROM hourly_block hb
	INNER JOIN dbo.FNASplit(@block_val_id, ',') bv ON bv.item = hb.block_value_id
	GROUP BY block_value_id, week_day

	IF OBJECT_ID('tempdb..#hourly_sum_table') IS NOT NULL DROP TABLE #hourly_sum_table

	SELECT SUM([all_hour_sum]) [hr_sum]
	INTO #hourly_sum_table
	FROM #weekly_table
	GROUP BY week_day

	SELECT @final_sum = SUM(hr_sum)
	FROM #hourly_sum_table
	GROUP BY hr_sum
	--HAVING SUM(hr_sum) = 7 * 24

	IF @final_sum = 7 * 24
	BEGIN
		IF @return_status = 1
		BEGIN
			SELECT @return_status = 1
		END
		ELSE
		BEGIN
			SELECT 1 AS [is_valid], @final_sum [final_sum]
		END
	END
	ELSE
	BEGIN
		IF @return_status = 1
			SELECT @return_status = 0
		ELSE
			SELECT 0 AS [is_valid], @final_sum [final_sum]
	END
END

GO