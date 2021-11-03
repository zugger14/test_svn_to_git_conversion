BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'B8081ACD_A34F_4C54_A70B_DE7DC2E4C2B1'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'EPEX Retrieve Market Results Day Ahead'
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
					'EPEX Retrieve Market Results Day Ahead' ,
					'N' ,
					NULL ,
					'DELETE udt FROM udt_epex_market_results udt 
INNER JOIN [temp_process_table] a ON a.[date] = udt.utc_date AND a.participant = udt.participant
INNER JOIN static_data_value sdv_area ON sdv_area.code = a.[Area] AND sdv_area.[type_id] = 112500
AND sdv_area.value_id = udt.area 

DECLARE @default_code_value INT, @run_date DATETIME, @col NVARCHAR(300), @sql NVARCHAR(4000)

--SELECT * FROM adiha_default_codes
SELECT @default_code_value = [dbo].[FNAGetDefaultCodeValue](36, 1)

INSERT INTO udt_epex_market_results
(
	area
	,participant
	,utc_date
	,mcp
	,mcv
	,total_sched_net
	,total_sched_purchase
	,total_sched_sale
	,linear_sched_net
	,linear_sched_purchase
	,linear_sched_sale
	,block_sched_net
	,block_sched_purchase
	,block_sched_sale
	,complex_sched_net
	,complex_sched_purchase
	,complex_sched_sale
	,area_set
	,[hour]
	,std_date
	,auction_name 
)
SELECT 
	sdv_area.value_id [Area]
	,[Participant]
	,[Date]
	,[MCP (EUR/MWh)]
	,[MCV (MW)]
	,[Total Sched Net]
	,[Total Sched Purchase]
	,[Total Sched Sale]
	,[Linear Sched Net]
	,[Linear Sched Purchase]
	,[Linear Sched Sale]
	,[Block Sched Net]
	,[Block Sched Purchase]
	,[Block Sched Sale]
	,[Complex Sched Net]
	,[Complex Sched Purchase]
	,[Complex Sched Sale]
	,[Area Set]
	, DATEPART(HOUR, [dbo].[FNAGetLOCALTime]([Date], @default_code_value)) [hour]
	, [dbo].[FNAGetLOCALTime]([Date], @default_code_value) [std_time]
	,sdv_name.value_id [Auction Name]
--FROM adiha_process.dbo.temp_import_data_table_ermr_209ECF98_BD4D_4FC0_8034_C99B649526B8 a
FROM [temp_process_table] a
INNER JOIN static_data_value sdv_area ON sdv_area.code = a.[Area] AND sdv_area.[type_id] = 112500
INNER JOIN static_data_value sdv_name ON sdv_name.code = a.[Auction Name] AND sdv_name.[type_id] = 112600

SELECT @run_date = CAST([dbo].[FNAGetLOCALTime]([Date] , @default_code_value) AS DATE) FROM [temp_process_table] 

--SET @run_date = ''2021-10-31''

SELECT market_result_id, area, utc_date
,mcp
,mcv
,total_sched_net
,total_sched_purchase
,total_sched_sale
,linear_sched_net
,linear_sched_purchase
,linear_sched_sale
,block_sched_net
,block_sched_purchase
,block_sched_sale
,complex_sched_net
,complex_sched_purchase
,complex_sched_sale
,area_set
,[hour]
,std_date
,auction_name, participant  
INTO #udt_epex_market_results
FROM udt_epex_market_results WHERE CAST(std_date AS DATE) = @run_date

UPDATE a
SET [hour] = 24		
FROM #udt_epex_market_results a
INNER JOIN (
SELECT ROW_NUMBER() OVER (PARTITION BY area, area_set, auction_name, participant, std_date  
ORDER BY market_result_id) rn, market_result_id FROM #udt_epex_market_results
) b ON b.market_result_id = a.market_result_id AND rn =2
 	
IF OBJECT_ID(''tempdb..#profile'') IS NOT NULL
	DROP TABLE #profile

CREATE TABLE #profile(
	[profile_id] INT,
	[auction_name_id] INT,
	[date] DATE,
	[min] INT,
	[participant] NVARCHAR(100) COLLATE DATABASE_DEFAULT,
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
	[hr24] FLOAT,
	[hr25] FLOAT
)

