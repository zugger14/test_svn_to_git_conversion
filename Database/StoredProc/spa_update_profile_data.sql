IF OBJECT_ID(N'[dbo].[spa_update_profile_data]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_update_profile_data]
GO

/**
	TBD
	Parameters
	@flag : Operation flag mandatory
			'x' - TBD
			'b' - TBD
			'z' - TBD
			't' - TBD
			'u' - TBD
			'r' - TBD
			'a' - TBD
			'p' - TBD
	@profile_id : Unique Profile Id
	@term_start : Term Start Filter
	@term_end : Term End Filter
	@hour_from : Hour From Filter
	@hour_to :  Hour To Filter
	@process_id : Unique Process Id
	@xml : XML Data
	@source_deal_detail_id :Unique Id for Source Deal Header.
	@location_id : Unique Id form Location.
	@filter_value : Filter data.
*/ 
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[spa_update_profile_data]
		@flag CHAR(1),
		@profile_id INT = NULL,
		@term_start DATETIME = NULL,
		@term_end DATETIME = NULL,
		@hour_from INT = NULL,
		@hour_to INT = NULL,
		@process_id VARCHAR(200) = NULL,    
		@xml XML = NULL,
		@source_deal_detail_id INT = NULL,
		@location_id INT = NULL,
		@filter_value VARCHAR(1000) = NULL
    
AS
SET NOCOUNT ON
/*------------Debug Section------------
DECLARE @flag CHAR(1),
				@profile_id INT = NULL,
				@term_start DATETIME = NULL,
				@term_end DATETIME = NULL,
				@hour_from INT = NULL,
				@hour_to INT = NULL,
				@process_id VARCHAR(200) = NULL,    
				@xml XML = NULL,
				@source_deal_detail_id INT = NULL

SELECT @flag='u',@xml='<GridXML><GridRow  col_profile_name="Basic" col_profile_id="75" col_20180801="250" col_20180802="250" col_20180803="" col_20180804="" col_20180805="" col_20180806="" col_20180807="" col_20180808="" col_20180809="" col_20180810="" col_20180811="" col_20180812="" col_20180813="" col_20180814="" col_20180815="" col_20180816="" col_20180817="" col_20180818="" col_20180819="" col_20180820="" col_20180821="" col_20180822="" col_20180823="" col_20180824="" col_20180825="" col_20180826="" col_20180827="" col_20180828="" col_20180829="" col_20180830="" col_20180831=""></GridRow></GridXML>',@process_id='07BC8B1C_6F29_4FAE_A4BE_9ED325B9269E',@source_deal_detail_id=209527
----------------------------------------*/

SET @source_deal_detail_id = IIF(@source_deal_detail_id LIKE '%NEW%', NULL, @source_deal_detail_id)

DECLARE @sql VARCHAR(MAX),		
		@dst_group_value_id INT

SELECT @dst_group_value_id = tz.dst_group_value_id
	FROM dbo.adiha_default_codes_values adcv
		INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
	WHERE adcv.instance_no = 1
		AND adcv.default_code_id = 36
		AND adcv.seq_no = 1
 
IF @flag = 'x'
BEGIN
    SET @sql = '
		SELECT fp.profile_id, fp.profile_name
		FROM forecast_profile fp
	'
	IF NULLIF(@filter_value, '<FILTER_VALUE>') IS NOT NULL
	BEGIN
		SET @sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s
							ON s.item = fp.profile_id'
	END

	SET @sql += ' ORDER by fp.profile_name '
	EXEC(@sql)
    RETURN
END

-- Returns profile_name and profile_id
IF @flag = 'b'
BEGIN
	IF @profile_id IS NOT NULL
	BEGIN
		SELECT profile_id, profile_name FROM forecast_profile WHERE profile_id = @profile_id
	END
	ELSE IF @location_id IS NOT NULL
	BEGIN
		SELECT profile_id, profile_name FROM (
		select fp.profile_id, fp.profile_name from source_minor_location sml
		inner join forecast_profile fp on fp.profile_id = sml.profile_id
		left join forecast_profile fp1 on fp1.profile_id = sml.proxy_profile_id
		where sml.source_minor_location_id = @location_id
		union
		select fp1.profile_id, fp1.profile_name from source_minor_location sml
		inner join forecast_profile fp on fp.profile_id = sml.profile_id
		left join forecast_profile fp1 on fp1.profile_id = sml.proxy_profile_id
		where sml.source_minor_location_id = @location_id
		) a
		WHERE profile_id is not null
	END	
    RETURN
END

IF @flag = 'z'
BEGIN
	SELECT CASE WHEN fp.granularity IN (994,987,989,995,982) OR fp.granularity IS NULL THEN 'y' ELSE 'n' END show_hours,granularity
	FROM forecast_profile fp 
	WHERE fp.profile_id = @profile_id
		
	RETURN
END

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID() 

DECLARE @user_name VARCHAR(100) = dbo.FNADBUser() 
DECLARE @process_table VARCHAR(400) = dbo.FNAProcessTableName('profile_data', @user_name, @process_id)
DECLARE @table_name VARCHAR(400)
DECLARE @dst_insert VARCHAR(MAX)

IF @flag = 'u'
BEGIN
	IF OBJECT_ID('tempdb..#temp_process_profile_data') IS NOT NULL
		DROP TABLE #temp_process_profile_data
	
	CREATE TABLE #temp_process_profile_data (
		profile_id INT, term_start DATETIME, term_end DATETIME
	)
	
	SET @sql = 'INSERT INTO #temp_process_profile_data (profile_id, term_start, term_end)
				SELECT profile_id,
				       MIN(term_date),
				       MAX(term_date)
				FROM   ' + @process_table + '
				GROUP BY profile_id'
	EXEC(@sql)
	
	SELECT TOP(1) 
		   @profile_id = profile_id,
	       @term_start     = term_start,
	       @term_end       = term_end
	FROM #temp_process_profile_data
		
	IF @term_start IS NULL
	BEGIN
		IF OBJECT_ID('tempdb..#temp_process_table_columns') IS NOT NULL
			DROP TABLE #temp_process_table_columns
		
		CREATE TABLE #temp_process_table_columns(column_name VARCHAR(100) COLLATE DATABASE_DEFAULT , date_equiv DATETIME)
		
		SET @table_name = REPLACE(@process_table, 'adiha_process.dbo.', '')
		
		INSERT INTO #temp_process_table_columns(column_name)
		SELECT COLUMN_NAME
 		FROM adiha_process.INFORMATION_SCHEMA.COLUMNS WITH(NOLOCK)
 		WHERE TABLE_NAME = @table_name
 		
 		UPDATE #temp_process_table_columns
 		SET date_equiv = CONVERT(DATETIME, column_name, 120)
 		WHERE ISDATE(column_name) = 1
 		
 		SELECT @term_start = MIN(date_equiv),
 				@term_end = MAX(date_equiv)
 		FROM #temp_process_table_columns
 		WHERE date_equiv IS NOT NULL
	END
