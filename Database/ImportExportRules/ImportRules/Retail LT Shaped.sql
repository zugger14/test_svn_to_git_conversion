BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'EE76081F_5A1A_4D3A_BBB8_E23E5C3C2B1E'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Retail LT Shaped'
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
					'Retail LT Shaped' ,
					'N' ,
					NULL ,
					'
UPDATE [temp_process_table]
SET [Term Date] = CAST(dbo.FNAClientToSqlDate([Term Date]) AS DATE)

IF OBJECT_ID(N''tempdb..#generic_mapping_values'') IS NOT NULL
DROP TABLE #generic_mapping_values

DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header 
WHERE mapping_name = ''Transfer Volume Mapping''

SELECT gmv.[mapping_table_id]
	   , gmv.[clm2_value]  [effective_date]
	   , gmv.[clm17_value] [cummulative_delta]
	   , gmv.[clm18_value] [pfc_curve]
	   , gmv.[clm19_value] [aggregation_level]
INTO #generic_mapping_values
FROM  generic_mapping_header gmh
INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id
CROSS APPLY (
	SELECT clm1_value, clm2_value, clm3_value, clm4_value
	FROM generic_mapping_values gmv 
	WHERE gmv.mapping_table_id = gmh.mapping_table_id
	GROUP BY clm1_value, clm2_value, clm3_value, clm4_value
) mx
INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id 
	AND gmv.clm1_value = mx.clm1_value
	AND gmv.clm2_value = mx.clm2_value
	AND ISNULL(gmv.clm3_value, 1) = ISNULL(mx.clm3_value, 1)
	AND ISNULL(gmv.clm4_value, 1) = ISNULL(mx.clm4_value, 1)
OUTER APPLY(
	SELECT MAX(gmv.[clm2_value]) [clm2_value]
	FROM generic_mapping_values gmv
	INNER JOIN source_price_curve_def spcd 
		ON spcd.source_curve_def_id = gmv.clm18_value
	INNER JOIN source_commodity sc
		ON sc.source_commodity_id = spcd.commodity_id
	WHERE gmv.mapping_table_id = gmh.mapping_table_id 
		AND gmv.clm1_value = 112701
		AND gmv.mapping_table_id = @mapping_table_id
		AND sc.commodity_id = ''Power''
) mx2
WHERE gmh.mapping_name = ''Transfer Volume Mapping'' 
	AND gmv.clm1_value = 112701
	AND gmv.mapping_table_id = @mapping_table_id
	AND gmv.clm2_value  = mx2.clm2_value

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
SELECT MIN([Term Date]) term_start, MAX([Term Date]) term_end, MAX(mx.as_of_date), MAX(mx.pfc_curve),
	MAX(mx.Granularity), MAX(sdh.profile_granularity)
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh ON a.[Deal Ref ID] = sdh.deal_id 
OUTER APPLY (
	SELECT MAX(as_of_date) as_of_date, MAX(gmv.pfc_curve) pfc_curve , MAX(spcd.Granularity) Granularity
	FROM #generic_mapping_values gmv
	INNER JOIN source_price_curve spc
		ON gmv.pfc_curve = spc.source_curve_def_id
	INNER JOIN source_price_curve_def spcd
		ON spcd.source_curve_def_id = spc.source_curve_def_id
	WHERE spc.curve_source_value_id = 4500
) mx 

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
	FROM source_price_curve spc
	INNER JOIN source_price_curve_def spcd
		ON  spcd.source_curve_def_id = spc.source_curve_def_id
	INNER JOIN #curve_max_term cmt
		ON spcd.source_curve_def_id = cmt.pfc_curve
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
	SELECT 
		CAST(spc.maturity_date AS DATE) [term_date],
		spc.curve_value,
		spc.is_dst,
		spcd.Granularity,
		(DATEPART(HH,maturity_date) + 1)  [hour],
		DATEPART(MINUTE,maturity_date) [minute]
	FROM source_price_curve spc
	INNER JOIN source_price_curve_def spcd
		ON  spcd.source_curve_def_id = spc.source_curve_def_id
	INNER JOIN #curve_max_term cmt
		ON spcd.source_curve_def_id = cmt.pfc_curve
	WHERE spc.as_of_date = cmt.as_of_date
		AND spc.maturity_date >= cmt.term_start
		AND spc.maturity_date <= DATEADD(dd,1,cmt.term_end)
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
FROM dbo.FNAGetPivotGranularityColumn(@min_term,@max_term,@granularity,@dst_group_value_id) 

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
SELECT  DISTINCT sdh2.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	(ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume [Price], a.Leg
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = a.[Deal Ref ID]  
INNER JOIN source_deal_header sdh2
	ON sdh2.close_reference_id = sdh.source_deal_header_id
INNER JOIN source_deal_header sdh3
		ON sdh3.close_reference_id = sdh2.source_deal_header_id
INNER JOIN source_deal_detail sdd
	ON sdh2.source_deal_header_id = sdd.source_deal_header_id
	AND sdd.leg = a.leg
	AND a.[Term Date] BETWEEN sdd.term_start AND sdd.term_end
INNER JOIN #price_from_curve  pfc
	ON a.[Term Date] = pfc.term_date
	and a.Hour = pfc.hour
	and a.Minute = pfc.minute
	and a.[Is DST] = pfc.is_dst
INNER JOIN source_deal_detail_hour sddh
	ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
	AND CAST(sddh.term_date as date) = a.[Term Date]
INNER JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
	AND CAST(LEFT(thb.user_clm, 2) AS INT) = a.Hour
	AND CAST(RIGHT(thb.user_clm, 2) AS INT) = ISNULL(a.Minute, 0)
	AND thb.is_dst = a.[Is DST]
UNION
SELECT  DISTINCT sdh2.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	(ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume [Price], a.Leg
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = a.[Deal Ref ID]  
INNER JOIN source_deal_header sdh2
	ON sdh2.close_reference_id = sdh.source_deal_header_id
INNER JOIN source_deal_header sdh3
		ON sdh3.close_reference_id = sdh2.source_deal_header_id
INNER JOIN source_deal_detail sdd
	ON sdh2.source_deal_header_id = sdd.source_deal_header_id
	AND sdd.leg = a.leg
	AND a.[Term Date] BETWEEN sdd.term_start AND sdd.term_end
INNER JOIN #price_from_curve  pfc
	ON a.[Term Date] = pfc.term_date
	and a.Hour = pfc.hour
	and a.Minute = pfc.minute
	and a.[Is DST] = pfc.is_dst
LEFT JOIN source_deal_detail_hour sddh
	ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
	AND CAST(sddh.term_date as date) = a.[Term Date]
LEFT JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
WHERE sddh.source_deal_detail_id IS NULL
	  AND thb.clm_name IS NULL
UNION
SELECT  DISTINCT sdh3.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	(ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume [Price], a.Leg
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
INNER JOIN #price_from_curve  pfc
	ON a.[Term Date] = pfc.term_date
	and a.Hour = pfc.hour
	and a.Minute = pfc.minute
	and a.[Is DST] = pfc.is_dst
INNER JOIN source_deal_detail_hour sddh
	ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
	AND CAST(sddh.term_date as date) = a.[Term Date]
INNER JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
	AND CAST(LEFT(thb.user_clm, 2) AS INT) = a.Hour
	AND CAST(RIGHT(thb.user_clm, 2) AS INT) = ISNULL(a.Minute, 0)
	AND thb.is_dst = a.[Is DST]
UNION
SELECT  DISTINCT sdh3.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	(ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume [Price], a.Leg
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
INNER JOIN #price_from_curve  pfc
	ON a.[Term Date] = pfc.term_date
	and a.Hour = pfc.hour
	and a.Minute = pfc.minute
	and a.[Is DST] = pfc.is_dst
LEFT JOIN source_deal_detail_hour sddh
	ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
	AND CAST(sddh.term_date as date) = a.[Term Date]
LEFT JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
WHERE sddh.source_deal_detail_id IS NULL
	  AND thb.clm_name IS NULL',
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23502,
					1,
					'EE76081F_5A1A_4D3A_BBB8_E23E5C3C2B1E'
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
			SET ixp_rules_name = 'Retail LT Shaped'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = '
UPDATE [temp_process_table]
SET [Term Date] = CAST(dbo.FNAClientToSqlDate([Term Date]) AS DATE)

IF OBJECT_ID(N''tempdb..#generic_mapping_values'') IS NOT NULL
DROP TABLE #generic_mapping_values

DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header 
WHERE mapping_name = ''Transfer Volume Mapping''

SELECT gmv.[mapping_table_id]
	   , gmv.[clm2_value]  [effective_date]
	   , gmv.[clm17_value] [cummulative_delta]
	   , gmv.[clm18_value] [pfc_curve]
	   , gmv.[clm19_value] [aggregation_level]
INTO #generic_mapping_values
FROM  generic_mapping_header gmh
INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id
CROSS APPLY (
	SELECT clm1_value, clm2_value, clm3_value, clm4_value
	FROM generic_mapping_values gmv 
	WHERE gmv.mapping_table_id = gmh.mapping_table_id
	GROUP BY clm1_value, clm2_value, clm3_value, clm4_value
) mx
INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id 
	AND gmv.clm1_value = mx.clm1_value
	AND gmv.clm2_value = mx.clm2_value
	AND ISNULL(gmv.clm3_value, 1) = ISNULL(mx.clm3_value, 1)
	AND ISNULL(gmv.clm4_value, 1) = ISNULL(mx.clm4_value, 1)
OUTER APPLY(
	SELECT MAX(gmv.[clm2_value]) [clm2_value]
	FROM generic_mapping_values gmv
	INNER JOIN source_price_curve_def spcd 
		ON spcd.source_curve_def_id = gmv.clm18_value
	INNER JOIN source_commodity sc
		ON sc.source_commodity_id = spcd.commodity_id
	WHERE gmv.mapping_table_id = gmh.mapping_table_id 
		AND gmv.clm1_value = 112701
		AND gmv.mapping_table_id = @mapping_table_id
		AND sc.commodity_id = ''Power''
) mx2
WHERE gmh.mapping_name = ''Transfer Volume Mapping'' 
	AND gmv.clm1_value = 112701
	AND gmv.mapping_table_id = @mapping_table_id
	AND gmv.clm2_value  = mx2.clm2_value

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
SELECT MIN([Term Date]) term_start, MAX([Term Date]) term_end, MAX(mx.as_of_date), MAX(mx.pfc_curve),
	MAX(mx.Granularity), MAX(sdh.profile_granularity)
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh ON a.[Deal Ref ID] = sdh.deal_id 
OUTER APPLY (
	SELECT MAX(as_of_date) as_of_date, MAX(gmv.pfc_curve) pfc_curve , MAX(spcd.Granularity) Granularity
	FROM #generic_mapping_values gmv
	INNER JOIN source_price_curve spc
		ON gmv.pfc_curve = spc.source_curve_def_id
	INNER JOIN source_price_curve_def spcd
		ON spcd.source_curve_def_id = spc.source_curve_def_id
	WHERE spc.curve_source_value_id = 4500
) mx 

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
	FROM source_price_curve spc
	INNER JOIN source_price_curve_def spcd
		ON  spcd.source_curve_def_id = spc.source_curve_def_id
	INNER JOIN #curve_max_term cmt
		ON spcd.source_curve_def_id = cmt.pfc_curve
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
	SELECT 
		CAST(spc.maturity_date AS DATE) [term_date],
		spc.curve_value,
		spc.is_dst,
		spcd.Granularity,
		(DATEPART(HH,maturity_date) + 1)  [hour],
		DATEPART(MINUTE,maturity_date) [minute]
	FROM source_price_curve spc
	INNER JOIN source_price_curve_def spcd
		ON  spcd.source_curve_def_id = spc.source_curve_def_id
	INNER JOIN #curve_max_term cmt
		ON spcd.source_curve_def_id = cmt.pfc_curve
	WHERE spc.as_of_date = cmt.as_of_date
		AND spc.maturity_date >= cmt.term_start
		AND spc.maturity_date <= DATEADD(dd,1,cmt.term_end)
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
FROM dbo.FNAGetPivotGranularityColumn(@min_term,@max_term,@granularity,@dst_group_value_id) 

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
SELECT  DISTINCT sdh2.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	(ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume [Price], a.Leg
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = a.[Deal Ref ID]  
INNER JOIN source_deal_header sdh2
	ON sdh2.close_reference_id = sdh.source_deal_header_id
INNER JOIN source_deal_header sdh3
		ON sdh3.close_reference_id = sdh2.source_deal_header_id
INNER JOIN source_deal_detail sdd
	ON sdh2.source_deal_header_id = sdd.source_deal_header_id
	AND sdd.leg = a.leg
	AND a.[Term Date] BETWEEN sdd.term_start AND sdd.term_end
INNER JOIN #price_from_curve  pfc
	ON a.[Term Date] = pfc.term_date
	and a.Hour = pfc.hour
	and a.Minute = pfc.minute
	and a.[Is DST] = pfc.is_dst
INNER JOIN source_deal_detail_hour sddh
	ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
	AND CAST(sddh.term_date as date) = a.[Term Date]
INNER JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
	AND CAST(LEFT(thb.user_clm, 2) AS INT) = a.Hour
	AND CAST(RIGHT(thb.user_clm, 2) AS INT) = ISNULL(a.Minute, 0)
	AND thb.is_dst = a.[Is DST]
UNION
SELECT  DISTINCT sdh2.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	(ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume [Price], a.Leg
FROM [temp_process_table] a
INNER JOIN source_deal_header sdh
	ON sdh.deal_id = a.[Deal Ref ID]  
INNER JOIN source_deal_header sdh2
	ON sdh2.close_reference_id = sdh.source_deal_header_id
INNER JOIN source_deal_header sdh3
		ON sdh3.close_reference_id = sdh2.source_deal_header_id
INNER JOIN source_deal_detail sdd
	ON sdh2.source_deal_header_id = sdd.source_deal_header_id
	AND sdd.leg = a.leg
	AND a.[Term Date] BETWEEN sdd.term_start AND sdd.term_end
INNER JOIN #price_from_curve  pfc
	ON a.[Term Date] = pfc.term_date
	and a.Hour = pfc.hour
	and a.Minute = pfc.minute
	and a.[Is DST] = pfc.is_dst
LEFT JOIN source_deal_detail_hour sddh
	ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
	AND CAST(sddh.term_date as date) = a.[Term Date]
LEFT JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
WHERE sddh.source_deal_detail_id IS NULL
	  AND thb.clm_name IS NULL
UNION
SELECT  DISTINCT sdh3.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	(ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume [Price], a.Leg
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
INNER JOIN #price_from_curve  pfc
	ON a.[Term Date] = pfc.term_date
	and a.Hour = pfc.hour
	and a.Minute = pfc.minute
	and a.[Is DST] = pfc.is_dst
INNER JOIN source_deal_detail_hour sddh
	ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
	AND CAST(sddh.term_date as date) = a.[Term Date]
INNER JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
	AND CAST(LEFT(thb.user_clm, 2) AS INT) = a.Hour
	AND CAST(RIGHT(thb.user_clm, 2) AS INT) = ISNULL(a.Minute, 0)
	AND thb.is_dst = a.[Is DST]
UNION
SELECT  DISTINCT sdh3.deal_id, a.[Term Date], a.Hour, a.Minute, a.[Is DST], a.Volume, a.[Actual Volume], a.[Schedule Volume],
	(ISNULL(sddh.volume,0) * ISNULL(sddh.price,0) + (a.Volume - ISNULL(sddh.volume,0)) * pfc.curve_value)/a.volume [Price], a.Leg
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
INNER JOIN #price_from_curve  pfc
	ON a.[Term Date] = pfc.term_date
	and a.Hour = pfc.hour
	and a.Minute = pfc.minute
	and a.[Is DST] = pfc.is_dst
LEFT JOIN source_deal_detail_hour sddh
	ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
	AND CAST(sddh.term_date as date) = a.[Term Date]
LEFT JOIN #temp_hour_breakdown thb
	ON thb.process_clm = sddh.hr
	AND thb.is_dst = sddh.is_dst
WHERE sddh.source_deal_detail_id IS NULL
	  AND thb.clm_name IS NULL'
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
						   '\\EU-D-SQL01\shared_docs_TRMTracker_Enercity\temp_Note\0',
						   NULL,
						   ',',
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
						   NULL,
						   NULL
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
		