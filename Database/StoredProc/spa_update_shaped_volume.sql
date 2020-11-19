IF OBJECT_ID(N'[dbo].[spa_update_shaped_volume]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_update_shaped_volume]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Procedure that is used to save price and volume of the shaped/forecasted deal and dynamically generate columns and display the data on it that will be shown in update volume of deal.

	Parameters:
		@flag					:	Operation flag that decides the logic to be executed.
		@source_deal_header_id	:	Identifier to uniquely identify the Deal. "NEW_" is used as prefix for insertion case.
		@source_deal_detail_id	:	Identifier of the Detail of the Deal. "NEW_" is used as prefix for insertion case.
		@term_start				:	The specific date that is used as a start of term.
		@term_end				:	The specific date that is used as an end of term.
		@hour_from				:	The specific hour that is used as a begin hour.
		@hour_to				:	The specific hour that is used as an end hour.
		@process_id				:	Unique Identifier to create process table that stores data related to volumes.
		@leg					:	Specify the Leg of the single/multi legged deal detail.
		@xml					:	Data related to volume in XML format.
		@template_id			:	Numeric Identifier of a deal template that is used to create a deal.
		@volume_price			:	Type of the value Volume or Price (v/p).
		@response				:	Specify whether to give response or not (y/n).
		@copy_deal_id			:	Numeric identifier of the deal from which the current deal was copied. Used to get template id from it.
		@granularity			:	Granularity of the deal (Hourly,Monthly,Daily,Yearly and so on).
		@location_id			:	Numeric identifier of the location used in a deal.
		@curve_id				:	Numeric identifier of the price curve used in a deal.
		@contract_id			:	Numeric identifier of the contract used in a deal.
*/

CREATE PROCEDURE [dbo].[spa_update_shaped_volume]
	@flag CHAR(1),
	@source_deal_header_id VARCHAR(100) = NULL,
	@source_deal_detail_id VARCHAR(100) = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@process_id VARCHAR(300) = NULL,
	@leg INT = NULL,
	@xml XML = NULL,
	@template_id INT = NULL,
	@volume_price CHAR(1) = NULL,
	@response CHAR(1) = 'y',
	@copy_deal_id INT = NULL,
	@granularity INT = NULL,
	@location_id INT = NULL,
	@curve_id INT = NULL,
	@contract_id INT = NULL
AS
SET NOCOUNT ON

/*--------------Debug Section----------------
DECLARE @flag CHAR(1),
	@source_deal_header_id VARCHAR(100) = NULL,
	@source_deal_detail_id VARCHAR(100) = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@process_id VARCHAR(300) = NULL,
	@leg INT = NULL,
	@xml XML = NULL,
	@template_id INT = NULL,
	@volume_price CHAR(1) = NULL,
	@response CHAR(1) = 'y',
	@copy_deal_id INT = NULL,
	@granularity INT = NULL,
	@location_id INT = NULL,
	@curve_id INT = NULL,
	@contract_id INT = NULL

SELECT  @flag = 't'
	,@source_deal_header_id = 6816
	,@source_deal_detail_id = 45730
	,@term_start = '2020-01-01'
	,@term_end = '2020-01-31'
	,@hour_from = NULL
	,@hour_to = NULL
	,@process_id = '12E67FE8_BEB1_4000_8B97_AE28DBA96BFA'
	,@template_id = NULL
	,@leg = NULL
	,@copy_deal_id = NULL
	,@granularity = '982'
	,@curve_id = NULL
	,@location_id = NULL
	,@contract_id = NULL
-------------------------------------------*/

DECLARE @sql                      VARCHAR(MAX),
        @desc                     VARCHAR(500),
        @max_term_end             DATETIME,
        @min_term_start           DATETIME,
        @frequency                CHAR(1),
        @dst_present              INT,
        @show_only_first_hour     INT,
        @pivot_columns            VARCHAR(MAX),
        @pivot_columns_create     VARCHAR(MAX),
        @pivot_columns_update     VARCHAR(MAX),
        @max_leg                  INT,
        @column_list              VARCHAR(MAX),
        @column_label             VARCHAR(MAX),
        @column_type              VARCHAR(MAX),
        @column_width             VARCHAR(MAX),
        @column_visibility        VARCHAR(MAX),
        @err_no                   INT,
        @select_list              VARCHAR(MAX), 
		@time_zone				  INT,
        @dst_process_table		  INT,
		@transfer_deal_ids		  VARCHAR(1000),
		@offset_deal_ids		  VARCHAR(1000)
        
IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID() 

DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()        
DECLARE @process_table VARCHAR(400) = dbo.FNAProcessTableName('shaped_volume', @user_name, @process_id)
DECLARE @sql_stmt NVARCHAR(MAX)
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

IF @flag = 'v' AND @source_deal_header_id IS NOT NULL
BEGIN
	IF OBJECT_ID(@process_table) IS NOT NULL
	BEGIN
		SET @sql_stmt = 'SELECT TOP(1) @granularity = granularity FROM ' + @process_table
		EXEC sp_executesql @sql_stmt, N'@granularity INT output', @granularity OUTPUT
	END
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

DECLARE @term_frequency INT

SELECT @term_frequency = IIF(sdh.internal_desk_id <> 17300, NULL, CASE ISNULL(sdh.term_frequency, sdht.term_frequency)
	                          WHEN 'm' THEN 980
	                          WHEN 'q' THEN 991
	                          WHEN 'h' THEN 982
	                          WHEN 's' THEN 992
	                          WHEN 'a' THEN 993
	                          WHEN 'd' THEN 981
	                          WHEN 'z' THEN 0
	                     END)
FROM source_deal_header sdh
INNER JOIN source_deal_header_template sdht ON sdh.template_id = sdht.template_id
WHERE sdh.source_deal_header_id = @source_deal_header_id

IF @source_deal_header_id IS NOT NULL AND @source_deal_header_id NOT LIKE '%NEW_%' 
BEGIN
	SELECT @granularity = COALESCE(@granularity, @term_frequency, sdd.granularity, sdh.profile_granularity, sdht.profile_granularity, sdht.hourly_position_breakdown, 982)
	FROM source_deal_header sdh
	INNER JOIN source_deal_header_template sdht On sdht.template_id = sdh.template_id
	OUTER APPLY (
		SELECT TOP(1) sddh.granularity granularity
		FROM source_deal_detail sdd
		LEFT JOIN source_deal_detail_hour sddh ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
		WHERE sdd.source_deal_header_id = sdh.source_deal_header_id
	) sdd
	WHERE sdh.source_deal_header_id = @source_deal_header_id
	
	IF @source_deal_detail_id NOT LIKE '%NEW_%'
	BEGIN		
		SELECT @max_term_end = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id
		SELECT @min_term_start = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id
	END
	ELSE
	BEGIN
		SELECT @max_term_end = @term_end
		SELECT @min_term_start = @term_start
	END
END

IF @copy_deal_id IS NOT NULL
BEGIN
	SELECT @template_id = template_id
	FROM source_deal_header sdh 
	WHERE sdh.source_deal_header_id = @copy_deal_id
END

IF (@source_deal_header_id IS NULL OR @source_deal_header_id LIKE '%NEW_%') AND @template_id IS NOT NULL
BEGIN
	SELECT @granularity = COALESCE(@granularity, sdht.profile_granularity, sdht.hourly_position_breakdown, 982)
	FROM source_deal_header_template sdht
	WHERE sdht.template_id = @template_id
	
	SELECT @leg = ISNULL(@leg, MAX(leg))
	FROM source_deal_detail_template sddt 
	WHERE sddt.template_id = @template_id
	
	SELECT @max_term_end = @term_end
	SELECT @min_term_start = @term_start
END 

IF OBJECT_ID(@process_table) IS NOT NULL AND @granularity IS NOT NULL AND @flag = 's'
BEGIN
	SET @sql_stmt = 'SELECT @dst_process_table = MAX(dst_present) FROM ' + @process_table
	EXEC sp_executesql @sql_stmt, N'@dst_process_table INT output', @dst_process_table OUTPUT
	SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @process_table + ' WHERE granularity <> ' + CAST(@granularity AS VARCHAR(20)) + ')
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
SET @frequency = CASE WHEN @granularity IN (981, 982, 989, 987, 994, 995) THEN 'd' WHEN @granularity = 980 THEN 'm' WHEN @granularity = 991 THEN 'q' WHEN @granularity = 992 THEN 's' WHEN @granularity = 990 THEN 'w' END
SET @show_only_first_hour = CASE WHEN @granularity IN (982, 989, 987, 994, 995) THEN 0 ELSE 1 END

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

IF OBJECT_ID('tempdb..#temp_shaped_terms') IS NOT NULL
	DROP TABLE #temp_shaped_terms

CREATE TABLE #temp_shaped_terms (term_start DATETIME, is_dst INT)

;WITH cte_terms AS (
 	SELECT @term_start [term_start]
 	UNION ALL
 	SELECT dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1)
 	FROM cte_terms cte 
 	WHERE dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1) <= @term_end
) 
INSERT INTO #temp_shaped_terms(term_start)
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