IF OBJECT_ID(''tempdb..#curve'') IS NOT NULL
	DROP TABLE #curve

CREATE TABLE #curve (
	curve_id INT,
	curve_value FLOAT,
	std_date DATETIME,
	is_dst BIT,
	curve_source_value_id INT, 
	assessment_curve_type_value_id INT
)
--SELECT * FROM #udt_epex_market_results

DECLARE @auction_name NVARCHAR(100), @participant NVARCHAR(100), @column_name NVARCHAR(150),  @profile_id NVARCHAR(20), @curve_id NVARCHAR(20)
DECLARE profile_cursor CURSOR FOR
	SELECT DISTINCT a.auction_name, a.participant, a.column_name, a.profile_id, a.curve_id FROM #udt_epex_market_results upmr
	OUTER APPLY (
	SELECT clm1_value auction_name, clm2_value participant, REPLACE(REPLACE(clm3_value, '' '', ''_''), ''.'', '''') + ''_''+ clm4_value column_name, clm5_value profile_id, clm6_value curve_id FROM generic_mapping_values gmv 
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
	WHERE gmh.mapping_name = ''EPEX DA/ID Aggregation Mapping''
	) a 
	WHERE CAST(upmr.auction_name AS NVARCHAR(20)) = a.auction_name AND upmr.participant = a.participant
OPEN profile_cursor
FETCH NEXT FROM profile_cursor
INTO @auction_name, @participant, @column_name, @profile_id, @curve_id
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @sql = ''
			WITH cte AS (
			SELECT auction_name, CAST(std_date AS DATE) std_date, ('' + @column_name + '') '' + @column_name +'', [hour], 0[min], participant
				FROM #udt_epex_market_results 
			UNION ALL
			SELECT auction_name, std_date, '' + @column_name + '', [hour], [min] + 15 , participant
			FROM cte 
	
			WHERE [min] + 15 <= 45
			)
			INSERT INTO #profile([profile_id], [auction_name_id], [date], [min], [participant], [hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12], [hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], [hr23], [hr24], [hr25])
			SELECT '' + @profile_id + '', auction_name,std_date, [min], participant, [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24]
			FROM (
			SELECT * FROM cte
			) p
			PIVOT
			(
			  SUM('' + @column_name + '')
			  FOR [hour] in ([0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24])
			) piv
			WHERE auction_name = '''''' + @auction_name + '''''' AND participant= '''''' + @participant + ''''''''

	SET @sql += '' 

			INSERT INTO #curve(curve_id, std_date, curve_value, is_dst, curve_source_value_id, assessment_curve_type_value_id)		
			SELECT '' + @curve_id + '', std_date, mcp , IIF([hour] = 24, 1, 0), 4500,77
			FROM #udt_epex_market_results piv WHERE 1 = 1
			AND piv.auction_name = '''''' + @auction_name + '''''' AND piv.participant= '''''' + @participant + ''''''''
	
	EXEC(@sql) 
	FETCH NEXT FROM profile_cursor INTO @auction_name, @participant, @column_name, @profile_id, @curve_id
END
CLOSE profile_cursor
DEALLOCATE profile_cursor

SELECT @col = ''Hr'' + CAST(md.hour AS NVARCHAR) + '' = Hr'' + CAST(md.hour AS NVARCHAR) + '' + ISNULL(Hr25, 0)''
FROM #profile tmp
INNER JOIN mv90_DST md ON  md.date = tmp.date AND md.insert_delete = ''i''
	AND md.dst_group_value_id = 102201

SET @sql = '' UPDATE	tmp
 			SET '' + @col + ''
 			FROM #profile tmp
 			INNER JOIN mv90_DST md
 				ON  md.date = tmp.date 
 				AND md.insert_delete = ''''i''''
				AND md.dst_group_value_id = 102201''
EXEC(@sql)

UPDATE ddh
SET 
Hr1 = p.Hr1 
, Hr2 = p.Hr2
, Hr3 = p.Hr3
, Hr4 = p.Hr4
, Hr5 = p.Hr5
, Hr6 = p.Hr6
, Hr7 = p.Hr7
, Hr8 = p.Hr8
, Hr9 = p.Hr9
, Hr10 = p.Hr10
, Hr11 = p.Hr11
, Hr12 = p.Hr12
, Hr13 = p.Hr13
, Hr14 = p.Hr14
, Hr15 = p.Hr15
, Hr16 = p.Hr16
, Hr17 = p.Hr17
, Hr18 = p.Hr18
, Hr19 = p.Hr19
, Hr20 = p.Hr20
, Hr21 = p.Hr21
, Hr22 = p.Hr22
, Hr23 = p.Hr23
, Hr24 = p.Hr24
, Hr25 = p.Hr25
FROM deal_detail_hour ddh 
INNER JOIN #profile p ON p.profile_id = ddh.profile_id AND p.[date] = ddh.[term_date] AND p.[min] = ddh.[period]

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
	, Hr25
	, [period]
)
SELECT p.[date]
	, p.profile_id
	, p.Hr1
	, p.Hr2
	, p.Hr3
	, p.Hr4
	, p.Hr5
	, p.Hr6
	, p.Hr7
	, p.Hr8
	, p.Hr9
	, p.Hr10
	, p.Hr11
	, p.Hr12
	, p.Hr13
	, p.Hr14
	, p.Hr15
	, p.Hr16
	, p.Hr17
	, p.Hr18
	, p.Hr19
	, p.Hr20
	, p.Hr21
	, p.Hr22
	, p.Hr23
	, p.Hr24
	, p.Hr25
	, p.[min]
FROM #profile p 
LEFT JOIN deal_detail_hour ddh ON p.profile_id = ddh.profile_id AND p.[date] = ddh.[term_date] AND p.[min] = ddh.[period]
WHERE ddh.[term_date] IS NULL

UPDATE
spc 
SET curve_value = c.curve_value
FROM #curve c
INNER JOIN source_price_curve spc ON spc.source_curve_def_id = c.curve_id AND spc.maturity_date = c.std_date 
AND spc.is_dst = c.is_dst AND spc.curve_source_value_id = c.curve_source_value_id AND spc.Assessment_curve_type_value_id = c.assessment_curve_type_value_id
AND spc.as_of_date = CAST(DATEADD(DAY, 0, std_date) AS DATE)

INSERT INTO source_price_curve
(
source_curve_def_id
,as_of_date
,Assessment_curve_type_value_id
,curve_source_value_id
,maturity_date
,curve_value
,is_dst
)
SELECT DISTINCT 
c.curve_id,  CAST(DATEADD(DAY, 0, std_date) AS DATE) , c.Assessment_curve_type_value_id, c.curve_source_value_id, std_date, c.curve_value, c.is_dst
FROM #curve c
LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = c.curve_id AND spc.maturity_date = c.std_date 
AND spc.is_dst = c.is_dst AND spc.curve_source_value_id = c.curve_source_value_id AND spc.Assessment_curve_type_value_id = c.assessment_curve_type_value_id
AND spc.as_of_date =  CAST(DATEADD(DAY, 0, std_date) AS DATE)
WHERE spc.source_curve_def_id  IS NULL 

DECLARE @prss_id NVARCHAR(200), @user_login_id NVARCHAR(50), @report_position_deals NVARCHAR(100)
SET @prss_id = dbo.FNAGetNewID()

SET @report_position_deals = dbo.FNAProcessTableName(''report_position'', @user_login_id, @prss_id)
EXEC (''CREATE TABLE '' + @report_position_deals + ''(source_deal_header_id INT, create_user NVARCHAR(50), [action] NVARCHAR(1), source_deal_detail_id INT)'')
		
SET @sql = ''INSERT INTO '' + @report_position_deals + ''(source_deal_header_id, source_deal_detail_id) 
	SELECT source_deal_header_id, source_deal_detail_id  FROM #profile p
	INNER JOIN source_deal_detail sdd ON sdd.profile_id = p.profile_id''

EXEC (@sql)

EXEC dbo.spa_update_deal_total_volume NULL, @prss_id

',
					'IF NOT EXISTS (SELECT 1 FROM [temp_process_table])
BEGIN
	DELETE FROM source_system_data_import_status_detail WHERE process_id = ''@process_id''

	INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description])
	SELECT DISTINCT ''@process_id'', ''ixp_custom_tables'', ''Data Import'', ''Market results not available.''

	UPDATE source_system_data_import_status
	SET code = ''Error'',
		[description] = ''Data could not be imported <font color=red>(ERRORS found)</font>.''
	WHERE Process_id = ''@process_id''
END
',
					'i' ,
					'n' ,
					@admin_user ,
					23500,
					1,
					'B8081ACD_A34F_4C54_A70B_DE7DC2E4C2B1'
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
			SET ixp_rules_name = 'EPEX Retrieve Market Results Day Ahead'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'DELETE udt FROM udt_epex_market_results udt 
INNER JOIN [temp_process_table] a ON a.[date] = udt.utc_date AND a.participant = udt.participant
INNER JOIN static_data_value sdv_area ON sdv_area.code = a.[Area] AND sdv_area.[type_id] = 112500
AND sdv_area.value_id = udt.area 

DECLARE @default_code_value INT, @run_date DATETIME, @col NVARCHAR(300), @sql NVARCHAR(4000)

--SELECT * FROM adiha_default_codes
SELECT @default_code_value = [dbo].[FNAGetDefaultCodeValue](36, 1)

INSERT INTO udt_epex_market_results
(
	area
	,participant
	,utc_date
	,mcp
	,mcv
	,total_sched_net
	,total_sched_purchase
	,total_sched_sale
	,linear_sched_net
	,linear_sched_purchase
	,linear_sched_sale
	,block_sched_net
	,block_sched_purchase
	,block_sched_sale
	,complex_sched_net
	,complex_sched_purchase
	,complex_sched_sale
	,area_set
	,[hour]
	,std_date
	,auction_name 
)
SELECT 
	sdv_area.value_id [Area]
	,[Participant]
	,[Date]
	,[MCP (EUR/MWh)]
	,[MCV (MW)]
	,[Total Sched Net]
	,[Total Sched Purchase]
	,[Total Sched Sale]
	,[Linear Sched Net]
	,[Linear Sched Purchase]
	,[Linear Sched Sale]
	,[Block Sched Net]
	,[Block Sched Purchase]
	,[Block Sched Sale]
	,[Complex Sched Net]
	,[Complex Sched Purchase]
	,[Complex Sched Sale]
	,[Area Set]
	, DATEPART(HOUR, [dbo].[FNAGetLOCALTime]([Date], @default_code_value)) [hour]
	, [dbo].[FNAGetLOCALTime]([Date], @default_code_value) [std_time]
	,sdv_name.value_id [Auction Name]
--FROM adiha_process.dbo.temp_import_data_table_ermr_209ECF98_BD4D_4FC0_8034_C99B649526B8 a
FROM [temp_process_table] a
INNER JOIN static_data_value sdv_area ON sdv_area.code = a.[Area] AND sdv_area.[type_id] = 112500
INNER JOIN static_data_value sdv_name ON sdv_name.code = a.[Auction Name] AND sdv_name.[type_id] = 112600

SELECT @run_date = CAST([dbo].[FNAGetLOCALTime]([Date] , @default_code_value) AS DATE) FROM [temp_process_table] 

--SET @run_date = ''2021-10-31''

SELECT market_result_id, area, utc_date
,mcp
,mcv
,total_sched_net
,total_sched_purchase
,total_sched_sale
,linear_sched_net
,linear_sched_purchase
,linear_sched_sale
,block_sched_net
,block_sched_purchase
,block_sched_sale
,complex_sched_net
,complex_sched_purchase
,complex_sched_sale
,area_set
,[hour]
,std_date
,auction_name, participant  
INTO #udt_epex_market_results
FROM udt_epex_market_results WHERE CAST(std_date AS DATE) = @run_date

UPDATE a
SET [hour] = 24		
FROM #udt_epex_market_results a
INNER JOIN (
SELECT ROW_NUMBER() OVER (PARTITION BY area, area_set, auction_name, participant, std_date  
ORDER BY market_result_id) rn, market_result_id FROM #udt_epex_market_results
) b ON b.market_result_id = a.market_result_id AND rn =2
 	
IF OBJECT_ID(''tempdb..#profile'') IS NOT NULL
	DROP TABLE #profile

CREATE TABLE #profile(
	[profile_id] INT,
	[auction_name_id] INT,
	[date] DATE,
	[min] INT,
	[participant] NVARCHAR(100) COLLATE DATABASE_DEFAULT,
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
	[hr24] FLOAT,
	[hr25] FLOAT
)

IF OBJECT_ID(''tempdb..#curve'') IS NOT NULL
	DROP TABLE #curve

CREATE TABLE #curve (
	curve_id INT,
	curve_value FLOAT,
	std_date DATETIME,
	is_dst BIT,
	curve_source_value_id INT, 
	assessment_curve_type_value_id INT
)
--SELECT * FROM #udt_epex_market_results

DECLARE @auction_name NVARCHAR(100), @participant NVARCHAR(100), @column_name NVARCHAR(150),  @profile_id NVARCHAR(20), @curve_id NVARCHAR(20)
DECLARE profile_cursor CURSOR FOR
	SELECT DISTINCT a.auction_name, a.participant, a.column_name, a.profile_id, a.curve_id FROM #udt_epex_market_results upmr
	OUTER APPLY (
	SELECT clm1_value auction_name, clm2_value participant, REPLACE(REPLACE(clm3_value, '' '', ''_''), ''.'', '''') + ''_''+ clm4_value column_name, clm5_value profile_id, clm6_value curve_id FROM generic_mapping_values gmv 
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
	WHERE gmh.mapping_name = ''EPEX DA/ID Aggregation Mapping''
	) a 
	WHERE CAST(upmr.auction_name AS NVARCHAR(20)) = a.auction_name AND upmr.participant = a.participant
OPEN profile_cursor
FETCH NEXT FROM profile_cursor
INTO @auction_name, @participant, @column_name, @profile_id, @curve_id
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @sql = ''
			WITH cte AS (
			SELECT auction_name, CAST(std_date AS DATE) std_date, ('' + @column_name + '') '' + @column_name +'', [hour], 0[min], participant
				FROM #udt_epex_market_results 
			UNION ALL
			SELECT auction_name, std_date, '' + @column_name + '', [hour], [min] + 15 , participant
			FROM cte 
	
			WHERE [min] + 15 <= 45
			)
			INSERT INTO #profile([profile_id], [auction_name_id], [date], [min], [participant], [hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12], [hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], [hr23], [hr24], [hr25])
			SELECT '' + @profile_id + '', auction_name,std_date, [min], participant, [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24]
			FROM (
			SELECT * FROM cte
			) p
			PIVOT
			(
			  SUM('' + @column_name + '')
			  FOR [hour] in ([0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24])
			) piv
			WHERE auction_name = '''''' + @auction_name + '''''' AND participant= '''''' + @participant + ''''''''

	SET @sql += '' 

			INSERT INTO #curve(curve_id, std_date, curve_value, is_dst, curve_source_value_id, assessment_curve_type_value_id)		
			SELECT '' + @curve_id + '', std_date, mcp , IIF([hour] = 24, 1, 0), 4500,77
			FROM #udt_epex_market_results piv WHERE 1 = 1
			AND piv.auction_name = '''''' + @auction_name + '''''' AND piv.participant= '''''' + @participant + ''''''''
	
	EXEC(@sql) 
	FETCH NEXT FROM profile_cursor INTO @auction_name, @participant, @column_name, @profile_id, @curve_id
END
CLOSE profile_cursor
DEALLOCATE profile_cursor

SELECT @col = ''Hr'' + CAST(md.hour AS NVARCHAR) + '' = Hr'' + CAST(md.hour AS NVARCHAR) + '' + ISNULL(Hr25, 0)''
FROM #profile tmp
INNER JOIN mv90_DST md ON  md.date = tmp.date AND md.insert_delete = ''i''
	AND md.dst_group_value_id = 102201

SET @sql = '' UPDATE	tmp
 			SET '' + @col + ''
 			FROM #profile tmp
 			INNER JOIN mv90_DST md
 				ON  md.date = tmp.date 
 				AND md.insert_delete = ''''i''''
				AND md.dst_group_value_id = 102201''
EXEC(@sql)

UPDATE ddh
SET 
Hr1 = p.Hr1 
, Hr2 = p.Hr2
, Hr3 = p.Hr3
, Hr4 = p.Hr4
, Hr5 = p.Hr5
, Hr6 = p.Hr6
, Hr7 = p.Hr7
, Hr8 = p.Hr8
, Hr9 = p.Hr9
, Hr10 = p.Hr10
, Hr11 = p.Hr11
, Hr12 = p.Hr12
, Hr13 = p.Hr13
, Hr14 = p.Hr14
, Hr15 = p.Hr15
, Hr16 = p.Hr16
, Hr17 = p.Hr17
, Hr18 = p.Hr18
, Hr19 = p.Hr19
, Hr20 = p.Hr20
, Hr21 = p.Hr21
, Hr22 = p.Hr22
, Hr23 = p.Hr23
, Hr24 = p.Hr24
, Hr25 = p.Hr25
FROM deal_detail_hour ddh 
INNER JOIN #profile p ON p.profile_id = ddh.profile_id AND p.[date] = ddh.[term_date] AND p.[min] = ddh.[period]

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
	, Hr25
	, [period]
)
SELECT p.[date]
	, p.profile_id
	, p.Hr1
	, p.Hr2
	, p.Hr3
	, p.Hr4
	, p.Hr5
	, p.Hr6
	, p.Hr7
	, p.Hr8
	, p.Hr9
	, p.Hr10
	, p.Hr11
	, p.Hr12
	, p.Hr13
	, p.Hr14
	, p.Hr15
	, p.Hr16
	, p.Hr17
	, p.Hr18
	, p.Hr19
	, p.Hr20
	, p.Hr21
	, p.Hr22
	, p.Hr23
	, p.Hr24
	, p.Hr25
	, p.[min]