END

DECLARE @granularity INT
SELECT @granularity = ISNULL(fp.granularity, 982)
FROM forecast_profile fp WHERE fp.profile_id = @profile_id

DECLARE @desc VARCHAR(500),
 		@err_no INT,
 		@frequency CHAR(1),
 		@column_list VARCHAR(MAX),
 		@column_label VARCHAR(MAX),
 		@column_type VARCHAR(MAX),
		@data_type VARCHAR(MAX),
 		@column_width VARCHAR(MAX),
 		@column_visibility VARCHAR(MAX),
 		@pivot_columns VARCHAR(MAX), 
 		@pivot_columns_create VARCHAR(MAX), 
 		@pivot_columns_update VARCHAR(MAX),
 		@select_list VARCHAR(MAX),
 		--@dst_present INT,
 		@pivot_select VARCHAR(MAX)

SET @frequency = CASE 
                      WHEN @granularity IN (981, 982, 989, 987, 994, 995) THEN 'd'
                      WHEN @granularity = 980 THEN 'm'
                      WHEN @granularity = 991 THEN 'q'
                      WHEN @granularity = 992 THEN 's'
                      WHEN @granularity = 990 THEN 'w'
                 END

IF OBJECT_ID('tempdb..#temp_profile_data_terms') IS NOT NULL
	DROP TABLE #temp_profile_data_terms
 
CREATE TABLE #temp_profile_data_terms (term_start DATETIME, is_dst INT)
 
;WITH cte_profile_terms AS (
	SELECT @term_start [term_start]
	UNION ALL
	SELECT dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1)
	FROM cte_profile_terms cte 
	WHERE dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1) <= @term_end
) 
INSERT INTO #temp_profile_data_terms(term_start)
SELECT term_start
FROM cte_profile_terms cte
OPTION (maxrecursion 0)

DECLARE @baseload_block_type VARCHAR(10),
        @baseload_block_define_id VARCHAR(10)
 		
SET @baseload_block_type = '12000'	-- Internal Static Data
 
SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10))
FROM static_data_value
WHERE[type_id] = 10018
AND code LIKE 'Base Load' -- External Static Data

	-- get all  dst date
	IF OBJECT_ID('tempdb..#temp_dst_date') IS NOT NULL
		DROP TABLE #temp_dst_date

	CREATE TABLE #temp_dst_date (dst_date DATE, insert_delete CHAR(1) COLLATE DATABASE_DEFAULT, dst_hour INT)

	INSERT INTO #temp_dst_date select temp.term_start, mv.insert_delete, mv.hour from #temp_profile_data_terms temp INNER JOIN mv90_DST mv 
	ON temp.term_start = mv.[date]
	AND mv.dst_group_value_id = @dst_group_value_id


 
 DECLARE @filter_hour_from INT, @filter_hour_to INT
 
 -- create process table with all hours but filter the hours while showing it on screen
 IF @flag = 't'
 BEGIN
 	SET @filter_hour_from = ISNULL(@hour_from, 0)
 	SET @filter_hour_to = ISNULL(@hour_to, 25)
 	SET @hour_from = NULL
 	SET @hour_to = NULL
 END 
 
  IF @granularity IN (980, 981, 982, 989, 987, 994, 995)
