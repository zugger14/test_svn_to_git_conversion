IF OBJECT_ID(N'[dbo].[spa_update_actual_meter]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_update_actual_meter]
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
-- @flag CHAR(1)- Operation Flag
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_update_actual_meter]
	@flag CHAR(1),	
	@source_deal_header_id INT,
	@source_deal_detail_id INT = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@process_id VARCHAR(300) = NULL,
	@channel INT = NULL,
	@xml XML = NULL,
	@meter_ids VARCHAR(MAX) = NULL,
	@location_id INT = NULL,
	@meter_id INT = NULL -- Added this parameter to use on flag b and c
AS
/*-------------Debug Section----------------
DECLARE @flag CHAR(1),	
				@source_deal_header_id INT,
				@source_deal_detail_id INT = NULL,
				@term_start DATETIME = NULL,
				@term_end DATETIME = NULL,
				@hour_from INT = NULL,
				@hour_to INT = NULL,
				@process_id VARCHAR(300) = NULL,
				@channel INT = NULL,
				@xml XML = NULL,
				@meter_ids VARCHAR(MAX) = NULL,
				@location_id INT = NULL

SELECT @flag='a',@source_deal_header_id=NULL,@source_deal_detail_id=NULL,@meter_ids=119,@term_start='2018-11-01',@term_end='2018-11-30',@hour_from=NULL,@hour_to=NULL,@process_id='93358A2D_4766_4752_9F21_9818ED2F0EF8',@channel='1'
-------------------------------------------*/
SET NOCOUNT ON
 
DECLARE @sql VARCHAR(MAX),
 	@desc VARCHAR(500),
 	@err_no INT,
 	@actual_granularity INT,
 	@frequency CHAR(1),
 	@max_channel INT,
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
	@dst_term DATETIME,
	@granularity INT

IF @meter_ids IS NOT NULL
BEGIN
	SELECT @granularity = granularity FROM meter_id mi WHERE mi.meter_id = @meter_ids
END
ELSE
BEGIN
	SELECT @granularity = ISNULL(mi1.granularity, mi.granularity)
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
	LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sml.source_minor_location_id
	LEFT JOIN meter_id mi ON mi.meter_id = smlm.meter_id
	LEFT JOIN meter_id mi1 ON mi1.meter_id = sdd.meter_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
		AND sdd.source_deal_detail_id = @source_deal_detail_id
END

SELECT @dst_group_value_id = tz.dst_group_value_id
	FROM dbo.adiha_default_codes_values adcv
		INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
	WHERE adcv.instance_no = 1
	AND adcv.default_code_id = 36
	AND adcv.seq_no = 1

IF OBJECT_ID('tempdb..#temp_deal_meter_ids') IS NOT NULL
	DROP TABLE #temp_deal_meter_ids
 
CREATE TABLE #temp_deal_meter_ids(source_deal_detail_id INT, location_id INT, meter_id INT, meter_name VARCHAR(500) COLLATE DATABASE_DEFAULT , channel INT, term_start DATETIME, term_end DATETIME)
 
IF @meter_ids IS NOT NULL
BEGIN
	INSERT INTO #temp_deal_meter_ids(source_deal_detail_id, location_id, meter_id, meter_name, channel, term_start, term_end)
	SELECT @source_deal_detail_id [source_deal_detail_id],
		ISNULL(smlm.source_minor_location_id, @location_id) [location_id],
		mi.meter_id,
		mi.recorderid [meter_name],
		rp.channel,
		MAX(sdd.term_start) [term_start],
		MAX(sdd.term_end) [term_end]
	FROM meter_id mi
	LEFT JOIN source_minor_location_meter smlm ON smlm.meter_id = mi.meter_id
	INNER JOIN recorder_properties rp ON rp.meter_id = mi.meter_id
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = @source_deal_detail_id
	WHERE mi.meter_id = @meter_ids
	GROUP BY mi.meter_id, mi.recorderid, rp.channel, smlm.source_minor_location_id
END
ELSE
BEGIN
	SET @sql = '
			INSERT INTO #temp_deal_meter_ids(source_deal_detail_id, location_id, meter_id, meter_name, channel, term_start, term_end)
			SELECT sdd.source_deal_detail_id, sdd.location_id, sdd.meter_id, mi.recorderid, ' + CAST(ISNULL(@channel, 1) AS VARCHAR(20)) + ', MIN(sdd.term_start), MAX(sdd.term_end)	
			FROM source_deal_detail sdd
			INNER JOIN meter_id mi ON mi.meter_id = sdd.meter_id
			WHERE 1 = 1
			AND sdd.meter_id IS NOT NULL
			'
				
	IF @source_deal_header_id IS NOT NULL
		SET @sql += ' AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(20))
	
	IF @source_deal_detail_id IS NOT NULL
		SET @sql += ' AND sdd.source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(20))
 
	SET @sql += ' GROUP BY sdd.source_deal_detail_id, sdd.location_id, sdd.meter_id, mi.recorderid'
	
	EXEC(@sql)
	
	SET @sql = '
			INSERT INTO #temp_deal_meter_ids(source_deal_detail_id, location_id, meter_id, meter_name, channel, term_start, term_end)
			SELECT sdd.source_deal_detail_id, sdd.location_id, smlm.meter_id, mi.recorderid, rp.channel, MIN(sdd.term_start), MAX(sdd.term_end)
			FROM source_deal_detail sdd
			INNER JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sdd.location_id
			INNER JOIN meter_id mi ON mi.meter_id = smlm.meter_id
			INNER JOIN recorder_properties rp ON rp.meter_id = mi.meter_id
			LEFT JOIN #temp_deal_meter_ids t1 ON t1.location_id = sdd.location_id
			WHERE 1 = 1
			AND sdd.meter_id IS NULL
			AND t1.location_id IS NULL
			'
				
	IF @source_deal_header_id IS NOT NULL
		SET @sql += ' AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(20))
	
	IF @source_deal_detail_id IS NOT NULL
		SET @sql += ' AND sdd.source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(20))
 
	SET @sql += ' GROUP BY sdd.source_deal_detail_id, sdd.location_id, smlm.meter_id, mi.recorderid, rp.channel'
		
	EXEC(@sql)
END