FROM #profile p 
LEFT JOIN deal_detail_hour ddh ON p.profile_id = ddh.profile_id AND p.[date] = ddh.[term_date] AND p.[min] = ddh.[period]
WHERE ddh.[term_date] IS NULL

UPDATE
spc 
SET curve_value = c.curve_value
FROM #curve c
INNER JOIN source_price_curve spc ON spc.source_curve_def_id = c.curve_id AND spc.maturity_date = c.std_date 
AND spc.is_dst = c.is_dst AND spc.curve_source_value_id = c.curve_source_value_id AND spc.Assessment_curve_type_value_id = c.assessment_curve_type_value_id
AND spc.as_of_date = CAST(DATEADD(DAY, 0, std_date) AS DATE)

INSERT INTO source_price_curve
(
source_curve_def_id
,as_of_date
,Assessment_curve_type_value_id
,curve_source_value_id
,maturity_date
,curve_value
,is_dst
)
SELECT DISTINCT 
c.curve_id,  CAST(DATEADD(DAY, 0, std_date) AS DATE) , c.Assessment_curve_type_value_id, c.curve_source_value_id, std_date, c.curve_value, c.is_dst
FROM #curve c
LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = c.curve_id AND spc.maturity_date = c.std_date 
AND spc.is_dst = c.is_dst AND spc.curve_source_value_id = c.curve_source_value_id AND spc.Assessment_curve_type_value_id = c.assessment_curve_type_value_id
AND spc.as_of_date =  CAST(DATEADD(DAY, 0, std_date) AS DATE)
WHERE spc.source_curve_def_id  IS NULL 