BEGIN
	IF OBJECT_ID('tempdb..#temp_hour_breakdown') IS NOT NULL
		DROP TABLE #temp_hour_breakdown

	SELECT clm_name, is_dst, alias_name, CAST(CASE WHEN is_dst = 0 THEN RIGHT('0' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '_' + RIGHT(clm_name, 2) ELSE '25' + '_' + RIGHT(clm_name, 2) END AS VARCHAR(100)) [process_clm_name]
	INTO #temp_hour_breakdown 
	FROM dbo.FNAGetPivotGranularityColumn(@term_start,@term_end,@granularity,@dst_group_value_id) 
	WHERE CAST (LEFT(alias_name,2) AS INT)> = ISNULL(@hour_from, 0) AND  CAST (LEFT(alias_name,2) AS INT)<=ISNULL(@hour_to, 25)
END

IF OBJECT_ID('tempdb..#temp_min_break') IS NOT NULL
	DROP TABLE #temp_min_break
 
CREATE TABLE #temp_min_break(granularity int, period tinyint, factor numeric(6,2))
 
IF @granularity IN (989, 994, 995, 987)
BEGIN
	INSERT INTO #temp_min_break (granularity, period, factor)
	VALUES (989,0,2), (989,30,2), -- 30Min
 			(987,0,4),(987,15,4),(987,30,4),(987,45,4), -- 15Min
 			(994,0,6), (994,10,6), (994,20,6), (994,30,6), (994,40,6), (994,50,6), --10Min
 			(995,0,12), (995,5,12), (995,10,12), (995,15,12), (995,20,12), (995,25,12), (995,30,12), (995,35,12), (995,40,12), (995,45,12), (995,50,12), (995,55,12) --5Min
END
	
IF @flag = 't'
BEGIN
	IF OBJECT_ID('tempdb..#temp_profile_data_dump') IS NOT NULL 
 		DROP TABLE #temp_profile_data_dump
 	
	CREATE TABLE #temp_profile_data_dump(
		id               INT IDENTITY(1, 1),
		profile_id       INT,
		profile_name     VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		period           INT,
		[term_date]      DATETIME
	)
		
	IF @granularity IN (982, 989, 994, 995, 987)
	BEGIN
 		ALTER TABLE #temp_profile_data_dump
 		ADD	
 			Hr1 FLOAT, Hr2 FLOAT, Hr3 FLOAT, Hr4 FLOAT, Hr5 FLOAT, Hr6 FLOAT, Hr7 FLOAT, Hr8 FLOAT, Hr9 FLOAT, Hr10 FLOAT,
 			Hr11 FLOAT, Hr12 FLOAT, Hr13 FLOAT, Hr14 FLOAT, Hr15 FLOAT, Hr16 FLOAT, Hr17 FLOAT, Hr18 FLOAT, Hr19 FLOAT, Hr20 FLOAT,
 			Hr21 FLOAT, Hr22 FLOAT, Hr23 FLOAT, Hr24 FLOAT, Hr25 FLOAT
	END
	ELSE
	BEGIN
 		ALTER TABLE #temp_profile_data_dump ADD volume FLOAT
	END
	
	INSERT INTO #temp_profile_data_dump (
 		profile_id, profile_name, term_date, period
	)
	SELECT fp.profile_id, fp.profile_name, t2.term_start, t3.period
	FROM forecast_profile fp
	OUTER APPLY (SELECT * FROM #temp_profile_data_terms) t2
	LEFT JOIN #temp_min_break t3 ON t3.granularity = @granularity
	WHERE fp.profile_id = @profile_id
	
	IF @granularity IN (982, 989, 994, 995, 987)
	BEGIN
 		UPDATE t1
 		SET Hr1 = ddh.Hr1,
 			Hr2 = ddh.Hr2,
 			Hr3 = ddh.Hr3,
 			Hr4 = ddh.Hr4,
 			Hr5 = ddh.Hr5,
 			Hr6 = ddh.Hr6,
 			Hr7 = ddh.Hr7,
 			Hr8 = ddh.Hr8,
 			Hr9 = ddh.Hr9,
 			Hr10 = ddh.Hr10,
 			Hr11 = ddh.Hr11,
 			Hr12 = ddh.Hr12,
 			Hr13 = ddh.Hr13,
 			Hr14 = ddh.Hr14,
 			Hr15 = ddh.Hr15,
 			Hr16 = ddh.Hr16,
 			Hr17 = ddh.Hr17,
 			Hr18 = ddh.Hr18,
 			Hr19 = ddh.Hr19,
 			Hr20 = ddh.Hr20,
 			Hr21 = ddh.Hr21,
 			Hr22 = ddh.Hr22,
 			Hr23 = ddh.Hr23,
 			Hr24 = ddh.Hr24,
 			Hr25 = ddh.Hr25
 		FROM #temp_profile_data_dump t1
 		INNER JOIN deal_detail_hour ddh
 			ON ddh.profile_id = t1.profile_id
 			AND ddh.term_date = t1.term_date
 			AND ISNULL(ddh.period, 0) = ISNULL(t1.period, 0)
	END
	ELSE
	BEGIN
 		UPDATE t1
 		SET volume = ddh.Hr1
 		FROM #temp_profile_data_dump t1
 		INNER JOIN deal_detail_hour ddh 
 			ON ddh.profile_id = t1.profile_id
 			AND ddh.term_date = t1.term_date
 			AND ISNULL(ddh.period, 0) = ISNULL(t1.period, 0)
	END
	
	CREATE NONCLUSTERED INDEX NCI_TMDD_PROFILE_ID ON #temp_profile_data_dump (profile_id)
	CREATE NONCLUSTERED INDEX NCI_TMDD_PROD ON #temp_profile_data_dump (term_date)
	
	IF @granularity IN (982, 989, 987, 994, 995)
	BEGIN
		SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + process_clm_name + ']',
 				@pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + process_clm_name + '] FLOAT NULL',
 				@pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + process_clm_name + '] = a.[' + process_clm_name + ']',
 				@pivot_select = COALESCE(@pivot_select + ',', '') + 'Hr' + CAST(CAST(LEFT(process_clm_name,2) AS INT) AS VARCHAR) +' AS [' + process_clm_name + ']'
 		FROM #temp_hour_breakdown 

 		-- for hourly
 		SET @pivot_select = 'profile_id, profile_name, term_date, '+ @pivot_select
 		
 		SELECT granularity, period, 'a_' + CAST(period AS VARCHAR(10)) [alias]
 		INTO #temp_min_break2
 		FROM #temp_min_break		
 		WHERE granularity = @granularity
 		
 		DECLARE @sql_string VARCHAR(MAX)
 		SELECT @sql_string = COALESCE(@sql_string + CHAR(13)+CHAR(10), '') + ' INNER JOIN ( SELECT Hr1 AS [01_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr2 AS [02_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr3 AS [03_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr4 AS [04_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr5 AS [05_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr6 AS [06_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr7 AS [07_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr8 AS [08_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr9 AS [09_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr10 AS [10_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr11 AS [11_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr12 AS [12_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr13 AS [13_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr14 AS [14_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr15 AS [15_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr16 AS [16_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr17 AS [17_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr18 AS [18_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr19 AS [19_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr20 AS [20_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr21 AS [21_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr22 AS [22_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr23 AS [23_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr24 AS [24_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr25 AS [25_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '], profile_id, profile_name, term_date FROM #temp_profile_data_dump temp
 							WHERE period = ' + CAST(period AS VARCHAR(10)) + ' ) ' + tm.alias + ' ON ' + tm.alias + '.profile_id = a.profile_id AND ' + tm.alias + '.term_date = a.term_date'
 		FROM #temp_min_break2 tm 
 		
 		SET @sql = '
 			CREATE TABLE ' + @process_table + '(
 				id               INT IDENTITY(1, 1),
 				profile_id       INT,
 				profile_name     VARCHAR(200),
 				term_date        DATETIME,
 				' + @pivot_columns_create + '
 			)
 			
 			INSERT INTO ' + @process_table + ' (
 				profile_id,
 				profile_name,
 				term_date,
 				' + @pivot_columns + '
 			)			
 			'
 		
 		IF @sql_string IS NULL -- hourly
 		BEGIN
 			SET @sql += '
 				SELECT ' + @pivot_select + '
 				FROM #temp_profile_data_dump		
 			'
 		END
 		ELSE
 		BEGIN
 			SET @sql += '
 						SELECT  a.profile_id,
 								a.profile_name,
 								a.term_date,
 								' + @pivot_columns + '
 						FROM (
 							SELECT profile_id, profile_name, term_date
 							FROM #temp_profile_data_dump
 							GROUP BY profile_id, profile_name, term_date
 						) a	'
 						+ ISNULL(@sql_string, '') + '
 			
 				'
 		END
 		
 		SELECT @column_list = COALESCE(@column_list + ',', '') + process_clm_name,
 				@column_label = COALESCE(@column_label + ',', '') + alias_name,
 				@column_type = COALESCE(@column_type + ',', '') + 'ed_no',
				@data_type = COALESCE(@data_type + ',', '') + 'float',
 				@column_width = COALESCE(@column_width + ',', '') + '100',
 				@column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
 		FROM #temp_hour_breakdown 
 		WHERE CAST (LEFT(alias_name,2) AS INT)> = ISNULL(@filter_hour_from, 0) AND  CAST (LEFT(alias_name,2) AS INT)<=ISNULL(@filter_hour_to, 25)
 
 		SET @column_list = 'profile_name,profile_id,term_date,' + @column_list
 		SET @column_label = 'profile,ID,Date,' + @column_label
 		SET @column_type = 'ro,ro,ro_dhxCalendarA,' + @column_type
		SET @data_type = ',,,' + @data_type
 		SET @column_width = '150,10,100,' + @column_width
 		SET @column_visibility = 'false,true,false,' + @column_visibility
	END
	ELSE
	BEGIN
 		SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + ']',
 				@pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] FLOAT NULL',
 				@pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] = a.[' + CONVERT(VARCHAR(8), term_start, 112) + ']'
 		FROM #temp_profile_data_terms
 		ORDER BY term_start	
 				
 		SET @sql = '
 			CREATE TABLE ' + @process_table + '(
 				id                        INT IDENTITY(1, 1),
 				profile_id                  INT,
 				profile_name                     VARCHAR(200),
 				term_date                 DATETIME,
 				' + @pivot_columns_create + '
 			)
 			
 			INSERT INTO ' + @process_table + ' (
 				profile_id,
 				profile_name,
 				term_date,
 				' + @pivot_columns + '
 			)			
 			SELECT profile_id, profile_name, term_date, ' + @pivot_columns + '
 			FROM (
 				SELECT temp.profile_id, temp.profile_name, temp.term_date, CONVERT(VARCHAR(8), temp.term_date, 112) term_date_p, volume
 				FROM #temp_profile_data_dump temp 
 			) a			
 			PIVOT (SUM(volume) FOR term_date_p IN (' + @pivot_columns + ') )unpvt
 		'
 		
 		SELECT @column_list = COALESCE(@column_list + ',', '') + CONVERT(VARCHAR(8), term_start, 112),
 				@column_label = COALESCE(@column_label + ',', '') + dbo.FNADateFormat(term_start),
 				@column_type = COALESCE(@column_type + ',', '') + 'ed_no',
				@data_type = COALESCE(@data_type + ',', '') + 'float',
 				@column_width = COALESCE(@column_width + ',', '') + '150',
 				@column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
 		FROM #temp_profile_data_terms		
 		WHERE term_start <= @term_end
 
 		SET @column_list = 'profile_name,profile_id,' + @column_list
 		SET @column_label = 'profile,ID,' + @column_label
 		SET @column_type = 'ro,ro,' + @column_type
		SET @data_type = ',,' + @data_type
 		SET @column_width = '150,10,' + @column_width
 		SET @column_visibility = 'false,true,' + @column_visibility
	END
	
	EXEC(@sql)	
	
	SELECT @column_list [column_list],
	       @column_label [column_label],
	       @column_type [column_type],
	       @column_width [column_width],
	       @term_start [term_start],
	       @term_end [term_end],
	       @granularity [granularity],
	       @column_visibility [visibility],
	       @process_id [process_id],
		   @data_type [data_type]
	RETURN