IF @source_deal_header_id IS NULL AND @source_deal_detail_id IS NULL AND @location_id IS NOT NULL
BEGIN
	SELECT @meter_ids = ISNULL(@meter_ids + ',', '') + CAST(meter_id AS VARCHAR(10))
	FROM source_minor_location_meter
	WHERE source_minor_location_id = @location_id
	
	DELETE FROM #temp_deal_meter_ids
	
	INSERT INTO #temp_deal_meter_ids(source_deal_detail_id, location_id, meter_id, meter_name, channel, term_start, term_end)
	SELECT NULL source_deal_detail_id, NULL location_id, smlm.meter_id, mi.recorderid, rp.channel, @term_start, @term_end
	FROM source_minor_location_meter smlm
	INNER JOIN meter_id mi ON mi.meter_id = smlm.meter_id
	INNER JOIN recorder_properties rp ON rp.meter_id = mi.meter_id
	INNER JOIN (SELECT TOP (1) item FROM dbo.SplitCommaSeperatedValues(@meter_ids)) i ON i.item = mi.meter_id
	GROUP BY smlm.source_minor_location_id, smlm.meter_id, mi.recorderid, rp.channel
END	

IF EXISTS(SELECT 1 FROM #temp_deal_meter_ids WHERE meter_id IS NULL) AND @flag <> 'u' AND @flag <> 'v'
BEGIN
	IF @source_deal_detail_id IS NOT NULL
 		SET @desc = 'Please map meter.'
	ELSE 
 		SET @desc = 'Some of the details in deal do not have meter mapped. Please map meter to all detail.'
 		
	EXEC spa_ErrorHandler -1
 			, 'table_name'
 			, 'spa_name'
 			, 'Error'
 			, @desc
 			, ''
	RETURN
END
 
IF EXISTS(SELECT 1 FROM #temp_deal_meter_ids WHERE channel IS NULL) AND @flag <> 'u' AND @flag <> 'v'
BEGIN
	IF @source_deal_detail_id IS NOT NULL
 		SET @desc = 'Please select channel.'
	ELSE 
 		SET @desc = 'Some of the meter do not have channel. Please correct the meter.'
 		
	EXEC spa_ErrorHandler -1
 			, 'table_name'
 			, 'spa_name'
 			, 'Error'
 			, @desc
 			, ''
	RETURN
END

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID() 
 	
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
 
DECLARE @process_table VARCHAR(400) = dbo.FNAProcessTableName('meter_volume', @user_name, @process_id)
 
SELECT @deal_type_id = sdh.source_deal_type_id,
       @pricing_type     = sdh.pricing_type,
       @commodity_id     = sdh.commodity_id
FROM   source_deal_header sdh
WHERE sdh.source_deal_header_id = @source_deal_header_id

SELECT TOP(1) @actual_granularity = ISNULL(@granularity, mi.granularity)
FROM #temp_deal_meter_ids t1
INNER JOIN meter_id mi ON t1.meter_id = mi.meter_id
INNER JOIN (SELECT TOP (1) item FROM dbo.SplitCommaSeperatedValues(@meter_ids)) i ON i.item = mi.meter_id

--994 - 10Min, 987 - 15Min, 989 - 30Min, 993 - Annually, 981 - Daily, 982 - Hourly, 980 - Monthly, 991 - Quarterly, 992 - Semi-Annually, 990 - Weekly
IF EXISTS(SELECT 1 FROM deal_default_value WHERE deal_type_id = @deal_type_id AND commodity = @commodity_id AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type))
BEGIN
	SELECT @actual_granularity = COALESCE(@granularity, @actual_granularity, actual_granularity)
	FROM deal_default_value 
	WHERE deal_type_id = @deal_type_id 
	AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type)
	AND commodity = @commodity_id
END

SELECT @actual_granularity = COALESCE(@granularity, @actual_granularity, sdht.actual_granularity)
FROM source_deal_header sdh
INNER JOIN source_deal_header_template sdht On sdht.template_id = sdh.template_id
WHERE sdh.source_deal_header_id = @source_deal_header_id
 
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
 
IF @source_deal_detail_id IS NULL
BEGIN	
	SELECT @max_term_end = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id
	SELECT @min_term_start = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id
END
ELSE
BEGIN
	SET @max_term_end = @term_end
	SET @min_term_start = @term_start
END
 
IF @max_term_end < @term_end
	SET @term_end = @max_term_end
IF @min_term_start > @term_start
	SET @term_start = @min_term_start
 
--a	Annually, d	Daily, h - Hourly, m - Monthly, q - Quarterly, s - Semi-Annually
SET @frequency = CASE WHEN @actual_granularity IN (981, 982, 989, 987, 994, 995) THEN 'd' WHEN @actual_granularity = 980 THEN 'm' WHEN @actual_granularity = 991 THEN 'q' WHEN @actual_granularity = 992 THEN 's' WHEN @actual_granularity = 990 THEN 'w' END
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
 
IF OBJECT_ID('tempdb..#temp_meter_terms') IS NOT NULL
	DROP TABLE #temp_meter_terms
 
CREATE TABLE #temp_meter_terms (term_start DATETIME, is_dst INT)
 
;WITH cte_terms AS (
	SELECT @term_start [term_start]
	UNION ALL
	SELECT dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1)
	FROM cte_terms cte 
	WHERE dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1) <= @term_end
) 
INSERT INTO #temp_meter_terms(term_start)
SELECT term_start
FROM cte_terms cte
OPTION (maxrecursion 0)
 
DECLARE @baseload_block_type VARCHAR(10),
	@baseload_block_define_id VARCHAR(10)
 		
SET @baseload_block_type = '12000'	-- Internal Static Data
 
SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10))
FROM static_data_value
WHERE [type_id] = 10018
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
SELECT @dst_present = CASE WHEN MAX(mv.id) IS NOT NULL THEN 1 ELSE 0 END,
@dst_term = CASE WHEN MAX(mv.id) IS NOT NULL THEN MAX(mv.date) ELSE NULL END
FROM #temp_meter_terms temp
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = @source_deal_header_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN #temp_detail_ids t1 ON t1.detail_id = sdd.source_deal_detail_id
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
LEFT JOIN dbo.vwDealTimezone tz on  sdd.source_deal_header_id=tz.source_deal_header_id
	AND tz.curve_id=isnull(sdd.curve_id,-1) AND tz.location_id=isnull(sdd.location_id,-1) 
