BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '4E837672_DF0E_457A_B67C_03311778B611'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Retail LT Gas Shaped ESALES'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				-- Added to preserve rule detail like folder location, File endpoint details.
				IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
					DROP TABLE #pre_ixp_import_data_source

				SELECT rules_id
					, folder_location
					, file_transfer_endpoint_id
					, remote_directory 
				INTO #pre_ixp_import_data_source
				FROM ixp_import_data_source 
				WHERE rules_id = @old_ixp_rule_id

				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Retail LT Gas Shaped ESALES' ,
					'N' ,
					NULL ,
					'UPDATE a
	SET [Term Date] = dd.sql_date_string
FROM [temp_process_table] a
INNER JOIN vw_date_details dd
	ON a.[Term Date] = dd.user_date

-- GAS SHIFT Date
UPDATE a
SET [Term Date] = CAST(DATEADD(DD,-1, [Term Date]) AS DATE) 
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date]
		BETWEEN sdd.term_start
		AND DATEADD(DAY, 1, sdd.term_end)
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1
    AND 
		( sdh.profile_granularity = 982
		AND (a.[Hour] BETWEEN 1 AND 6))
	

UPDATE a
SET [Term Date] = CAST(DATEADD(DD,-1, [Term Date]) AS DATE) 
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date]
		BETWEEN sdd.term_start
		AND DATEADD(DAY, 1, sdd.term_end)
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1
    AND (
			sdh.profile_granularity <> 982
			AND a.[Hour] BETWEEN 0 AND 5
			)

UPDATE a
SET [Term Date] = CAST(DATEADD(DD,-1, [Term Date]) AS DATE) 
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date]
		BETWEEN sdd.term_start
		AND DATEADD(DAY, 1, sdd.term_end)
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1
    AND (
			sdh.profile_granularity <> 982
			AND (a.[Hour] = 6 and a.[Minute] = 0))
-- End of GAS SHIFT Date		

IF OBJECT_ID(N''tempdb..#curve_max_term'') IS NOT NULL
	DROP TABLE #curve_max_term
-- DEAL List
CREATE TABLE #curve_max_term (
	  term_start DATE
	, term_end DATE
	, as_of_date DATE
	, pfc_curve INT
	, curve_granularity INT
	, deal_granularity INT
)

INSERT INTO #curve_max_term (term_start, term_end, as_of_date, pfc_curve, curve_granularity, deal_granularity)
SELECT min([Term Date]) term_start, max(dc.[Term_end]) term_end, max(mx.as_of_date), (dc.curve_id),
	max(mx.Granularity), max(dc.profile_granularity)
FROM [temp_process_table] a
OUTER APPLY (
	SELECT sdd.term_start, sdd.term_end, sdh.source_deal_header_id source_deal_header_id, sdd.curve_id curve_id,sdh.profile_granularity profile_granularity
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
		and sdd.leg = a.leg
		and sdd.term_start = a.[Term Date]
	WHERE a.[Deal Ref ID] = sdh.deal_id
) dc
OUTER APPLY (
	SELECT top 1 spc.as_of_date as_of_date, spc.curve_value, spc.source_curve_def_id pfc_curve , spcd.Granularity Granularity
	FROM source_price_curve spc
	INNER JOIN source_price_curve_def spcd
		ON spcd.source_curve_def_id = spc.source_curve_def_id
	WHERE spc.source_curve_def_id = dc.curve_id
	and spc.maturity_date = dc.term_start
	AND spc.curve_source_value_id = 4500
	order by spc.as_of_date desc
) mx
WHERE dc.curve_id IS NOT NULL
group by dc.curve_id

IF OBJECT_ID(N''tempdb..#price_from_curve'') IS NOT NULL
	DROP TABLE #price_from_curve
-- @@ dataset1  PFC
CREATE TABLE #price_from_curve (
	  term_date date
	, curve_value float(53)
	, is_dst int
	, Granularity int
	, hour	int
	, minute int
)
IF EXISTS (
		SELECT 1
		FROM #curve_max_term
		WHERE deal_granularity = 987
			AND curve_granularity = 982
		)