END

-- currently not used
IF @flag = 'r'
BEGIN
	IF @granularity IN (982, 989, 987, 994, 995)
	BEGIN		
 		SELECT @column_list = COALESCE(@column_list + ',', '') + process_clm_name,
 				@column_label = COALESCE(@column_label + ',', '') + alias_name,
 				@column_type = COALESCE(@column_type + ',', '') + 'ed_no',
 				@column_width = COALESCE(@column_width + ',', '') + '100',
 				@column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
 		FROM #temp_hour_breakdown
 
 		SET @column_list = 'profile_name,profile_id,term_date,' + @column_list
 		SET @column_label = 'profile,ID,Date,' + @column_label
 		SET @column_type = 'ro,ro,ro_dhxCalendarA,' + @column_type
 		SET @column_width = '150,10,100,' + @column_width
 		SET @column_visibility = 'false,true,false,' + @column_visibility
	END
	ELSE
	BEGIN
 		SELECT @column_list = COALESCE(@column_list + ',', '') + CONVERT(VARCHAR(8), term_start, 112),
 				@column_label = COALESCE(@column_label + ',', '') + dbo.FNADateFormat(term_start),
 				@column_type = COALESCE(@column_type + ',', '') + 'ed_no',
 				@column_width = COALESCE(@column_width + ',', '') + '150',
 				@column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
 		FROM #temp_profile_data_terms		
 		WHERE term_start <= @term_end
 
 		SET @column_list = 'profile_name,profile_id,' + @column_list
 		SET @column_label = 'profile,ID,' + @column_label
 		SET @column_type = 'ro,ro,' + @column_type
 		SET @column_width = '150,10,' + @column_width
 		SET @column_visibility = 'false,true,' + @column_visibility
	END
	 
	SELECT @column_list [column_list],
	       @column_label [column_label],
	       @column_type [column_type],
	       @column_width [column_width],
	       @term_start [term_start],
	       @term_end [term_end],
	       @granularity [granularity],
	       @column_visibility [visibility],
	       @process_id [process_id]
	RETURN
