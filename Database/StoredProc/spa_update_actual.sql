IF OBJECT_ID(N'[dbo].[spa_update_actual]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_update_actual]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2016-11-22
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Operation Flag
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_update_actual]
    @flag CHAR(1),	
		@source_deal_header_id INT,
		@source_deal_detail_id INT = NULL,
		@term_start DATETIME = NULL,
		@term_end DATETIME = NULL,
		@hour_from INT = NULL,
		@hour_to INT = NULL,
		@process_id VARCHAR(300) = NULL,
		@leg INT = NULL,
		@xml XML = NULL,
		@granularity INT = NULL
AS

/*------------Debug Section-----------
DECLARE @flag CHAR(1),	
				@source_deal_header_id INT,
				@source_deal_detail_id INT = NULL,
				@term_start DATETIME = NULL,
				@term_end DATETIME = NULL,
				@hour_from INT = NULL,
				@hour_to INT = NULL,
				@process_id VARCHAR(300) = NULL,
				@leg INT = NULL,
				@xml XML = NULL,
				@granularity INT = NULL
SELECT @flag='v',@source_deal_header_id='8597',@source_deal_detail_id='209527',@process_id='7F5A0D50_438D_4912_9D99_D02269E83417',@granularity='981'
----------------------------------*/
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX),
				@desc VARCHAR(500),
				@err_no INT,
				@actual_granularity INT,
				@frequency CHAR(1),
				@max_leg INT,
				@column_list VARCHAR(MAX),
				@column_label VARCHAR(MAX),
				@column_type VARCHAR(MAX),
				@column_width VARCHAR(MAX),
				@column_visibility VARCHAR(MAX),
				@pivot_columns VARCHAR(MAX), 
				@pivot_columns_create VARCHAR(MAX), 
				@pivot_columns_update VARCHAR(MAX),
				@select_list VARCHAR(MAX),
				@dst_present INT,
				@show_only_first_hour INT,
				@max_term_end DATETIME,
				@min_term_start DATETIME,
				@deal_type_id INT,
				@pricing_type INT,
				@commodity_id INT,
				@dst_group_value_id INT,
        @dst_process_table INT,
				@dst_term DATETIME,
				@dst_hour VARCHAR(10)
		
SELECT @dst_group_value_id = tz.dst_group_value_id
FROM dbo.adiha_default_codes_values adcv
INNER JOIN time_zones tz 
	ON tz.timezone_id = adcv.var_value
WHERE adcv.instance_no = 1
	AND adcv.default_code_id = 36
	AND adcv.seq_no = 1

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID() 

DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
SELECT @max_term_end = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id
SELECT @min_term_start = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id

DECLARE @process_table VARCHAR(400) = dbo.FNAProcessTableName('actual_volume', @user_name, @process_id)

DECLARE @is_deal_commodity_gas BIT

IF @source_deal_detail_id IS NOT NULL
BEGIN
	-- Deal detail with gas commodity
	IF EXISTS (
		SELECT 1
		FROM source_deal_detail sdd
		INNER JOIN source_price_curve_def spcd 
			ON sdd.curve_id = spcd.source_curve_def_id
		WHERE source_deal_detail_id = @source_deal_detail_id
			AND commodity_id = -1
	)
	BEGIN
		SET @is_deal_commodity_gas = 1
	END
	ELSE
	BEGIN
		SET @is_deal_commodity_gas = 0
	END
END
ELSE
BEGIN
	-- Deal header with gas commodity
	IF EXISTS (
		SELECT 1
		FROM source_deal_header
		WHERE source_deal_header_id = @source_deal_header_id
			AND commodity_id = -1
	)
	BEGIN
		SET @is_deal_commodity_gas = 1
	END
	ELSE
	BEGIN
		SET @is_deal_commodity_gas = 0
	END
END

SELECT @deal_type_id = sdh.source_deal_type_id,
	     @pricing_type = sdh.pricing_type,
	     @commodity_id = sdh.commodity_id	   
FROM source_deal_header sdh
WHERE sdh.source_deal_header_id = @source_deal_header_id

--994 - 10Min, 987 - 15Min, 989 - 30Min, 993 - Annually, 981 - Daily, 982 - Hourly, 980 - Monthly, 991 - Quarterly, 992 - Semi-Annually, 990 - Weekly
SELECT @actual_granularity = ISNULL(@granularity, sdht.actual_granularity)
FROM source_deal_header sdh
INNER JOIN source_deal_header_template sdht On sdht.template_id = sdh.template_id
WHERE sdh.source_deal_header_id = @source_deal_header_id

IF EXISTS(SELECT 1 FROM deal_default_value WHERE deal_type_id = @deal_type_id AND commodity = @commodity_id AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type))
BEGIN
	SELECT @actual_granularity = COALESCE(@granularity, actual_granularity, @actual_granularity)
	FROM deal_default_value 
	WHERE deal_type_id = @deal_type_id 
	AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type)
	AND commodity = @commodity_id
END

IF @term_start IS NULL
BEGIN
	IF @source_deal_detail_id IS NOT NULL
		SELECT @term_start = term_start FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id
	ELSE
		SELECT @term_start = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id
END

IF @term_end IS NULL
BEGIN
	IF @source_deal_detail_id IS NOT NULL
		SELECT @term_end = term_end FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id
	ELSE
		SELECT @term_end = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id
END


IF OBJECT_ID(@process_table) IS NOT NULL AND @actual_granularity IS NOT NULL AND @flag = 's'
BEGIN
	SET @sql = 'SELECT @dst_process_table = MAX(dst_present) FROM ' + @process_table
	EXEC sp_executesql @sql, N'@dst_process_table INT output', @dst_process_table OUTPUT
	SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @process_table + ' WHERE granularity <> ' + CAST(@actual_granularity AS VARCHAR(20)) + ')
				BEGIN
					DROP TABLE ' + @process_table + '
				END'
	EXEC(@sql)