BEGIN
	INSERT INTO #price_from_curve
	SELECT 
		CAST(spc.maturity_date AS DATE) [term_date],
		spc.curve_value,
		spc.is_dst,
		spcd.Granularity,
		IIF(minute <> 0, DATEPART(HH,maturity_date), (DATEPART(HH,maturity_date) + 1))  [hour],
		--DATEPART(MINUTE,maturity_date) [minute],
		minute
	FROM #curve_max_term cmt
	INNER JOIN source_price_curve_def spcd
		ON  spcd.source_curve_def_id = cmt.pfc_curve
	INNER JOIN source_price_curve spc
		ON spc.source_curve_def_id = spcd.source_curve_def_id
	CROSS JOIN (
			VALUES (0),(15),(30),(45)
	) rs (minute)
	WHERE spc.as_of_date = cmt.as_of_date
		AND spc.maturity_date >= cmt.term_start
		AND spc.maturity_date <= DATEADD(dd,1,cmt.term_end)
		AND spc.source_curve_def_id = cmt.pfc_curve
		AND spc.curve_source_value_id = 4500
END
ELSE
BEGIN
	INSERT INTO #price_from_curve
	SELECT DISTINCT
		CAST(spc.maturity_date AS DATE) [term_date],
		spc.curve_value,
		spc.is_dst,
		spcd.Granularity,
		(DATEPART(HH,maturity_date) + 1)  [hour],
		DATEPART(MINUTE,maturity_date) [minute]
	FROM #curve_max_term cmt
	INNER JOIN source_price_curve_def spcd
		ON  spcd.source_curve_def_id = cmt.pfc_curve
	INNER JOIN source_price_curve spc
		ON spc.source_curve_def_id = spcd.source_curve_def_id
	WHERE spc.as_of_date = cmt.as_of_date
		AND spc.maturity_date >= cmt.term_start
		AND spc.maturity_date <= DATEADD(dd,2,cmt.term_end)
		AND spc.source_curve_def_id = cmt.pfc_curve
		AND spc.curve_source_value_id = 4500
END

DECLARE @dst_group_value_id INT 
	, @granularity INT 
	, @min_term DATETIME 
	, @max_term DATETIME

SELECT @dst_group_value_id = tz.dst_group_value_id	--102201
FROM adiha_default_codes_values adcv
INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
WHERE adcv.default_code_id = 36

SELECT @granularity = deal_granularity
	, @min_term = term_start
	, @max_term = term_end
FROM #curve_max_term