DECLARE @prss_id NVARCHAR(200), @user_login_id NVARCHAR(50), @report_position_deals NVARCHAR(100)
SET @prss_id = dbo.FNAGetNewID()

SET @report_position_deals = dbo.FNAProcessTableName(''report_position'', @user_login_id, @prss_id)
EXEC (''CREATE TABLE '' + @report_position_deals + ''(source_deal_header_id INT, create_user NVARCHAR(50), [action] NVARCHAR(1), source_deal_detail_id INT)'')
		
SET @sql = ''INSERT INTO '' + @report_position_deals + ''(source_deal_header_id, source_deal_detail_id) 
	SELECT source_deal_header_id, source_deal_detail_id  FROM #profile p
	INNER JOIN source_deal_detail sdd ON sdd.profile_id = p.profile_id''

EXEC (@sql)

EXEC dbo.spa_update_deal_total_volume NULL, @prss_id

'
				, after_insert_trigger = 'IF NOT EXISTS (SELECT 1 FROM [temp_process_table])
BEGIN
	DELETE FROM source_system_data_import_status_detail WHERE process_id = ''@process_id''

	INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description])
	SELECT DISTINCT ''@process_id'', ''ixp_custom_tables'', ''Data Import'', ''Market results not available.''

	UPDATE source_system_data_import_status
	SET code = ''Error'',
		[description] = ''Data could not be imported <font color=red>(ERRORS found)</font>.''
	WHERE Process_id = ''@process_id''