END

IF @flag = 'a'
BEGIN
	IF @granularity IN (982, 989, 987, 994, 995)
	BEGIN
		--DECLARE @dst_hour VARCHAR(10),@dst_hour1 VARCHAR(10)
		--SELECT	DISTINCT @dst_hour =  RIGHT('0'+CAST(CAST(MD.HOUR AS INT) AS VARCHAR),2) + '_00'
 	--	FROM mv90_DST md 
		--WHERE md.insert_delete = 'i'
		--AND md.dst_group_value_id = @dst_group_value_id

		--SELECT DISTINCT @dst_hour1 = tmp.process_clm_name
		--FROM #temp_hour_breakdown tmp
		--WHERE is_dst = 1

		update t set t.process_clm_name =  'ISNULL([' + nd.process_clm_name + '],0)' + '-' + 'ISNULL(['+ d.process_clm_name + '],0)'
		from #temp_hour_breakdown t
		inner join 
		(
		select * from 
		#temp_hour_breakdown
		where is_dst = 0) nd
		on t.clm_name = nd.clm_name
		INNER JOIN 
		(
		select * from 
		#temp_hour_breakdown
		where is_dst = 1) d

		on nd.clm_name = d.clm_name
		where t.is_dst = 0
				
 		SELECT @column_list = COALESCE(@column_list + ',', '') + CASE WHEN LEN(process_clm_name)>5 THEN 'NULLIF(ABS(' + process_clm_name + '),0)' ELSE '[' + process_clm_name + ']' 
		END  + CASE WHEN LEN(process_clm_name)> 7 THEN LEFT(REPLACE(process_clm_name,'ISNULL(',''), 7) ELSE  '[' + process_clm_name + ']'  END     
 		FROM  #temp_hour_breakdown
		SET @column_list = 'profile_name,profile_id,term_date,' + @column_list
	END
	ELSE
	BEGIN
 		SELECT @column_list = COALESCE(@column_list + ',', '') + 'max([' + CONVERT(VARCHAR(8), term_start, 112) + ']) [' + CONVERT(VARCHAR(8), term_start, 112) + ']'
 		FROM #temp_profile_data_terms
 		WHERE term_start <= @term_end
 		SET @column_list = 'max(profile_name) profile_name, max(profile_id) profile_id,' + @column_list
	END
 
	SET @sql = 'SELECT ' + @column_list + ' FROM ' + @process_table + ' a '
	SET @sql += ' WHERE 1 = 1'
	
	SET @sql += ' AND a.profile_id = ' + CAST(@profile_id AS VARCHAR(20))
	
	IF @granularity IN (982, 989, 987, 994, 995)
		SET @sql += ' AND a.term_date >= ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''' AND a.term_date <= ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''''
	
	IF @granularity IN (982, 989, 987, 994, 995)
		SET @sql += ' ORDER BY a.term_date'
	
	--PRINT(@sql)
	EXEC(@sql)
	RETURN
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		
 		IF @xml IS NOT NULL
		BEGIN
			DECLARE @xml_process_table VARCHAR(200)
			SET @xml_process_table = dbo.FNAProcessTableName('xml_table', @user_name, dbo.FNAGetNewID())
		
			EXEC spa_parse_xml_file 'b', NULL, @xml, @xml_process_table
			DECLARE @dst_hr VARCHAR(10)
			select top 1 @dst_hr=CAST(CAST(LEFT(clm_name,2) AS INT) +1  as varchar) from #temp_hour_breakdown where is_dst = 1
		
			IF OBJECT_ID('tempdb..#temp_xml_table_columns') IS NOT NULL
				DROP TABLE #temp_xml_table_columns
		
			CREATE TABLE #temp_xml_table_columns(column_name VARCHAR(100) COLLATE DATABASE_DEFAULT )
		
			SET @table_name = REPLACE(@xml_process_table, 'adiha_process.dbo.', '')
		
			INSERT INTO #temp_xml_table_columns(column_name)
			SELECT COLUMN_NAME
 			FROM adiha_process.INFORMATION_SCHEMA.COLUMNS WITH (NOLOCK)
 			WHERE TABLE_NAME = @table_name
						
				
 			IF OBJECT_ID('tempdb..#temp_changed_profile_data') IS NOT NULL
 				DROP TABLE #temp_changed_profile_data
 
 			CREATE TABLE #temp_changed_profile_data(
 				profile_id                  INT,
 				term_date                 DATETIME,
 				hr                        VARCHAR(20) COLLATE DATABASE_DEFAULT ,
 				is_dst                    INT,
 				volume                    FLOAT
 			)
 			
 			DECLARE @select_statement VARCHAR(MAX)
 			DECLARE @select_statement2 VARCHAR(MAX)
 			DECLARE @for_statement VARCHAR(MAX)
		 		
 			IF @granularity IN (982, 989, 987, 994, 995)
 			BEGIN		
 				IF OBJECT_ID('tempdb..#temp_cols_lists') IS NOT NULL
 					DROP TABLE #temp_cols_lists
 				
 				SELECT process_clm_name [column_name],
 					   'col_' + process_clm_name [select_columns]
 				INTO  #temp_cols_lists FROM
				#temp_hour_breakdown
 				
 				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + t1.[column_name] + ']',
 						@select_list = COALESCE(@select_list + ',', '') + 'ISNULL(CAST([' + t1.[select_columns] + '] AS FLOAT), 0) [' + t1.[column_name] + ']'
 				FROM #temp_cols_lists t1
 				INNER JOIN #temp_xml_table_columns t2 ON t2.column_name = t1.select_columns
 			
 				SET @select_statement = 'SELECT col_profile_id, col_term_date, NULLIF(volume, ''0'') [volume], REPLACE(hrs, ''_'', '':'') hr, 0'
 				SET @select_statement2 = 'SELECT col_profile_id, col_term_date, ' + @select_list
 				SET @for_statement = 'hrs'
 				
 				DECLARE @hidden_columns_list VARCHAR(MAX)
 				DECLARE @hidden_select_list VARCHAR(MAX)
 				DECLARE @hidden_select_statement2 VARCHAR(MAX) 
 				
 				SELECT @hidden_columns_list = COALESCE(@hidden_columns_list + ',', '') + '[' + t1.[column_name] + ']',
 					   @hidden_select_list = COALESCE(@hidden_select_list + ',', '') + 'ISNULL([' + t1.[column_name] + '], 0) [' + t1.[column_name] + ']'
 				FROM #temp_cols_lists t1
 				LEFT JOIN #temp_xml_table_columns t2 ON t2.column_name = t1.select_columns
 				WHERE t2.column_name IS NULL
				
			
 				IF NULLIF(@hidden_select_list, '') IS NOT NULL
 				BEGIN

 					SET @hidden_select_statement2 = 'SELECT profile_id, term_date, ' + @hidden_select_list
 					SET @for_statement = 'hrs'
 				
 					SET @sql = '
 						INSERT INTO #temp_changed_profile_data(profile_id, term_date, volume, [hr], is_dst)
 						SELECT profile_id, term_date, NULLIF(volume, 0) [volume], REPLACE(hrs, ''_'', '':'') hr, 0
 						FROM ( ' + 
 							@hidden_select_statement2 + ' 
 							FROM (SELECT MIN(col_term_date) term_start, MAX(col_term_date) term_end FROM ' + @xml_process_table + ') term
 							OUTER APPLY (
 								SELECT * FROM ' + @process_table + ' 
 								WHERE term_date >= term.term_start AND term_date <= term.term_end
 							) t1						
 						) tmp
 						UNPIVOT (
 							volume
 							FOR ' + @for_statement + '
 							IN (
 								' + @hidden_columns_list + '
 							) 
 						) unpvt
 					'
 					--PRINT(@sql)
 					EXEC(@sql)

				

 				END
 			END
 			ELSE
 			BEGIN
 				SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + ']',
 						@select_list = COALESCE(@select_list + ',', '') + 'ISNULL(NULLIF(CAST([col_' + CONVERT(VARCHAR(8), term_start, 112) + '] AS FLOAT), ''''), 0) [' + CONVERT(VARCHAR(8), term_start, 112) + ']'
 				FROM #temp_profile_data_terms tat
 
 				SET @select_statement = 'SELECT col_profile_id, CONVERT(DATETIME, term_date2, 120) term_date, NULLIF(volume, 0) [volume], NULL hr, 0'
 				SET @select_statement2 = 'SELECT col_profile_id, ' + @select_list
 				SET @for_statement = 'term_date2'
 			END
			SET @sql = '
 					INSERT INTO #temp_changed_profile_data(profile_id, term_date, volume, [hr], is_dst)
 					' + @select_statement + '
 					FROM ( ' + 
 						@select_statement2 + ' 
 						FROM ' + @xml_process_table + '
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
 			
 			IF OBJECT_ID('tempdb..#temp_profile_data_hour') IS NOT NULL
 				DROP TABLE #temp_profile_data_hour
 				
 			CREATE TABLE #temp_profile_data_hour (
 				profile_id INT,
 				term_date DATETIME, period INT,
 				Hr1 FLOAT, Hr2 FLOAT, Hr3 FLOAT, Hr4 FLOAT, Hr5 FLOAT, Hr6 FLOAT, Hr7 FLOAT, Hr8 FLOAT, Hr9 FLOAT, Hr10 FLOAT,
 				Hr11 FLOAT, Hr12 FLOAT, Hr13 FLOAT, Hr14 FLOAT, Hr15 FLOAT, Hr16 FLOAT, Hr17 FLOAT, Hr18 FLOAT, Hr19 FLOAT, Hr20 FLOAT,
 				Hr21 FLOAT, Hr22 FLOAT, Hr23 FLOAT, Hr24 FLOAT, Hr25 FLOAT		
 			)
 			
 			IF @granularity IN (982, 989, 987, 994, 995)
 			BEGIN 			
 				INSERT INTO #temp_profile_data_hour(
 					profile_id, term_date, period,
 					Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25
 				)	
 				SELECT profile_id, term_date, period, [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25]
				FROM
				(
					SELECT t1.profile_id, t1.term_date, t1.volume, CAST(LEFT(t1.hr, 2) AS INT) [hour], t2.period
 					FROM #temp_changed_profile_data t1
 					LEFT JOIN #temp_min_break t2 
 						ON granularity = @granularity
 						AND CAST(RIGHT(t1.hr, 2) AS INT) = t2.period
					--WHERE t1.volume IS NOT NULL
				) p
				PIVOT(
				SUM(volume)
				FOR [hour]
				IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25])
				) AS pvt; 	
			
				--to delete data inserted on dst hour field for non dst date 
				UPDATE #temp_profile_data_hour SET Hr25 = NULL WHERE term_date NOT IN (SELECT dst_date FROM #temp_dst_date WHERE insert_delete = 'i')
	
				IF @dst_hr IS NOT NULL
					EXEC('update  #temp_profile_data_hour set Hr' +@dst_hr+ '= ISNULL(Hr'+@dst_hr + ',0)+' +'ISNULL(Hr25,0)')
		
				
				
				
				
				 DECLARE @update_column VARCHAR(30 )
				 SELECT @update_column = COALESCE(@update_column + ',', '') + 'Hr'+CAST(tdd.dst_hour AS VARCHAR(20)) + '= NULL' FROM #temp_dst_date tdd WHERE 
				 tdd.insert_delete = 'd'

				 IF(@update_column IS NOT NULL)
				 EXEC('
					update tmdh 
					set ' + @update_column + ' 
					from #temp_profile_data_hour tmdh 
					inner join #temp_dst_date tdd 
						on tmdh.term_date = tdd.dst_date
					where tdd.insert_delete = ''d''
				')

 					
 			END
 			ELSE
 			BEGIN
 				INSERT INTO #temp_profile_data_hour(
 					profile_id, term_date, period, Hr1
 				)	
 				SELECT t1.profile_id, t1.term_date, NULL, t1.volume
 				FROM #temp_changed_profile_data t1
 				--WHERE t1.volume IS NOT NULL
 			END
			--SELECT * FROM #temp_profile_data_hour		
 			IF OBJECT_ID('tempdb..#temp_inserted_updated_deal_profile') IS NOT NULL
 				DROP TABLE #temp_inserted_updated_deal_profile
 			CREATE TABLE #temp_inserted_updated_deal_profile(profile_id INT)
		
 			IF EXISTS(SELECT 1 FROM #temp_profile_data_hour)
 			BEGIN
 				UPDATE ddh
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
 				FROM deal_detail_hour ddh
 				INNER JOIN #temp_profile_data_hour t1 
 					ON t1.profile_id = ddh.profile_id
 					AND t1.term_date = ddh.term_date
 					AND ISNULL(t1.period, 0) = ISNULL(ddh.period, 0)
 				
 				INSERT INTO deal_detail_hour (
 					profile_id, term_date, period,
 					Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, 
 					Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20,
 					Hr21, Hr22, Hr23, Hr24, Hr25
 				)
 				SELECT 
 					t1.profile_id, t1.term_date, t1.period,
 					t1.Hr1, t1.Hr2, t1.Hr3, t1.Hr4, t1.Hr5, t1.Hr6, t1.Hr7, t1.Hr8, t1.Hr9, t1.Hr10,
 					t1.Hr11, t1.Hr12, t1.Hr13, t1.Hr14, t1.Hr15, t1.Hr16, t1.Hr17, t1.Hr18, t1.Hr19, t1.Hr20,
 					t1.Hr21, t1.Hr22, t1.Hr23, t1.Hr24, t1.Hr25
 				FROM #temp_profile_data_hour t1
 				LEFT JOIN deal_detail_hour ddh
 					ON t1.profile_id = ddh.profile_id
 					AND t1.term_date = ddh.term_date
 					AND ISNULL(t1.period, 0) = ISNULL(ddh.period, 0)
 				WHERE ddh.profile_id IS NULL

				DELETE ddh
				FROM  deal_detail_hour ddh
				INNER JOIN #temp_profile_data_hour t1
					ON t1.profile_id = ddh.profile_id
 					AND t1.term_date = ddh.term_date
 					AND ISNULL(t1.period, 0) = ISNULL(ddh.period, 0)
				WHERE ddh.Hr1 IS NULL AND ddh.Hr2 IS NULL AND ddh.Hr3 IS NULL AND ddh.Hr4 IS NULL AND ddh.Hr5 IS NULL
				AND ddh.Hr6 IS NULL AND ddh.Hr7 IS NULL AND ddh.Hr8 IS NULL AND ddh.Hr9 IS NULL AND ddh.Hr10 IS NULL
				AND ddh.Hr11 IS NULL AND ddh.Hr12 IS NULL AND ddh.Hr13 IS NULL AND ddh.Hr14 IS NULL AND ddh.Hr15 IS NULL 
				AND ddh.Hr16 IS NULL AND ddh.Hr17 IS NULL AND ddh.Hr18 IS NULL AND ddh.Hr19 IS NULL AND ddh.Hr20 IS NULL 
				AND ddh.Hr21 IS NULL AND ddh.Hr22 IS NULL AND ddh.Hr23 IS NULL AND ddh.Hr24 IS NULL AND ddh.Hr25 IS NULL

				IF @source_deal_detail_id IS NOT NULL
				BEGIN
					UPDATE sdd
					SET sdd.deal_volume = a.deal_volume
					FROM source_deal_header sdh
					INNER JOIN source_deal_detail sdd
						ON sdh.source_deal_header_id = sdd.source_deal_header_id
					OUTER APPLY (
						SELECT AVG(avg_vol) deal_volume
						FROM #temp_profile_data_hour
						UNPIVOT(
							avg_vol FOR [hour] IN (
								hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13,
								hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24)
						) unvpt
					) a
					WHERE sdd.source_deal_detail_id = @source_deal_detail_id
				END
 			END
		END
		COMMIT
 		EXEC spa_ErrorHandler 0
 			, 'mv90_data_hour'
 			, 'spa_update_profile_data'
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
 			, 'mv90_data_hour'
 			, 'spa_update_profile_data'
 			, 'Error'
 			, @DESC
 			, ''
	END CATCH
 	
END

IF @flag = 'p'
BEGIN
	IF @source_deal_detail_id IS NOT NULL AND @location_id IS NULL
	BEGIN
		SELECT ISNULL(sdd.profile_id, sml.profile_id) profile_id
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd 
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN source_minor_location sml 
			ON sml.source_minor_location_id = sdd.location_id
		WHERE sdd.source_deal_detail_id = @source_deal_detail_id
	END
	ELSE IF @profile_id IS NOT NULL
	BEGIN
		SELECT profile_id, external_id FROM forecast_profile WHERE profile_id = @profile_id
	END
	ELSE
	BEGIN
		SELECT ISNULL(profile_id, proxy_profile_id) [profile_id] FROM source_minor_location WHERE source_minor_location_id = @location_id
	END
END
