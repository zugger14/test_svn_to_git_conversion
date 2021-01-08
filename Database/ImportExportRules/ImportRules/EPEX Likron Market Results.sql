 BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'EC5FA481_EA55_45F1_B23D_DE4470421805'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'EPEX Likron Market Results'
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
					'EPEX Likron Market Results' ,
					'N' ,
					NULL ,
					'DELETE ulmr FROM udt_likron_market_results ulmr INNER JOIN
[temp_process_table] tpt ON ulmr.external_trade_id = tpt.external_trade_id AND ulmr.delivery_date  = tpt.delivery_date


DELETE FROM [temp_process_table]
WHERE [text] = ''SYNECO''',
					'IF OBJECT_ID(''tempdb..#tmp_data'') IS NOT NULL
	DROP TABLE #tmp_data

CREATE TABLE #tmp_data(
	[quantity] FLOAT,
	[delivery_date] DATE,
	[hour] NVARCHAR(5) COLLATE DATABASE_DEFAULT,
	[minutes] NVARCHAR(5) COLLATE DATABASE_DEFAULT, 
	deal_reference NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	amount FLOAT 
)

DECLARE @delivery_date DATETIME = GETDATE()

--For Quarterly
INSERT INTO #tmp_data([quantity], [delivery_date], [hour], [minutes], deal_reference, amount)
SELECT SUM(ulmr.quantity) quantity, ulmr.delivery_date, ulmr.[hour] + 1 [hour],ulmr.[minutes], a.deal_ref, SUM((ulmr.quantity)*ABS(ulmr.price) )
FROM udt_likron_market_results ulmr
OUTER APPLY (
	SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value internal_profile FROM generic_mapping_values gmv 
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
	WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping'' 
) a 
WHERE IIF(ulmr.[text] IN (''GKH'', ''GuD'') OR NULLIF(ulmr.[text],'''') IS NULL, ''KONV'', ulmr.[text]) = IIF(a.texts IN (''GKH'', ''GuD'') OR NULLIF(a.texts,'''') IS NULL, ''KONV'', a.texts) AND ulmr.tso_name = a.tso_name
AND ulmr.buy_or_sell = IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') AND IIF(ulmr.price < 0 , ''n'', ''p'') = a.price_sign
AND is_quarter = ''TRUE'' 
AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'')
AND CAST(ulmr.delivery_date AS DATE) = CAST(@delivery_date AS DATE)
AND a.internal_profile IS NULL
GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.deal_ref

--For Hourly
;WITH cte AS (
	SELECT SUM(ulmr.quantity) quantity, ulmr.delivery_date, ulmr.[hour]  [hour],ulmr.[minutes], a.deal_ref, SUM((ulmr.quantity)*ABS(ulmr.price) ) amount
	FROM udt_likron_market_results ulmr
	OUTER APPLY (
		SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value internal_profile, clm8_value profiles FROM generic_mapping_values gmv 
		INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
		WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping''
	) a 
	WHERE IIF(ulmr.[text] IN (''GKH'', ''GuD'') OR NULLIF(ulmr.[text],'''') IS NULL, ''KONV'', ulmr.[text]) = IIF(a.texts IN (''GKH'', ''GuD'') OR NULLIF(a.texts,'''') IS NULL, ''KONV'', a.texts) AND ulmr.tso_name = a.tso_name
		AND ulmr.buy_or_sell = IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') AND IIF(ulmr.price < 0 , ''n'', ''p'') = a.price_sign
		AND is_hour = ''TRUE'' AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'')
		AND CAST(ulmr.delivery_date AS DATE) = CAST(@delivery_date AS DATE)
		AND a.internal_profile IS NULL 
	GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.deal_ref
	UNION ALL
	SELECT quantity, delivery_date, [hour],[minutes] + 15, deal_ref,amount
	FROM cte 	
	WHERE [minutes] + 15 <= 45
)
INSERT INTO #tmp_data([quantity], [delivery_date], [hour], [minutes], deal_reference, amount)
SELECT * FROM cte

UPDATE 
#tmp_data
SET [hour] = IIF(LEN([hour]) < 2,''0'' + [hour], [hour])
, [minutes] = IIF(LEN([minutes]) < 2,''0'' + [minutes], [minutes])

DELETE sddh
FROM #tmp_data td 
INNER JOIN source_deal_header sdh ON sdh.deal_id = td.deal_reference
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id 
AND CAST(sddh.term_date AS DATE) = td.delivery_date 
--AND sddh.hr = td.[hour] + '':'' + td.[Minutes]

INSERT INTO source_deal_detail_hour (source_deal_detail_id, term_date, hr, is_dst, volume, granularity, price)
SELECT sdd.source_deal_detail_id, td.delivery_date, 
	[hour] + '':''+ [minutes] hr,
	0 is_dst, SUM([quantity]) volume, 987 granularity, SUM(amount)/SUM([quantity]) price FROM #tmp_data td 
INNER JOIN source_deal_header sdh ON sdh.deal_id = td.deal_reference
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND td.delivery_date BETWEEN sdd.term_start AND sdd.term_end
GROUP BY sdd.source_deal_detail_id, td.delivery_date,[hour] + '':''+ [minutes]

--- For Profile

IF OBJECT_ID(''tempdb..#profile'') IS NOT NULL
	DROP TABLE #profile

CREATE TABLE #profile(
	[profile_id] INT,	
	[delivery_date] DATE,
	[minutes] INT,
	[internal_profile] INT,
	[hr1] FLOAT,
	[hr2] FLOAT,
	[hr3] FLOAT,
	[hr4] FLOAT,
	[hr5] FLOAT,
	[hr6] FLOAT,
	[hr7] FLOAT,
	[hr8] FLOAT,
	[hr9] FLOAT,
	[hr10] FLOAT,
	[hr11] FLOAT,
	[hr12] FLOAT,
	[hr13] FLOAT,
	[hr14] FLOAT,
	[hr15] FLOAT,
	[hr16] FLOAT,
	[hr17] FLOAT,
	[hr18] FLOAT,
	[hr19] FLOAT,
	[hr20] FLOAT,
	[hr21] FLOAT,
	[hr22] FLOAT,
	[hr23] FLOAT,
	[hr24] FLOAT	
)
--For Hourly
;WITH cte AS (
	SELECT SUM(IIF(ulmr.buy_or_sell = ''Buy'', -1, 1) * ulmr.quantity) quantity, ulmr.delivery_date, ulmr.[hour] - 1 [hour],ulmr.[minutes], a.profiles, MAX(internal_profile) internal_profile
	FROM udt_likron_market_results ulmr
	OUTER APPLY (
		SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value internal_profile, clm8_value profiles FROM generic_mapping_values gmv 
		INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
		WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping''
	) a 
	WHERE IIF(ulmr.[text] IN (''GKH'', ''GuD'') OR NULLIF(ulmr.[text],'''') IS NULL, ''KONV'', ulmr.[text]) = IIF(a.texts IN (''GKH'', ''GuD'') OR NULLIF(a.texts,'''') IS NULL, ''KONV'', a.texts) AND ulmr.tso_name = a.tso_name 
	
	
		AND ulmr.buy_or_sell = CASE WHEN a.internal_profile IS NULL THEN IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') ELSE ulmr.buy_or_sell END
		AND IIF(ulmr.price < 0 , ''n'', ''p'') = CASE WHEN a.internal_profile IS NULL THEN a.price_sign ELSE IIF(ulmr.price < 0 , ''n'', ''p'') END
		AND is_hour = ''TRUE'' 
		AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  CASE WHEN a.internal_profile IS NULL THEN IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'') ELSE ISNULL(NULLIF(a.analysis_info,''''), ''True'') END
		AND CAST(ulmr.delivery_date AS DATE) = CAST(@delivery_date AS DATE)
		AND a.texts = ''NGR'' 
		AND a.profiles IS NOT NULL
	GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.profiles
	UNION ALL
	SELECT quantity, delivery_date, [hour],[minutes] + 15, profiles, internal_profile
	FROM cte 	
	WHERE [minutes] + 15 <= 45
)
INSERT INTO #profile([profile_id], [delivery_date], [minutes], [hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12], [hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], [hr23], [hr24], internal_profile)
SELECT profiles, delivery_date, [minutes], [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], internal_profile 
FROM cte
PIVOT
(
	SUM(quantity)
	FOR [hour] in ([0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23])
) piv