-- Granularity Column
IF OBJECT_ID(''tempdb..#temp_hour_breakdown'') IS NOT NULL
	DROP TABLE #temp_hour_breakdown

SELECT clm_name, is_dst, REPLACE(alias_name,''DST'','''') [user_clm],
	CASE 
		WHEN is_dst = 0 THEN RIGHT(''0'' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '':'' + RIGHT(clm_name, 2) 
		ELSE RIGHT(''0'' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '':'' + RIGHT(clm_name, 2) 
	END [process_clm]
INTO #temp_hour_breakdown
FROM dbo.[FNAGetDisplacedPivotGranularityColumn](@min_term,@max_term,@granularity,@dst_group_value_id,6) 

-- Shift DATE for PFC
UPDATE pfc
SET [Term_date] = CAST(DATEADD(DD,-1, [Term_date]) AS DATE)
FROM #price_from_curve pfc
WHERE 1 = 1
	AND (pfc.Granularity = 982
		AND (pfc.[hour] BETWEEN 1 AND 6))

UPDATE pfc
SET [Term_date] = CAST(DATEADD(DD,-1, [Term_date]) AS DATE)
FROM #price_from_curve pfc
WHERE 1 = 1
	AND (
			pfc.Granularity <> 982
			AND pfc.[Hour] BETWEEN 0 AND 5
		)

UPDATE pfc
SET [Term_date] = CAST(DATEADD(DD,-1, [Term_date]) AS DATE)
FROM #price_from_curve pfc
WHERE 1 = 1
	AND ( pfc.Granularity <> 982
			AND pfc.[Hour] = 6 and pfc.[minute] = 0
		)
-- End of shift DATE for PFC

IF OBJECT_ID(''tempdb..#deal_data'') IS NOT NULL
	DROP TABLE #deal_data
CREATE TABLE #deal_data(
	source_deal_header_id INT,
	deal_id NVARCHAR(400),
	source_deal_detail_id INT,
	parent_deal_id NVARCHAR(400),
	term_date DATE
)
INSERT INTO #deal_data(source_deal_header_id,deal_id,source_deal_detail_id, parent_deal_id,term_date)
SELECT DISTINCT sdh2.source_deal_header_id, sdh2.deal_id, sdd.source_deal_detail_id, a.[Deal Ref ID], a.[Term Date]
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = a.[Deal Ref ID]  
INNER JOIN source_deal_header sdh2
	ON sdh2.close_reference_id = sdh.source_deal_header_id
INNER JOIN source_deal_detail sdd
	ON sdh2.source_deal_header_id = sdd.source_deal_header_id
	AND sdd.leg = a.leg
	AND a.[Term Date] BETWEEN sdd.term_start AND sdd.term_end
UNION ALL
SELECT DISTINCT sdh3.source_deal_header_id, sdh3.deal_id, sdd.source_deal_detail_id, a.[Deal Ref ID], a.[Term Date]
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = a.[Deal Ref ID]  
INNER JOIN source_deal_header sdh2
	ON sdh2.close_reference_id = sdh.source_deal_header_id
INNER JOIN source_deal_header sdh3
		ON sdh3.close_reference_id = sdh2.source_deal_header_id
INNER JOIN source_deal_detail sdd
	ON sdh3.source_deal_header_id = sdd.source_deal_header_id
	AND sdd.leg = a.leg
	AND a.[Term Date] BETWEEN sdd.term_start AND sdd.term_end

IF OBJECT_ID(''tempdb..#source_deal_detail_hour'') IS NOT NULL
	DROP TABLE #source_deal_detail_hour

SELECT dd.source_deal_header_id, dd.source_deal_detail_id, dd.parent_deal_id, sddh.volume, sddh.price, sddh.hr, sddh.is_dst, CAST(sddh.term_date AS DATE) term_date
INTO #source_deal_detail_hour
FROM #deal_data dd	
INNER JOIN source_deal_detail_hour sddh
	ON sddh.source_deal_detail_id = dd.source_deal_detail_id
	AND CAST(sddh.term_date as date) = dd.[term_date]

-- calculate and built offset and xfered datasets
INSERT INTO [temp_process_table] (
	 [Deal Ref ID]
	,[Term Date]
	,[Hour]
	,[Minute]
	,[Is DST]
	,[Volume]
	,[Actual Volume]
	,[Schedule Volume]
	,[Price]
	,[Leg]
)
SELECT  DISTINCT dd.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	cast((ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume as numeric(38,10)) [Price], a.Leg
FROM [temp_process_table] a
INNER JOIN #deal_data dd	
	ON dd.parent_deal_id = a.[Deal Ref ID]
	AND dd.term_date = a.[Term Date]
INNER JOIN #price_from_curve  pfc
	ON IIF(a.[Is DST] = 1, DATEADD(DD,1,a.[Term Date]),a.[Term Date]) = pfc.term_date
	and a.Hour = pfc.hour
	and ISNULL(a.Minute,0) = pfc.minute
	and a.[Is DST] = pfc.is_dst
INNER JOIN #source_deal_detail_hour sddh
	ON sddh.source_deal_header_id = dd.source_deal_header_id
	AND sddh.term_date = dd.term_date
INNER JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
	AND CAST(LEFT(thb.user_clm, 2) AS INT) = CAST(a.Hour AS INT)
	AND CAST(RIGHT(thb.user_clm, 2) AS INT) = ISNULL(CAST(a.Minute AS INT), 0)
	AND thb.is_dst = a.[Is DST]
UNION ALL
SELECT  DISTINCT dd.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	cast((ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume as numeric(38,10)) [Price], a.Leg
FROM [temp_process_table] a
INNER JOIN #deal_data dd	
	ON dd.parent_deal_id = a.[Deal Ref ID]
	AND dd.term_date = a.[Term Date]
INNER JOIN #price_from_curve  pfc
	ON IIF(a.[Is DST] = 1, DATEADD(DD,1,a.[Term Date]),a.[Term Date]) = pfc.term_date
	and a.Hour = pfc.hour
	and ISNULL(a.Minute,0) = pfc.minute
	and a.[Is DST] = pfc.is_dst
LEFT JOIN #source_deal_detail_hour sddh
	ON sddh.source_deal_header_id = dd.source_deal_header_id
	AND sddh.term_date = dd.term_date
LEFT JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
WHERE sddh.source_deal_detail_id IS NULL
	  AND thb.clm_name IS NULL

-- Gas Shift Hour
UPDATE a
SET [Hour] = CASE WHEN [HOUR] BETWEEN  7 AND 24 THEN [HOUR] - 6
        WHEN [HOUR] = 6 AND ISNULL([Minute], '''') <> 0 THEN 0
		WHEN [HOUR] BETWEEN 0 AND 6 THEN [HOUR] + 18
	ELSE [HOUR]
	END
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date] BETWEEN sdd.term_start
		AND sdd.term_end
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1',
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23502,
					1,
					'4E837672_DF0E_457A_B67C_03311778B611'
					 )

				SET @ixp_rules_id_new = SCOPE_IDENTITY()
				EXEC spa_print 	@ixp_rules_id_new

				UPDATE ixp
				SET import_export_id = @ixp_rules_id_new
				FROM ipx_privileges ixp
				WHERE ixp.import_export_id = @old_ixp_rule_id
		END
				
				

		ELSE 
		BEGIN
			SET @ixp_rules_id_new = @old_ixp_rule_id
			EXEC spa_print 	@ixp_rules_id_new
			
			UPDATE
			ixp_rules
			SET ixp_rules_name = 'Retail LT Gas Shaped ESALES'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'UPDATE a
	SET [Term Date] = dd.sql_date_string