END


IF @max_term_end < @term_end
	SET @term_end = @max_term_end
IF @min_term_start > @term_start
	SET @term_start = @min_term_start


--a	Annually, d	Daily, h - Hourly, m - Monthly, q - Quarterly, s - Semi-Annually
SET @frequency = CASE WHEN @actual_granularity IN (981, 982, 989, 987, 994) THEN 'd' WHEN @actual_granularity = 980 THEN 'm' WHEN @actual_granularity = 991 THEN 'q' WHEN @actual_granularity = 992 THEN 's' WHEN @actual_granularity = 990 THEN 'w' END
SET @show_only_first_hour = CASE WHEN @actual_granularity IN (982, 989, 987, 994) THEN 0 ELSE 1 END

DECLARE @limit_term_end DATETIME
	
--a	Annually, d	Daily, h - Hourly, m - Monthly, q - Quarterly, s - Semi-Annually
IF @frequency = 'd'
	SET @limit_term_end = DATEADD(MONTH, DATEDIFF(MONTH, -1, DATEADD(month, 1, @term_start))-1, -1)
IF @frequency = 'm'
	SET @limit_term_end = DATEADD(month, 30, @term_start)
IF @frequency = 'w'
	SET @limit_term_end = DATEADD(week, 30, @term_start)
IF @frequency = 'q'
	SET @limit_term_end = DATEADD(quarter, 15, @term_start)
IF @frequency = 's'
	SET @limit_term_end = DATEADD(year, 15, @term_start)

IF OBJECT_ID('tempdb..#temp_actual_terms') IS NOT NULL
	DROP TABLE #temp_actual_terms

CREATE TABLE #temp_actual_terms (term_start DATETIME, is_dst INT)

;WITH cte_terms AS (
 	SELECT @term_start [term_start]
 	UNION ALL
 	SELECT dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1)
 	FROM cte_terms cte 
 	WHERE dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1) <= @term_end
) 
INSERT INTO #temp_actual_terms(term_start)
SELECT term_start
FROM cte_terms cte
option (maxrecursion 0)

DECLARE @baseload_block_type       VARCHAR(10),
		@baseload_block_define_id  VARCHAR(10)
		
SET @baseload_block_type = '12000'	-- Internal Static Data

SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10))
FROM   static_data_value
WHERE  [type_id] = 10018
		AND code LIKE 'Base Load' -- External Static Data

IF OBJECT_ID('tempdb..#temp_detail_ids') IS NOT NULL 
	DROP TABLE #temp_detail_ids
CREATE TABLE #temp_detail_ids (detail_id INT)

IF @source_deal_detail_id IS NOT NULL
BEGIN
	INSERT INTO #temp_detail_ids
	SELECT @source_deal_detail_id
END
ELSE
BEGIN
	INSERT INTO #temp_detail_ids
	SELECT sdd.source_deal_detail_id 
	FROM source_deal_detail sdd
	WHERE sdd.source_deal_header_id = @source_deal_header_id
END


--dst check
SELECT @dst_present =   CASE WHEN MAX(mv.id) IS NOT NULL THEN 1 ELSE 0 END,
	   @dst_term = CASE WHEN MAX(mv.id) IS NOT NULL THEN MAX(mv.date) ELSE NULL END,
	   @dst_hour = CASE WHEN MAX(mv.id) IS NOT NULL THEN MAX(mv.[hour]) ELSE NULL END,
	   @dst_group_value_id = MAX(tz.dst_group_value_id)
FROM #temp_actual_terms temp
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = @source_deal_header_id
INNER JOIN source_deal_detail sdd ON  sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN #temp_detail_ids t1 ON t1.detail_id = sdd.source_deal_detail_id
LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = sdd.curve_id
LEFT JOIN dbo.vwDealTimezone tz on  sdd.source_deal_header_id=tz.source_deal_header_id
	AND tz.curve_id=isnull(sdd.curve_id,-1)  and tz.location_id=isnull(sdd.location_id,-1) 
LEFT JOIN hour_block_term hbt 
	ON  hbt.block_define_id = COALESCE(spcd.block_define_id,sdh.block_define_id,  @baseload_block_define_id)
	AND hbt.block_type = COALESCE(spcd.block_type, sdh.block_type, @baseload_block_type)
	AND hbt.term_date = temp.term_start
	AND hbt.dst_group_value_id = tz.dst_group_value_id
LEFT JOIN mv90_DST mv ON  (hbt.term_date) = (mv.date)
	AND mv.insert_delete = 'i'
	AND hbt.dst_applies = 'y'
	AND mv.dst_group_value_id = tz.dst_group_value_id

--IF OBJECT_ID('tempdb..#temp_hours') IS NOT NULL
--	DROP TABLE #temp_hours

--;WITH cte_hours AS (
-- 	SELECT ISNULL(@hour_from, 0) [hrs]
-- 	UNION ALL
-- 	SELECT hrs + 1 [hrs]
-- 	FROM cte_hours cte 
-- 	WHERE hrs + 1 < ISNULL(@hour_to+1, 25)
--) 
--SELECT hrs 
--INTO #temp_hours
--FROM cte_hours
--WHERE (@dst_present = 1 OR (@dst_present = 0 AND hrs < 24))
--AND (@frequency = 'd' OR (@frequency <> 'd' AND hrs < 1))

IF @is_deal_commodity_gas = 1
BEGIN
	SET @dst_term = DATEADD(DAY, -1, @dst_term )
	SET @dst_hour = @dst_hour + 18
END

IF OBJECT_ID('tempdb..#temp_min_break') IS NOT NULL
	DROP TABLE #temp_min_break