LEFT JOIN hour_block_term hbt 
	ON hbt.block_define_id = COALESCE(spcd.block_define_id,sdh.block_define_id,@baseload_block_define_id)
	AND hbt.block_type = COALESCE(spcd.block_type, sdh.block_type, @baseload_block_type)
	AND hbt.term_date = temp.term_start
	AND hbt.dst_group_value_id = tz.dst_group_value_id
LEFT JOIN mv90_DST mv 
	ON(hbt.term_date) = (mv.date)
	AND mv.insert_delete = 'i'
	AND hbt.dst_applies = 'y'
	AND mv.dst_group_value_id = tz.dst_group_value_id
 
IF OBJECT_ID('tempdb..#temp_hours') IS NOT NULL
	DROP TABLE #temp_hours
 
--;WITH cte_hours AS (
--	SELECT ISNULL(@hour_from, 0) [hrs]
--	UNION ALL
--	SELECT hrs + 1 [hrs]
--	FROM cte_hours cte 
--	WHERE hrs + 1 < ISNULL(@hour_to+1, 25)
--) 
--SELECT hrs 
--INTO #temp_hours
--FROM cte_hours
--WHERE (@dst_present = 1 OR (@dst_present = 0 AND hrs < 24))
--AND (@frequency = 'd' OR (@frequency <> 'd' AND hrs < 1))