FROM [temp_process_table] a
INNER JOIN vw_date_details dd
	ON a.[Term Date] = dd.user_date

-- GAS SHIFT Date
UPDATE a
SET [Term Date] = CAST(DATEADD(DD,-1, [Term Date]) AS DATE) 
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date]
		BETWEEN sdd.term_start
		AND DATEADD(DAY, 1, sdd.term_end)
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1
    AND 
		( sdh.profile_granularity = 982
		AND (a.[Hour] BETWEEN 1 AND 6))
	

UPDATE a
SET [Term Date] = CAST(DATEADD(DD,-1, [Term Date]) AS DATE) 
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date]
		BETWEEN sdd.term_start
		AND DATEADD(DAY, 1, sdd.term_end)
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1
    AND (
			sdh.profile_granularity <> 982
			AND a.[Hour] BETWEEN 0 AND 5
			)

UPDATE a
SET [Term Date] = CAST(DATEADD(DD,-1, [Term Date]) AS DATE) 
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date]
		BETWEEN sdd.term_start
		AND DATEADD(DAY, 1, sdd.term_end)
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1
    AND (
			sdh.profile_granularity <> 982
			AND (a.[Hour] = 6 and a.[Minute] = 0))
-- End of GAS SHIFT Date		

IF OBJECT_ID(N''tempdb..#curve_max_term'') IS NOT NULL
	DROP TABLE #curve_max_term
-- DEAL List
CREATE TABLE #curve_max_term (
	  term_start DATE
	, term_end DATE
	, as_of_date DATE
	, pfc_curve INT
	, curve_granularity INT
	, deal_granularity INT
)

INSERT INTO #curve_max_term (term_start, term_end, as_of_date, pfc_curve, curve_granularity, deal_granularity)
SELECT min([Term Date]) term_start, max(dc.[Term_end]) term_end, max(mx.as_of_date), (dc.curve_id),
	max(mx.Granularity), max(dc.profile_granularity)