--For Quarterly
INSERT INTO #profile([profile_id], [delivery_date], [minutes], [hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12], [hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], [hr23], [hr24], internal_profile)
SELECT profiles, delivery_date, [minutes], [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], internal_profile 
FROM (
SELECT SUM(IIF(ulmr.buy_or_sell = ''Buy'', -1, 1) * ulmr.quantity) quantity, ulmr.delivery_date, ulmr.[hour]  [hour],ulmr.[minutes], a.profiles, MAX(internal_profile) internal_profile
FROM udt_likron_market_results ulmr
OUTER APPLY (
	SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value internal_profile, clm8_value profiles FROM generic_mapping_values gmv 
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
	WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping''
) a 
WHERE IIF(ulmr.[text] IN (''GKH'', ''GuD'') OR NULLIF(ulmr.[text],'''') IS NULL, ''KONV'', ulmr.[text]) = IIF(a.texts IN (''GKH'', ''GuD'') OR NULLIF(a.texts,'''') IS NULL, ''KONV'', a.texts)		AND ulmr.tso_name = a.tso_name
	  AND ulmr.buy_or_sell = CASE WHEN a.internal_profile IS NULL THEN IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') ELSE ulmr.buy_or_sell END
	  AND IIF(ulmr.price < 0 , ''n'', ''p'') = CASE WHEN a.internal_profile IS NULL THEN a.price_sign ELSE IIF(ulmr.price < 0 , ''n'', ''p'') END
	  AND is_quarter = ''TRUE'' 
	  AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  CASE WHEN a.internal_profile IS NULL THEN IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'') ELSE ISNULL(NULLIF(a.analysis_info,''''), ''True'') END
	  AND CAST(ulmr.delivery_date AS DATE) =  CAST(@delivery_date AS DATE)
	  AND a.texts = ''NGR'' 
	  AND a.profiles IS NOT NULL
GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.profiles ) a
PIVOT
(
	SUM(quantity)
	FOR [hour] in ([0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23])
) piv

DELETE ddh
FROM deal_detail_hour ddh 
INNER JOIN #profile p ON p.profile_id = ddh.profile_id 
AND p.[delivery_date] = ddh.[term_date] 

INSERT INTO deal_detail_hour (
	term_date
	, profile_id
	, Hr1
	, Hr2
	, Hr3
	, Hr4
	, Hr5
	, Hr6
	, Hr7
	, Hr8
	, Hr9
	, Hr10
	, Hr11
	, Hr12
	, Hr13
	, Hr14
	, Hr15
	, Hr16
	, Hr17
	, Hr18
	, Hr19
	, Hr20
	, Hr21
	, Hr22
	, Hr23
	, Hr24
	, [period]
)
SELECT p.[delivery_date]
	, p.profile_id
	, SUM(ISNULL(p.Hr1,0))  + MAX(ISNULL(ddh_profile.Hr1, 0))
	, SUM(ISNULL(p.Hr2,0))	 + MAX(ISNULL(ddh_profile.Hr2, 0))
	, SUM(ISNULL(p.Hr3,0))	 + MAX(ISNULL(ddh_profile.Hr3, 0))
	, SUM(ISNULL(p.Hr4,0))	 + MAX(ISNULL(ddh_profile.Hr4, 0))
	, SUM(ISNULL(p.Hr5,0))	 + MAX(ISNULL(ddh_profile.Hr5, 0))
	, SUM(ISNULL(p.Hr6,0))	 + MAX(ISNULL(ddh_profile.Hr6, 0))
	, SUM(ISNULL(p.Hr7,0))	 + MAX(ISNULL(ddh_profile.Hr7, 0))
	, SUM(ISNULL(p.Hr8,0))	 + MAX(ISNULL(ddh_profile.Hr8, 0))
	, SUM(ISNULL(p.Hr9,0))	 + MAX(ISNULL(ddh_profile.Hr9, 0))
	, SUM(ISNULL(p.Hr10,0)) + MAX(ISNULL(ddh_profile.Hr10, 0))
	, SUM(ISNULL(p.Hr11,0)) + MAX(ISNULL(ddh_profile.Hr11, 0))
	, SUM(ISNULL(p.Hr12,0)) + MAX(ISNULL(ddh_profile.Hr12, 0))
	, SUM(ISNULL(p.Hr13,0)) + MAX(ISNULL(ddh_profile.Hr13, 0))
	, SUM(ISNULL(p.Hr14,0)) + MAX(ISNULL(ddh_profile.Hr14, 0))
	, SUM(ISNULL(p.Hr15,0)) + MAX(ISNULL(ddh_profile.Hr15, 0))
	, SUM(ISNULL(p.Hr16,0)) + MAX(ISNULL(ddh_profile.Hr16, 0))
	, SUM(ISNULL(p.Hr17,0)) + MAX(ISNULL(ddh_profile.Hr17, 0))
	, SUM(ISNULL(p.Hr18,0)) + MAX(ISNULL(ddh_profile.Hr18, 0))
	, SUM(ISNULL(p.Hr19,0)) + MAX(ISNULL(ddh_profile.Hr19, 0))
	, SUM(ISNULL(p.Hr20,0)) + MAX(ISNULL(ddh_profile.Hr20, 0))
	, SUM(ISNULL(p.Hr21,0)) + MAX(ISNULL(ddh_profile.Hr21, 0))
	, SUM(ISNULL(p.Hr22,0)) + MAX(ISNULL(ddh_profile.Hr22, 0))
	, SUM(ISNULL(p.Hr23,0)) + MAX(ISNULL(ddh_profile.Hr23, 0))
	, SUM(ISNULL(p.Hr24,0)) + MAX(ISNULL(ddh_profile.Hr24, 0))
	, p.[minutes]
FROM #profile p 
LEFT JOIN deal_detail_hour ddh 
	ON p.profile_id = ddh.profile_id 
	AND p.[delivery_date] = ddh.[term_date] 
	AND p.[minutes] = ddh.[period]
LEFT JOIN deal_detail_hour ddh_profile
	ON ddh_profile.profile_id = p.internal_profile
	AND ddh_profile.[term_date] = p.[delivery_date]
	AND ddh_profile.[period] = p.[minutes]
WHERE ddh.[term_date] IS NULL
GROUP BY p.profile_id, p.[delivery_date], p.[minutes]

DECLARE @sql NVARCHAR(MAX), @prss_id NVARCHAR(200), @user_login_id NVARCHAR(50), @report_position_deals NVARCHAR(100)
SET @prss_id = dbo.FNAGetNewID()

SET @report_position_deals = dbo.FNAProcessTableName(''report_position'', @user_login_id, @prss_id)
EXEC (''CREATE TABLE '' + @report_position_deals + ''(source_deal_header_id INT, create_user NVARCHAR(50), [action] NVARCHAR(1), source_deal_detail_id INT)'')
			
SET @sql = ''INSERT INTO '' + @report_position_deals + ''(source_deal_header_id, source_deal_detail_id) 
SELECT DISTINCT source_deal_header_id, source_deal_detail_id  
FROM #profile p
INNER JOIN source_deal_detail sdd ON sdd.profile_id = p.profile_id
AND YEAR(sdd.term_start) = YEAR(p.[delivery_date]) AND MONTH(sdd.term_start) = MONTH(p.[delivery_date])
UNION ALL
SELECT DISTINCT sdd.source_deal_header_id, sdd.source_deal_detail_id
FROM #tmp_data td 
INNER JOIN source_deal_header sdh ON sdh.deal_id = td.deal_reference
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
AND YEAR(td.delivery_date) = YEAR(sdd.term_start) AND MONTH(sdd.term_start) = MONTH(td.delivery_date)
''
EXEC (@sql)

EXEC dbo.spa_update_deal_total_volume NULL, @prss_id',
					'i' ,
					'n' ,
					@admin_user ,
					23502,
					1,
					'EC5FA481_EA55_45F1_B23D_DE4470421805'
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
			SET ixp_rules_name = 'EPEX Likron Market Results'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'DELETE ulmr FROM udt_likron_market_results ulmr INNER JOIN
[temp_process_table] tpt ON ulmr.external_trade_id = tpt.external_trade_id AND ulmr.delivery_date  = tpt.delivery_date


DELETE FROM [temp_process_table]
WHERE [text] = ''SYNECO'''
				, after_insert_trigger = 'IF OBJECT_ID(''tempdb..#tmp_data'') IS NOT NULL
	DROP TABLE #tmp_data

CREATE TABLE #tmp_data(
	[quantity] FLOAT,
	[delivery_date] DATE,
	[hour] NVARCHAR(5) COLLATE DATABASE_DEFAULT,
	[minutes] NVARCHAR(5) COLLATE DATABASE_DEFAULT, 
	deal_reference NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	amount FLOAT 
)

DECLARE @delivery_date DATETIME = GETDATE()

--For Quarterly
INSERT INTO #tmp_data([quantity], [delivery_date], [hour], [minutes], deal_reference, amount)
SELECT SUM(ulmr.quantity) quantity, ulmr.delivery_date, ulmr.[hour] + 1 [hour],ulmr.[minutes], a.deal_ref, SUM((ulmr.quantity)*ABS(ulmr.price) )
FROM udt_likron_market_results ulmr
OUTER APPLY (
	SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value internal_profile FROM generic_mapping_values gmv 
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
	WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping'' 
) a 
WHERE IIF(ulmr.[text] IN (''GKH'', ''GuD'') OR NULLIF(ulmr.[text],'''') IS NULL, ''KONV'', ulmr.[text]) = IIF(a.texts IN (''GKH'', ''GuD'') OR NULLIF(a.texts,'''') IS NULL, ''KONV'', a.texts) AND ulmr.tso_name = a.tso_name
AND ulmr.buy_or_sell = IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') AND IIF(ulmr.price < 0 , ''n'', ''p'') = a.price_sign
AND is_quarter = ''TRUE'' 
AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'')
AND CAST(ulmr.delivery_date AS DATE) = CAST(@delivery_date AS DATE)
AND a.internal_profile IS NULL
GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.deal_ref

--For Hourly
;WITH cte AS (
	SELECT SUM(ulmr.quantity) quantity, ulmr.delivery_date, ulmr.[hour]  [hour],ulmr.[minutes], a.deal_ref, SUM((ulmr.quantity)*ABS(ulmr.price) ) amount
	FROM udt_likron_market_results ulmr
	OUTER APPLY (
		SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value internal_profile, clm8_value profiles FROM generic_mapping_values gmv 
		INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
		WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping''
	) a 
	WHERE IIF(ulmr.[text] IN (''GKH'', ''GuD'') OR NULLIF(ulmr.[text],'''') IS NULL, ''KONV'', ulmr.[text]) = IIF(a.texts IN (''GKH'', ''GuD'') OR NULLIF(a.texts,'''') IS NULL, ''KONV'', a.texts) AND ulmr.tso_name = a.tso_name
		AND ulmr.buy_or_sell = IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') AND IIF(ulmr.price < 0 , ''n'', ''p'') = a.price_sign
		AND is_hour = ''TRUE'' AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'')
		AND CAST(ulmr.delivery_date AS DATE) = CAST(@delivery_date AS DATE)
		AND a.internal_profile IS NULL 
	GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.deal_ref
	UNION ALL
	SELECT quantity, delivery_date, [hour],[minutes] + 15, deal_ref,amount
	FROM cte 	
	WHERE [minutes] + 15 <= 45
)
INSERT INTO #tmp_data([quantity], [delivery_date], [hour], [minutes], deal_reference, amount)
SELECT * FROM cte

UPDATE 
#tmp_data
SET [hour] = IIF(LEN([hour]) < 2,''0'' + [hour], [hour])
, [minutes] = IIF(LEN([minutes]) < 2,''0'' + [minutes], [minutes])

DELETE sddh
FROM #tmp_data td 
INNER JOIN source_deal_header sdh ON sdh.deal_id = td.deal_reference
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id 
AND CAST(sddh.term_date AS DATE) = td.delivery_date 
--AND sddh.hr = td.[hour] + '':'' + td.[Minutes]

INSERT INTO source_deal_detail_hour (source_deal_detail_id, term_date, hr, is_dst, volume, granularity, price)
SELECT sdd.source_deal_detail_id, td.delivery_date, 
	[hour] + '':''+ [minutes] hr,
	0 is_dst, SUM([quantity]) volume, 987 granularity, SUM(amount)/SUM([quantity]) price FROM #tmp_data td 
INNER JOIN source_deal_header sdh ON sdh.deal_id = td.deal_reference
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND td.delivery_date BETWEEN sdd.term_start AND sdd.term_end
GROUP BY sdd.source_deal_detail_id, td.delivery_date,[hour] + '':''+ [minutes]

--- For Profile

IF OBJECT_ID(''tempdb..#profile'') IS NOT NULL
	DROP TABLE #profile

CREATE TABLE #profile(
	[profile_id] INT,	
	[delivery_date] DATE,
	[minutes] INT,
	[internal_profile] INT,
	[hr1] FLOAT,
	[hr2] FLOAT,
	[hr3] FLOAT,
	[hr4] FLOAT,
	[hr5] FLOAT,
	[hr6] FLOAT,
	[hr7] FLOAT,
	[hr8] FLOAT,
	[hr9] FLOAT,
	[hr10] FLOAT,
	[hr11] FLOAT,
	[hr12] FLOAT,
	[hr13] FLOAT,
	[hr14] FLOAT,
	[hr15] FLOAT,
	[hr16] FLOAT,
	[hr17] FLOAT,
	[hr18] FLOAT,
	[hr19] FLOAT,
	[hr20] FLOAT,
	[hr21] FLOAT,
	[hr22] FLOAT,
	[hr23] FLOAT,
	[hr24] FLOAT	
)
--For Hourly
;WITH cte AS (
	SELECT SUM(IIF(ulmr.buy_or_sell = ''Buy'', -1, 1) * ulmr.quantity) quantity, ulmr.delivery_date, ulmr.[hour] - 1 [hour],ulmr.[minutes], a.profiles, MAX(internal_profile) internal_profile
	FROM udt_likron_market_results ulmr
	OUTER APPLY (
		SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value internal_profile, clm8_value profiles FROM generic_mapping_values gmv 
		INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
		WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping''
	) a 
	WHERE IIF(ulmr.[text] IN (''GKH'', ''GuD'') OR NULLIF(ulmr.[text],'''') IS NULL, ''KONV'', ulmr.[text]) = IIF(a.texts IN (''GKH'', ''GuD'') OR NULLIF(a.texts,'''') IS NULL, ''KONV'', a.texts) AND ulmr.tso_name = a.tso_name 
	
	
		AND ulmr.buy_or_sell = CASE WHEN a.internal_profile IS NULL THEN IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') ELSE ulmr.buy_or_sell END
		AND IIF(ulmr.price < 0 , ''n'', ''p'') = CASE WHEN a.internal_profile IS NULL THEN a.price_sign ELSE IIF(ulmr.price < 0 , ''n'', ''p'') END
		AND is_hour = ''TRUE'' 
		AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  CASE WHEN a.internal_profile IS NULL THEN IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'') ELSE ISNULL(NULLIF(a.analysis_info,''''), ''True'') END
		AND CAST(ulmr.delivery_date AS DATE) = CAST(@delivery_date AS DATE)
		AND a.texts = ''NGR'' 
		AND a.profiles IS NOT NULL
	GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.profiles
	UNION ALL
	SELECT quantity, delivery_date, [hour],[minutes] + 15, profiles, internal_profile
	FROM cte 	
	WHERE [minutes] + 15 <= 45
)
INSERT INTO #profile([profile_id], [delivery_date], [minutes], [hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12], [hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], [hr23], [hr24], internal_profile)
SELECT profiles, delivery_date, [minutes], [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], internal_profile 
FROM cte
PIVOT
(
	SUM(quantity)
	FOR [hour] in ([0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23])
) piv

--For Quarterly
INSERT INTO #profile([profile_id], [delivery_date], [minutes], [hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12], [hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], [hr23], [hr24], internal_profile)
SELECT profiles, delivery_date, [minutes], [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], internal_profile 
FROM (
SELECT SUM(IIF(ulmr.buy_or_sell = ''Buy'', -1, 1) * ulmr.quantity) quantity, ulmr.delivery_date, ulmr.[hour]  [hour],ulmr.[minutes], a.profiles, MAX(internal_profile) internal_profile
FROM udt_likron_market_results ulmr
OUTER APPLY (
	SELECT clm1_value texts, clm2_value tso_name,clm3_value buy_sell, clm4_value price_sign, clm5_value analysis_info, clm6_value deal_ref, clm7_value internal_profile, clm8_value profiles FROM generic_mapping_values gmv 
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
	WHERE gmh.mapping_name = ''EPEX Continuous Trading Mapping''
) a 
WHERE IIF(ulmr.[text] IN (''GKH'', ''GuD'') OR NULLIF(ulmr.[text],'''') IS NULL, ''KONV'', ulmr.[text]) = IIF(a.texts IN (''GKH'', ''GuD'') OR NULLIF(a.texts,'''') IS NULL, ''KONV'', a.texts)		AND ulmr.tso_name = a.tso_name
	  AND ulmr.buy_or_sell = CASE WHEN a.internal_profile IS NULL THEN IIF(a.buy_sell = ''b'', ''Buy'', ''Sell'') ELSE ulmr.buy_or_sell END
	  AND IIF(ulmr.price < 0 , ''n'', ''p'') = CASE WHEN a.internal_profile IS NULL THEN a.price_sign ELSE IIF(ulmr.price < 0 , ''n'', ''p'') END
	  AND is_quarter = ''TRUE'' 
	  AND ISNULL(NULLIF(a.analysis_info,''''), ''True'') =  CASE WHEN a.internal_profile IS NULL THEN IIF(ulmr.analysis_info = ''Netting'', ''Netting'', ''True'') ELSE ISNULL(NULLIF(a.analysis_info,''''), ''True'') END
	  AND CAST(ulmr.delivery_date AS DATE) =  CAST(@delivery_date AS DATE)
	  AND a.texts = ''NGR'' 
	  AND a.profiles IS NOT NULL
GROUP BY ulmr.delivery_date, ulmr.[hour],ulmr.[minutes], a.profiles ) a
PIVOT
(
	SUM(quantity)
	FOR [hour] in ([0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23])
) piv

DELETE ddh
FROM deal_detail_hour ddh 
INNER JOIN #profile p ON p.profile_id = ddh.profile_id 
AND p.[delivery_date] = ddh.[term_date] 

INSERT INTO deal_detail_hour (
	term_date
	, profile_id
	, Hr1
	, Hr2
	, Hr3
	, Hr4
	, Hr5
	, Hr6
	, Hr7
	, Hr8
	, Hr9
	, Hr10
	, Hr11
	, Hr12
	, Hr13
	, Hr14
	, Hr15
	, Hr16
	, Hr17
	, Hr18
	, Hr19
	, Hr20
	, Hr21
	, Hr22
	, Hr23
	, Hr24
	, [period]
)
SELECT p.[delivery_date]
	, p.profile_id
	, SUM(ISNULL(p.Hr1,0))  + MAX(ISNULL(ddh_profile.Hr1, 0))
	, SUM(ISNULL(p.Hr2,0))	 + MAX(ISNULL(ddh_profile.Hr2, 0))
	, SUM(ISNULL(p.Hr3,0))	 + MAX(ISNULL(ddh_profile.Hr3, 0))
	, SUM(ISNULL(p.Hr4,0))	 + MAX(ISNULL(ddh_profile.Hr4, 0))
	, SUM(ISNULL(p.Hr5,0))	 + MAX(ISNULL(ddh_profile.Hr5, 0))
	, SUM(ISNULL(p.Hr6,0))	 + MAX(ISNULL(ddh_profile.Hr6, 0))
	, SUM(ISNULL(p.Hr7,0))	 + MAX(ISNULL(ddh_profile.Hr7, 0))
	, SUM(ISNULL(p.Hr8,0))	 + MAX(ISNULL(ddh_profile.Hr8, 0))
	, SUM(ISNULL(p.Hr9,0))	 + MAX(ISNULL(ddh_profile.Hr9, 0))
	, SUM(ISNULL(p.Hr10,0)) + MAX(ISNULL(ddh_profile.Hr10, 0))
	, SUM(ISNULL(p.Hr11,0)) + MAX(ISNULL(ddh_profile.Hr11, 0))
	, SUM(ISNULL(p.Hr12,0)) + MAX(ISNULL(ddh_profile.Hr12, 0))
	, SUM(ISNULL(p.Hr13,0)) + MAX(ISNULL(ddh_profile.Hr13, 0))
	, SUM(ISNULL(p.Hr14,0)) + MAX(ISNULL(ddh_profile.Hr14, 0))
	, SUM(ISNULL(p.Hr15,0)) + MAX(ISNULL(ddh_profile.Hr15, 0))
	, SUM(ISNULL(p.Hr16,0)) + MAX(ISNULL(ddh_profile.Hr16, 0))
	, SUM(ISNULL(p.Hr17,0)) + MAX(ISNULL(ddh_profile.Hr17, 0))
	, SUM(ISNULL(p.Hr18,0)) + MAX(ISNULL(ddh_profile.Hr18, 0))
	, SUM(ISNULL(p.Hr19,0)) + MAX(ISNULL(ddh_profile.Hr19, 0))
	, SUM(ISNULL(p.Hr20,0)) + MAX(ISNULL(ddh_profile.Hr20, 0))
	, SUM(ISNULL(p.Hr21,0)) + MAX(ISNULL(ddh_profile.Hr21, 0))
	, SUM(ISNULL(p.Hr22,0)) + MAX(ISNULL(ddh_profile.Hr22, 0))
	, SUM(ISNULL(p.Hr23,0)) + MAX(ISNULL(ddh_profile.Hr23, 0))
	, SUM(ISNULL(p.Hr24,0)) + MAX(ISNULL(ddh_profile.Hr24, 0))
	, p.[minutes]
FROM #profile p 
LEFT JOIN deal_detail_hour ddh 
	ON p.profile_id = ddh.profile_id 
	AND p.[delivery_date] = ddh.[term_date] 
	AND p.[minutes] = ddh.[period]
LEFT JOIN deal_detail_hour ddh_profile
	ON ddh_profile.profile_id = p.internal_profile
	AND ddh_profile.[term_date] = p.[delivery_date]
	AND ddh_profile.[period] = p.[minutes]
WHERE ddh.[term_date] IS NULL
GROUP BY p.profile_id, p.[delivery_date], p.[minutes]

DECLARE @sql NVARCHAR(MAX), @prss_id NVARCHAR(200), @user_login_id NVARCHAR(50), @report_position_deals NVARCHAR(100)
SET @prss_id = dbo.FNAGetNewID()

SET @report_position_deals = dbo.FNAProcessTableName(''report_position'', @user_login_id, @prss_id)
EXEC (''CREATE TABLE '' + @report_position_deals + ''(source_deal_header_id INT, create_user NVARCHAR(50), [action] NVARCHAR(1), source_deal_detail_id INT)'')
			
SET @sql = ''INSERT INTO '' + @report_position_deals + ''(source_deal_header_id, source_deal_detail_id) 
SELECT DISTINCT source_deal_header_id, source_deal_detail_id  
FROM #profile p
INNER JOIN source_deal_detail sdd ON sdd.profile_id = p.profile_id
AND YEAR(sdd.term_start) = YEAR(p.[delivery_date]) AND MONTH(sdd.term_start) = MONTH(p.[delivery_date])
UNION ALL
SELECT DISTINCT sdd.source_deal_header_id, sdd.source_deal_detail_id
FROM #tmp_data td 
INNER JOIN source_deal_header sdh ON sdh.deal_id = td.deal_reference
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
AND YEAR(td.delivery_date) = YEAR(sdd.term_start) AND MONTH(sdd.term_start) = MONTH(td.delivery_date)
''
EXEC (@sql)

EXEC dbo.spa_update_deal_total_volume NULL, @prss_id'
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23502
				, is_system_import = 'n'
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
									WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\EU-U-SQL03\shared_docs_TRMTracker_Enercity_UAT\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'udt',
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
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = 'Likron' 
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
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'daylight_change_suffix', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'daylight_change_suffix' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'short_name', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'short_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'major_type', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'major_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'is_block', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_block' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'is_half_hour', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_half_hour' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'is_hour', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_hour' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'is_quarter', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_quarter' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'traded_underlying_delivery_day', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'traded_underlying_delivery_day' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_hour', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_hour' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'scaling_factor', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'scaling_factor' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'target_tso', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'target_tso' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tso', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'tso' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tso_name', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'tso_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'price', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'quantity', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'quantity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'is_buy_trade', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_buy_trade' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'trade_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trade_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'exchange_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'exchange_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'external_trade_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'external_trade_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'execution_local_date', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'execution_local_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'execution_time_local_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'execution_time_local_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'execution_time_local_time_cet', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'execution_time_local_time_cet' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'execution_utc_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'execution_utc_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'execution_ticks', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'execution_ticks' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'analysis_info', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'analysis_info' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'balance_group', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'balance_group' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'com_xerv_account_type', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'com_xerv_account_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'com_xerv_eic', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'com_xerv_eic' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'external_order_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'external_order_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'portfolio', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'portfolio' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pre_arranged_type', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'pre_arranged_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'state', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'state' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'strategy_name', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strategy_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_end_utc_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_end_utc_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_end_ticks', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_end_ticks' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_end_local_date', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_end_local_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'type', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'name', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_end_local_time_cet', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_end_local_time_cet' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_end_local_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_end_local_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_start_local_date', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_start_local_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'underlying_end', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'underlying_end' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_start_utc_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_start_utc_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_start_ticks', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_start_ticks' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_start_local_time_cet', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_start_local_time_cet' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_start_local_time', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_start_local_time' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'trader_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trader_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'underlying_start', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'underlying_start' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'related_order_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'related_order_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'strategy_order_id', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strategy_order_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'text', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'text' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'trading_cost_group', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trading_cost_group' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'user_code', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'user_code' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pre_arranged', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'pre_arranged' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'com_xerv_product', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'com_xerv_product' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'contract', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'contract_type', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'exchange_key', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'exchange_key' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'product_name', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'product_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'buy_or_sell', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'buy_or_sell' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_day', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_day' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'scaled_quantity', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'scaled_quantity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'signed_quantity', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'signed_quantity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'self_trade', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'self_trade' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'delivery_date', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'delivery_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hour', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hour' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'minutes', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_likron_market_results'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'minutes' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_likron_market_results'

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
		