CREATE TABLE #temp_min_break(granularity int, period tinyint, factor numeric(6,2))  

IF @actual_granularity IN (989, 987, 994)
BEGIN
	--select * from static_data_value where type_id  = 978
	INSERT INTO #temp_min_break (granularity, period, factor)
	VALUES (989,0,2), (989,30,2), -- 30Min
			(987,0,4),(987,15,4),(987,30,4),(987,45,4), -- 15Min
			(994,0,6), (994,10,6), (994,20,6), (994,30,6), (994,40,6), (994,50,6) --10Min
	
END 


IF @actual_granularity IN (982, 989, 987, 994, 995)
BEGIN
	IF OBJECT_ID('tempdb..#temp_hour_breakdown') IS NOT NULL
		DROP TABLE #temp_hour_breakdown

	SELECT clm_name, is_dst, alias_name, CASE WHEN is_dst = 0 THEN RIGHT('0' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '_' + RIGHT(clm_name, 2) ELSE RIGHT('0' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '_' + RIGHT(clm_name, 2) + '_DST' END [process_clm_name]
	INTO #temp_hour_breakdown 
	FROM dbo.FNAGetDisplacedPivotGranularityColumn(@term_start,@term_end,@actual_granularity,@dst_group_value_id,IIF(@is_deal_commodity_gas = 1,6,0))
	WHERE CAST (LEFT(alias_name,2) AS INT)> = ISNULL(@hour_from, 0) AND  CAST (LEFT(alias_name,2) AS INT)<=ISNULL(@hour_to, 25)
END


IF @dst_process_table IS NOT NULL 
BEGIN
	IF @dst_process_table = 0 AND @dst_present = 1
	BEGIN
		IF OBJECT_ID(@process_table) IS NOT NULL AND @flag = 's'
		BEGIN
			DECLARE @additional_columns VARCHAR(MAX)
			SELECT @additional_columns = COALESCE(@additional_columns + ',', '') + '[' + process_clm_name + '] NUMERIC(38, 20)  NULL'
			FROM #temp_hour_breakdown
			WHERE is_dst = 1
			
			SET @sql = ' ALTER TABLE ' + @process_table + ' ADD  ' + @additional_columns
			EXEC(@sql)
		END
	END
END

IF @flag = 's'
BEGIN

	IF OBJECT_ID('tempdb..#temp_deal_acutal_data') IS NOT NULL 
		DROP TABLE #temp_deal_acutal_data

	CREATE TABLE #temp_deal_acutal_data(source_deal_detail_id INT, leg INT, term_date DATETIME, hr VARCHAR(10) COLLATE DATABASE_DEFAULT , is_dst INT, volume NUMERIC(38, 20), actual_volume NUMERIC(38, 20), schedule_volume NUMERIC(38, 20), term_date_p VARCHAR(8) COLLATE DATABASE_DEFAULT)
	
	/** GENERATE terms and hours**/
	INSERT INTO #temp_deal_acutal_data(source_deal_detail_id, term_date, hr, is_dst, leg, term_date_p)
	SELECT source_deal_detail_id, term_date, RIGHT('0' + CAST(a.[Hours] AS VARCHAR(10)), 2) + ':' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) [hrs], DST is_dst, leg, CONVERT(VARCHAR(8), term_date, 112)
	FROM 
	(
		SELECT source_deal_detail_id,
			   term_date,
				CASE REPLACE(hr, 'hr', '')
					WHEN 25 THEN volume
					WHEN [DST_hour] THEN NULL
					ELSE REPLACE(hr, 'hr', '')
				END [Hours],
				CASE REPLACE(hr, 'hr', '')
					WHEN 25 THEN 1
					ELSE 0
				END DST,
				leg
		FROM   (
			SELECT sdd.source_deal_detail_id,  
					hbt.term_date,
					hbt.hr1,hbt.hr2,hbt.hr3,hbt.hr4,hbt.hr5,hbt.hr6,hbt.hr7,hbt.hr8,
					hbt.hr9,hbt.hr10,hbt.hr11,hbt.hr12,hbt.hr13,hbt.hr14,hbt.hr15,hbt.hr16,
					hbt.hr17,hbt.hr18,hbt.hr19,hbt.hr20,hbt.hr21,hbt.hr22,hbt.hr23,hbt.hr24,
					mv.[hour] [hr25], mv1.Hour [DST_hour],
					sdd.leg
			FROM #temp_actual_terms temp
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = @source_deal_header_id
			INNER JOIN source_deal_detail sdd ON  sdd.source_deal_header_id = sdh.source_deal_header_id
				AND temp.term_start BETWEEN sdd.term_start AND sdd.term_end
			INNER JOIN #temp_detail_ids t1 ON t1.detail_id = sdd.source_deal_detail_id
			LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = sdd.curve_id
			LEFT JOIN dbo.vwDealTimezone tz on  sdd.source_deal_header_id=tz.source_deal_header_id
				AND tz.curve_id=isnull(sdd.curve_id,-1)  and tz.location_id=isnull(sdd.location_id,-1) 
			LEFT JOIN hour_block_term hbt 
				ON  hbt.block_define_id = COALESCE(spcd.block_define_id,sdh.block_define_id,  @baseload_block_define_id)
				AND hbt.block_type = COALESCE(spcd.block_type, sdh.block_type, @baseload_block_type)
				AND hbt.term_date = temp.term_start
				AND hbt.dst_group_value_id = tz.dst_group_value_id
			LEFT JOIN mv90_DST mv ON  (hbt.term_date) = (mv.date)
				AND mv.insert_delete = 'i'
				AND hbt.dst_applies = 'y'
				AND mv.dst_group_value_id = tz.dst_group_value_id
			LEFT JOIN mv90_DST mv1 ON  (hbt.term_date) = (mv1.date)
				AND mv1.insert_delete = 'd'
				AND hbt.dst_applies = 'y'
				AND mv.dst_group_value_id = tz.dst_group_value_id
		) AS p
		UNPIVOT(
			volume FOR hr IN ([hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12], 
							[hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], 
							[hr23], [hr24], [hr25])
		) unpvt 
	) a
	LEFT JOIN #temp_min_break tm ON tm.granularity = @actual_granularity	
	WHERE (@show_only_first_hour = 0 OR (@show_only_first_hour = 1 AND a.[Hours] < 2))
	
	CREATE NONCLUSTERED INDEX NCI_TDAD_DEAL ON #temp_deal_acutal_data (source_deal_detail_id)
	CREATE NONCLUSTERED INDEX NCI_TDAD_TERM ON #temp_deal_acutal_data (term_date)
	CREATE NONCLUSTERED INDEX NCI_TDAD_HOUR ON #temp_deal_acutal_data (hr)
	
	SET @sql = '
		UPDATE temp 
		SET volume = sddh.volume,
			actual_volume = sddh.actual_volume,
			schedule_volume = sddh.schedule_volume,
			leg = ISNULL(sddh.leg, 1)
		FROM #temp_deal_acutal_data temp
		INNER JOIN (
			SELECT  sddh.source_deal_detail_id, sdd.leg, sddh.term_date, sddh.hr, sddh.is_dst, sddh.volume, sddh.actual_volume, sddh.schedule_volume, CONVERT(VARCHAR(8), sddh.term_date, 112) [term_date_p]
			FROM source_deal_detail_hour sddh
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
			WHERE sddh.term_date >= ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''' AND sddh.term_date <= ''' + CONVERT(VARCHAR(10), @term_end, 120) + '''
			AND CAST(LEFT(sddh.hr, 2) AS INT) >= ' + CAST(ISNULL(@hour_from+1, 1) AS VARCHAR(10)) + '
			AND CAST(LEFT(sddh.hr, 2) AS INT) < ' + CAST(ISNULL(@hour_to+1, 25) AS VARCHAR(10)) + '' 
			+ CASE WHEN @source_deal_detail_id IS NOT NULL THEN ' AND sddh.source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(10)) ELSE '' END
			+ CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10)) ELSE '' END
		+ ') sddh 
		ON sddh.source_deal_detail_id = temp.source_deal_detail_id
		AND sddh.term_date = temp.term_date
		AND sddh.hr = temp.hr'
	--PRINT(@sql)
	EXEC(@sql)

	/* Update Volume for DST hour*/
	UPDATE temp
	SET volume = sddh.volume,
		actual_volume = sddh.actual_volume,
		schedule_volume = sddh.schedule_volume
	FROM #temp_deal_acutal_data temp
	INNER JOIN source_deal_detail_hour sddh ON temp.source_deal_detail_id = sddh.source_deal_detail_id
		AND temp.term_date = sddh.term_date
		AND temp.is_dst = sddh.[is_dst]
		AND temp.[hr] = sddh.hr
	WHERE temp.is_dst = 1 

	/* show deal volume for non shaped deal*/
	UPDATE temp 
	SET volume = sdd.deal_volume
	FROM #temp_deal_acutal_data temp
	INNER JOIN source_deal_detail sdd ON temp.source_deal_detail_id = sdd.source_deal_detail_id
	INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE temp.volume IS NULL AND sdh.internal_desk_id <> 17302


	IF @actual_granularity IN (982, 989, 987, 994)
	BEGIN
		--SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) + ']',
		--		@pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) + '] NUMERIC(38, 20)  NULL',
		--		@pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) + '] = a.[' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) + ']'
		--FROM #temp_hours cte
		--LEFT JOIN #temp_min_break tm ON tm.granularity = @actual_granularity

		SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + process_clm_name + ']',
				@pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + process_clm_name + '] NUMERIC(38, 20)  NULL',
				@pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + process_clm_name + '] = a.[' + process_clm_name + ']'
		FROM #temp_hour_breakdown

		SET @sql = '
			CREATE TABLE ' + @process_table + '(
				source_deal_detail_id INT,
				leg INT,
				type CHAR(1),
				type_name VARCHAR(100),
				term_date DATETIME NULL,
				is_dst INT,
				dst_present INT,
				' + @pivot_columns_create + '
			)
			
			INSERT INTO ' + @process_table + ' (source_deal_detail_id, leg, type, type_name, term_date, is_dst, dst_present)
			SELECT sdd.source_deal_detail_id, sdd.leg, vol_type.type, vol_type.type_name, sdd.term_date, sdd.is_dst,'+ CAST(@dst_present AS VARCHAR(10)) + '
			FROM (
				SELECT source_deal_detail_id, leg, term_date, MAX(is_dst) is_dst
				FROM #temp_deal_acutal_data
				GROUP BY source_deal_detail_id, leg, term_date
			) sdd
			OUTER APPLY (
				SELECT ''a'' [type], ''Actual Volume'' [type_name] UNION ALL
				SELECT ''s'', ''Schedule Volume'' UNION ALL
				SELECT ''v'', ''Deal Volume'' 
			) vol_type
			'
		--PRINT(@sql)
		EXEC(@sql)

		SET @sql = '
			UPDATE temp
			SET ' + @pivot_columns_update + '
			FROM ' + @process_table + ' temp
			INNER JOIN 
			(
				SELECT source_deal_detail_id, term_date, ' + @pivot_columns + '
				FROM (
					SELECT source_deal_detail_id, term_date, REPLACE(hr, '':'', ''_'') + IIF(is_dst=1,''_DST'','''') hrs, volume
					FROM  #temp_deal_acutal_data temp
				) a			
				PIVOT (SUM(volume) FOR hrs IN (' + @pivot_columns + ') )unpvt
			) a ON temp.source_deal_detail_id = a.source_deal_detail_id 
				AND temp.term_date = a.term_date
				AND temp.[type] = ''v''
			'
		--PRINT(@sql)
		EXEC(@sql)

		SET @sql = '
			UPDATE temp
			SET ' + @pivot_columns_update + '
			FROM ' + @process_table + ' temp
			INNER JOIN 
			(
				SELECT source_deal_detail_id, term_date, ' + @pivot_columns + '
				FROM (
					SELECT source_deal_detail_id, term_date, REPLACE(hr, '':'', ''_'') + IIF(is_dst=1,''_DST'','''') hrs, actual_volume
					FROM  #temp_deal_acutal_data temp
				) a			
				PIVOT (SUM(actual_volume) FOR hrs IN (' + @pivot_columns + ') )unpvt
			) a ON temp.source_deal_detail_id = a.source_deal_detail_id 
				AND temp.term_date = a.term_date
				AND temp.[type] = ''a''
			'
		--PRINT(@sql)
		EXEC(@sql)

		SET @sql = '
			UPDATE temp
			SET ' + @pivot_columns_update + '
			FROM ' + @process_table + ' temp
			INNER JOIN 
			(
				SELECT source_deal_detail_id, term_date, ' + @pivot_columns + '
				FROM (
					SELECT source_deal_detail_id, term_date,REPLACE(hr, '':'', ''_'') + IIF(is_dst=1,''_DST'','''') hrs, schedule_volume
					FROM  #temp_deal_acutal_data temp
				) a			
				PIVOT (SUM(schedule_volume) FOR hrs IN (' + @pivot_columns + ') )unpvt
			) a ON temp.source_deal_detail_id = a.source_deal_detail_id 
				AND temp.term_date = a.term_date
				AND temp.[type] = ''s''
			'
		--PRINT(@sql)
		EXEC(@sql)
	END
	ELSE
	BEGIN
		SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + ']',
			   @pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] NUMERIC(38, 20)  NULL',
			   @pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] = a.[' + CONVERT(VARCHAR(8), term_start, 112) + ']'
		FROM #temp_actual_terms
		ORDER BY term_start		
			
		SET @sql = '
			CREATE TABLE ' + @process_table + '(
					source_deal_detail_id INT,
					leg INT,
					type CHAR(1),
					type_name VARCHAR(100),
					term_date DATETIME NULL,
					is_dst INT,
					dst_present INT,
					' + @pivot_columns_create + '
			)
			
			INSERT INTO ' + @process_table + ' (source_deal_detail_id, leg, type, type_name, is_dst, dst_present)
			SELECT sdd.source_deal_detail_id, sdd.leg, vol_type.type, vol_type.type_name, sdd.is_dst ' + ', ' + CAST(@dst_present AS VARCHAR(10)) + '
			FROM (
				SELECT source_deal_detail_id, leg, is_dst
				FROM #temp_deal_acutal_data				
				WHERE hr = ''01:00''
				GROUP BY source_deal_detail_id, leg, is_dst
			) sdd
			OUTER APPLY (
				SELECT ''a'' [type], ''Actual Volume'' [type_name] UNION ALL
				SELECT ''s'', ''Schedule Volume'' UNION ALL
				SELECT ''v'', ''Deal Volume'' 
			) vol_type
			'
		--PRINT(@sql)
		EXEC(@sql)

		SET @sql = '
			UPDATE temp
			SET ' + @pivot_columns_update + '
			FROM ' + @process_table + ' temp
			INNER JOIN 
			(
				SELECT source_deal_detail_id, ' + @pivot_columns + '
				FROM (
					SELECT source_deal_detail_id, term_date_p, volume
					FROM  #temp_deal_acutal_data temp 
					WHERE temp.hr = ''01:00''
				) a			
				PIVOT (SUM(volume) FOR term_date_p IN (' + @pivot_columns + ') )unpvt
			) a ON temp.source_deal_detail_id = a.source_deal_detail_id AND temp.[type] = ''v''
			'
		--PRINT(@sql)
		EXEC(@sql)

		SET @sql = '
			UPDATE temp
			SET ' + @pivot_columns_update + '
			FROM ' + @process_table + ' temp
			INNER JOIN 
			(
				SELECT source_deal_detail_id, ' + @pivot_columns + '
				FROM (
					SELECT source_deal_detail_id, term_date_p, actual_volume
					FROM  #temp_deal_acutal_data temp 
					WHERE temp.hr = ''01:00''
				) a			
				PIVOT (SUM(actual_volume) FOR term_date_p IN (' + @pivot_columns + ') )unpvt
			) a ON temp.source_deal_detail_id = a.source_deal_detail_id AND temp.[type] = ''a''
			'
		--PRINT(@sql)
		EXEC(@sql)

		SET @sql = '
			UPDATE temp
			SET ' + @pivot_columns_update + '
			FROM ' + @process_table + ' temp
			INNER JOIN 
			(
				SELECT source_deal_detail_id, ' + @pivot_columns + '
				FROM (
					SELECT source_deal_detail_id, term_date_p, schedule_volume
					FROM  #temp_deal_acutal_data temp 
					WHERE temp.hr = ''01:00''
				) a			
				PIVOT (SUM(schedule_volume) FOR term_date_p IN (' + @pivot_columns + ') )unpvt
			) a ON temp.source_deal_detail_id = a.source_deal_detail_id AND temp.[type] = ''s''
			'
		--PRINT(@sql)
		EXEC(@sql)

		SET @sql = 'UPDATE temp
					SET term_date = sdd.term_start
					FROM ' + @process_table + ' temp
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = temp.source_deal_detail_id
					'
		EXEC(@sql)
	END
	
	DECLARE @is_locked CHAR(1)
	SELECT @is_locked = ISNULL(deal_locked, 'n') FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id

	SELECT @max_leg = MAX(leg) FROM source_deal_detail where source_deal_header_id = @source_deal_header_id
	SELECT @actual_granularity [granularity],
		   @max_leg [max_leg],
		   @term_start [term_start],
		   CASE WHEN @limit_term_end < @term_end THEN @limit_term_end ELSE @term_end END [term_end],
		   @process_id [process_id],
		   dbo.FNADateFormat(@min_term_start) [min_term_start],
		   dbo.FNADateFormat(@max_term_end) [max_term_end],
		   @is_locked [is_locked],
		   dbo.FNADateFormat(@dst_term) [dst_term]
	RETURN