FROM [temp_process_table] a
OUTER APPLY (
	SELECT sdd.term_start, sdd.term_end, sdh.source_deal_header_id source_deal_header_id, sdd.curve_id curve_id,sdh.profile_granularity profile_granularity
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
		and sdd.leg = a.leg
		and sdd.term_start = a.[Term Date]
	WHERE a.[Deal Ref ID] = sdh.deal_id
) dc
OUTER APPLY (
	SELECT top 1 spc.as_of_date as_of_date, spc.curve_value, spc.source_curve_def_id pfc_curve , spcd.Granularity Granularity
	FROM source_price_curve spc
	INNER JOIN source_price_curve_def spcd
		ON spcd.source_curve_def_id = spc.source_curve_def_id
	WHERE spc.source_curve_def_id = dc.curve_id
	and spc.maturity_date = dc.term_start
	AND spc.curve_source_value_id = 4500
	order by spc.as_of_date desc
) mx
WHERE dc.curve_id IS NOT NULL
group by dc.curve_id

IF OBJECT_ID(N''tempdb..#price_from_curve'') IS NOT NULL
	DROP TABLE #price_from_curve
-- @@ dataset1  PFC
CREATE TABLE #price_from_curve (
	  term_date date
	, curve_value float(53)
	, is_dst int
	, Granularity int
	, hour	int
	, minute int
)
IF EXISTS (
		SELECT 1
		FROM #curve_max_term
		WHERE deal_granularity = 987
			AND curve_granularity = 982
		)
BEGIN
	INSERT INTO #price_from_curve
	SELECT 
		CAST(spc.maturity_date AS DATE) [term_date],
		spc.curve_value,
		spc.is_dst,
		spcd.Granularity,
		IIF(minute <> 0, DATEPART(HH,maturity_date), (DATEPART(HH,maturity_date) + 1))  [hour],
		--DATEPART(MINUTE,maturity_date) [minute],
		minute
	FROM #curve_max_term cmt
	INNER JOIN source_price_curve_def spcd
		ON  spcd.source_curve_def_id = cmt.pfc_curve
	INNER JOIN source_price_curve spc
		ON spc.source_curve_def_id = spcd.source_curve_def_id
	CROSS JOIN (
			VALUES (0),(15),(30),(45)
	) rs (minute)
	WHERE spc.as_of_date = cmt.as_of_date
		AND spc.maturity_date >= cmt.term_start
		AND spc.maturity_date <= DATEADD(dd,1,cmt.term_end)
		AND spc.source_curve_def_id = cmt.pfc_curve
		AND spc.curve_source_value_id = 4500
END
ELSE
BEGIN
	INSERT INTO #price_from_curve
	SELECT DISTINCT
		CAST(spc.maturity_date AS DATE) [term_date],
		spc.curve_value,
		spc.is_dst,
		spcd.Granularity,
		(DATEPART(HH,maturity_date) + 1)  [hour],
		DATEPART(MINUTE,maturity_date) [minute]
	FROM #curve_max_term cmt
	INNER JOIN source_price_curve_def spcd
		ON  spcd.source_curve_def_id = cmt.pfc_curve
	INNER JOIN source_price_curve spc
		ON spc.source_curve_def_id = spcd.source_curve_def_id
	WHERE spc.as_of_date = cmt.as_of_date
		AND spc.maturity_date >= cmt.term_start
		AND spc.maturity_date <= DATEADD(dd,2,cmt.term_end)
		AND spc.source_curve_def_id = cmt.pfc_curve
		AND spc.curve_source_value_id = 4500
END

DECLARE @dst_group_value_id INT 
	, @granularity INT 
	, @min_term DATETIME 
	, @max_term DATETIME

SELECT @dst_group_value_id = tz.dst_group_value_id	--102201
FROM adiha_default_codes_values adcv
INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
WHERE adcv.default_code_id = 36

SELECT @granularity = deal_granularity
	, @min_term = term_start
	, @max_term = term_end
FROM #curve_max_term

