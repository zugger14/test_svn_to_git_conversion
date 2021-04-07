IF OBJECT_ID(N'[dbo].[spa_calc_weighted_average_price]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_calc_weighted_average_price]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON 
GO

/**
	Returns dataset with weighted average price calculated.

	Parameters 
	@flag : Operational flag.
			'c' for calculating weighted average price.
	@source_process_table : Uploaded source data
	@calc_process_table : Calculated data
	@generic_mapping_process : Mapping process name
	@debug_mode	: Default is 0 to suppress query execution used for debugging purpose. To debug set 1.
*/


CREATE PROCEDURE [dbo].[spa_calc_weighted_average_price]
	@flag CHAR(50),
	@source_process_table NVARCHAR(200) = NULL, 
	@calc_process_table NVARCHAR(200) = NULL
	, @generic_mapping_process NVARCHAR(200) = NULL
	, @debug_mode BIT = 0
AS

SET NOCOUNT ON;

/*
--Added for Debugging Purpose
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'

EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'farrms_admin';

DECLARE	@flag CHAR(50)
	, @source_process_table NVARCHAR(200)  
	, @calc_process_table NVARCHAR(200) 
	, @generic_mapping_process NVARCHAR(200) = NULL
	, @debug_mode BIT = 1

----case Generation
--SELECT @flag = 'c'
--	, @source_process_table= 'adiha_process.dbo.ixp_generation_lt_import_0_makryal_D63730D7_EC11_421F_88B5_4C8B6CE85BD4'
--	, @calc_process_table= 'adiha_process.dbo.generationms1_11111' 
	
--case Renewable
--SELECT @flag = 'c'
--	, @source_process_table= 'adiha_process.dbo.upload_case_1_renewal_farrms_admin_22222'
--	, @calc_process_table= 'adiha_process.dbo.msrenewal1_22222' 

--case Transportation Capacity
SELECT @flag = 'c'
	, @source_process_table= 'adiha_process.dbo.temp_src_details_EA0C189A_3B88_4E87_A924_6205310A5800'
	, @calc_process_table= 'adiha_process.dbo.temp_output_details_EA0C189A_3B88_4E87_A924_6205310A5800' 
	, @generic_mapping_process = 'Transportation Capacity'
--	select * from adiha_process.dbo.upload_case_1_generation_farrms_admin_11111
--Drops all temp tables created in this scope.

--EXEC spa_drop_all_temp_table
--*/

DECLARE @sql NVARCHAR(MAX)
IF @flag = 'c'
BEGIN
	SET @sql = 'IF NOT EXISTS(
 		   SELECT 1
 		   FROM   adiha_process.sys.columns WITH (NOLOCK)
 		   WHERE  [name] = ''index''
 				  AND [object_id] = OBJECT_ID(''' + @source_process_table + ''')
 		)
 		ALTER TABLE ' + @source_process_table + ' ADD [index] NVARCHAR(100)'
		
EXEC (@sql)

EXEC ('IF NOT EXISTS(
 		   SELECT 1
 		   FROM   adiha_process.sys.columns WITH (NOLOCK)
 		   WHERE  [name] = ''price''
 				  AND [object_id] = OBJECT_ID(''' + @source_process_table + ''')
 		)
 		ALTER TABLE ' + @source_process_table + ' ADD price FLOAT'
     )

DECLARE @dst_group_value_id INT 
	, @aggregation_level INT = 980
	, @total_columns NVARCHAR(MAX)
	, @granularity int 
	, @min_term varchar(10) 
	, @max_term varchar(10)

SELECT @dst_group_value_id = tz.dst_group_value_id	--102201
FROM adiha_default_codes_values adcv
INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
WHERE adcv.default_code_id = 36

DROP TABLE IF EXISTS #mapping_name
CREATE TABLE #mapping_name(mapping_id INT, mapping_name NVARCHAR(200) COLLATE DATABASE_DEFAULT)

SET @sql = 'IF NOT EXISTS(
 		   SELECT 1
 		   FROM   adiha_process.sys.columns WITH (NOLOCK)
 		   WHERE  [name] = ''mapping_name''
 				  AND [object_id] = OBJECT_ID(''' + @source_process_table + ''')
 		)
		ALTER TABLE ' + @source_process_table + ' ADD mapping_name NVARCHAR(200)'