IF @actual_granularity IN (982, 989, 987, 994, 995)
BEGIN
	IF OBJECT_ID('tempdb..#temp_hour_breakdown') IS NOT NULL
		DROP TABLE #temp_hour_breakdown

	SELECT clm_name, is_dst, alias_name, CASE WHEN is_dst = 0 THEN RIGHT('0' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '_' + RIGHT(clm_name, 2) ELSE '25' + '_' + RIGHT(clm_name, 2) END [process_clm_name]
	INTO #temp_hour_breakdown 
	FROM dbo.FNAGetPivotGranularityColumn(@term_start,@term_end,@actual_granularity,@dst_group_value_id) 
	WHERE CAST (LEFT(alias_name,2) AS INT)> = ISNULL(@hour_from, 0) AND  CAST (LEFT(alias_name,2) AS INT)<=ISNULL(@hour_to, 25)
END

IF OBJECT_ID('tempdb..#temp_min_break') IS NOT NULL
	DROP TABLE #temp_min_break
 
CREATE TABLE #temp_min_break(granularity int, period tinyint, factor numeric(6,2))
 
IF @actual_granularity IN (989, 994, 995, 987)
BEGIN
	INSERT INTO #temp_min_break (granularity, period, factor)
	VALUES (989,0,2), (989,30,2), -- 30Min
 			(987,0,4),(987,15,4),(987,30,4),(987,45,4), -- 15Min
 			(994,0,6), (994,10,6), (994,20,6), (994,30,6), (994,40,6), (994,50,6), --10Min
 			(995,0,12), (995,5,12), (995,10,12), (995,15,12), (995,20,12), (995,25,12), (995,30,12), (995,35,12), (995,40,12), (995,45,12), (995,50,12), (995,55,12) --5Min
END 
 
IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#temp_deal_acutal_meter_data') IS NOT NULL 
 		DROP TABLE #temp_deal_acutal_meter_data
 	
	CREATE TABLE #temp_deal_acutal_meter_data(
		id                        INT IDENTITY(1, 1),
		source_deal_detail_id     INT,
		meter_id                  INT,
		meter                     VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		channel                   INT,
		meter_data_id             INT,
		gen_date                  DATETIME,
		from_date                 DATETIME,
		to_date                   DATETIME,
		prod_date                 DATETIME,
		period                    INT,
	)
 	
	--994 - 10Min, 987 - 15Min, 989 - 30Min, 993 - Annually, 981 - Daily, 982 - Hourly, 980 - Monthly, 991 - Quarterly, 992 - Semi-Annually, 990 - Weekly
	IF @actual_granularity IN (982, 989, 994, 995, 987)
	BEGIN
 		ALTER TABLE #temp_deal_acutal_meter_data
 		ADD	
 			Hr1 FLOAT, Hr2 FLOAT, Hr3 FLOAT, Hr4 FLOAT, Hr5 FLOAT, Hr6 FLOAT, Hr7 FLOAT, Hr8 FLOAT, Hr9 FLOAT, Hr10 FLOAT,
 			Hr11 FLOAT, Hr12 FLOAT, Hr13 FLOAT, Hr14 FLOAT, Hr15 FLOAT, Hr16 FLOAT, Hr17 FLOAT, Hr18 FLOAT, Hr19 FLOAT, Hr20 FLOAT,
 			Hr21 FLOAT, Hr22 FLOAT, Hr23 FLOAT, Hr24 FLOAT, Hr25 FLOAT
	END
	ELSE
	BEGIN
 		ALTER TABLE #temp_deal_acutal_meter_data ADD volume FLOAT
	END
 	
	INSERT INTO #temp_deal_acutal_meter_data (
 		source_deal_detail_id, meter_id, meter, channel, gen_date, from_date, to_date, prod_date, period
	)	
	SELECT t1.source_deal_detail_id,
 			t1.meter_id,
 			mi.recorderid,
 			t1.channel,
 			dbo.FNAGetFirstLastDayOfMonth(t2.term_start, 'f'),
 			dbo.FNAGetFirstLastDayOfMonth(t2.term_start, 'f'),
 			dbo.FNAGetFirstLastDayOfMonth(t2.term_start, 'l'),
 			t2.term_start,
 			t3.period
	FROM #temp_deal_meter_ids t1
	INNER JOIN meter_id mi ON t1.meter_id = mi.meter_id
	OUTER APPLY (SELECT * FROM #temp_meter_terms WHERE term_start BETWEEN t1.term_start AND t1.term_end) t2
	LEFT JOIN #temp_min_break t3 ON t3.granularity = @actual_granularity

	IF @actual_granularity IN (982, 989, 994, 995, 987)
	BEGIN
 		UPDATE t1
 		SET meter_data_id = md.meter_data_id,
 			Hr1 = mdh.Hr1,
 			Hr2 = mdh.Hr2,
 			Hr3 = mdh.Hr3,
 			Hr4 = mdh.Hr4,
 			Hr5 = mdh.Hr5,
 			Hr6 = mdh.Hr6,
 			Hr7 = mdh.Hr7,
 			Hr8 = mdh.Hr8,
 			Hr9 = mdh.Hr9,
 			Hr10 = mdh.Hr10,
 			Hr11 = mdh.Hr11,
 			Hr12 = mdh.Hr12,
 			Hr13 = mdh.Hr13,
 			Hr14 = mdh.Hr14,
 			Hr15 = mdh.Hr15,
 			Hr16 = mdh.Hr16,
 			Hr17 = mdh.Hr17,
 			Hr18 = mdh.Hr18,
 			Hr19 = mdh.Hr19,
 			Hr20 = mdh.Hr20,
 			Hr21 = mdh.Hr21,
 			Hr22 = mdh.Hr22,
 			Hr23 = mdh.Hr23,
 			Hr24 = mdh.Hr24,
 			Hr25 = mdh.Hr25
 		FROM #temp_deal_acutal_meter_data t1
 		INNER JOIN mv90_data md 
 			ON md.meter_id = t1.meter_id
 			AND md.channel = t1.channel
 		INNER JOIN mv90_data_hour mdh 
 			ON mdh.meter_data_id = md.meter_data_id
 			AND mdh.prod_date = t1.prod_date
 			AND ISNULL(mdh.period, 0) = ISNULL(t1.period, 0)

	END
	ELSE
	BEGIN
 		UPDATE t1
 		SET meter_data_id = md.meter_data_id,
 			volume = mdh.Hr1
 		FROM #temp_deal_acutal_meter_data t1
 		INNER JOIN mv90_data md 
 			ON md.meter_id = t1.meter_id
 			AND md.channel = t1.channel
 		INNER JOIN mv90_data_hour mdh 
 			ON mdh.meter_data_id = md.meter_data_id
 			AND mdh.prod_date = t1.prod_date
 			AND ISNULL(mdh.period, 0) = ISNULL(t1.period, 0)
	END

	CREATE NONCLUSTERED INDEX NCI_TDAMD_DEAL ON #temp_deal_acutal_meter_data (source_deal_detail_id)
	CREATE NONCLUSTERED INDEX NCI_TDAMD_PROD ON #temp_deal_acutal_meter_data (prod_date)
 	
	DECLARE @pivot_select VARCHAR(MAX)

	IF OBJECT_ID('tempdb..#temp_min_break2') IS NOT NULL
		DROP TABLE #temp_min_break2
 	
	IF @actual_granularity IN (982, 989, 987, 994, 995)
	BEGIN
 		--SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) + ']',
 		--		@pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) + '] FLOAT NULL',
 		--		@pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) + '] = a.[' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) + ']',
 		--		@pivot_select = COALESCE(@pivot_select + ',', '') + 'Hr' + CAST(cte.hrs+1 AS VARCHAR(10)) +' AS [' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) + ']'
 		--FROM #temp_hours cte
 		--LEFT JOIN #temp_min_break tm ON tm.granularity = @actual_granularity 

		SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + process_clm_name + ']',
 				@pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + process_clm_name + '] FLOAT NULL',
 				@pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + process_clm_name + '] = a.[' + process_clm_name + ']',
 				@pivot_select = COALESCE(@pivot_select + ',', '') + 'Hr' + CAST(CAST(LEFT(process_clm_name,2) AS INT) AS VARCHAR) +' AS [' + process_clm_name + ']'
 		FROM #temp_hour_breakdown 
 		 		
 		-- for hourly
 		SET @pivot_select = 'source_deal_detail_id, meter_id, meter, channel, gen_date, from_date, to_date, prod_date, '+ @pivot_select
 		
 		SELECT granularity, period, 'a_' + CAST(period AS VARCHAR(10)) [alias]
 		INTO #temp_min_break2
 		FROM #temp_min_break		
 		WHERE granularity = @actual_granularity
 		
 		DECLARE @sql_string VARCHAR(MAX)
 		SELECT @sql_string = COALESCE(@sql_string + CHAR(13)+CHAR(10), '') + ' INNER JOIN ( SELECT Hr1 AS [01_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr2 AS [02_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr3 AS [03_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr4 AS [04_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr5 AS [05_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr6 AS [06_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr7 AS [07_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr8 AS [08_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr9 AS [09_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr10 AS [10_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr11 AS [11_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr12 AS [12_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr13 AS [13_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr14 AS [14_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr15 AS [15_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr16 AS [16_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr17 AS [17_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr18 AS [18_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr19 AS [19_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr20 AS [20_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr21 AS [21_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr22 AS [22_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr23 AS [23_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr24 AS [24_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr25 AS [25_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '], source_deal_detail_id, meter_id, meter, prod_date, channel FROM #temp_deal_acutal_meter_data temp
 							WHERE period = ' + CAST(period AS VARCHAR(10)) + ' ) ' + tm.alias + ' ON ' + tm.alias + '.source_deal_detail_id = a.source_deal_detail_id AND ' + tm.alias + '.meter_id = a.meter_id AND ' + tm.alias + '.prod_date = a.prod_date AND ' + tm.alias + '.channel = a.channel'
 		FROM #temp_min_break2 tm 
 		
 		SET @sql = '
 			CREATE TABLE ' + @process_table + '(
 				id                        INT IDENTITY(1, 1),
 				source_deal_detail_id     INT,
 				meter_id                  INT,
 				meter                     VARCHAR(200),
 				channel                   INT,
 				meter_data_id             INT,
 				gen_date                  DATETIME,
 				from_date                 DATETIME,
 				to_date                   DATETIME,
 				prod_date                 DATETIME,
 				' + @pivot_columns_create + '
 			)
 			
 			INSERT INTO ' + @process_table + ' (
 				source_deal_detail_id,
 				meter_id,
 				meter,
 				channel,
 				gen_date,
 				from_date,
 				to_date,
 				prod_date,
 				' + @pivot_columns + '
 			)			
 			'

 		IF @sql_string IS NULL
 		BEGIN
 			SET @sql += '
 				SELECT ' + @pivot_select + '
 				FROM #temp_deal_acutal_meter_data'
 		END
 		ELSE -- for 15 mins and hourly
 		BEGIN
 			SET @sql += '
 						SELECT a.source_deal_detail_id,
 								a.meter_id,
 								a.meter,
 								a.channel,
 								a.gen_date,
 								a.from_date,
 								a.to_date,
 								a.prod_date,
 								' + @pivot_columns + '
 						FROM (
 							SELECT source_deal_detail_id, meter_id, meter, channel, gen_date, from_date, to_date, prod_date 
 							FROM #temp_deal_acutal_meter_data
 							GROUP BY source_deal_detail_id, meter_id, meter, channel, gen_date, from_date, to_date, prod_date 
 						) a	'
 						+ ISNULL(@sql_string, '') + '
 			
 				'
 		END
	END
	ELSE
	BEGIN
 		SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + ']',
 				@pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] FLOAT NULL',
 				@pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] = a.[' + CONVERT(VARCHAR(8), term_start, 112) + ']'
 		FROM #temp_meter_terms
 		ORDER BY term_start	
 				
 		SET @sql = '
 			CREATE TABLE ' + @process_table + '(
 				id                        INT IDENTITY(1, 1),
 				source_deal_detail_id     INT,
 				meter_id                  INT,
 				meter                     VARCHAR(200),
 				channel                   INT,
 				meter_data_id             INT,
 				gen_date                  DATETIME,
 				from_date                 DATETIME,
 				to_date                   DATETIME,
 				' + @pivot_columns_create + '
 			)
 			
 			INSERT INTO ' + @process_table + ' (
 				source_deal_detail_id,
 				meter_id,
 				meter,
 				channel,
 				gen_date,
 				from_date,
 				to_date,
 				' + @pivot_columns + '
 			)			
 			SELECT source_deal_detail_id, meter_id, meter, channel, gen_date, from_date, to_date, ' + @pivot_columns + '
 			FROM (
 				SELECT source_deal_detail_id, meter_id, meter, channel, gen_date, from_date, to_date, CONVERT(VARCHAR(8), temp.prod_date, 112) term_date_p, volume
 				FROM #temp_deal_acutal_meter_data temp 
 			) a			
 			PIVOT (SUM(volume) FOR term_date_p IN (' + @pivot_columns + ') )unpvt
 		'
	END
	
	EXEC(@sql)

	SELECT @max_channel = MAX(rp.channel) 
	FROM recorder_properties rp
	INNER JOIN #temp_deal_meter_ids temp ON temp.meter_id = rp.meter_id

	DECLARE @is_locked CHAR(1)
	SELECT @is_locked = ISNULL(deal_locked, 'n') FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id
 	
	SELECT @actual_granularity [granularity],
 		@max_channel [max_channel],
 		@term_start [term_start],
 		CASE WHEN @limit_term_end < @term_end THEN @limit_term_end ELSE @term_end END [term_end],
 		@process_id [process_id],
 		dbo.FNADateFormat(@min_term_start) [min_term_start],
 		dbo.FNADateFormat(@max_term_end) [max_term_end],
		@is_locked [is_locked],
		dbo.FNADateFormat(@dst_term) [dst_term],
		a.meter_id
	FROM (
		SELECT DISTINCT TOP(1) meter_id
		FROM #temp_deal_acutal_meter_data
	) a
	RETURN