-- Granularity Column
IF OBJECT_ID(''tempdb..#temp_hour_breakdown'') IS NOT NULL
	DROP TABLE #temp_hour_breakdown

SELECT clm_name, is_dst, REPLACE(alias_name,''DST'','''') [user_clm],
	CASE 
		WHEN is_dst = 0 THEN RIGHT(''0'' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '':'' + RIGHT(clm_name, 2) 
		ELSE RIGHT(''0'' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '':'' + RIGHT(clm_name, 2) 
	END [process_clm]
INTO #temp_hour_breakdown
FROM dbo.[FNAGetDisplacedPivotGranularityColumn](@min_term,@max_term,@granularity,@dst_group_value_id,6) 

-- Shift DATE for PFC
UPDATE pfc
SET [Term_date] = CAST(DATEADD(DD,-1, [Term_date]) AS DATE)
FROM #price_from_curve pfc
WHERE 1 = 1
	AND (pfc.Granularity = 982
		AND (pfc.[hour] BETWEEN 1 AND 6))

UPDATE pfc
SET [Term_date] = CAST(DATEADD(DD,-1, [Term_date]) AS DATE)
FROM #price_from_curve pfc
WHERE 1 = 1
	AND (
			pfc.Granularity <> 982
			AND pfc.[Hour] BETWEEN 0 AND 5
		)

UPDATE pfc
SET [Term_date] = CAST(DATEADD(DD,-1, [Term_date]) AS DATE)
FROM #price_from_curve pfc
WHERE 1 = 1
	AND ( pfc.Granularity <> 982
			AND pfc.[Hour] = 6 and pfc.[minute] = 0
		)
-- End of shift DATE for PFC

IF OBJECT_ID(''tempdb..#deal_data'') IS NOT NULL
	DROP TABLE #deal_data
CREATE TABLE #deal_data(
	source_deal_header_id INT,
	deal_id NVARCHAR(400),
	source_deal_detail_id INT,
	parent_deal_id NVARCHAR(400),
	term_date DATE
)
INSERT INTO #deal_data(source_deal_header_id,deal_id,source_deal_detail_id, parent_deal_id,term_date)
SELECT DISTINCT sdh2.source_deal_header_id, sdh2.deal_id, sdd.source_deal_detail_id, a.[Deal Ref ID], a.[Term Date]
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = a.[Deal Ref ID]  
INNER JOIN source_deal_header sdh2
	ON sdh2.close_reference_id = sdh.source_deal_header_id
INNER JOIN source_deal_detail sdd
	ON sdh2.source_deal_header_id = sdd.source_deal_header_id
	AND sdd.leg = a.leg
	AND a.[Term Date] BETWEEN sdd.term_start AND sdd.term_end
UNION ALL
SELECT DISTINCT sdh3.source_deal_header_id, sdh3.deal_id, sdd.source_deal_detail_id, a.[Deal Ref ID], a.[Term Date]
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = a.[Deal Ref ID]  
INNER JOIN source_deal_header sdh2
	ON sdh2.close_reference_id = sdh.source_deal_header_id
INNER JOIN source_deal_header sdh3
		ON sdh3.close_reference_id = sdh2.source_deal_header_id
INNER JOIN source_deal_detail sdd
	ON sdh3.source_deal_header_id = sdd.source_deal_header_id
	AND sdd.leg = a.leg
	AND a.[Term Date] BETWEEN sdd.term_start AND sdd.term_end

IF OBJECT_ID(''tempdb..#source_deal_detail_hour'') IS NOT NULL
	DROP TABLE #source_deal_detail_hour

SELECT dd.source_deal_header_id, dd.source_deal_detail_id, dd.parent_deal_id, sddh.volume, sddh.price, sddh.hr, sddh.is_dst, CAST(sddh.term_date AS DATE) term_date
INTO #source_deal_detail_hour
FROM #deal_data dd	
INNER JOIN source_deal_detail_hour sddh
	ON sddh.source_deal_detail_id = dd.source_deal_detail_id
	AND CAST(sddh.term_date as date) = dd.[term_date]

-- calculate and built offset and xfered datasets
INSERT INTO [temp_process_table] (
	 [Deal Ref ID]
	,[Term Date]
	,[Hour]
	,[Minute]
	,[Is DST]
	,[Volume]
	,[Actual Volume]
	,[Schedule Volume]
	,[Price]
	,[Leg]
)
SELECT  DISTINCT dd.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	cast((ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume as numeric(38,10)) [Price], a.Leg
FROM [temp_process_table] a
INNER JOIN #deal_data dd	
	ON dd.parent_deal_id = a.[Deal Ref ID]
	AND dd.term_date = a.[Term Date]
INNER JOIN #price_from_curve  pfc
	ON IIF(a.[Is DST] = 1, DATEADD(DD,1,a.[Term Date]),a.[Term Date]) = pfc.term_date
	and a.Hour = pfc.hour
	and ISNULL(a.Minute,0) = pfc.minute
	and a.[Is DST] = pfc.is_dst
INNER JOIN #source_deal_detail_hour sddh
	ON sddh.source_deal_header_id = dd.source_deal_header_id
	AND sddh.term_date = dd.term_date
INNER JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
	AND CAST(LEFT(thb.user_clm, 2) AS INT) = CAST(a.Hour AS INT)
	AND CAST(RIGHT(thb.user_clm, 2) AS INT) = ISNULL(CAST(a.Minute AS INT), 0)
	AND thb.is_dst = a.[Is DST]
UNION ALL
SELECT  DISTINCT dd.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	cast((ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume as numeric(38,10)) [Price], a.Leg
FROM [temp_process_table] a
INNER JOIN #deal_data dd	
	ON dd.parent_deal_id = a.[Deal Ref ID]
	AND dd.term_date = a.[Term Date]
INNER JOIN #price_from_curve  pfc
	ON IIF(a.[Is DST] = 1, DATEADD(DD,1,a.[Term Date]),a.[Term Date]) = pfc.term_date
	and a.Hour = pfc.hour
	and ISNULL(a.Minute,0) = pfc.minute
	and a.[Is DST] = pfc.is_dst
LEFT JOIN #source_deal_detail_hour sddh
	ON sddh.source_deal_header_id = dd.source_deal_header_id
	AND sddh.term_date = dd.term_date
LEFT JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
WHERE sddh.source_deal_detail_id IS NULL
	  AND thb.clm_name IS NULL

-- Gas Shift Hour
UPDATE a
SET [Hour] = CASE WHEN [HOUR] BETWEEN  7 AND 24 THEN [HOUR] - 6
        WHEN [HOUR] = 6 AND ISNULL([Minute], '''') <> 0 THEN 0
		WHEN [HOUR] BETWEEN 0 AND 6 THEN [HOUR] + 18
	ELSE [HOUR]
	END
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
    ON a.[Deal Ref ID] = sdh.deal_id
INNER JOIN source_deal_detail sdd 
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
	AND a.[Term Date] BETWEEN sdd.term_start
		AND sdd.term_end
	AND sdd.leg = a.[Leg]
LEFT JOIN source_price_curve_def spcd 
    ON spcd.source_curve_def_id = sdd.curve_id
WHERE spcd.commodity_id = -1'
				, after_insert_trigger = NULL
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23502
				, is_system_import = 'y'
				, is_active = 1
			WHERE ixp_rules_id = @ixp_rules_id_new
				
		END

				
INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)  
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  0,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\EU-U-SQL03\shared_docs_TRMTracker_Enercity_UAT\temp_Note\0',
						   NULL,
						   ';',
						   2,
						   'SD',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   '',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   icf.ixp_clr_functions_id,
						   '', 
						   '0',
						   '0',
						   '11',
						   'Import2TRM/RETAIL_Esales/DEAL_Retail_LT_Shaped_GAS'
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new
						IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
						BEGIN
							UPDATE iids
							SET folder_location = piids.folder_location
								, file_transfer_endpoint_id = piids.file_transfer_endpoint_id
								, remote_directory = piids.remote_directory
							FROM ixp_import_data_source iids
							INNER JOIN #pre_ixp_import_data_source piids 
							ON iids.rules_id = piids.rules_id
						END
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Deal Ref ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Term Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Hour]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hr' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Is DST]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_dst' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Price]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Leg]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Schedule Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'schedule_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Actual Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'actual_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'SD.[Minute]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'minute' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
INSERT INTO ixp_import_where_clause(rules_id, table_id, ixp_import_where_clause, repeat_number)  
										SELECT @ixp_rules_id_new,
										it.ixp_tables_id,
										NULL,
										0
										FROM ixp_tables it 
										WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template'
										
COMMIT 

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
				DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
				DECLARE @msg_severity INT = ERROR_SEVERITY();
				DECLARE @msg_state INT = ERROR_STATE();
					
				RAISERROR(@msg, @msg_severity, @msg_state)
			
				--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
END
		