IF OBJECT_ID('tempdb..#temp_shaped_detail_ids') IS NOT NULL 
	DROP TABLE #temp_shaped_detail_ids
CREATE TABLE #temp_shaped_detail_ids (detail_id VARCHAR(100) COLLATE DATABASE_DEFAULT )

IF @source_deal_detail_id IS NOT NULL
BEGIN
	INSERT INTO #temp_shaped_detail_ids
	SELECT @source_deal_detail_id
END
ELSE
BEGIN
	INSERT INTO #temp_shaped_detail_ids
	SELECT sdd.source_deal_detail_id 
	FROM source_deal_detail sdd
	WHERE sdd.source_deal_header_id = @source_deal_header_id
END


SELECT @time_zone = var_value
FROM dbo.adiha_default_codes_values
WHERE instance_no         = 1
AND default_code_id     = 36
AND seq_no              = 1

DECLARE @dst_term DATETIME
DECLARE @dst_hour VARCHAR(10)
DECLARE @dst_group_value_id INT

IF @source_deal_detail_id IS NOT NULL AND @source_deal_detail_id NOT LIKE '%NEW%'
BEGIN
	SELECT @location_id = sdd.location_id,
		   @curve_id = sdd.curve_id,
		   @contract_id = sdh.contract_id
	FROM source_deal_detail sdd 
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	WHERE sdd.source_deal_detail_id = @source_deal_detail_id
END
	
IF @source_deal_header_id IS NOT NULL AND @source_deal_header_id NOT LIKE '%NEW_%' AND ISNULL(@source_deal_detail_id, '') NOT LIKE '%NEW_%'
BEGIN
	SELECT @dst_present =  CASE WHEN MAX(mv.id) IS NOT NULL THEN 1 ELSE 0 END,
		   @dst_term = CASE WHEN MAX(mv.id) IS NOT NULL THEN MAX(mv.date) ELSE NULL END,
		   @dst_hour = CASE WHEN MAX(mv.id) IS NOT NULL THEN MAX(mv.[hour]) ELSE NULL END,
		   @dst_group_value_id = MAX(tz.dst_group_value_id)
	FROM #temp_shaped_terms temp
	INNER JOIN source_deal_header sdh ON CAST(sdh.source_deal_header_id AS VARCHAR(100)) = @source_deal_header_id
	INNER JOIN source_deal_detail sdd ON  sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #temp_shaped_detail_ids t1 ON t1.detail_id = CAST(sdd.source_deal_detail_id AS VARCHAR(100))
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = COALESCE(@location_id, CAST(sdd.location_id AS VARCHAR(100)), -1)
	LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = COALESCE(@curve_id, CAST(sdd.curve_id AS VARCHAR(100)), -1)
	LEFT JOIN contract_group cg ON cg.contract_id = COALESCE(@contract_id, CAST(sdh.contract_id AS VARCHAR(100)), -1)
	LEFT JOIN time_zones tz ON tz.timezone_id = COALESCE(cg.time_zone, sdh.timezone_id, sml.time_zone, spcd.time_zone, @time_zone)
	LEFT JOIN hour_block_term hbt 
		ON  hbt.block_define_id = COALESCE(spcd.block_define_id,sdh.block_define_id,  @baseload_block_define_id)
		AND hbt.block_type = COALESCE(spcd.block_type, sdh.block_type, @baseload_block_type)
		AND hbt.term_date = temp.term_start
		AND hbt.dst_group_value_id = tz.dst_group_value_id
	LEFT JOIN mv90_DST mv ON  (hbt.term_date) = (mv.date)
		AND mv.insert_delete = 'i'
		AND hbt.dst_applies = 'y'
		AND mv.dst_group_value_id =  tz.dst_group_value_id
END
ELSE IF @source_deal_header_id IS NOT NULL AND @source_deal_header_id NOT LIKE '%NEW_%' AND @source_deal_detail_id LIKE '%NEW_%'
BEGIN
	SELECT @dst_present =  CASE WHEN MAX(mv.id) IS NOT NULL THEN 1 ELSE 0 END,
		   @dst_term = CASE WHEN MAX(mv.id) IS NOT NULL THEN MAX(mv.date) ELSE NULL END,
		   @dst_hour = CASE WHEN MAX(mv.id) IS NOT NULL THEN MAX(mv.[hour]) ELSE NULL END,
		   @dst_group_value_id = MAX(tz.dst_group_value_id)
	FROM #temp_shaped_terms temp
	INNER JOIN source_deal_header sdh ON CAST(sdh.source_deal_header_id AS VARCHAR(100)) = @source_deal_header_id
	INNER JOIN #temp_shaped_detail_ids t1 ON t1.detail_id = @source_deal_detail_id
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = ISNULL(@location_id, -1)
	LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = ISNULL(@curve_id, -1)
	LEFT JOIN contract_group cg ON cg.contract_id = ISNULL(@contract_id, -1)
	LEFT JOIN time_zones tz ON tz.timezone_id = COALESCE(cg.time_zone, sdh.timezone_id, sml.time_zone, spcd.time_zone, @time_zone)
	LEFT JOIN hour_block_term hbt 
		ON  hbt.block_define_id = COALESCE(spcd.block_define_id,sdh.block_define_id,  @baseload_block_define_id)
		AND hbt.block_type = COALESCE(spcd.block_type, sdh.block_type, @baseload_block_type)
		AND hbt.term_date = temp.term_start
		AND hbt.dst_group_value_id = tz.dst_group_value_id
	LEFT JOIN mv90_DST mv ON  (hbt.term_date) = (mv.date)
		AND mv.insert_delete = 'i'
		AND hbt.dst_applies = 'y'
		AND mv.dst_group_value_id =  tz.dst_group_value_id