END
'
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23500
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
									WHERE it.ixp_tables_name = 'ixp_custom_tables'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\EU-U-SQL03\shared_docs_TRMTracker_Enercity_UAT\temp_Note\0',
						   NULL,
						   '|',
						   2,
						   'ermr',
						   '1',
						   'DECLARE @response NVARCHAR(MAX) = '''', @process_table NVARCHAR(150)
SELECT @response = COALESCE(@response + ''<br>'', '''') + column1 FROM [temp_process_table] ORDER BY ixp_source_unique_id ASC
SET @process_table = dbo.FNAProcessTableName(''epex_market_results'', dbo.FNADBUser(), dbo.FNAGetNewID())

EXEC(''
IF OBJECT_ID('''''' + @process_table + '''''') IS NOT NULL DROP TABLE '' + @process_table + '' 
CREATE TABLE '' + @process_table +'' (
[Area] NVARCHAR(600),
[Area Set] NVARCHAR(600),
[Auction Name] NVARCHAR(600),
[Participant] NVARCHAR(600),
[Date] NVARCHAR(600),
[MCP (EUR/MWh)] NVARCHAR(600),
[MCV (MW)] NVARCHAR(600),
[Total Sched Net] NVARCHAR(600),
[Total Sched Purchase] NVARCHAR(600),
[Total Sched Sale] NVARCHAR(600),
[Linear Sched Net] NVARCHAR(600),
[Linear Sched Purchase] NVARCHAR(600),
[Linear Sched Sale] NVARCHAR(600),
[Block Sched Net] NVARCHAR(600),
[Block Sched Purchase] NVARCHAR(600),
[Block Sched Sale] NVARCHAR(600),
[Complex Sched Net] NVARCHAR(600),
[Complex Sched Purchase] NVARCHAR(600),
[Complex Sched Sale] NVARCHAR(600)
)
''
)
IF NULLIF(@response, '''') IS NOT NULL  
BEGIN
	EXEC spa_build_epex_data_table @process_table, ''DE-TPS'', @response 
END
EXEC(''
SELECT * 
--[__custom_table__]
FROM '' + @process_table)
',
						   'y',
						   0,
						   '',
						   '1',
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
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = 'EPEXRetrieveMarketResultsForDayAhead' 
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
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Area]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Participant]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[MCP (EUR/MWh)]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[MCV (MW)]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column5' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Total Sched Net]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column6' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Total Sched Purchase]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column7' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Total Sched Sale]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column8' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Linear Sched Net]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column9' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Linear Sched Purchase]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column10' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Linear Sched Sale]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column11' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Block Sched Net]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column12' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Block Sched Purchase]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column13' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Block Sched Sale]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column14' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Complex Sched Net]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column16' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Complex Sched Purchase]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column17' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Complex Sched Sale]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column18' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Area Set]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column19' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'ermr.[Auction Name]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_custom_tables'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'column20' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_custom_tables'

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