END
 
-- Returns Grid Definitions
IF @flag = 't'
BEGIN
	IF @actual_granularity IN (982, 989, 987, 994, 995)
	BEGIN		
 --		SELECT @column_list = COALESCE(@column_list + ',', '') + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2),
 --				@column_label = COALESCE(@column_label + ',', '') + RIGHT('0' + CAST(cte.hrs AS VARCHAR(10)), 2) + ':' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2),
 --				@column_type = COALESCE(@column_type + ',', '') + 'ed_no',
 --				@column_width = COALESCE(@column_width + ',', '') + '100',
 --				@column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
 --		FROM #temp_hours cte
 --		LEFT JOIN #temp_min_break tm ON tm.granularity = @actual_granularity

		SELECT @column_list = COALESCE(@column_list + ',', '') + process_clm_name,
 				@column_label = COALESCE(@column_label + ',', '') + alias_name,
 				@column_type = COALESCE(@column_type + ',', '') + 'ed_no',
 				@column_width = COALESCE(@column_width + ',', '') + '100',
 				@column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
 		FROM #temp_hour_breakdown 
 		--WHERE CAST (LEFT(alias_name,2) AS INT)> = ISNULL(@filter_hour_from, 0) AND  CAST (LEFT(alias_name,2) AS INT)<=ISNULL(@filter_hour_to, 25)
 
 		SET @column_list = 'source_deal_detail_id,meter,meter_id,channel,prod_date,' + @column_list
 		SET @column_label = 'Detail ID,Meter,ID,Channel,Date,' + @column_label
 		SET @column_type = 'ro,ro,ro,ro,ro_dhxCalendarA,' + @column_type
 		SET @column_width = '100,150,10,80,100,' + @column_width
 		SET @column_visibility = 'false,false,true,false,false,' + @column_visibility
	END
	ELSE
	BEGIN
 		SELECT @column_list = COALESCE(@column_list + ',', '') + CONVERT(VARCHAR(8), term_start, 112),
 				@column_label = COALESCE(@column_label + ',', '') + dbo.FNADateFormat(term_start),
 				@column_type = COALESCE(@column_type + ',', '') + 'ed_no',
 				@column_width = COALESCE(@column_width + ',', '') + '150',
 				@column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
 		FROM #temp_meter_terms		
 		WHERE term_start <= @term_end
 
 		SET @column_list = 'source_deal_detail_id,meter,meter_id,channel,' + @column_list
 		SET @column_label = 'Detail ID,Meter,ID,Channel,' + @column_label
 		SET @column_type = 'ro,ro,ro,ro,' + @column_type
 		SET @column_width = '100,150,10,80,' + @column_width
 		SET @column_visibility = 'false,false,true,false,' + @column_visibility
	END
	 
	SELECT @column_list [column_list],
 			@column_label [column_label],
 			@column_type [column_type],
 			@column_width [column_width],
 			@term_start [term_start],
 			@term_end [term_end],
 			@actual_granularity [granularity],
 			@column_visibility [visibility],
			@process_id [process_id]
END