END

-- Returns Grid Definitions
IF @flag = 't'
BEGIN
    IF @actual_granularity IN (982, 989, 987, 994)
	BEGIN		
		SELECT @column_list = COALESCE(@column_list + ',', '') + process_clm_name,
			   @column_label = COALESCE(@column_label + ',', '') + alias_name,
			   @column_type = COALESCE(@column_type + ',', '') + 'ed_v',
			   @column_width = COALESCE(@column_width + ',', '') + '100',
			   @column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
		FROM #temp_hour_breakdown

		SET @column_list = 'source_deal_detail_id,leg,type,type_name,term_date,' + @column_list
		SET @column_label = 'Detail ID,Leg,Type,Type,Term Date,' + @column_label
		SET @column_type = 'ro,ro,ro,ro,ro_dhxCalendarA,' + @column_type
		SET @column_width = '100,50,10,100,100,' + @column_width
		SET @column_visibility = 'false,false,true,false,false,' + @column_visibility
	END
	ELSE
	BEGIN
		SELECT @column_list = COALESCE(@column_list + ',', '') + CONVERT(VARCHAR(8), term_start, 112),
			   @column_label = COALESCE(@column_label + ',', '') + dbo.FNADateFormat(term_start),
			   @column_type = COALESCE(@column_type + ',', '') + 'ed_v',
			   @column_width = COALESCE(@column_width + ',', '') + '150',
			   @column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
		FROM #temp_actual_terms		
		WHERE term_start <= @term_end

		SET @column_list = 'source_deal_detail_id,leg,type,type_name,' + @column_list
		SET @column_label = 'Detail ID,Leg,Type,Type,' + @column_label
		SET @column_type = 'ro,ro,ro,ro,' + @column_type
		SET @column_width = '100,50,10,100,' + @column_width
		SET @column_visibility = 'false,false,true,false,' + @column_visibility
	END

	SELECT @max_leg = MAX(leg) FROM source_deal_detail where source_deal_header_id = @source_deal_header_id

	SELECT @column_list [column_list],
		   @column_label [column_label],
		   @column_type [column_type],
		   @column_width [column_width],
		   @term_start [term_start],
		   @term_end [term_end],
		   @actual_granularity [granularity],
		   @max_leg [max_leg],
		   @column_visibility [visibility]