EXEC (@sql)		 
IF @generic_mapping_process IS NOT NULL
BEGIN
	SET @sql += ' UPDATE ' + @source_process_table + ' SET mapping_name = ''' + @generic_mapping_process + ''''
	EXEC (@sql)
END

EXEC('INSERT INTO #mapping_name(mapping_id,mapping_name)
		SELECT TOP 1 sdv.value_id, sdv.code FROM ' + @source_process_table + ' src
		INNER JOIN static_data_value sdv ON sdv.code = src.mapping_name AND sdv.type_id = 112700'
		)

 -- alter table adiha_process.dbo.src_capacity_33333 drop column mapping_name

DECLARE @mapping_id INT = 112700 

SELECT @mapping_id = mapping_id  FROM #mapping_name

DECLARE @gas_case INT = 0

IF @mapping_id IN (112704,112707,112703) 
SET @gas_case = 1

--Generic mapping block starts.
IF OBJECT_ID(N'tempdb..#generic_mapping_values') IS NOT NULL
DROP TABLE #generic_mapping_values

CREATE TABLE #generic_mapping_values(mapping_table_id	int,
			clm1_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm2_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm3_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm4_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm5_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm6_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm7_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm8_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm9_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm10_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm11_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm12_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm13_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm14_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm15_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm16_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm17_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm18_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm19_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT,
			clm20_value	nvarchar(MAX) COLLATE DATABASE_DEFAULT
			)
SET @sql = '
	INSERT INTO #generic_mapping_values(mapping_table_id
		, clm1_value	
		, clm2_value	
		, clm3_value	
		, clm4_value	
		, clm5_value	
		, clm6_value	
		, clm7_value	
		, clm8_value	
		, clm9_value	
		, clm10_value
		, clm11_value
		, clm12_value
		, clm13_value
		, clm14_value
		, clm15_value
		, clm16_value
		, clm17_value
		, clm18_value
		, clm19_value
		, clm20_value
	)
	SELECT gmv.[mapping_table_id]	 
	   , gmv.[clm1_value]
	   , gmv.[clm2_value]		
	   , gmv.[clm3_value]		
	   , gmv.[clm4_value]		
	   , gmv.[clm5_value]		
	   , gmv.[clm6_value]		
	   , gmv.[clm7_value]		
	   , gmv.[clm8_value]		
	   , gmv.[clm9_value]		
	   , gmv.[clm10_value]		
	   , gmv.[clm11_value]		
	   , gmv.[clm12_value]		
	   , gmv.[clm13_value]		
	   , gmv.[clm14_value]		
	   , gmv.[clm15_value]		
	   , gmv.[clm16_value]		
	   , gmv.[clm17_value]		
	   , gmv.[clm18_value]		
	   , gmv.[clm19_value]		
	   , gmv.[clm20_value]	
FROM  generic_mapping_header gmh
INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id
'  

IF @mapping_id = 112704
BEGIN
	--Storage ST case pick process_type, template, delivery max effective date
	SET @sql += '
		CROSS APPLY (
			SELECT clm1_value, MAX(clm2_value) clm2_value,clm13_value,clm20_value 
			FROM generic_mapping_values gmv 
			WHERE gmv.mapping_table_id = gmh.mapping_table_id
			GROUP BY clm1_value,clm13_value,clm20_value
		) mx
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id 
			AND gmv.clm1_value = mx.clm1_value
			AND gmv.clm2_value = mx.clm2_value
			AND ISNULL(gmv.clm13_value, '''') = ISNULL(mx.clm13_value,'''')
			AND ISNULL(gmv.clm20_value,'''') = ISNULL(mx.clm20_value,'''')
		'
END
ELSE IF @mapping_id = 112703
BEGIN
	--Transportation Capacity case pick max effective date of process_type, location
	SET @sql += '
		CROSS APPLY (
			SELECT clm1_value, MAX(clm2_value) clm2_value,clm11_value 
			FROM generic_mapping_values gmv 
			WHERE gmv.mapping_table_id = gmh.mapping_table_id
			GROUP BY clm1_value,clm11_value
		) mx
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id 
			AND gmv.clm1_value = mx.clm1_value
			AND gmv.clm2_value = mx.clm2_value
			AND ISNULL(gmv.clm11_value, '''') = ISNULL(mx.clm11_value,'''')
		'
END
ELSE 
BEGIN
	--Max effective data of process type
	SET @sql += '
		CROSS APPLY (
			SELECT clm1_value, MAX(clm2_value) clm2_value
			FROM generic_mapping_values gmv 
			WHERE gmv.mapping_table_id = gmh.mapping_table_id
			GROUP BY clm1_value
		) mx
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id 
			AND gmv.clm1_value = mx.clm1_value
			AND gmv.clm2_value = mx.clm2_value
		'
END

SET @sql += '
	WHERE gmh.mapping_name = ''Transfer Volume Mapping'' 
		AND TRY_CAST(gmv.clm1_value AS INT) = ' + CAST(@mapping_id AS NVARCHAR(10))
	
EXEC(@sql)



IF @debug_mode = 1
select 'generic_mapping_values', * from #generic_mapping_values
--return

DROP TABLE IF EXISTS #gm_deals
CREATE TABLE #gm_deals(source_deal_header_id INT)

INSERT INTO #gm_deals
select sdh.close_reference_id source_deal_header_id 
FROM source_deal_header sdh
INNER JOIN #generic_mapping_values gmv ON gmv.clm15_value = sdh.source_deal_header_id OR gmv.clm16_value = sdh.source_deal_header_id 
UNION
select sdh.source_deal_header_id
FROM source_deal_header sdh
INNER JOIN #generic_mapping_values gmv ON gmv.clm14_value = sdh.source_deal_header_id

IF OBJECT_ID(N'tempdb..#deal_max_term') IS NOT NULL
DROP TABLE #deal_max_term

CREATE TABLE #deal_max_term(
	source_deal_header_id INT
	, block_define_id INT
	, term_start DATE
	, term_end DATE
	, profile_name NVARCHAR(200) COLLATE DATABASE_DEFAULT
)

IF OBJECT_ID('tempdb..#src_hour_breakdown') IS NOT NULL 
		DROP TABLE #src_hour_breakdown
CREATE TABLE #src_hour_breakdown(dummy_column int)

IF @mapping_id = 112700
BEGIN
	SET @sql = '
		INSERT INTO #deal_max_term(source_deal_header_id, block_define_id, term_start, term_end)
		SELECT sdh.source_deal_header_id
			, MAX(sdh.block_define_id) block_define_id
			, MIN(CAST([term_start] AS DATE)) term_start
			, MAX(CAST([term_end]  AS DATE)) term_end	
		FROM ' + @source_process_table + ' s1
		INNER JOIN source_deal_header sdh ON sdh.deal_id = s1.[deal_id]
		GROUP BY sdh.source_deal_header_id '
	EXEC(@sql)

	SET @sql = '
		SELECT RIGHT(''0'' + CAST(DATEPART(hour,breakdown_term_end)+1 AS NVARCHAR(4)),2) + '':'' + RIGHT(''0'' + CAST(DATEPART(minute,breakdown_term_end) AS NVARCHAR(4)),2) hr_min
			, RIGHT(''0'' + CAST(DATEPART(hour,breakdown_term_end)+1 AS NVARCHAR(4)),2) + '':'' + RIGHT(''0'' + CAST(DATEPART(minute,breakdown_term_end) AS NVARCHAR(4)),2) src_hr_min	--TODO this may needs correction
			, CAST(breakdown_term_start AS DATE) term
			, DATEPART(hour,breakdown_term_end)+1 [hr]
			, DATEPART(minute,breakdown_term_end) [period]
			, is_dst
			, upload_date
			, deal_id
			, volume
			, product
			, price
			, [index]
			, CAST(term_start AS DATE) src_term_start
			, CAST(term_end AS DATE) src_term_end
		FROM(
			SELECT 
				tbd.term_start breakdown_term_start,tbd.term_end breakdown_term_end,tbd.is_dst,t.* 	
			FROM ' + @source_process_table + ' t
			INNER JOIN source_deal_header sdh ON sdh.deal_id = t.deal_id
			INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id 
			CROSS APPLY (
				SELECT * 
				FROM dbo.FNATermBreakdownByGranularity(ISNULL(sdht.hourly_position_breakdown, 982), t.[term_start], t.[term_end],' + CAST(@dst_group_value_id AS NVARCHAR(8)) + ')
			) tbd
		) rs
		'
END
ELSE IF @mapping_id IN (112702,112703,112704)
BEGIN	
	IF @mapping_id = 112702
BEGIN	
	SET @sql = '
		INSERT INTO #deal_max_term(source_deal_header_id, block_define_id, term_start, term_end, profile_name)
		SELECT sdh.source_deal_header_id
			, MAX(sdh.block_define_id) block_define_id
			, MIN(CAST(s1.[term] AS DATE)) term_start
			, MAX(CAST(s1.[term]  AS DATE)) term_end
			, MAX(s1.profile_name) profile_name
		FROM #gm_deals gd
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = gd.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = ISNULL(sdd.location_id, -1)
		LEFT JOIN forecast_profile fp ON fp.profile_id = COALESCE(sdd.profile_id, sml.profile_id, -1)				
		INNER JOIN ' + @source_process_table + ' s1 ON s1.profile_name = fp.external_id
		GROUP BY sdh.source_deal_header_id '
	EXEC(@sql)

	SELECT @min_term = CONVERT(VARCHAR(10),MIN(term_start),120)
		, @max_term =  CONVERT(VARCHAR(10),MAX(term_end),120) 
		, @granularity = MAX(fp.granularity) 
	FROM #deal_max_term src
	INNER JOIN forecast_profile fp ON fp.external_id = src.profile_name

	END
	ELSE
	BEGIN
		SET @sql = '
			INSERT INTO #deal_max_term(source_deal_header_id, block_define_id, term_start, term_end)
			SELECT sdh.source_deal_header_id
				, MAX(sdh.block_define_id) block_define_id
				, MIN(CAST(s1.[term] AS DATE)) term_start
				, MAX(CAST(s1.[term] AS DATE)) term_end			
			FROM ' + @source_process_table + ' s1
			INNER JOIN source_deal_header sdh ON sdh.deal_id = s1.[deal_id]			
			GROUP BY sdh.source_deal_header_id '

		EXEC(@sql)

		SELECT @min_term = CONVERT(VARCHAR(10),MIN(term_start),120)
			, @max_term =  CONVERT(VARCHAR(10),MAX(term_end),120) 
			, @granularity = 982 
		FROM #deal_max_term src
		--INNER JOIN forecast_profile fp ON fp.external_id = src.profile_name
	END


	IF @granularity IN (982, 989, 987, 994, 995)
	BEGIN
		DECLARE @shift_value INT = 0
		IF @gas_case = 1
		SET @shift_value = 6 --Gas case source hr starts from 7 as first hour.

		IF OBJECT_ID('tempdb..#temp_hour_breakdown') IS NOT NULL
			DROP TABLE #temp_hour_breakdown

		SELECT clm_name, is_dst, alias_name, CASE WHEN is_dst = 0 THEN RIGHT('0' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '_' + RIGHT(clm_name, 2) ELSE RIGHT('0' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '_' + RIGHT(clm_name, 2) + '_DST' END [process_clm_name]
		INTO #temp_hour_breakdown 
		FROM dbo.FNAGetDisplacedPivotGranularityColumn(@min_term,@max_term,@granularity,@dst_group_value_id, @shift_value) 
	END
	
	SET @sql = 'SELECT  REPLACE(REPLACE(thb.process_clm_name, ''_DST'',''''),''_'','':'') hr_min
					, REPLACE(thb.alias_name,''DST'','''') src_hr_min
					, CAST(LEFT(REPLACE(thb.process_clm_name, ''_DST'',''''),2) AS INT)  hr
					, CAST(RIGHT(REPLACE(thb.process_clm_name, ''_DST'',''''),2) AS INT) [period]
					, CAST(src.term AS DATE) src_term_start
					, CAST(src.term AS DATE) src_term_end
					, src.* 		
				FROM ' + @source_process_table + '  src
				INNER JOIN #temp_hour_breakdown thb ON REPLACE(REPLACE(thb.process_clm_name, ''_DST'',''''),''_'','':'') = RIGHT(''0'' + src.hour,2) + '':'' + RIGHT(''0''+ISNULL(minute,0),2)
					AND thb.is_dst = src.is_dst
				--where src.term=''2021-10-31'' and [is_dst]=1
				ORDER BY term,hour,minute,[is_dst]'
	--select @sql

END
EXEC spa_get_output_schema_or_data @sql_query = @sql
		,@process_table_name = '#src_hour_breakdown'
		,@data_output_col_count = @total_columns OUTPUT
		,@flag = 'data'
--todo term length is nvarchar(600 n max allowed idex length is 450

create nonclustered index indx_src_hour_breakdown on #src_hour_breakdown (hr,[period])

IF @debug_mode = 1
select  '#src_hour_breakdown',count(1) from #src_hour_breakdown --order by term,hr,[period]

IF @mapping_id = 112704	--storage case
BEGIN
	DROP TABLE IF EXISTS #group_deals
	CREATE TABLE #group_deals(structured_deal_id INT, group_source_deal_header_id INT, group_deal_id NVARCHAR(500))

	INSERT INTO #group_deals(structured_deal_id,group_source_deal_header_id, group_deal_id)
	SELECT DISTINCT lnk_deal.structured_deal_id,lnk_deal.source_deal_header_id,lnk_deal.deal_id
	FROM #deal_max_term dmt
	CROSS APPLY (
		SELECT structured_deal_id,source_deal_header_id,deal_id FROM source_deal_header WHERE structured_deal_id = dmt.source_deal_header_id --AND source_deal_header_id <> dmt.source_deal_header_id
	) lnk_deal
	LEFT JOIN #deal_max_term dmt1 ON dmt1.source_deal_header_id = lnk_deal.source_deal_header_id
	WHERE dmt1.source_deal_header_id is null
	
	drop table if exists #src_hour_breakdown_grp

	IF EXISTS(SELECT 1 FROM #group_deals)
	BEGIN
		
		SELECT sdh.*,a.*
		INTO #src_hour_breakdown_grp
		from #src_hour_breakdown sdh
		INNER JOIN source_deal_header sdh1 ON sdh1.deal_id = sdh.deal_id
		CROSS APPLY(SELECT group_source_deal_header_id, group_deal_id FROM #group_deals gd WHERE gd.structured_deal_id = sdh1.source_deal_header_id)a
		UNION
		SELECT *,null,deal_id
		from #src_hour_breakdown 

		UPDATE a
		SET deal_id = group_deal_id
		from #src_hour_breakdown_grp a
		--INNER JOIN #src_hour_breakdown b ON a.deal_id = b.deal_id	AND a.term = b.term and a.hour = b.hour and a.minute = b.minute and a.is_dst = b.is_dst

		
	END
END

SELECT @min_term = MIN(CAST(term_start AS DATE))
	, @max_term = MAX(CAST(term_end AS DATE)) 
FROM #deal_max_term src

--Collect deals either from file, generic mapping
IF OBJECT_ID(N'tempdb..#collect_deals') IS NOT NULL
DROP TABLE #collect_deals

SELECT DISTINCT sdh.source_deal_header_id, sdh.deal_id,sdh.counterparty_id,sdh.source_deal_type_id, sdh.deal_sub_type_type_id
	, sdh.template_id
	, sdh.header_buy_sell_flag
	, sdh.contract_id
	, sdh.internal_desk_id
	, sdh.commodity_id
	, sdh.close_reference_id
	, ISNULL(sdh.block_define_id, -10000298) block_define_id --Base Load
	, sdh.physical_financial_flag
	, sdh.profile_granularity
	, sdh.sub_book
	, sdh.internal_counterparty
	, sdh.pricing_type
	, sdd.source_deal_detail_id
	, sdd.term_start
	, sdd.term_end
	, sdd.leg
	, sdd.curve_id
	, sdd.fixed_price
	, sdd.deal_volume
	, sdd.deal_volume_frequency	
	, sdd.location_id
	, sdd.buy_sell_flag
	, dmt.profile_name
	, sdh.structured_deal_id
INTO #collect_deals	
FROM #deal_max_term dmt
OUTER APPLY (
	select source_deal_header_id from source_deal_header where structured_deal_id = dmt.source_deal_header_id AND source_deal_header_id <> dmt.source_deal_header_id
) lnk_deal
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = dmt.source_deal_header_id OR sdh.source_deal_header_id = lnk_deal.source_deal_header_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	--AND (sdd.term_start BETWEEN dmt.term_start  AND dmt.term_end --daily
	--	AND (dmt.term_start BETWEEN sdd.term_start  AND sdd.term_end OR dmt.term_end BETWEEN sdd.term_start  AND sdd.term_end)
	--	)
CREATE INDEX indx_collect_deals_ps ON #collect_deals(source_deal_header_id, term_start, term_end)
--select 'total collect deals' , count(1) FROM #collect_deals
--return

IF OBJECT_ID(N'tempdb..#mv90_dst') IS NOT NULL
DROP TABLE #mv90_dst

SELECT [year]
	, IIF(@gas_case = 0, [date], DATEADD(DAY,-1,date)) [date]
	, IIF(@gas_case = 0, [hour], [hour]+18) [hour]
INTO #mv90_dst
FROM mv90_dst
WHERE insert_delete = 'i'
	AND dst_group_value_id = @dst_group_value_id 
	
	-------------------------Collect hour_block_term starts------------------------
IF OBJECT_ID(N'tempdb..#hour_block_term') IS NOT NULL
DROP TABLE #hour_block_term

CREATE TABLE #hour_block_term(block_define_id INT,term_date DATETIME, term_start DATETIME, hr INT)

INSERT INTO #hour_block_term(block_define_id,term_date,term_start,hr)
SELECT  upv.block_define_id,upv.term_date, upv.term_start,cast(substring(upv.hr,3,2) AS INT) Hr
FROM (
SELECT hb.block_define_id
	, p.term_start 
	, hb.term_date
	, hb.hr1,hb.hr2,hb.hr3,hb.hr4,hb.hr5,hb.hr6,hb.hr7,hb.hr8,hb.hr9,hb.hr10,hb.hr11,hb.hr12,hb.hr13,hb.hr14,hb.hr15,hb.hr16
	,hb.hr17,hb.hr18,hb.hr19,hb.hr20,hb.hr21,hb.hr22,hb.hr23,hb.hr24
FROM (
		SELECT * FROM #deal_max_term			
	) p
	inner join  hour_block_term hb  ON hb.block_define_id = ISNULL(p.block_define_id, -10000298)
		AND isnull(hb.block_type,12000)=12000
		AND hb.term_date BETWEEN p.term_start AND p.term_end
		AND hb.dst_group_value_id =  @dst_group_value_id
) s
	UNPIVOT
	(on_off FOR Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)	
) upv	
WHERE on_off=1
GROUP BY block_define_id,term_date,term_start,hr
ORDER BY term_start,term_date,hr
--select count(1) from #hour_block_term
--return

create nonclustered index indx_udt_aaa ON #hour_block_term (block_define_id,term_date,hr)
	-------------------------Collect hour_block_term starts------------------------

------------------------collect deal position starts-------------------------------------------------------------
DROP TABLE IF EXISTS  #temp_position

SELECT source_deal_header_id
	, source_deal_detail_id
	, term_start
	--, cast(substring(upv.hr,3,2) AS INT) hr
	, IIF(cast(substring(upv.hr,3,2) AS INT) = 25, dst.hour , cast(substring(upv.hr,3,2) AS INT)) Hr
	, [period]
	, IIF(cast(substring(upv.hr,3,2) AS INT) <> 25,0,1)  is_dst
	, val volume
	, granularity
	, deal_volume_frequency
INTO #temp_position
FROM (
SELECT rhpd.source_deal_header_id
		, d.source_deal_detail_id
 		, rhpd.term_start
		, hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25
		, rhpd.[period]
		, rhpd.granularity	
		, d.deal_volume_frequency	
	FROM #collect_deals d
	INNER JOIN report_hourly_position_deal	rhpd ON rhpd.source_deal_header_id = d.source_deal_header_id
		AND rhpd.term_start BETWEEN d.term_start AND d.term_end
		AND rhpd.term_start BETWEEN @min_term AND @max_term
		AND ISNULL(rhpd.location_id, -1) = ISNULL(d.location_id, -1)
		AND rhpd.curve_id = d.curve_id
		) rs
	UNPIVOT
		(val for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)	
) upv
OUTER APPLY(SELECT dst.date,dst.[hour]
	FROM #mv90_dst dst 
	WHERE dst.date = upv.term_start
	GROUP BY dst.date,dst.[hour]
	) dst
UNION
SELECT source_deal_header_id
	, source_deal_detail_id
	, term_start
	--, cast(substring(upv.hr,3,2) AS INT) hr
	, IIF(cast(substring(upv.hr,3,2) AS INT) = 25, dst.hour , cast(substring(upv.hr,3,2) AS INT)) Hr
	, [period]
	, IIF(cast(substring(upv.hr,3,2) AS INT) <> 25,0,1)  is_dst
	, val volume
	, granularity
	, deal_volume_frequency	
FROM (
	SELECT rhpd.source_deal_header_id
		, d.source_deal_detail_id
 		, rhpd.term_start
		, hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25
		, rhpd.[period]
		, rhpd.granularity	
		, d.deal_volume_frequency	
	FROM #collect_deals d
	INNER JOIN report_hourly_position_profile rhpd ON rhpd.source_deal_header_id = d.source_deal_header_id
		AND rhpd.term_start BETWEEN d.term_start AND d.term_end
		AND rhpd.term_start BETWEEN @min_term AND @max_term
		AND ISNULL(rhpd.location_id, -1) = ISNULL(d.location_id, -1)
		AND rhpd.curve_id = d.curve_id
		) rs
	UNPIVOT
		(val for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)	
) upv
OUTER APPLY(SELECT dst.date,dst.[hour]
	FROM #mv90_dst dst 
	WHERE dst.date = upv.term_start
	GROUP BY dst.date,dst.[hour]
	) dst
CREATE INDEX indx_udt_tp ON #temp_position (source_deal_detail_id,term_start,hr,[period])



------------------------collect deal position ends-------------------------------------------------------------
DROP TABLE IF EXISTS #source_deal_detail_hour
	
SELECT sddh.source_deal_detail_id,sddh.term_date
	, sddh.hr hr_min
	, CAST(LEFT(sddh.hr,2) AS INT) hr
	, CAST(RIGHT(sddh.hr,2) AS INT) [period]
	, sddh.is_dst
	, sddh.granularity, sddh.volume
	, sddh.price fixed_price
INTO #source_deal_detail_hour
FROM #collect_deals cd
INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = cd.source_deal_detail_id
	AND sddh.term_date BETWEEN @min_term AND @max_term
WHERE cd.internal_desk_id = 17302

CREATE INDEX indx_udt_sddh ON #source_deal_detail_hour (source_deal_detail_id,term_date,hr,[period])

DROP TABLE IF EXISTS #src_term_breakdown
CREATE TABLE #src_term_breakdown(id INT)

SET @sql = 'select  cd.profile_name, cd.deal_id,src.Term,src.hr , src.[period], src.is_dst is_dst
		, src.volume uploaded_volume, cd.deal_volume org_volume
		, src.price uploaded_fixed_price
		, sddh.fixed_price,cd.fixed_price org_fixed_price
		, spcd.source_curve_def_id uploaded_curve_id
		, cd.internal_desk_id
		, ' + IIF (@gas_case = 0, 'src.src_hr_min', 'src.hr_min') + ' src_hr_min
		, src.src_term_start 
		, src.src_term_end 
		, src.hr_min process_hr_min	--added for resolving source hr for gas dst case.
	'
IF OBJECT_ID('tempdb..#src_hour_breakdown_grp') IS NULL
SET @sql += ' FROM #src_hour_breakdown src '
ELSE 
SET @sql += ' FROM  #src_hour_breakdown_grp src '

IF @mapping_id IN (112700,112703,112704)
BEGIN
	SET @sql += '
			INNER JOIN #collect_deals cd ON src.deal_id = cd.deal_id 
			AND src.term between cd.term_start AND cd.term_end
			'
END
ELSE IF @mapping_id = 112702
BEGIN
	SET @sql += '
		INNER JOIN #collect_deals cd ON src.profile_name = cd.profile_name 
				AND src.term between cd.term_start AND cd.term_end
	'		
END

SET @sql += '
	LEFT JOIN source_price_curve_def spcd ON spcd.curve_id = src.[index]
	LEFT JOIN #source_deal_detail_hour sddh ON sddh.source_deal_detail_id = cd.source_deal_detail_id		
		AND sddh.term_date = src.term 
		AND sddh.hr_min = src.hr_min
		AND sddh.is_dst = src.is_dst
	'
	

EXEC spa_get_output_schema_or_data @sql_query = @sql
		,@process_table_name = '#src_term_breakdown'
		,@data_output_col_count = @total_columns OUTPUT
		,@flag = 'data'

If @debug_mode = 1
SELECT top 1 '#src_term_breakdown',@sql, * FROM #src_term_breakdown	--where term = '2020-01-01' and hr=1	

IF OBJECT_ID(N'tempdb..#original_deal') IS NOT NULL
	DROP TABLE #original_deal

	SELECT cd.deal_id
		, cd.source_deal_header_id
		, src.term term_start
		, ISNULL(tp.granularity, cd.profile_granularity) granularity
		, src.hr	--IIF(src.hr = 25, dst.hour , src.hr) Hr
		, src.[period]
		, src.is_dst	--IIF(src.hr = 25, 1 , 0)  is_dst
		, ABS(ISNULL(tp.volume,0) * IIF(ISNULL(tp.granularity, cd.profile_granularity) = 987,4,1)) original_volume
		, COALESCE(sddh.price, src.org_fixed_price,0) original_price	--sddh price , sdd fixed price or 0 if not found in rhp
		, cd.source_deal_detail_id
		, cd.curve_id	
		, cd.location_id
		, cd.internal_desk_id
		, cd.profile_name
		, src.src_hr_min
		, src.src_term_start
		, src.src_term_end
		, cd.contract_id
		, cd.template_id
		, cd.structured_deal_id
		, tp.deal_volume_frequency
		, src.process_hr_min
	INTO #original_deal
	--select top 1 * --from #collect_deals
	FROM #src_term_breakdown src
	INNER JOIN #collect_deals cd ON (src.profile_name = cd.profile_name  OR src.deal_id = cd.deal_id)
		AND src.term between cd.term_start AND cd.term_end
	LEFT JOIN #temp_position tp ON tp.source_deal_detail_id = cd.source_deal_detail_id
		AND tp.term_start = src.term 
		AND tp.hr = src.hr
		AND tp.[period] = src.[period]
		AND tp.is_dst = src.is_dst
	LEFT JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = cd.source_deal_detail_id
		AND sddh.term_date = src.term 
		AND sddh.hr = src.src_hr_min
		AND sddh.is_dst = src.is_dst
	INNER JOIN #hour_block_term hbt ON hbt.block_define_id = cd.block_define_id
		AND hbt.term_date = src.term
		AND hbt.hr = src.hr

		
UPDATE a
SET original_volume = IIF(a.is_dst = 0, a.original_volume - rs.original_volume,a.original_volume)  
FROM #original_deal a
CROSS APPLY(SELECT source_deal_header_id,term_start,hr,original_volume 
	FROM #original_deal b 
	WHERE b.source_deal_header_id = a.source_deal_header_id
		AND a.term_start = b.term_start
		AND a.hr = b.hr
		AND b.is_dst = 1) rs

--select 'original_deal', count(1) from #original_deal --where term_start= '2021-10-31 00:00:00.000'
--return

IF OBJECT_ID(N'tempdb..#source_price_curve') IS NOT NULL
DROP TABLE #source_price_curve

CREATE TABLE #source_price_curve(source_curve_def_id INT, maturity_date DATETIME, as_of_date DATETIME, is_dst INT, granularity INT)
SET @sql = 'INSERT INTO #source_price_curve(source_curve_def_id,maturity_date,as_of_date,is_dst,granularity)
	SELECT spc.source_curve_def_id, spc.maturity_date, MAX(spc.as_of_date) as_of_date, spc.is_dst,MAX(spcd.granularity) granularity
	FROM (SELECT DISTINCT curve_id FROM  #collect_deals) d	
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = d.curve_id
	INNER JOIN source_price_curve spc ON  spc.source_curve_def_id = spcd.source_curve_def_id
	WHERE spc.curve_source_value_id = 4500
		AND spc.maturity_date BETWEEN ''' + @min_term + ''' AND ''' + @max_term + '''
	GROUP BY spc.source_curve_def_id, spc.maturity_date, spc.is_dst
	UNION
	SELECT spc.source_curve_def_id, spc.maturity_date, MAX(spc.as_of_date) as_of_date, spc.is_dst,MAX(spcd.granularity) granularity
	FROM ' + @source_process_table + ' d
	INNER JOIN source_price_curve_def spcd ON spcd.curve_id = d.[index]
	INNER JOIN source_price_curve spc ON  spc.source_curve_def_id = spcd.source_curve_def_id
	WHERE spc.curve_source_value_id = 4500
			AND spc.maturity_date BETWEEN ''' + @min_term + ''' AND ''' + @max_term + '''
	GROUP BY spc.source_curve_def_id, spc.maturity_date, spc.is_dst
	UNION
	SELECT spc.source_curve_def_id, spc.maturity_date, MAX(spc.as_of_date) as_of_date, spc.is_dst,MAX(spcd.granularity) granularity
	FROM #generic_mapping_values gmv
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = gmv.clm18_value
	INNER JOIN source_price_curve spc ON  spc.source_curve_def_id = spcd.source_curve_def_id
		AND spc.maturity_date BETWEEN ''' + @min_term + ''' AND ''' + @max_term + '''
	WHERE spc.curve_source_value_id = 4500
	GROUP BY spc.source_curve_def_id, spc.maturity_date, spc.is_dst
	'


EXEC(@sql)
--select top 2 * from #source_price_curve where term_start='2021-01-01' and hr=1

DECLARE @stg_withdrawal_template_id INT
--Hardcoded for withdrawal template as per requested.
SELECT @stg_withdrawal_template_id = template_id FROM source_deal_header_template WHERE template_name = 'Storage Withdrawal'

IF OBJECT_ID(N'tempdb..#pfc_view') IS NOT NULL
DROP TABLE #pfc_view

SET @sql = CAST('' AS NVARCHAR(MAX)) + N'
	SELECT  org.* 
		, IIF(gmv.clm17_value = ''d'',''Delta'',''Cummulative'') cumulative_delta
		, gmv.clm19_value
		, IIF(gmv.clm17_value = ''d'', src.uploaded_volume, src.uploaded_volume - org.original_volume) delta_volume
		, IIF(NULLIF(src.uploaded_fixed_price,'''') IS NOT NULL, NULL, spc.curve_value) pfc_price
		, IIF(NULLIF(src.uploaded_fixed_price,'''') IS NOT NULL, NULL,(IIF(gmv.clm17_value = ''d'', src.uploaded_volume, src.uploaded_volume - org.original_volume)*spc.curve_value)
			) delta_pfc_price
		, IIF(gmv.clm17_value = ''d'', src.uploaded_volume, src.uploaded_volume - org.original_volume) + org.original_volume total_volume
		, IIF(NULLIF(src.uploaded_fixed_price,'''') IS NOT NULL, src.uploaded_fixed_price,
			IIF( org.template_id = ' + CAST(@stg_withdrawal_template_id AS NVARCHAR(20)) + ', NULL --ISNULL(csw.wacog,0)
			,(org.original_volume*org.original_price 
				+ IIF(gmv.clm17_value = ''d'', src.uploaded_volume, src.uploaded_volume - org.original_volume) * spc.curve_value
				)/CASE WHEN IIF(gmv.clm17_value = ''d'', src.uploaded_volume, src.uploaded_volume - org.original_volume) 
					+ iif(nullIF(org.original_price,0) is null,0,org.original_volume) = 0 
				THEN 1 ELSE
					IIF(gmv.clm17_value = ''d'', src.uploaded_volume, src.uploaded_volume - org.original_volume) + iif(nullIF(org.original_price,0) is null,0,org.original_volume)
					END
				)
			)wap
		, CAST(LEFT(' + IIF(@gas_case = 1, 'org.process_hr_min', 'org.src_hr_min') + ',2) AS INT)  src_hr
		, CAST(RIGHT(' + IIF(@gas_case = 1, 'org.process_hr_min', 'org.src_hr_min') + ',2) AS INT)  src_period
		, IIF(NULLIF(src.uploaded_fixed_price,'''') IS NOT NULL, src.uploaded_fixed_price,(org.original_volume*org.original_price 
				+ IIF(gmv.clm17_value = ''d'', src.uploaded_volume, src.uploaded_volume - org.original_volume) * spc.curve_value
				)/CASE WHEN IIF(gmv.clm17_value = ''d'', src.uploaded_volume, src.uploaded_volume - org.original_volume) 
					+ iif(nullIF(org.original_price,0) is null,0,org.original_volume) = 0 
				THEN 1 ELSE
					IIF(gmv.clm17_value = ''d'', src.uploaded_volume, src.uploaded_volume - org.original_volume) + iif(nullIF(org.original_price,0) is null,0,org.original_volume)
					END
				) pfc_wap
	FROM #original_deal org 
	INNER JOIN #src_term_breakdown  src ON src.deal_id = org.deal_id
		AND org.term_start = src.[Term]
		AND org.hr = src.hr
		AND org.[period] =  src.[period]
		AND org.is_dst = src.is_dst '

IF @mapping_id = 112704	--Storage case check template and delivery path if defined in generic mapping.
BEGIN
	SET @sql += ' OUTER APPLY(SELECT DISTINCT gmv.clm1_value, gmv.clm17_value,gmv.clm18_value, gmv.clm19_value
			FROM #generic_mapping_values gmv
			LEFT JOIN source_deal_header sdh ON ISNULL(gmv.clm13_value,sdh.template_id) = sdh.template_id
				AND sdh.source_deal_header_id = ISNULL(org.structured_deal_id,org.source_deal_header_id)
			LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
			INNER JOIN static_data_value sdv ON sdv.type_id = 5500 
					AND uddft.field_id = sdv.value_id 
					AND sdv.code = ''Delivery Path''
			LEFT JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id 
				AND uddf.source_deal_header_id = sdh.source_deal_header_id
			WHERE 1=1 
				AND (gmv.clm13_value IS NULL OR gmv.clm13_value = ISNULL(sdh.template_id,-1))
				AND (gmv.clm20_value IS NULL OR gmv.clm20_value = ISNULL(uddf.udf_value,-1))		
		) gmv'
END
ELSE  IF @mapping_id = 112703	--Transportation capacity check location if defined in generic mapping.
BEGIN
	SET @sql += ' OUTER APPLY(SELECT DISTINCT gmv.clm1_value, gmv.clm17_value,gmv.clm18_value, gmv.clm19_value
			FROM #generic_mapping_values gmv
			WHERE 1=1 
				AND  gmv.clm11_value = ISNULL(org.location_id,-1)	
		) gmv'
END
ELSE  
BEGIN
	SET @sql += ' 
	OUTER APPLY(SELECT DISTINCT gmv.clm1_value, gmv.clm17_value,gmv.clm18_value, gmv.clm19_value
			FROM #generic_mapping_values gmv		
		) gmv'
END

SET @sql += 
	'
	LEFT JOIN #source_price_curve max_curve ON max_curve.source_curve_def_id = COALESCE(src.uploaded_curve_id,gmv.clm18_value,org.curve_id)
			AND CONVERT(date, max_curve.maturity_date) =  org.term_start 
			AND DATEPART(hour,max_curve.maturity_date) = IIF(max_curve.granularity=981,DATEPART(hour,max_curve.maturity_date),org.hr -1)
			AND DATEPART(minute,max_curve.maturity_date) = IIF(max_curve.granularity=982,DATEPART(minute,max_curve.maturity_date),org.[period])
			AND max_curve.is_dst = IIF(max_curve.granularity IN (995,994,987,989,982),org.is_dst,0)
	LEFT JOIN source_price_curve spc ON spc.as_of_date = max_curve.as_of_date
		AND spc.source_curve_def_id = max_curve.source_curve_def_id
		AND spc.maturity_date = max_curve.maturity_date
		AND spc.is_dst = max_curve.is_dst
		AND spc.curve_source_value_id = 4500
	--OUTER APPLY( SELECT MAX(csw.term) term ,csw.location_id,csw.contract_id
	--	FROM calcprocess_storage_wacog csw 
	--	WHERE csw.term < org.term_start
	--		AND csw.location_id = org.location_id
	--		AND csw.contract_id = org.contract_id
	--		GROUP BY csw.location_id, csw.contract_id
	--) mx_wacog
	--LEFT JOIN calcprocess_storage_wacog csw ON csw.term = mx_wacog.term
	--	AND csw.location_id = mx_wacog.location_id
	--	AND csw.contract_id = mx_wacog.contract_id
	
	'
IF @debug_mode = 1
select '#pfc_view',@sql

	CREATE TABLE #pfc_view(src_column NVARCHAR(20) COLLATE DATABASE_DEFAULT)
	
	EXEC spa_get_output_schema_or_data @sql_query = @sql
			, @process_table_name = '#pfc_view'
			, @data_output_col_count = @total_columns OUTPUT
			, @flag = 'data'
	--select @sql
--select '#pfc_view' ,count(1)  from #pfc_view-- where term_start = '2021-01-01'
--return
IF @debug_mode = 1
select 'detail data', * from #pfc_view

--select * from #temp_position where term_start='2021-01-01' and source_deal_header_id=6809
SELECT @aggregation_level = ISNULL(clm19_value,@aggregation_level) FROM #generic_mapping_values
	--set @aggregation_level=987
SET @sql = '
	IF OBJECT_ID(''' + @calc_process_table + ''') IS NOT NULL
	DROP TABLE ' + @calc_process_table + '

	SELECT MAX(pv.profile_name) profile,pv.source_deal_header_id
		, MAX(pv.deal_id) deal_id 
		, MIN(pv.src_term_start) term_start
		, MAX(pv.src_term_end) term_end
		, ' + CASE WHEN @aggregation_level = 980 THEN '0'
				ELSE 'AVG(pv.src_hr)'
			END + '  hr
		, ' + CASE WHEN @aggregation_level = 980 THEN '0'
				ELSE 'AVG(pv.src_period)'
			END + ' period
		, ' + CASE WHEN @aggregation_level = 980 THEN '0'
				ELSE 'pv.is_dst'
			END + ' is_dst
		, CASE WHEN MAX(pv.deal_volume_frequency) = ''m'' then SUM(pv.total_volume) ELSE AVG(pv.total_volume) END volume
		, AVG(pv.wap) price
		, MAX(pv.internal_desk_id) internal_desk_id
		, AVG(pv.pfc_wap) pfc_price
	INTO ' + @calc_process_table + '
	FROM #pfc_view pv	' +
	CASE WHEN @aggregation_level = 980 --monthly
			THEN ' GROUP BY year(pv.term_start),month(pv.term_start),pv.source_deal_header_id
					ORDER BY source_deal_header_id, term_start'
			ELSE ' GROUP BY pv.term_start,pv.source_deal_header_id,pv.src_hr,pv.src_period,pv.is_dst
					ORDER BY source_deal_header_id, term_start,src_hr,src_period'
			END
--select @sql
	EXEC(@sql)
	--print @calc_process_table
	
	--Final result set
	IF @debug_mode = 1
	EXEC('select ''final data'', * from ' + @calc_process_table + ' order by deal_id,term_start,term_end,hr,period,is_dst' )
END