-- Returns data
IF @flag = 'a'
BEGIN
	IF @actual_granularity IN (982, 989, 987, 994, 995)
	BEGIN
		SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + process_clm_name + '] [' + process_clm_name + ']'
 		FROM #temp_hour_breakdown
 		SET @column_list = 'source_deal_detail_id,meter,meter_id,channel,prod_date,' + @column_list
	END
	ELSE
	BEGIN
 		SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] [' + CONVERT(VARCHAR(8), term_start, 112) + ']'
 		FROM #temp_meter_terms
 		WHERE term_start <= @term_end
 		SET @column_list = 'source_deal_detail_id,meter,meter_id,channel,' + @column_list
	END
 
	SET @sql = 'SELECT ' + @column_list + ' FROM ' + @process_table + ' a '
	
	IF @meter_ids IS NOT NULL
	BEGIN
		SET @sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @meter_ids + ''') scsv ON scsv.item = a.meter_id  '
	END
	
	SET @sql += ' WHERE 1 = 1'
	
	IF @actual_granularity IN (982, 989, 987, 994, 995)
		SET @sql += ' AND a.prod_date >= ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''' AND a.prod_date <= ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''''
	
	IF @channel IS NOT NULL
	BEGIN
		SET @sql += ' AND a.channel = ' + CAST(@channel AS VARCHAR(20))
	END
	
	IF @actual_granularity IN (982, 989, 987, 994, 995)
		SET @sql += ' ORDER BY a.prod_date'
	
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
		
			INSERT INTO #temp_header_columns	
			EXEC spa_Transpose @table_name, NULL, 1
		
 			IF @actual_granularity IN (982, 989, 987, 994, 995)
 			BEGIN		
 				--SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) + '] = CAST(NULLIF(temp.[col_' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2) + '], '''') AS FLOAT)'
 				--FROM #temp_hours cte
 				--LEFT JOIN #temp_min_break tm ON tm.granularity = @actual_granularity
 				--INNER JOIN (SELECT DISTINCT columns_name FROM #temp_header_columns) temp ON temp.columns_name = 'col_' + RIGHT('0' + CAST(cte.hrs+1 AS VARCHAR(10)), 2) + '_' + RIGHT(ISNULL('0' + CAST(tm.period AS VARCHAR(10)), '00'), 2)
 				
				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + process_clm_name +'] = CAST(NULLIF(temp.[col_' + process_clm_name + '], '''') AS FLOAT)'
 					FROM #temp_hour_breakdown 
 			END
 			ELSE
 			BEGIN
 				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] = CAST(NULLIF(temp.[col_' + + CONVERT(VARCHAR(8), term_start, 112) + '], '''') AS FLOAT)'
 				FROM #temp_meter_terms tat
 				INNER JOIN (SELECT DISTINCT columns_name FROM #temp_header_columns) temp ON temp.columns_name = 'col_' + + CONVERT(VARCHAR(8), term_start, 112)
 			END
 
 			SET @sql = '
 				UPDATE pt 
 				SET ' + @column_list + '
 				FROM ' + @process_table + ' pt
 				INNER JOIN ' + @xml_process_table + ' temp 
 					ON pt.source_deal_detail_id = temp.col_source_deal_detail_id
 					AND pt.[meter_id] = temp.col_meter_id	
 					AND pt.[channel] = temp.col_channel		
 			'
 
 			IF @actual_granularity IN (982, 989, 987, 994, 995)
 				SET @sql += ' AND pt.prod_date = temp.col_prod_date'
		END
		--PRINT(@sql)
 		EXEC(@sql)
 		EXEC('DROP TABLE ' + @xml_process_table)
 
 		EXEC spa_ErrorHandler 0
 			, 'source_deal_detail_hour'
 			, 'spa_update_actual_meter'
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
 			IF OBJECT_ID('tempdb..#temp_source_deal_detail_meter') IS NOT NULL
 				DROP TABLE #temp_source_deal_detail_meter
 
 			CREATE TABLE #temp_source_deal_detail_meter(
 				source_deal_detail_id     INT,
 				meter_id                  INT,
 				channel                   INT,
 				prod_date                 DATETIME,
 				hr                        VARCHAR(20) COLLATE DATABASE_DEFAULT ,
 				is_dst                    INT,
 				volume                    FLOAT
 			)
 
 			DECLARE @select_statement VARCHAR(MAX)
 			DECLARE @select_statement2 VARCHAR(MAX)
 			DECLARE @for_statement VARCHAR(MAX)
 			DECLARE @on_statement VARCHAR(MAX)
 
 			IF @actual_granularity IN (982, 989, 987, 994, 995)
 			BEGIN		

	--select * from #temp_hour_breakdown
 				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + process_clm_name+ ']',
 						@select_list = COALESCE(@select_list + ',', '') + 'ISNULL([' +  process_clm_name + '], 0) [' + process_clm_name + ']'
 				FROM #temp_hour_breakdown 

				--select @column_list
				--select @select_list
				--return
				--#temp_hours cte
 				--LEFT JOIN #temp_min_break tm ON tm.granularity = @actual_granularity	


 			
 				SET @select_statement = 'SELECT source_deal_detail_id, meter_id, channel, prod_date, NULLIF(volume, 0) [volume], REPLACE(hrs, ''_'', '':'') hr, 0'
 				SET @select_statement2 = 'SELECT source_deal_detail_id, meter_id, channel, prod_date, ' + @select_list
 				SET @for_statement = 'hrs'
 			END
 			ELSE
 			BEGIN
 				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + ']',
 						@select_list = COALESCE(@select_list + ',', '') + 'ISNULL([' + CONVERT(VARCHAR(8), term_start, 112) + '], 0) [' + CONVERT(VARCHAR(8), term_start, 112) + ']'
 				FROM #temp_meter_terms tat
 
 				SET @select_statement = 'SELECT source_deal_detail_id, meter_id, channel, CONVERT(DATETIME, term_date2, 120) prod_date, NULLIF(volume, 0) [volume], NULL hr, 0'
 				SET @select_statement2 = 'SELECT source_deal_detail_id, meter_id, channel, ' + @select_list
 				SET @for_statement = 'term_date2'
 			END
 
 			SET @sql = '
 					INSERT INTO #temp_source_deal_detail_meter(source_deal_detail_id, meter_id, channel, prod_date, volume, [hr], is_dst)
 					' + @select_statement + '
 					FROM ( ' + 
 						@select_statement2 + ' 
 						FROM ' + @process_table + '
 					) tmp
 					UNPIVOT (
 						volume
 						FOR ' + @for_statement + '
 						IN (
 							' + @column_list + '
 						) 
 					) unpvt
 				'
 			EXEC(@sql)
 						
 			IF OBJECT_ID('tempdb..#temp_mv90_data_hour') IS NOT NULL
 				DROP TABLE #temp_mv90_data_hour
 				
 			CREATE TABLE #temp_mv90_data_hour (
 				source_deal_detail_id INT,
 				meter_id INT,
 				channel INT,
 				prod_date DATETIME, period INT, meter_data_id INT,
 				Hr1 FLOAT, Hr2 FLOAT, Hr3 FLOAT, Hr4 FLOAT, Hr5 FLOAT, Hr6 FLOAT, Hr7 FLOAT, Hr8 FLOAT, Hr9 FLOAT, Hr10 FLOAT,
 				Hr11 FLOAT, Hr12 FLOAT, Hr13 FLOAT, Hr14 FLOAT, Hr15 FLOAT, Hr16 FLOAT, Hr17 FLOAT, Hr18 FLOAT, Hr19 FLOAT, Hr20 FLOAT,
 				Hr21 FLOAT, Hr22 FLOAT, Hr23 FLOAT, Hr24 FLOAT, Hr25 FLOAT		
 			)
 			
 			IF @actual_granularity IN (982, 989, 987, 994, 995)
 			BEGIN 			
 				INSERT INTO #temp_mv90_data_hour(
 					source_deal_detail_id, meter_id, channel, prod_date, period,
 					Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25
 				)	
 				SELECT source_deal_detail_id, meter_id, channel, prod_date, period, [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25]
				FROM
				(
					SELECT t1.source_deal_detail_id, t1.meter_id, t1.channel, t1.prod_date, t1.volume, CAST(LEFT(t1.hr, 2) AS INT) [hour], t2.period
 					FROM #temp_source_deal_detail_meter t1
 					LEFT JOIN #temp_min_break t2 
 						ON granularity = @actual_granularity
 						AND CAST(RIGHT(t1.hr, 2) AS INT) = t2.period
				) p
				PIVOT(
				SUM(volume)
				FOR [hour]
				IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25])
				) AS pvt; 	
 					
 			END
 			ELSE
 			BEGIN
 				INSERT INTO #temp_mv90_data_hour(
 					source_deal_detail_id, meter_id, channel, prod_date, period, Hr1
 				)	
 				SELECT t1.source_deal_detail_id, t1.meter_id, t1.channel, t1.prod_date, NULL, t1.volume
 				FROM #temp_source_deal_detail_meter t1
 			END
 						
 			IF OBJECT_ID('tempdb..#temp_inserted_updated_deal_meter') IS NOT NULL
 				DROP TABLE #temp_inserted_updated_deal_meter
 			CREATE TABLE #temp_inserted_updated_deal_meter(meter_data_id INT, meter_id INT, channel INT)
 			
 			IF EXISTS(SELECT 1 FROM #temp_mv90_data_hour)
 			BEGIN
 				IF OBJECT_ID('tempdb..#temp_mv90_data') IS NOT NULL
 					DROP TABLE #temp_mv90_data
 				
 				CREATE TABLE #temp_mv90_data (meter_data_id INT, meter_id INT, channel INT, from_date DATETIME, to_date DATETIME)
 				
 				INSERT INTO #temp_mv90_data (meter_id, channel, from_date, to_date)
 				SELECT meter_id, channel, MIN(prod_date) from_date, dbo.FNAGetTermEndDate(@frequency, MAX(prod_date), 0) to_date
 				FROM #temp_mv90_data_hour
 				GROUP BY meter_id, channel
 				
 				IF EXISTS(
 					SELECT 1
 					FROM #temp_mv90_data t1
 					INNER JOIN mv90_data md
 						ON md.meter_id = t1.meter_id
 						AND md.channel = t1.channel
 						AND md.granularity <> @actual_granularity
 				) 
 				BEGIN
 					DELETE mdh
 					FROM mv90_data_hour mdh
 					INNER JOIN mv90_data md ON md.meter_data_id = mdh.meter_data_id
 					INNER JOIN #temp_mv90_data t1
 						ON md.meter_id = t1.meter_id
 						AND md.channel = t1.channel
 						AND md.granularity <> @actual_granularity
 					
 					DELETE md
 					FROM #temp_mv90_data t1
 					INNER JOIN mv90_data md
 						ON md.meter_id = t1.meter_id
 						AND md.channel = t1.channel
 						AND md.granularity <> @actual_granularity
 				END
 				
				--select * from #temp_mv90_data
				--select * from #temp_mv90_data_hour
				--return
 				UPDATE md
 				SET gen_date = CASE WHEN md.gen_date <= t1.from_date THEN md.gen_date ELSE t1.from_date END,
 					from_date = CASE WHEN md.from_date <= t1.from_date THEN md.from_date ELSE t1.from_date END,
 					to_date = CASE WHEN md.to_date >= t1.to_date THEN md.to_date ELSE t1.to_date END,
 					granularity = @actual_granularity
 				OUTPUT INSERTED.meter_data_id, INSERTED.meter_id, INSERTED.channel INTO #temp_inserted_updated_deal_meter(meter_data_id, meter_id, channel)
 				FROM #temp_mv90_data t1
 				INNER JOIN mv90_data md
 					ON md.meter_id = t1.meter_id
 					AND md.channel = t1.channel
 				
 				INSERT INTO mv90_data (meter_id, gen_date, from_date, to_date, channel, granularity)
 				OUTPUT INSERTED.meter_data_id, INSERTED.meter_id, INSERTED.channel INTO #temp_inserted_updated_deal_meter(meter_data_id, meter_id, channel)
 				SELECT t1.meter_id, t1.from_date, t1.from_date, t1.to_date, t1.channel, @actual_granularity
 				FROM #temp_mv90_data t1
 				LEFT JOIN mv90_data md 
 					ON md.meter_id = t1.meter_id
 					AND md.channel = t1.channel
 				WHERE md.meter_data_id IS NULL
 								
 				UPDATE t1
 				SET meter_data_id = t2.meter_data_id
 				FROM #temp_mv90_data_hour t1
 				INNER JOIN #temp_inserted_updated_deal_meter t2 ON t2.meter_id = t1.meter_id AND t2.channel = t1.channel 
 				
				
 				UPDATE mvd
 				SET Hr1 = t1.Hr1,
 					Hr2= t1.Hr2,
 					Hr3= t1.Hr3,
 					Hr4= t1.Hr4,
 					Hr5= t1.Hr5,
 					Hr6= t1.Hr6,
 					Hr7= t1.Hr7,
 					Hr8= t1.Hr8,
 					Hr9= t1.Hr9,
 					Hr10 = t1.Hr10,
 					Hr11 = t1.Hr11,
 					Hr12 = t1.Hr12,
 					Hr13 = t1.Hr13,
 					Hr14 = t1.Hr14,
 					Hr15 = t1.Hr15,
 					Hr16 = t1.Hr16,
 					Hr17 = t1.Hr17,
 					Hr18 = t1.Hr18,
 					Hr19 = t1.Hr19,
 					Hr20 = t1.Hr20,
 					Hr21 = t1.Hr21,
 					Hr22 = t1.Hr22,
 					Hr23 = t1.Hr23,
 					Hr24 = t1.Hr24,
 					Hr25 = t1.Hr25
 				FROM mv90_data_hour mvd
 				INNER JOIN #temp_mv90_data_hour t1 
 					ON t1.meter_data_id = mvd.meter_data_id
 					AND t1.prod_date = mvd.prod_date
 					AND ISNULL(t1.period, 0) = ISNULL(mvd.period, 0)
 			

			--select * 
			--	FROM mv90_data_hour mvd
 		--		INNER JOIN #temp_mv90_data_hour t1 
 		--			ON t1.meter_data_id = mvd.meter_data_id
 		--			AND t1.prod_date = mvd.prod_date
 		--			AND ISNULL(t1.period, 0) = ISNULL(mvd.period, 0)
			--		--return
 				INSERT INTO mv90_data_hour (
 					meter_data_id, prod_date, period,
 					Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, 
 					Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20,
 					Hr21, Hr22, Hr23, Hr24, Hr25
 				)
 				SELECT 
 					t1.meter_data_id, t1.prod_date, t1.period,
 					t1.Hr1, t1.Hr2, t1.Hr3, t1.Hr4, t1.Hr5, t1.Hr6, t1.Hr7, t1.Hr8, t1.Hr9, t1.Hr10,
 					t1.Hr11, t1.Hr12, t1.Hr13, t1.Hr14, t1.Hr15, t1.Hr16, t1.Hr17, t1.Hr18, t1.Hr19, t1.Hr20,
 					t1.Hr21, t1.Hr22, t1.Hr23, t1.Hr24, t1.Hr25
 				FROM #temp_mv90_data_hour t1
 				LEFT JOIN mv90_data_hour mvd
 					ON t1.meter_data_id = mvd.meter_data_id
 					AND t1.prod_date = mvd.prod_date
 					AND ISNULL(t1.period, 0) = ISNULL(mvd.period, 0)
 				WHERE mvd.recid IS NULL
 			END
 			
			IF @source_deal_header_id IS NOT NULL AND @source_deal_detail_id IS NOT NULL
			BEGIN
				UPDATE sdd
				SET sdd.actual_volume = a.actual_volume
				FROM source_deal_header sdh
				INNER JOIN source_deal_detail sdd
					ON sdh.source_deal_header_id = sdd.source_deal_header_id
				OUTER APPLY (
					SELECT AVG(avg_vol) actual_volume
					FROM #temp_mv90_data_hour
					UNPIVOT(
						avg_vol FOR [hour] IN (
							hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13,
							hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24)
					) unvpt
				) a
				WHERE sdd.source_deal_detail_id = @source_deal_detail_id
			END
						
 			/*
 			IF EXISTS(SELECT 1 FROM #temp_inserted_updated_deal_meter)
 			BEGIN
 				DECLARE @_process_id NVARCHAR(500) = dbo.FNAGetNewID()
 				DECLARE @_report_position_deals NVARCHAR(600)
 
 				SET @_report_position_deals = dbo.FNAProcessTableName('report_position', @user_name, @_process_id)
 
 				DECLARE @_sql NVARCHAR(MAX)
 				SET @_sql = '
 					SELECT sdd.source_deal_header_id [source_deal_header_id], ''u'' [action]
 					INTO ' + @_report_position_deals + '
 					FROM source_deal_detail sdd
 					INNER JOIN #temp_inserted_updated_deal_meter temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
 					GROUP BY sdd.source_deal_header_id
 				'
 				EXEC(@_sql)
 
 				DECLARE @_pos_job_name VARCHAR(200) ='calc_position_breakdown_' + @_process_id
 				SET @_sql = 'spa_calc_deal_position_breakdown NULL,''' + @_process_id + ''''
 				EXEC spa_run_sp_as_job @_pos_job_name,@_sql, 'Position Calculation', @user_name
 			END
 			*/
 		END
 
 		COMMIT
 		EXEC spa_ErrorHandler 0
 			, 'source_deal_detail_hour'
 			, 'spa_update_actual_meter'
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
 			, 'spa_update_actual_meter'
 			, 'Error'
 			, @DESC
 			, ''
	END CATCH
END

IF @flag = 'x'
BEGIN 	
	SELECT meter_id, meter_name FROM #temp_deal_meter_ids GROUP BY meter_id, meter_name
END

-- Return meter id and meter name
IF @flag = 'b'
BEGIN
	IF @meter_id IS NOT NULL
	BEGIN
		SELECT meter_id, recorderid FROM meter_id WHERE meter_id = @meter_id
	END
	ELSE IF @location_id IS NOT NULL
	BEGIN
		SELECT mi.meter_id, mi.recorderid FROM source_minor_location_meter smlm
		INNER JOIN meter_id mi ON mi.meter_id = smlm.meter_id
		WHERE smlm.source_minor_location_id = @location_id
		ORDER BY mi.recorderid ASC
	END
END

-- Return meter id and granularity (required for validation in front end)
IF @flag = 'c'
BEGIN
	IF @meter_id IS NOT NULL
	BEGIN
		SELECT meter_id, granularity FROM meter_id WHERE meter_id = @meter_id
	END
	ELSE IF @location_id IS NOT NULL
	BEGIN
		SELECT mi.meter_id, mi.granularity FROM source_minor_location sml
		LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sml.source_minor_location_id
		LEFT JOIN meter_id mi ON mi.meter_id = smlm.meter_id
		WHERE smlm.source_minor_location_id = @location_id
	END
END

GO