END
ELSE
BEGIN
	SELECT @dst_present =  CASE WHEN MAX(mv.id) IS NOT NULL THEN 1 ELSE 0 END,
		   @dst_term = CASE WHEN MAX(mv.id) IS NOT NULL THEN MAX(mv.date) ELSE NULL END,
		   @dst_hour = CASE WHEN MAX(mv.id) IS NOT NULL THEN MAX(mv.[hour]) ELSE NULL END,
		   @dst_group_value_id = MAX(tz.dst_group_value_id)
	FROM #temp_shaped_terms temp	
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = @template_id
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = ISNULL(@location_id, -1)
	LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = ISNULL(@curve_id, -1)
	LEFT JOIN contract_group cg ON cg.contract_id = ISNULL(@contract_id, -1)
	LEFT JOIN time_zones tz ON tz.timezone_id = COALESCE(cg.time_zone, sdht.timezone_id, sml.time_zone, spcd.time_zone, @time_zone)
	LEFT JOIN hour_block_term hbt 
		ON  hbt.block_define_id = COALESCE(spcd.block_define_id,sdht.block_define_id,  @baseload_block_define_id)
		AND hbt.block_type = COALESCE(spcd.block_type, sdht.block_type, @baseload_block_type)
		AND hbt.term_date = temp.term_start
		AND hbt.dst_group_value_id = tz.dst_group_value_id
	LEFT JOIN mv90_DST mv ON  (hbt.term_date) = (mv.date)
		AND mv.insert_delete = 'i'
		AND hbt.dst_applies = 'y'
		AND mv.dst_group_value_id =  tz.dst_group_value_id
END

IF @is_deal_commodity_gas = 1
BEGIN
	SET @dst_term = DATEADD(DAY, -1, @dst_term )
	SET @dst_hour = @dst_hour + 18
END

IF OBJECT_ID('tempdb..#temp_min_break') IS NOT NULL
	DROP TABLE #temp_min_break

CREATE TABLE #temp_min_break(granularity int, period tinyint, factor numeric(6,2))  

IF @granularity IN (989, 987, 994, 995)
BEGIN
	INSERT INTO #temp_min_break (granularity, period, factor)
	VALUES (989,0,2), (989,30,2), -- 30Min
			(987,0,4),(987,15,4),(987,30,4),(987,45,4), -- 15Min
			(994,0,6), (994,10,6), (994,20,6), (994,30,6), (994,40,6), (994,50,6), --10Min
			(995,0,12), (995,5,12), (995,10,12), (995,15,12), (995,20,12), (995,25,12), (995,30,12), (995,35,12), (995,40,12), (995,45,12), (995,50,12), (995,55,12) --5Min
END