END
-- Returns data
IF @flag = 'a'
BEGIN
	IF @actual_granularity IN (982, 989, 987, 994)
	BEGIN
		SELECT @column_list = COALESCE(@column_list + ',', '') + 'dbo.FNARemoveTrailingZero([' + process_clm_name + ']) [' + process_clm_name + ']'
		FROM #temp_hour_breakdown
		SET @column_list = 'source_deal_detail_id,leg,type,type_name,term_date,' + @column_list
	END
	ELSE
	BEGIN
		SELECT @column_list = COALESCE(@column_list + ',', '') + 'dbo.FNARemoveTrailingZero([' + CONVERT(VARCHAR(8), term_start, 112) + ']) [' + CONVERT(VARCHAR(8), term_start, 112) + ']'
		FROM #temp_actual_terms
		WHERE term_start <= @term_end
		SET @column_list = 'source_deal_detail_id,leg,type,type_name,' + @column_list
	END

	SET @sql = 'SELECT ' + @column_list + ' FROM ' + @process_table + ' WHERE term_date >= ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''' AND term_date <= ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''''
	
	IF @leg IS NOT NULL
		SET @sql += ' AND leg = ' + CAST(@leg AS VARCHAR(10))
	
	SET @sql += ' ORDER BY term_date'
	--PRINT(@sql)
	EXEC(@sql)
END
IF @flag = 'u'
BEGIN
	BEGIN TRY
		IF @xml IS NOT NULL
 		BEGIN
 			DECLARE @xml_process_table VARCHAR(200)
 			SET @xml_process_table = dbo.FNAProcessTableName('xml_table', @user_name, dbo.FNAGetNewID())
 		
 			EXEC spa_parse_xml_file 'b', NULL, @xml, @xml_process_table

			IF OBJECT_ID('tempdb..#temp_header_columns') IS NOT NULL
 				DROP TABLE #temp_header_columns
 		
 			CREATE TABLE #temp_header_columns (
 				columns_name VARCHAR(200) COLLATE DATABASE_DEFAULT ,
 				columns_value VARCHAR(8000) COLLATE DATABASE_DEFAULT 
 			)
 		
 			DECLARE @table_name varchar(200) = REPLACE(@xml_process_table, 'adiha_process.dbo.', '')
 			DECLARE @sum_column VARCHAR(MAX)
 			INSERT INTO #temp_header_columns	
 			EXEC spa_Transpose @table_name, NULL, 1
		
			IF @actual_granularity IN (982, 989, 987, 994)
			BEGIN
				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + process_clm_name + '] = CAST(NULLIF(temp.[col_' + process_clm_name + '], '''') AS NUMERIC(38,20))',
					   @sum_column = COALESCE(@sum_column + '+', '') + 'ISNULL([' + process_clm_name + '], 0)'
				FROM #temp_hour_breakdown
				INNER JOIN (SELECT DISTINCT columns_name FROM #temp_header_columns) temp ON temp.columns_name = 'col_' + process_clm_name
			END
			ELSE
			BEGIN
				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] = CAST(NULLIF(temp.[col_' + + CONVERT(VARCHAR(8), term_start, 112) + '], '''') AS NUMERIC(38, 20))'
				FROM #temp_actual_terms tat
				INNER JOIN (SELECT DISTINCT columns_name FROM #temp_header_columns) temp ON temp.columns_name = 'col_' + + CONVERT(VARCHAR(8), term_start, 112)
			END

			SET @sql = '
				UPDATE pt 
				SET ' + @column_list + '
				FROM ' + @process_table + ' pt
				INNER JOIN ' + @xml_process_table + ' temp 
					ON pt.source_deal_detail_id = temp.col_source_deal_detail_id
					AND pt.[type] = temp.col_type			
			'

			IF @actual_granularity IN (982, 989, 987, 994)
				SET @sql += ' AND pt.term_date = temp.col_term_date'
		END
		EXEC(@sql)

		--EXEC('select * from ' +@process_table ) 
	
		EXEC('DROP TABLE ' + @xml_process_table)

		EXEC spa_ErrorHandler 0
			, 'source_deal_detail_hour'
			, 'spa_update_actual'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to save Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'table_name'
		   , 'spa_name'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
	
END
IF @flag = 'v' -- save data from process table to main table
BEGIN
	BEGIN TRY
	BEGIN TRAN
		IF OBJECT_ID(@process_table) IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..#temp_source_deal_detail_hour') IS NOT NULL
				DROP TABLE #temp_source_deal_detail_hour

			CREATE TABLE #temp_source_deal_detail_hour(source_deal_detail_id INT, term_date DATETIME, hr VARCHAR(20) COLLATE DATABASE_DEFAULT , is_dst INT, actual_volume NUMERIC(38, 20), schedule_volume NUMERIC(38, 20), deal_volume NUMERIC(38, 20))

			IF OBJECT_ID('tempdb..#temp_inserted_updated_deal') IS NOT NULL
				DROP TABLE #temp_inserted_updated_deal
			CREATE TABLE #temp_inserted_updated_deal(source_deal_detail_id INT)

			DECLARE @select_statement VARCHAR(MAX)
			DECLARE @select_statement2 VARCHAR(MAX)
			DECLARE @select_statement3 VARCHAR(MAX)
			DECLARE @for_statement VARCHAR(MAX)
			DECLARE @on_statement VARCHAR(MAX)

			IF @actual_granularity IN (982, 989, 987, 994)
			BEGIN	
			    SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + process_clm_name + ']',
					   @select_list = COALESCE(@select_list + ',', '') + 'ISNULL([' + process_clm_name + '], 0) [' + process_clm_name + ']'
				FROM #temp_hour_breakdown


				SET @select_statement = 'SELECT source_deal_detail_id, term_date, NULLIF(actual_volume,0) [actual_volume], NULL schedule_volume, REPLACE(REPLACE(hrs, ''_DST'', ''''), ''_'', '':'') hr, IIF(RIGHT(hrs, 4)=''_DST'', 1, 0) is_dst'
				SET @select_statement2 = 'SELECT source_deal_detail_id, term_date, NULLIF(schedule_volume,0) [schedule_volume], REPLACE(REPLACE(hrs, ''_DST'', ''''), ''_'', '':'') hr, IIF(RIGHT(hrs, 4)=''_DST'', 1, 0) is_dst'
				SET @select_statement3 = 'SELECT source_deal_detail_id, term_date, NULLIF(deal_volume,0) [deal_volume], REPLACE(REPLACE(hrs, ''_DST'', ''''), ''_'', '':'') hr, IIF(RIGHT(hrs, 4)=''_DST'', 1, 0) is_dst'
				
				SET @for_statement = 'hrs'
			END
			ELSE
			BEGIN
				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + ']',
					   @select_list = COALESCE(@select_list + ',', '') + 'ISNULL([' + CONVERT(VARCHAR(8), term_start, 112) + '],0) [' + CONVERT(VARCHAR(8), term_start, 112) + ']'
				FROM #temp_actual_terms tat

				SET @select_statement = 'SELECT source_deal_detail_id, term_date2, NULLIF(actual_volume,0) [actual_volume], NULL schedule_volume, ''01:00'' hr, 0'
				SET @select_statement2 = 'SELECT source_deal_detail_id, term_date2 term_date, schedule_volume [schedule_volume], ''01:00'' hr, 0 is_dst'
				SET @select_statement3 = 'SELECT source_deal_detail_id, term_date2 term_date, deal_volume [deal_volume], ''01:00'' hr, 0 is_dst'
				SET @for_statement = 'term_date2'
			END

			SET @sql = '
					INSERT INTO #temp_source_deal_detail_hour(source_deal_detail_id, term_date, actual_volume, schedule_volume, [hr], is_dst)
					' + @select_statement + '
					FROM (
						SELECT source_deal_detail_id, term_date, ' + @select_list + '
						FROM ' + @process_table + '  WHERE [type] = ''a''
					) tmp
					UNPIVOT (
						actual_volume
						FOR ' + @for_statement + '
						IN (
							' + @column_list + '
						) 
					) unpvt

				  UPDATE temp
					SET schedule_volume = NULLIF(unpvt.schedule_volume, ''0'') 
					--SELECT temp.schedule_volume, unpvt.schedule_volume
					FROM #temp_source_deal_detail_hour temp
					INNER JOIN (
						' + @select_statement2 + '
						FROM (
							SELECT source_deal_detail_id, term_date, ' + @select_list + '
							FROM ' + @process_table + ' WHERE [type] = ''s''
						) tmp
						UNPIVOT (
							schedule_volume
							FOR ' + @for_statement + '
							IN (
								' + @column_list + '
							) 
						) unpvt
					) unpvt
					ON unpvt.source_deal_detail_id = temp.source_deal_detail_id
					AND unpvt.Term_date = temp.term_date
					AND unpvt.hr = temp.hr

					-- Update Deal Volume
					UPDATE temp
					SET deal_volume = NULLIF(unpvt.deal_volume, ''0'') 
					--SELECT temp.deal_volume, unpvt.deal_volume
					FROM #temp_source_deal_detail_hour temp
					INNER JOIN (
						' + @select_statement3 + '
						FROM (
							SELECT source_deal_detail_id, term_date, ' + @select_list + '
							FROM ' + @process_table + ' WHERE [type] = ''v''
						) tmp
						UNPIVOT (
							deal_volume
							FOR ' + @for_statement + '
							IN (
								' + @column_list + '
							) 
						) unpvt
					) unpvt
					ON unpvt.source_deal_detail_id = temp.source_deal_detail_id
					AND unpvt.Term_date = temp.term_date
					AND unpvt.hr = temp.hr
				'
			EXEC(@sql)
			IF @dst_term IS NOT NULL
			BEGIN				
				DELETE 
				FROM #temp_source_deal_detail_hour
				WHERE term_date <> @dst_term
				AND is_dst = 1
			END

			
			UPDATE sddh
			SET actual_volume = temp.actual_volume,
				schedule_volume = temp.schedule_volume,
				volume = temp.deal_volume,
				granularity = @actual_granularity
			OUTPUT INSERTED.source_deal_detail_id INTO #temp_inserted_updated_deal(source_deal_detail_id)
			FROM source_deal_detail_hour sddh
			INNER JOIN #temp_source_deal_detail_hour temp
				ON temp.source_deal_detail_id = sddh.source_deal_detail_id
				AND temp.term_date = sddh.term_date
				AND temp.hr = sddh.hr
				AND temp.is_dst = sddh.is_dst
				--AND sddh.granularity = @actual_granularity			
			INNER JOIN source_deal_detail sdd 
				ON sdd.source_deal_detail_id = temp.source_deal_detail_id
				AND temp.term_date BETWEEN sdd.term_start AND sdd.term_end
			WHERE (ISNULL(sddh.actual_volume, -1) <> ISNULL(temp.actual_volume, -1)
			OR ISNULL(sddh.schedule_volume, -1) <> ISNULL(temp.schedule_volume, -1)
			OR ISNULL(sddh.volume, -1) <> ISNULL(temp.deal_volume, -1))
			
			INSERT INTO source_deal_detail_hour (source_deal_detail_id, term_date, hr,is_dst, actual_volume, schedule_volume, granularity, volume)
			OUTPUT INSERTED.source_deal_detail_id INTO #temp_inserted_updated_deal(source_deal_detail_id)
			SELECT temp.source_deal_detail_id, temp.term_date, temp.hr,  temp.is_dst, temp.actual_volume, temp.schedule_volume, @actual_granularity, temp.deal_volume
			FROM #temp_source_deal_detail_hour temp
			INNER JOIN source_deal_detail sdd 
				ON sdd.source_deal_detail_id = temp.source_deal_detail_id
				AND temp.term_date BETWEEN sdd.term_start AND sdd.term_end
			LEFT JOIN source_deal_detail_hour sddh
				ON temp.source_deal_detail_id = sddh.source_deal_detail_id
				AND temp.term_date = sddh.term_date
				AND temp.hr = sddh.hr
				AND temp.is_dst = sddh.is_dst
				--AND sddh.granularity = @actual_granularity
			WHERE sddh.source_deal_detail_id IS NULL
			
			UPDATE sdd
			SET schedule_volume = sddh.schedule_volume,
				actual_volume = sddh.actual_volume,
				deal_volume = sddh.volume
			FROM source_deal_detail sdd 
			INNER JOIN #temp_source_deal_detail_hour temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
			OUTER APPLY (
				SELECT SUM(sddh.schedule_volume) schedule_volume, SUM(sddh.actual_volume) actual_volume, SUM(sddh.volume) volume
				FROM source_deal_detail_hour sddh 
				WHERE sddh.source_deal_detail_id = sdd.source_deal_detail_id
			) sddh

			/*
			IF EXISTS(SELECT 1 FROM #temp_inserted_updated_deal)
			BEGIN
				DECLARE @_process_id NVARCHAR(500) = dbo.FNAGetNewID()
				DECLARE @_report_position_deals NVARCHAR(600)

				SET @_report_position_deals = dbo.FNAProcessTableName('report_position', @user_name, @_process_id)

				DECLARE @_sql NVARCHAR(MAX)
				SET @_sql = '
					SELECT sdd.source_deal_header_id [source_deal_header_id], ''u'' [action]
					INTO ' + @_report_position_deals + '
					FROM source_deal_detail sdd
					INNER JOIN #temp_inserted_updated_deal temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
					GROUP BY sdd.source_deal_header_id
				'
				EXEC(@_sql)

				DECLARE @_pos_job_name VARCHAR(200) =  'calc_position_breakdown_' + @_process_id
				SET @_sql = 'spa_calc_deal_position_breakdown NULL,''' + @_process_id + ''''
				EXEC spa_run_sp_as_job @_pos_job_name,  @_sql, 'Position Calculation', @user_name
			END
			*/
		END

		COMMIT
		EXEC spa_ErrorHandler 0
			, 'source_deal_detail_hour'
			, 'spa_update_actual'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to save Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'source_deal_detail_hour'
		   , 'spa_update_actual'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
	
END