IF @granularity IN (982, 989, 987, 994, 995)
BEGIN
	IF OBJECT_ID('tempdb..#temp_hour_breakdown') IS NOT NULL
		DROP TABLE #temp_hour_breakdown

	SELECT clm_name, is_dst, alias_name, CASE WHEN is_dst = 0 THEN RIGHT('0' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '_' + RIGHT(clm_name, 2) ELSE RIGHT('0' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '_' + RIGHT(clm_name, 2) + '_DST' END [process_clm_name]
	INTO #temp_hour_breakdown 
	FROM dbo.FNAGetDisplacedPivotGranularityColumn(@term_start,@term_end,@granularity,@dst_group_value_id,IIF(@is_deal_commodity_gas = 1,6,0)) 
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
    IF OBJECT_ID('tempdb..#temp_shaped_deal_data') IS NOT NULL 
		DROP TABLE #temp_shaped_deal_data

	CREATE TABLE #temp_shaped_deal_data(source_deal_detail_id VARCHAR(100) COLLATE DATABASE_DEFAULT , leg INT, term_date DATETIME, hr VARCHAR(10) COLLATE DATABASE_DEFAULT , is_dst INT, volume NUMERIC(38, 20), price NUMERIC(38, 20), term_date_p VARCHAR(8) COLLATE DATABASE_DEFAULT  )
	
	DECLARE @filter_sdh VARCHAR(20)
	DECLARE @filter_sdd VARCHAR(20)
	
	IF @source_deal_header_id IS NOT NULL
		SET @filter_sdh = @source_deal_header_id
	
	/*
	IF @copy_deal_id IS NOT NULL
		SET @filter_sdh = @copy_deal_id
		
	IF @copy_deal_id IS NOT NULL AND @term_start IS NOT NULL AND @term_end IS NOT NULL AND @leg IS NOT NULL
		SELECT @filter_sdd = sdd.source_deal_detail_id
		FROM source_deal_detail sdd
		WHERE sdd.source_deal_header_id = @copy_deal_id
		AND sdd.term_start = @term_start
		AND sdd.term_start = @term_start
		AND sdd.leg = @leg
	*/
	
	IF @source_deal_detail_id IS NOT NULL AND @filter_sdd IS NULL
		SET @filter_sdd = @source_deal_detail_id
		
	/** GENERATE terms and hours**/
	INSERT INTO #temp_shaped_deal_data(source_deal_detail_id, term_date, hr, is_dst, leg, term_date_p)
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
			SELECT ISNULL(@source_deal_detail_id, CAST(sdd.source_deal_detail_id AS VARCHAR(100))) source_deal_detail_id,
					hbt.term_date,
					hbt.hr1,hbt.hr2,hbt.hr3,hbt.hr4,hbt.hr5,hbt.hr6,hbt.hr7,hbt.hr8,
					hbt.hr9,hbt.hr10,hbt.hr11,hbt.hr12,hbt.hr13,hbt.hr14,hbt.hr15,hbt.hr16,
					hbt.hr17,hbt.hr18,hbt.hr19,hbt.hr20,hbt.hr21,hbt.hr22,hbt.hr23,hbt.hr24,
					case when spcd.commodity_id = -1 THEN (CAST(mvgas.[hour]+18 AS VARCHAR)) ELSE mv.[hour] end [hr25], 
					case when spcd.commodity_id = -1 THEN (CAST(mvgas1.[hour]+18 AS VARCHAR)) ELSE mv1.[hour] end [DST_hour],
					ISNULL(@leg, sdd.leg) leg
			FROM #temp_shaped_terms temp
			LEFT JOIN source_deal_header sdh ON CAST(sdh.source_deal_header_id AS VARCHAR(100)) = @source_deal_header_id
			LEFT JOIN source_deal_detail sdd 
				ON sdd.source_deal_header_id = sdh.source_deal_header_id
				AND sdd.source_deal_detail_id = CASE WHEN ISNUMERIC(@source_deal_detail_id) = 0 THEN sdd.source_deal_detail_id ELSE @source_deal_detail_id END 
				AND temp.term_start BETWEEN sdd.term_start AND sdd.term_end
			LEFT JOIN #temp_shaped_detail_ids t1 ON t1.detail_id = ISNULL(@source_deal_detail_id, CAST(sdd.source_deal_detail_id AS VARCHAR(100)))
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = COALESCE(@curve_id, sdd.curve_id, -1)
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = COALESCE(@location_id, sdd.location_id, -1)
			LEFT JOIN contract_group cg ON cg.contract_id = COALESCE(@contract_id, sdh.contract_id, -1)
			LEFT JOIN time_zones tz ON tz.timezone_id = COALESCE(cg.time_zone, sdh.timezone_id, sml.time_zone, spcd.time_zone, @time_zone)	
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
				AND mv1.dst_group_value_id = tz.dst_group_value_id
			LEFT JOIN mv90_DST mvgas ON  DATEADD(DAY,-1,mvgas.date) = (hbt.term_date) 
				AND mvgas.insert_delete = 'i'
				AND hbt.dst_applies = 'y'
				AND mvgas.dst_group_value_id = tz.dst_group_value_id
			LEFT JOIN mv90_DST mvgas1 ON  DATEADD(DAY,-1,mvgas1.date) = (hbt.term_date) 
				AND mvgas1.insert_delete = 'd'
				AND hbt.dst_applies = 'y'
				AND mvgas1.dst_group_value_id = tz.dst_group_value_id
		) AS p
		UNPIVOT(
			volume FOR hr IN ([hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12], 
							[hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], 
							[hr23], [hr24], [hr25])
		) unpvt 
	) a
	LEFT JOIN #temp_min_break tm ON tm.granularity = @granularity	
	WHERE (@show_only_first_hour = 0 OR (@show_only_first_hour = 1 AND a.[Hours] < 2))
	
	CREATE NONCLUSTERED INDEX NCI_TDAD_DEAL ON #temp_shaped_deal_data (source_deal_detail_id)
	CREATE NONCLUSTERED INDEX NCI_TDAD_TERM ON #temp_shaped_deal_data (term_date)
	CREATE NONCLUSTERED INDEX NCI_TDAD_HOUR ON #temp_shaped_deal_data (hr)
	
	SET @sql = '
		UPDATE temp 
		SET volume = ISNULL(sddh.volume, temp.volume),
			price = ISNULL(sddh.price, temp.price),
			leg = COALESCE(sddh.leg, temp.leg, 1)
		FROM #temp_shaped_deal_data temp
		INNER JOIN (
			SELECT  ' + CASE WHEN @filter_sdd IS NOT NULL AND @source_deal_detail_id IS NOT NULL THEN '''' + @source_deal_detail_id + '''' ELSE ' sddh.source_deal_detail_id '  END + ' source_deal_detail_id, 
					sdd.leg, sddh.term_date, sddh.hr, sddh.is_dst, sddh.volume, sddh.price, CONVERT(VARCHAR(8), sddh.term_date, 112) [term_date_p]
			FROM source_deal_detail_hour sddh
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
			WHERE sddh.term_date >= ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''' AND sddh.term_date <= ''' + CONVERT(VARCHAR(10), @term_end, 120) + '''
			AND CAST(LEFT(sddh.hr, 2) AS INT) >= ' + CAST(ISNULL(@hour_from+1, 1) AS VARCHAR(10)) + '
			AND CAST(LEFT(sddh.hr, 2) AS INT) < ' + CAST(ISNULL(@hour_to+1, 25) AS VARCHAR(10)) + '' 
			+ CASE WHEN @filter_sdd IS NOT NULL THEN ' AND CAST(sddh.source_deal_detail_id AS VARCHAR(100)) = ''' + CAST(@filter_sdd AS VARCHAR(10)) + '''' ELSE '' END
			+ CASE WHEN @filter_sdh IS NOT NULL THEN ' AND CAST(sdd.source_deal_header_id AS VARCHAR(100)) = ''' + CAST(@filter_sdh AS VARCHAR(10)) + '''' ELSE '' END
		+ ') sddh 
		ON CAST(sddh.source_deal_detail_id AS VARCHAR(100)) = temp.source_deal_detail_id
		AND sddh.term_date = temp.term_date
		AND sddh.hr = temp.hr
		AND sddh.is_dst = temp.is_dst 
		WHERE sddh.is_dst = 0'
	--PRINT(@sql)
	EXEC(@sql)
	
	--Logic to show the deal volume in update volume menu from sdd itself if it is missng in source_deal_detail hour
	IF EXISTS (SELECT 1 FROM source_deal_header WHERE internal_desk_id = 17300 AND source_deal_header_id = @filter_sdh)
	BEGIN
		UPDATE t
		SET t.volume = ISNULL(t.volume, sdd.deal_volume), 
			t.price = ISNULL(t.price, sdd.fixed_price)
		FROM #temp_shaped_deal_data t
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = t.source_deal_detail_id
	END

	/* Update Volume for DST hour*/
	UPDATE temp
	SET volume = sddh.volume,
		price = sddh.price
	FROM #temp_shaped_deal_data temp
	INNER JOIN source_deal_detail_hour sddh ON temp.source_deal_detail_id = CAST(sddh.source_deal_detail_id AS VARCHAR(100))
		AND temp.term_date = sddh.term_date
		AND temp.is_dst = sddh.[is_dst]
		AND temp.[hr] = sddh.hr
	WHERE temp.is_dst = 1
	
	IF OBJECT_ID('tempdb..#temp_inserted_data') IS NOT NULL
		DROP TABLE #temp_inserted_data
	CREATE TABLE #temp_inserted_data (detail_id VARCHAR(100) COLLATE DATABASE_DEFAULT )
	
	IF @granularity IN (982, 989, 987, 994, 995)
	BEGIN
		SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + process_clm_name + ']',
				@pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + process_clm_name + '] NUMERIC(38, 20)  NULL',
				@pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + process_clm_name + '] = a.[' + process_clm_name + ']'
		FROM #temp_hour_breakdown
			
		SET @sql = '
			IF OBJECT_ID(''' + @process_table + ''') IS NULL
			BEGIN
				CREATE TABLE ' + @process_table + '(
					source_deal_detail_id VARCHAR(100),
					leg INT,
					term_date DATETIME NULL,
					is_dst INT,
					old_source_deal_detail_id  VARCHAR(100),
					type CHAR(1),
					type_name VARCHAR(100),
					granularity INT,
					dst_present INT,
					' + @pivot_columns_create + '
				)
			END
			
			-- Existence check for Index IX_pt_1 in process table.
			IF NOT EXISTS (
				SELECT 1 
				FROM adiha_process.sys.indexes WITH(NOLOCK)
				WHERE OBJECT_ID = OBJECT_ID(''' + @process_table + ''') 
					AND [name] = ''IX_pt_1''
			)
			BEGIN
				CREATE INDEX IX_pt_1  ON ' + @process_table + '(source_deal_detail_id,term_date,type)
			END

			INSERT INTO ' + @process_table + ' (source_deal_detail_id, leg, term_date, is_dst, type, type_name, old_source_deal_detail_id, granularity, dst_present)
			OUTPUT INSERTED.source_deal_detail_id INTO #temp_inserted_data(detail_id)
			SELECT sdd.source_deal_detail_id, sdd.leg, sdd.term_date, sdd.is_dst, vol_type.type, vol_type.type_name, sdd.source_deal_detail_id, ' + CAST(@granularity AS VARCHAR(20)) + ', ' + CAST(@dst_present AS VARCHAR(10)) + '
			FROM (
				SELECT source_deal_detail_id, leg, term_date, MAX(is_dst) is_dst
				FROM #temp_shaped_deal_data
				GROUP BY source_deal_detail_id, leg, term_date
			) sdd
			OUTER APPLY (
				SELECT ''v'' [type], ''Volume'' [type_name] UNION ALL
				SELECT ''p'', ''Price''   
			) vol_type
			LEFT JOIN ' + @process_table + ' sdd1 
				ON sdd.source_deal_detail_id = sdd1.source_deal_detail_id
				AND sdd.leg = sdd1.leg
				AND sdd.term_date = sdd1.term_date
				AND sdd.is_dst = sdd1.is_dst
			WHERE sdd1.source_deal_detail_id IS NULL
			'

		EXEC(@sql)

	
		IF OBJECT_ID('tempdb..#temp1') IS NOT NULL DROP TABLE #temp1
		SET @sql = '
		    SELECT source_deal_detail_id, term_date, ' + @pivot_columns + '
			INTO #temp1 
			FROM (
					SELECT source_deal_detail_id, term_date, REPLACE(hr, '':'', ''_'') + IIF(is_dst=1,''_DST'','''') hrs, volume,is_dst
					FROM  #temp_shaped_deal_data temp
				 )  a			
			PIVOT (SUM(volume) FOR hrs IN (' + @pivot_columns + ') ) unpvt

			UPDATE temp
			SET ' + @pivot_columns_update + '
			FROM ' + @process_table + ' temp   WITH (NOLOCK) 
			INNER JOIN #temp_inserted_data t1 ON t1.detail_id = temp.source_deal_detail_id
			INNER JOIN #temp1 a 
			    ON temp.source_deal_detail_id = a.source_deal_detail_id 
				AND temp.term_date = a.term_date
				AND temp.[type] = ''v''   OPTION(RECOMPILE)
			'
		--PRINT(@sql)
		EXEC(@sql)
		
		IF OBJECT_ID('tempdb..#temp2') IS NOT NULL DROP TABLE #temp2
		SET @sql = '
		    SELECT source_deal_detail_id, term_date, ' + @pivot_columns + '
			INTO #temp2
			FROM ( SELECT source_deal_detail_id, term_date, REPLACE(hr, '':'', ''_'') + IIF(is_dst=1,''_DST'','''') hrs, price
				   FROM  #temp_shaped_deal_data temp
			     ) a			
			PIVOT (SUM(price) FOR hrs IN (' + @pivot_columns + ') )unpvt

			UPDATE temp
			SET ' + @pivot_columns_update + '
			FROM ' + @process_table + ' temp   WITH (NOLOCK) 
			INNER JOIN #temp_inserted_data t1 ON t1.detail_id = temp.source_deal_detail_id
			INNER JOIN #temp2 a 
			    ON temp.source_deal_detail_id = a.source_deal_detail_id 
				AND temp.term_date = a.term_date
				AND temp.[type] = ''p''    OPTION(RECOMPILE)
			'
		--PRINT(@sql)
		EXEC(@sql)
		
	END
	ELSE
	BEGIN
		SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + ']',
			   @pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] NUMERIC(38, 20)  NULL',
			   @pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] = a.[' + CONVERT(VARCHAR(8), term_start, 112) + ']'
		FROM #temp_shaped_terms
		ORDER BY term_start		

		DECLARE @existence_check VARCHAR(MAX) = ''
		 
		-- Existence check for new columns to be added in process table.
		SELECT @existence_check = @existence_check + CONCAT('
			IF NOT EXISTS (
				SELECT 1
				FROM adiha_process.sys.columns WITH(NOLOCK)
				WHERE OBJECT_ID = OBJECT_ID(''', @process_table, ''')
					AND [name] = ''', REPLACE(REPLACE(item, '[', ''), ']', ''), '''
			)
			BEGIN', '
				ALTER TABLE ' + @process_table + ' ADD ' + item + ' NUMERIC(38, 20)  NULL
			END')
		FROM dbo.FNASplit(@pivot_columns, ',')
		
		SET @sql = '
			IF OBJECT_ID(''' + @process_table + ''') IS NULL
			BEGIN
				CREATE TABLE ' + @process_table + '(
					source_deal_detail_id VARCHAR(100),
					leg INT,
					term_date DATETIME NULL,
					is_dst INT,
					old_source_deal_detail_id VARCHAR(100),
					type CHAR(1),
					type_name VARCHAR(100),
					granularity INT,
					dst_present INT,
					' + @pivot_columns_create + '
				)
			END
			ELSE IF NOT EXISTS(SELECT 1 FROM ' + @process_table + ' WHERE source_deal_detail_id = ''' + ISNULL(@source_deal_detail_id, '') + ''')
			BEGIN
				' + @existence_check + '
			END
			
			INSERT INTO ' + @process_table + ' (source_deal_detail_id, leg, is_dst, type, type_name, old_source_deal_detail_id, granularity, dst_present)
			OUTPUT INSERTED.source_deal_detail_id INTO #temp_inserted_data(detail_id)
			SELECT sdd.source_deal_detail_id, sdd.leg, sdd.is_dst, vol_type.type, vol_type.type_name, sdd.source_deal_detail_id, ' + CAST(@granularity AS VARCHAR(20)) + ', ' + CAST(@dst_present AS VARCHAR(10)) + '
			FROM (
				SELECT source_deal_detail_id, leg, is_dst
				FROM #temp_shaped_deal_data				
				WHERE hr = ''01:00''
				GROUP BY source_deal_detail_id, leg, is_dst
			) sdd
			OUTER APPLY (
				SELECT ''v'' [type], ''Volume'' [type_name] UNION ALL
				SELECT ''p'', ''Price''   
			) vol_type	
			LEFT JOIN ' + @process_table + ' sdd1 
				ON sdd.source_deal_detail_id = sdd1.source_deal_detail_id
				AND sdd.leg = sdd1.leg
				AND sdd.is_dst = sdd1.is_dst
			WHERE sdd1.source_deal_detail_id IS NULL	
			'
		-- PRINT(@sql)
		EXEC(@sql)
		
		SET @sql = '
			UPDATE temp
			SET ' + @pivot_columns_update + '
			FROM ' + @process_table + ' temp
			INNER JOIN #temp_inserted_data t1 ON t1.detail_id = temp.source_deal_detail_id
			INNER JOIN 
			(
				SELECT source_deal_detail_id, ' + @pivot_columns + '
				FROM (
					SELECT source_deal_detail_id, term_date_p, volume
					FROM  #temp_shaped_deal_data temp 
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
			INNER JOIN #temp_inserted_data t1 ON t1.detail_id = temp.source_deal_detail_id
			INNER JOIN 
			(
				SELECT source_deal_detail_id, ' + @pivot_columns + '
				FROM (
					SELECT source_deal_detail_id, term_date_p, price
					FROM  #temp_shaped_deal_data temp 
					WHERE temp.hr = ''01:00''
				) a			
				PIVOT (SUM(price) FOR term_date_p IN (' + @pivot_columns + ') )unpvt
			) a ON temp.source_deal_detail_id = a.source_deal_detail_id AND temp.[type] = ''p''
			'
		--PRINT(@sql)
		EXEC(@sql)

		SET @sql = 'UPDATE temp
					SET term_date = sdd.term_start
					FROM ' + @process_table + ' temp
					INNER JOIN source_deal_detail sdd ON CAST(sdd.source_deal_detail_id AS VARCHAR(100)) = temp.source_deal_detail_id
					
					UPDATE temp
					SET term_date = ''' + CONVERT(VARCHAR(10), @term_start, 120) + '''
					FROM ' + @process_table + ' temp
					WHERE temp.term_date IS NULL
					'
		EXEC(@sql)
	END
	
	DECLARE @is_locked CHAR(1)

	IF @source_deal_header_id IS NOT NULL AND @source_deal_header_id NOT LIKE '%NEW_%'
	BEGIN
		SELECT @max_leg = MAX(leg) FROM source_deal_detail WHERE CAST(source_deal_header_id AS VARCHAR(100)) = @source_deal_header_id
		SELECT @is_locked = ISNULL(deal_locked, 'n') FROM source_deal_header WHERE CAST(source_deal_header_id AS VARCHAR(100)) = @source_deal_header_id
	END
	ELSE
	BEGIN
		IF OBJECT_ID('temp..#temp_max_leg') IS NOT NULL
			DROP TABLE #temp_max_leg
			
		CREATE TABLE #temp_max_leg(leg INT)
		EXEC('
			INSERT INTO #temp_max_leg(leg)
			SELECT MAX(leg) 
			FROM ' + @process_table
		)
		SELECT @max_leg = leg FROM #temp_max_leg
		SET @is_locked = 'n'
	END
	
	SELECT @granularity [granularity],
		   @max_leg [max_leg],
		   @term_start [term_start],
		   CASE WHEN @limit_term_end < @term_end THEN @limit_term_end ELSE @term_end END [term_end],
		   @process_id [process_id],
		   dbo.FNADateFormat(@min_term_start) [min_term_start],
		   dbo.FNADateFormat(@max_term_end) [max_term_end],
		   @is_locked [is_locked],
		   dbo.FNADateFormat(@dst_term) [dst_term]
		   
	--SELECT @process_table
	RETURN
END

-- Returns Grid Definitions
IF @flag = 't'
BEGIN
	IF @granularity IN (982, 989, 987, 994, 995)
	BEGIN		
		SELECT @column_list = COALESCE(@column_list + ',', '') + process_clm_name,
			   @column_label = COALESCE(@column_label + ',', '') + alias_name,
			   @column_type = COALESCE(@column_type + ',', '') + 'ed_no',
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
			   @column_type = COALESCE(@column_type + ',', '') + 'ed_no',
			   @column_width = COALESCE(@column_width + ',', '') + '150',
			   @column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
		FROM #temp_shaped_terms		
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
		   @granularity [granularity],
		   @max_leg [max_leg],
		   @column_visibility [visibility]
END
-- Returns data
IF @flag = 'a'
BEGIN
	IF @granularity IN (982, 989, 987, 994, 995)
	BEGIN		
		SELECT @column_list = COALESCE(@column_list + ',', '') + 'dbo.FNARemoveTrailingZero([' + process_clm_name + ']) [' + process_clm_name + ']'
		FROM #temp_hour_breakdown
		SET @column_list = 'source_deal_detail_id,leg,type,type_name,term_date,' + @column_list
	END
	ELSE
	BEGIN
		SELECT @column_list = COALESCE(@column_list + ',', '') + 'dbo.FNARemoveTrailingZero([' + CONVERT(VARCHAR(8), term_start, 112) + ']) [' + CONVERT(VARCHAR(8), term_start, 112) + ']'
		FROM #temp_shaped_terms
		WHERE term_start <= @term_end
		SET @column_list = 'source_deal_detail_id,leg,type,type_name,' + @column_list
	END

	SET @sql = 'SELECT ' + @column_list + ' FROM ' + @process_table + ' 
	            WHERE term_date >= ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''' 
	            AND term_date <= ''' + CONVERT(VARCHAR(10), @term_end, 120) + '''  
	            ' + CASE WHEN @volume_price IS NOT NULL THEN ' AND type = ''' + @volume_price + '''' ELSE '' END + '
	            ' + CASE WHEN @source_deal_detail_id IS NOT NULL THEN ' AND source_deal_detail_id = ''' + @source_deal_detail_id + '''' ELSE '' END + '
	            ' + CASE WHEN @leg IS NOT NULL THEN ' AND leg = ' + CAST(@leg AS VARCHAR(10)) + '' ELSE '' END + '
	            ORDER BY term_date'
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
		
			IF @granularity IN (982, 989, 987, 994, 995)
			BEGIN		
				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + process_clm_name + '] = CAST(NULLIF(temp.[col_' + process_clm_name + '], '''') AS NUMERIC(38,20))',
					   @sum_column = COALESCE(@sum_column + '+', '') + 'ISNULL([' + process_clm_name + '], 0)'
				FROM #temp_hour_breakdown
				INNER JOIN (SELECT DISTINCT columns_name FROM #temp_header_columns) temp ON temp.columns_name = 'col_' + process_clm_name
				WHERE temp.columns_name NOT IN ('total_volume')
			END
			ELSE
			BEGIN
				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] = CAST(NULLIF(temp.[col_' + + CONVERT(VARCHAR(8), term_start, 112) + '], '''') AS NUMERIC(38, 20))',
					   @sum_column = COALESCE(@sum_column + '+', '') + 'ISNULL([' + CONVERT(VARCHAR(8), term_start, 112) + '], 0)'
				FROM #temp_shaped_terms tat
				INNER JOIN (SELECT DISTINCT columns_name FROM #temp_header_columns) temp ON temp.columns_name = 'col_' + + CONVERT(VARCHAR(8), term_start, 112)
				WHERE temp.columns_name NOT IN ('total_volume')
			END

			SET @sql = '
				UPDATE pt 
				SET ' + @column_list + '
				FROM ' + @process_table + ' pt
				INNER JOIN ' + @xml_process_table + ' temp 
					ON pt.source_deal_detail_id = temp.col_source_deal_detail_id
					AND pt.[type] = temp.col_type			
			'

			IF @granularity IN (982, 989, 987, 994, 995)
				SET @sql += ' AND pt.term_date = temp.col_term_date'
			--PRINT(@sql)
			EXEC(@sql)

			
			IF EXISTS (
				SELECT 1 
				FROM source_deal_header 
				WHERE source_Deal_header_id = @source_deal_header_id
					AND deal_reference_type_id = 12503
			)
			BEGIN
				SELECT @offset_deal_ids = CAST(close_reference_id AS VARCHAR(1000))				  
				FROM source_deal_header 
				WHERE source_deal_header_id = @source_deal_header_id
			END
			ELSE IF EXISTS (
				SELECT 1 
				FROM source_deal_header 
				WHERE close_reference_id = @source_deal_header_id
					AND close_reference_id IS NOT NULL
			) 
			BEGIN
				SELECT @offset_deal_ids = ISNULL( @offset_deal_ids + ', ' , '') + CAST(source_deal_header_id AS VARCHAR(1000))				  
				FROM source_deal_header 
				WHERE close_reference_id = @source_deal_header_id

				SELECT @transfer_deal_ids = ISNULL( @transfer_deal_ids + ', ' , '') + CAST(source_deal_header_id AS VARCHAR(1000))
				FROM source_deal_header sdh
				INNER JOIN dbo.SplitCommaSeperatedValues(@offset_deal_ids) t
					ON t.item = sdh.close_reference_id				
			END
			
			IF @transfer_deal_ids IS NOT NULL OR @offset_deal_ids IS NOT NULL
			BEGIN
				DECLARE @date_cols VARCHAR(MAX)

				SELECT  @date_cols = ISNULL(@date_cols + ', ', '') + 'a.[' + SUBSTRING(columns_name, 5, LEN(columns_name))+ ']'
				FROM ( SELECT DISTINCT columns_name
				FROM #temp_header_columns
				WHERE columns_name LIKE 'col[_][0-9][0-9]%') a


				SET @sql = 'INSERT INTO  ' +  @process_table + '
							SELECT sdd.source_deal_detail_id			
								, a.leg
								, a.term_date
								, a.is_dst
								, a.old_source_deal_detail_id
								, a.type
								, a.type_name
								, a.granularity
								, a.dst_present
								, ' + @date_cols + '		
							FROM source_deal_detail sdd
							CROSS JOIN ' +  @process_table + ' a
							INNER JOIN source_Deal_detail sdd_org
								ON sdd_org.source_deal_detail_id  = a.source_deal_detail_id
								AND sdd.term_start = sdd_org.term_start
								AND sdd.term_end = sdd_org.term_end
								AND sdd.leg = sdd_org.leg
							WHERE sdd.source_Deal_header_id IN ('+ ISNULL(@offset_deal_ids, '') + ISNULL(', ' + @transfer_deal_ids , '') +') '
				--print @sql
				EXEC(@sql)
			END

			EXEC('DROP TABLE ' + @xml_process_table)		
		END

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
 
		SET @desc = 'Fail to save Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'table_name'
		   , 'spa_name'
		   , 'Error'
		   , @desc
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

			CREATE TABLE #temp_source_deal_detail_hour(source_deal_detail_id VARCHAR(100) COLLATE DATABASE_DEFAULT , term_date DATETIME, hr VARCHAR(20) COLLATE DATABASE_DEFAULT , is_dst INT, volume NUMERIC(38, 20), price NUMERIC(38, 20), old_source_deal_detail_id VARCHAR(100) COLLATE DATABASE_DEFAULT , leg INT)

			IF OBJECT_ID('tempdb..#temp_inserted_updated_deal') IS NOT NULL
				DROP TABLE #temp_inserted_updated_deal
			CREATE TABLE #temp_inserted_updated_deal(source_deal_detail_id INT)

			DECLARE @select_statement VARCHAR(MAX)
			DECLARE @select_statement2 VARCHAR(MAX)
			DECLARE @for_statement VARCHAR(MAX)
			DECLARE @where_statement VARCHAR(MAX)
			DECLARE @sdd_filter VARCHAR(MAX) = ''

			IF EXISTS (
				SELECT 1 
				FROM source_deal_header 
				WHERE source_Deal_header_id = @source_deal_header_id
					AND deal_reference_type_id = 12503
			)
			BEGIN
				SELECT @offset_deal_ids = CAST(close_reference_id AS VARCHAR(1000))				  
				FROM source_deal_header 
				WHERE source_deal_header_id = @source_deal_header_id
			END
			ELSE IF EXISTS (
				SELECT 1 
				FROM source_deal_header 
				WHERE close_reference_id = @source_deal_header_id
					AND close_reference_id IS NOT NULL
			) 
			BEGIN
				SELECT @offset_deal_ids = ISNULL( @offset_deal_ids + ', ' , '') + CAST(source_deal_header_id AS VARCHAR(1000))				  
				FROM source_deal_header 
				WHERE close_reference_id = @source_deal_header_id

				SELECT @transfer_deal_ids = ISNULL( @transfer_deal_ids + ', ' , '') + CAST(source_deal_header_id AS VARCHAR(1000))
				FROM source_deal_header sdh
				INNER JOIN dbo.SplitCommaSeperatedValues(@offset_deal_ids) t
					ON t.item = sdh.close_reference_id				
			END

			DECLARE @tran_sdds VARCHAR(1000) = ''

			SELECT @tran_sdds =  @tran_sdds + ', ' +  CAST(a.source_deal_detail_id AS VARCHAR(10))
			FROM (
				SELECT DISTINCT sdd.source_deal_detail_id 
				FROM source_deal_detail sdd
				INNER JOIN source_deal_detail_hour sddh
					ON sdd.source_deal_detail_id = sddh.source_deal_detail_id	
				INNER JOIN dbo.SplitCommaSeperatedValues(@offset_deal_ids) t		
					ON t.item = sdd.source_deal_header_id 
				UNION ALL
				SELECT DISTINCT sdd.source_deal_detail_id 
				FROM source_deal_detail sdd
				INNER JOIN source_deal_detail_hour sddh
					ON sdd.source_deal_detail_id = sddh.source_deal_detail_id	
				INNER JOIN dbo.SplitCommaSeperatedValues(@transfer_deal_ids) t		
					ON t.item = sdd.source_deal_header_id 

			) a
									

			IF @granularity IN (982, 989, 987, 994, 995)
			BEGIN		
				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + process_clm_name + ']',
					   @select_list = COALESCE(@select_list + ',', '') + 'ISNULL([' + process_clm_name + '], 0) [' + process_clm_name + ']'
				FROM #temp_hour_breakdown
			
				SET @select_statement = 'SELECT source_deal_detail_id, old_source_deal_detail_id, leg, term_date, NULLIF(volume, 0) [volume], NULL price, REPLACE(REPLACE(hrs, ''_DST'', ''''), ''_'', '':'') hr, IIF(RIGHT(hrs, 4)=''_DST'', 1, 0) is_dst'
				SET @select_statement2 = 'SELECT source_deal_detail_id, old_source_deal_detail_id, leg, term_date, NULLIF(price, 0) [price], REPLACE(REPLACE(hrs, ''_DST'', ''''), ''_'', '':'') hr, IIF(RIGHT(hrs, 4)=''_DST'', 1, 0) is_dst'
				SET @for_statement = 'hrs'
			END
			ELSE
			BEGIN
				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + ']',
					   @select_list = COALESCE(@select_list + ',', '') + 'ISNULL([' + CONVERT(VARCHAR(8), term_start, 112) + '], 0) [' + CONVERT(VARCHAR(8), term_start, 112) + ']'
				FROM #temp_shaped_terms tat

				SET @select_statement = 'SELECT source_deal_detail_id, old_source_deal_detail_id, leg, term_date2, NULLIF(volume, 0) [volume], NULL price, ''01:00'' hr, 0'
				SET @select_statement2 = 'SELECT source_deal_detail_id, old_source_deal_detail_id, leg, term_date2 term_date, NULLIF(price, 0) [price], ''01:00'' hr, 0 is_dst'
				SET @for_statement = 'term_date2'
			END
			
			IF @source_deal_detail_id IS NOT NULL
			BEGIN
				SET @sdd_filter = '
								INNER JOIN dbo.SplitCommaSeperatedValues(''' + @source_deal_detail_id +  @tran_sdds + ''') t
								ON t.item = source_deal_detail_id '

			END
			
			IF @leg IS NOT NULL
			BEGIN
				SET @where_statement = ISNULL(@where_statement, '') + ' AND leg = ' + CAST(@leg AS VARCHAR(20))
			END
			SET @sql = '
					INSERT INTO #temp_source_deal_detail_hour(source_deal_detail_id, old_source_deal_detail_id, leg, term_date, volume, price, [hr],is_dst)
					' + @select_statement + '
					FROM (
						SELECT source_deal_detail_id, old_source_deal_detail_id, leg, term_date, ' + @select_list + '
						FROM ' + @process_table + '  WHERE [type] = ''v''
						' + ISNULL(@where_statement, '') + '
					) tmp
					UNPIVOT (
						volume
						FOR ' + @for_statement + '
						IN (
							' + @column_list + '
						) 
					) unpvt

					UPDATE temp
					SET price = unpvt.price
					FROM #temp_source_deal_detail_hour temp
					INNER JOIN (
						' + @select_statement2 + '
						FROM (
							SELECT source_deal_detail_id, old_source_deal_detail_id, leg, term_date, ' + @select_list + '
							FROM ' + @process_table + @sdd_filter  + ' WHERE [type] = ''p''
							' + ISNULL(@where_statement, '') + '
						) tmp
						UNPIVOT (
							price
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
			--PRINT(@sql)
			EXEC(@sql)


			IF @dst_term IS NOT NULL
			BEGIN				
				DELETE 
				FROM #temp_source_deal_detail_hour
				WHERE term_date <> @dst_term
				AND is_dst = 1
			END				

			UPDATE sddh
			SET volume = temp.volume,
				price = temp.price,
				granularity = @granularity
			OUTPUT INSERTED.source_deal_detail_id INTO #temp_inserted_updated_deal(source_deal_detail_id)
			FROM source_deal_detail_hour sddh
			INNER JOIN #temp_source_deal_detail_hour temp
				ON temp.source_deal_detail_id = sddh.source_deal_detail_id
				AND temp.term_date = sddh.term_date
				AND temp.hr = sddh.hr
				AND temp.is_dst = sddh.is_dst			
			INNER JOIN source_deal_detail sdd 
				ON sdd.source_deal_detail_id = temp.source_deal_detail_id
				AND temp.term_date BETWEEN sdd.term_start AND sdd.term_end
			WHERE (ISNULL(sddh.volume, -1) <> ISNULL(temp.volume, -1)
			OR ISNULL(sddh.price, -1) <> ISNULL(temp.price, -1))
			AND temp.source_deal_detail_id NOT LIKE '%NEW_%'
			
			
			INSERT INTO source_deal_detail_hour (source_deal_detail_id, term_date, hr, is_dst, volume, price, granularity)
			OUTPUT INSERTED.source_deal_detail_id INTO #temp_inserted_updated_deal(source_deal_detail_id)
			SELECT sdd.source_deal_detail_id, temp.term_date, temp.hr, temp.is_dst , SUM(temp.volume), SUM(temp.price), @granularity
			FROM #temp_source_deal_detail_hour temp
			INNER JOIN source_deal_detail sdd 
				ON sdd.source_deal_header_id = @source_deal_header_id				
				AND temp.term_date BETWEEN sdd.term_start AND sdd.term_end
			LEFT JOIN source_deal_detail_hour sddh
				ON temp.source_deal_detail_id = sddh.source_deal_detail_id
				AND temp.term_date = sddh.term_date
				AND temp.hr = sddh.hr
				AND temp.is_dst = sddh.is_dst
			WHERE sddh.source_deal_detail_id IS NULL
			AND temp.source_deal_detail_id NOT LIKE '%NEW_%'
			AND sdd.source_deal_detail_id = CASE WHEN temp.old_source_deal_detail_id LIKE '%NEW_%' THEN sdd.source_deal_detail_id ELSE temp.source_deal_detail_id END
			AND sdd.leg = CASE WHEN temp.old_source_deal_detail_id LIKE '%NEW_%' THEN temp.leg ELSE sdd.leg END
			GROUP BY sdd.source_deal_detail_id, temp.term_date, temp.hr, temp.is_dst
							
			UPDATE sdd
			SET deal_volume = sddh.volume,
				-- Added logic to update the value only if the price is added from Update Volume
				fixed_price = ISNULL(sddh.price, sdd.fixed_price)
			FROM source_deal_detail sdd
			INNER JOIN (SELECT DISTINCT source_deal_detail_id FROM #temp_inserted_updated_deal) temp ON sdd.source_deal_detail_id = temp.source_deal_detail_id
			OUTER APPLY (
				SELECT sddh.source_deal_detail_id,
					   AVG(sddh.volume) volume,
				       SUM(sddh.price * sddh.volume) / NULLIF(SUM(sddh.volume), 0) price
				FROM source_deal_detail_hour sddh
				WHERE sddh.source_deal_detail_id = temp.source_deal_detail_id
				GROUP BY sddh.source_deal_detail_id
			) sddh
			
			DECLARE @total_volume FLOAT, @total_price FLOAT
			DECLARE @recommendation VARCHAR(1000)
			
			IF EXISTS(SELECT 1 FROM #temp_source_deal_detail_hour) AND (@template_id IS NOT NULL OR @source_deal_detail_id LIKE '%NEW_%') 
			BEGIN 				
				SELECT @total_volume = sddh.volume,
					   @total_price = sddh.price 				
				FROM (
					SELECT AVG(sddh.volume) volume,
						   SUM(sddh.price * sddh.volume) / NULLIF(SUM(sddh.volume), 0) price
					FROM #temp_source_deal_detail_hour sddh
					WHERE sddh.source_deal_detail_id = @source_deal_detail_id
					GROUP BY sddh.source_deal_detail_id
				) sddh
			END
			
			SET @recommendation = CAST(@total_volume AS VARCHAR(500))
			
			IF @recommendation IS NOT NULL				 
				SET @recommendation = @recommendation + ISNULL('::' + CAST(@total_price AS VARCHAR(500)), '')
			ELSE 
				SET @recommendation = '::' + CAST(@total_price AS VARCHAR(500))
				
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
		END
		
		/* Update timestamp and user of the deal whose shaped volume are updated. */
		UPDATE source_deal_header
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		WHERE source_deal_header_id = @source_deal_header_id

		/* Update timestamp and user of child deals(offset/transfer) when parent deal is updated*/
		UPDATE sdh
			SET update_user = sdh.update_user
			   ,update_ts = sdh.update_ts
		FROM dbo.SplitCommaSeperatedValues(@offset_deal_ids) t
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = t.item

		UPDATE sdh
			SET update_user = sdh.update_user
			   ,update_ts = sdh.update_ts
		FROM dbo.SplitCommaSeperatedValues(@transfer_deal_ids) t
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = t.item
		/*End of timestamp and user update*/

		COMMIT
		
		IF @response = 'y'
			EXEC spa_ErrorHandler 0
				, 'source_deal_detail_hour'
				, 'spa_update_actual'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, @recommendation
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @desc = 'Fail to save Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'source_deal_detail_hour'
		   , 'spa_update_actual'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH 	
END
