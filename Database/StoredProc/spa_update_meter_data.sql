
IF OBJECT_ID(N'[dbo].[spa_update_meter_data]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_update_meter_data]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_update_meter_data]
    @flag CHAR(1),
    @meter_id INT = NULL,
    @term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@channel VARCHAR(100) = NULL,
    @process_id VARCHAR(200) = NULL,    
	@xml XML = NULL
    
AS
SET NOCOUNT ON

/*
DECLARE @flag CHAR(1),
	@meter_id INT = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@channel VARCHAR(100) = NULL,
	@process_id VARCHAR(200) = NULL,    
	@xml XML = NULL


	 select @flag='a',@meter_id='4943',@term_start='2017-11-05',@term_end='2017-11-05',@hour_from=NULL,@hour_to=NULL,@channel='1',@process_id='49ACA0F5_3F32_42FA_9F25_D88C74566B26'
	--select @flag='t',@meter_id='4943',@term_start='2017-11-05',@term_end='2017-11-05',@channel='1',@hour_from=NULL,@hour_to=NULL
	--EXEC spa_update_meter_data  @flag='u',@xml='<GridXML><GridRow  col_meter="Mtr15m" col_meter_id="4943" col_channel="1" col_prod_date="11/5/2017" col_01_00="24" col_01_15="25" col_01_30="26" col_01_45="27" col_02_00="26" col_02_15="62" col_02_30="64" col_02_45="66" col_25_00="32" col_25_15="33" col_25_30="34" col_25_45="35" col_03_00="36" col_03_15="37" col_03_30="38" col_03_45="39" col_04_00="40" col_04_15="41" col_04_30="42" col_04_45="43" col_05_00="44" col_05_15="45" col_05_30="46" col_05_45="47" col_06_00="48" col_06_15="49" col_06_30="50" col_06_45="" col_07_00="" col_07_15="" col_07_30="" col_07_45="" col_08_00="" col_08_15="" col_08_30="" col_08_45="" col_09_00="" col_09_15="" col_09_30="" col_09_45="" col_10_00="" col_10_15="" col_10_30="" col_10_45="" col_11_00="" col_11_15="" col_11_30="" col_11_45="" col_12_00="" col_12_15="" col_12_30="" col_12_45="" col_13_00="" col_13_15="" col_13_30="" col_13_45="" col_14_00="" col_14_15="" col_14_30="" col_14_45="" col_15_00="" col_15_15="" col_15_30="" col_15_45="" col_16_00="" col_16_15="" col_16_30="" col_16_45="" col_17_00="" col_17_15="" col_17_30="" col_17_45="" col_18_00="" col_18_15="" col_18_30="" col_18_45="" col_19_00="" col_19_15="" col_19_30="" col_19_45="" col_20_00="" col_20_15="" col_20_30="" col_20_45="" col_21_00="" col_21_15="" col_21_30="" col_21_45="" col_22_00="" col_22_15="" col_22_30="" col_22_45="" col_23_00="" col_23_15="" col_23_30="" col_23_45="" col_24_00="" col_24_15="" col_24_30="" col_24_45=""></GridRow></GridXML>',@process_id='6EB258FE_CBC6_41DE_932F_2E27C694CF68'
	--select @flag='u',@xml='<GridXML><GridRow  col_meter="Mtr15m" col_meter_id="4943" col_channel="1" col_prod_date="11/5/2017" col_01_00="152" col_01_15="157" col_01_30="162" col_01_45="167" col_02_00="50" col_02_15="-70" col_02_30="-72" col_02_45="-74" col_25_00="32" col_25_15="33" col_25_30="34" col_25_45="35" col_03_00="36" col_03_15="37" col_03_30="38" col_03_45="39" col_04_00="40" col_04_15="41" col_04_30="42" col_04_45="43" col_05_00="44" col_05_15="45" col_05_30="46" col_05_45="47" col_06_00="48" col_06_15="49" col_06_30="50" col_06_45="" col_07_00="" col_07_15="" col_07_30="" col_07_45="" col_08_00="" col_08_15="" col_08_30="" col_08_45="" col_09_00="" col_09_15="" col_09_30="" col_09_45="" col_10_00="" col_10_15="" col_10_30="" col_10_45="" col_11_00="" col_11_15="" col_11_30="" col_11_45="" col_12_00="" col_12_15="" col_12_30="" col_12_45="" col_13_00="" col_13_15="" col_13_30="" col_13_45="" col_14_00="" col_14_15="" col_14_30="" col_14_45="" col_15_00="" col_15_15="" col_15_30="" col_15_45="" col_16_00="" col_16_15="" col_16_30="" col_16_45="" col_17_00="" col_17_15="" col_17_30="" col_17_45="" col_18_00="" col_18_15="" col_18_30="" col_18_45="" col_19_00="" col_19_15="" col_19_30="" col_19_45="" col_20_00="" col_20_15="" col_20_30="" col_20_45="" col_21_00="" col_21_15="" col_21_30="" col_21_45="" col_22_00="" col_22_15="" col_22_30="" col_22_45="" col_23_00="" col_23_15="" col_23_30="" col_23_45="" col_24_00="" col_24_15="" col_24_30="" col_24_45=""></GridRow></GridXML>',@process_id='899DC4BA_A1A1_435E_8A00_A3EA86A16759'
--*/

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
    SELECT mi.meter_id,
           mi.recorderid
    FROM   meter_id mi
    INNER JOIN recorder_properties rp ON rp.meter_id = mi.meter_id
    GROUP BY mi.meter_id, mi.recorderid
    ORDER BY mi.recorderid
    
    RETURN
END

IF @flag = 'y'
BEGIN
	SELECT rp.channel, ISNULL(rp.channel_description, rp.channel) [desc]
	FROM recorder_properties rp
	WHERE rp.meter_id = @meter_id
	GROUP BY rp.channel, ISNULL(rp.channel_description, rp.channel)
	
	RETURN
END

IF @flag = 'z'
BEGIN
	SELECT CASE WHEN mi.granularity IN (994,987,989,995,982) THEN 'y' ELSE 'n' END show_hours, granularity
	FROM meter_id mi 
	WHERE mi.meter_id = @meter_id
	
	RETURN
END

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID() 

DECLARE @user_name VARCHAR(100) = dbo.FNADBUser() 
DECLARE @process_table VARCHAR(400) = dbo.FNAProcessTableName('meter_data', @user_name, @process_id)
DECLARE @table_name VARCHAR(400)
DECLARE @dst_insert VARCHAR(MAX)

IF @flag = 'u'
BEGIN

	IF OBJECT_ID('tempdb..#temp_process_table_data') IS NOT NULL
		DROP TABLE #temp_process_table_data
	
	CREATE TABLE #temp_process_table_data (
		meter_id INT, term_start DATETIME, term_end DATETIME, channel INT
	)
	
	SET @sql = 'INSERT INTO #temp_process_table_data (meter_id, term_start, term_end, channel)
				SELECT meter_id,
				       MIN(prod_date),
				       MAX(prod_date),
				       channel
				FROM   ' + @process_table + '
				GROUP BY meter_id, channel'
	EXEC(@sql)
	
	SELECT TOP(1) 
		   @meter_id = meter_id,
	       @term_start     = term_start,
	       @term_end       = term_end
	FROM   #temp_process_table_data
	
	SELECT @channel = COALESCE(@channel + ',', '') + CAST(channel AS VARCHAR(20))
	FROM #temp_process_table_data
	
	IF @term_start IS NULL
	BEGIN
		IF OBJECT_ID('tempdb..#temp_process_table_columns') IS NOT NULL
			DROP TABLE #temp_process_table_columns
		
		CREATE TABLE #temp_process_table_columns(column_name VARCHAR(100) COLLATE DATABASE_DEFAULT , date_equiv DATETIME)
		
		SET @table_name = REPLACE(@process_table, 'adiha_process.dbo.', '')
		
		INSERT INTO #temp_process_table_columns(column_name)
		SELECT COLUMN_NAME
 		FROM adiha_process.INFORMATION_SCHEMA.COLUMNS
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
SELECT @granularity = mi.granularity
FROM meter_id mi WHERE mi.meter_id = @meter_id

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

IF OBJECT_ID('tempdb..#temp_meter_data_terms') IS NOT NULL
	DROP TABLE #temp_meter_data_terms
 
CREATE TABLE #temp_meter_data_terms (term_start DATETIME, is_dst INT)
 
;WITH cte_meter_terms AS (
	SELECT @term_start [term_start]
	UNION ALL
	SELECT dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1)
	FROM cte_meter_terms cte 
	WHERE dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1) <= @term_end
) 
INSERT INTO #temp_meter_data_terms(term_start)
SELECT term_start
FROM cte_meter_terms cte
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

	INSERT INTO #temp_dst_date select temp.term_start, mv.insert_delete, mv.hour from #temp_meter_data_terms temp INNER JOIN mv90_DST mv 
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

	SELECT clm_name, is_dst, alias_name, CAST(CASE WHEN is_dst = 0 THEN RIGHT('0' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '_' + RIGHT(clm_name, 2) ELSE '25' + '_' + RIGHT(clm_name, 2) END AS VARCHAR(100))  [process_clm_name]
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

	IF OBJECT_ID('tempdb..#temp_meter_data_dump') IS NOT NULL 
 		DROP TABLE #temp_meter_data_dump
 	
	CREATE TABLE #temp_meter_data_dump(
		id                        INT IDENTITY(1, 1),
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
		
	IF @granularity IN (982, 989, 994, 995, 987)
	BEGIN
 		ALTER TABLE #temp_meter_data_dump
 		ADD	
 			Hr1 FLOAT, Hr2 FLOAT, Hr3 FLOAT, Hr4 FLOAT, Hr5 FLOAT, Hr6 FLOAT, Hr7 FLOAT, Hr8 FLOAT, Hr9 FLOAT, Hr10 FLOAT,
 			Hr11 FLOAT, Hr12 FLOAT, Hr13 FLOAT, Hr14 FLOAT, Hr15 FLOAT, Hr16 FLOAT, Hr17 FLOAT, Hr18 FLOAT, Hr19 FLOAT, Hr20 FLOAT,
 			Hr21 FLOAT, Hr22 FLOAT, Hr23 FLOAT, Hr24 FLOAT, Hr25 FLOAT
	END
	ELSE
	BEGIN
 		ALTER TABLE #temp_meter_data_dump ADD volume FLOAT
	END
	

	INSERT INTO #temp_meter_data_dump (
 		meter_id, meter, channel, gen_date, from_date, to_date, prod_date, period
	)	
	SELECT  mi.meter_id,
 			mi.recorderid,
 			ch.channel,
 			dbo.FNAGetFirstLastDayOfMonth(t2.term_start, 'f'),
 			dbo.FNAGetFirstLastDayOfMonth(t2.term_start, 'f'),
 			dbo.FNAGetFirstLastDayOfMonth(t2.term_start, 'l'),
 			t2.term_start,
 			t3.period
	FROM meter_id mi
	OUTER APPLY (SELECT * FROM #temp_meter_data_terms) t2
	OUTER APPLY (SELECT item [channel] FROM dbo.SplitCommaSeperatedValues(@channel) scsv) ch
	LEFT JOIN #temp_min_break t3 ON t3.granularity = @granularity
	WHERE mi.meter_id = @meter_id


	IF @granularity IN (982, 989, 994, 995, 987)
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
 		FROM #temp_meter_data_dump t1
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
 		FROM #temp_meter_data_dump t1
 		INNER JOIN mv90_data md 
 			ON md.meter_id = t1.meter_id
 			AND md.channel = t1.channel
 		INNER JOIN mv90_data_hour mdh 
 			ON mdh.meter_data_id = md.meter_data_id
 			AND mdh.prod_date = t1.prod_date
 			AND ISNULL(mdh.period, 0) = ISNULL(t1.period, 0)
	END
	
	CREATE NONCLUSTERED INDEX NCI_TMDD_METER_ID ON #temp_meter_data_dump (meter_id)
	CREATE NONCLUSTERED INDEX NCI_TMDD_PROD ON #temp_meter_data_dump (prod_date)
	
	IF @granularity IN (982, 989, 987, 994, 995)
	BEGIN

		SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + process_clm_name + ']',
 				@pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + process_clm_name + '] FLOAT NULL',
 				@pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + process_clm_name + '] = a.[' + process_clm_name + ']',
 				@pivot_select = COALESCE(@pivot_select + ',', '') + 'Hr' + CAST(CAST(LEFT(process_clm_name,2) AS INT) AS VARCHAR) +' AS [' + process_clm_name + ']'
 		FROM #temp_hour_breakdown 

 		-- for hourly
 		SET @pivot_select = 'meter_id, meter, channel, gen_date, from_date, to_date, prod_date, '+ @pivot_select
 		
 		SELECT granularity, period, 'a_' + CAST(period AS VARCHAR(10)) [alias]
 		INTO #temp_min_break2
 		FROM #temp_min_break		
 		WHERE granularity = @granularity
 		
 		DECLARE @sql_string VARCHAR(MAX)
 		SELECT @sql_string = COALESCE(@sql_string + CHAR(13)+CHAR(10), '') + ' INNER JOIN ( SELECT Hr1 AS [01_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr2 AS [02_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr3 AS [03_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr4 AS [04_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr5 AS [05_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr6 AS [06_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr7 AS [07_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr8 AS [08_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr9 AS [09_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr10 AS [10_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr11 AS [11_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr12 AS [12_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr13 AS [13_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr14 AS [14_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr15 AS [15_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr16 AS [16_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr17 AS [17_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr18 AS [18_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr19 AS [19_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr20 AS [20_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr21 AS [21_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr22 AS [22_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr23 AS [23_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr24 AS [24_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '],Hr25 AS [25_' + RIGHT(ISNULL('0' + CAST(period AS VARCHAR(10)), '00'), 2) + '], meter_id, meter, prod_date, channel FROM #temp_meter_data_dump temp
 							WHERE period = ' + CAST(period AS VARCHAR(10)) + ' ) ' + tm.alias + ' ON ' + tm.alias + '.meter_id = a.meter_id AND ' + tm.alias + '.prod_date = a.prod_date AND ' + tm.alias + '.channel = a.channel'
 		FROM #temp_min_break2 tm 
 		
 		SET @sql = '
 			CREATE TABLE ' + @process_table + '(
 				id                        INT IDENTITY(1, 1),
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
 		
 		IF @sql_string IS NULL -- hourly
 		BEGIN
 			SET @sql += '
 				SELECT ' + @pivot_select + '
 				FROM #temp_meter_data_dump		
 			'
 		END
 		ELSE
 		BEGIN
 			SET @sql += '
 						SELECT  a.meter_id,
 								a.meter,
 								a.channel,
 								a.gen_date,
 								a.from_date,
 								a.to_date,
 								a.prod_date,
 								' + @pivot_columns + '
 						FROM (
 							SELECT meter_id, meter, channel, gen_date, from_date, to_date, prod_date 
 							FROM #temp_meter_data_dump
 							GROUP BY meter_id, meter, channel, gen_date, from_date, to_date, prod_date 
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
 
 		SET @column_list = 'meter,meter_id,channel,prod_date,' + @column_list
 		SET @column_label = 'Meter,ID,Channel,Date,' + @column_label
 		SET @column_type = 'ro,ro,ro,ro_dhxCalendarA,' + @column_type
		SET @data_type = ',,,,' + @data_type
 		SET @column_width = '150,10,80,100,' + @column_width
 		SET @column_visibility = 'false,true,false,false,' + @column_visibility
	END
	ELSE
	BEGIN
 		SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + ']',
 				@pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] FLOAT NULL',
 				@pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + CONVERT(VARCHAR(8), term_start, 112) + '] = a.[' + CONVERT(VARCHAR(8), term_start, 112) + ']'
 		FROM #temp_meter_data_terms
 		ORDER BY term_start	
 				
 		SET @sql = '
 			CREATE TABLE ' + @process_table + '(
 				id                        INT IDENTITY(1, 1),
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
 				meter_id,
 				meter,
 				channel,
 				gen_date,
 				from_date,
 				to_date,
 				' + @pivot_columns + '
 			)			
 			SELECT meter_id, meter, channel, gen_date, from_date, to_date, ' + @pivot_columns + '
 			FROM (
 				SELECT meter_id, meter, channel, gen_date, from_date, to_date, CONVERT(VARCHAR(8), temp.prod_date, 112) term_date_p, volume
 				FROM #temp_meter_data_dump temp 
 			) a			
 			PIVOT (SUM(volume) FOR term_date_p IN (' + @pivot_columns + ') )unpvt
 		'
 		
 		SELECT @column_list = COALESCE(@column_list + ',', '') + CONVERT(VARCHAR(8), term_start, 112),
 				@column_label = COALESCE(@column_label + ',', '') + dbo.FNADateFormat(term_start),
 				@column_type = COALESCE(@column_type + ',', '') + 'ed_no',
				@data_type = COALESCE(@data_type + ',', '') + 'float',
 				@column_width = COALESCE(@column_width + ',', '') + '150',
 				@column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
 		FROM #temp_meter_data_terms		
 		WHERE term_start <= @term_end
 
 		SET @column_list = 'meter,meter_id,channel,' + @column_list
 		SET @column_label = 'Meter,ID,Channel,' + @column_label
 		SET @column_type = 'ro,ro,ro,' + @column_type
		SET @data_type = ',,,' + @data_type
 		SET @column_width = '150,10,80,' + @column_width
 		SET @column_visibility = 'false,true,false,' + @column_visibility
	END
	

	EXEC(@sql)	
	
	SELECT @column_list [column_list],
	       @column_label [column_label],
	       @column_type [column_type],
		   @data_type [data_type],
	       @column_width [column_width],
	       @term_start [term_start],
	       @term_end [term_end],
	       @granularity [granularity],
	       @column_visibility [visibility],
	       @process_id [process_id]
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

 
 		SET @column_list = 'meter,meter_id,channel,prod_date,' + @column_list
 		SET @column_label = 'Meter,ID,Channel,Date,' + @column_label
 		SET @column_type = 'ro,ro,ro,ro_dhxCalendarA,' + @column_type
 		SET @column_width = '150,10,80,100,' + @column_width
 		SET @column_visibility = 'false,true,false,false,' + @column_visibility
	END
	ELSE
	BEGIN
 		SELECT @column_list = COALESCE(@column_list + ',', '') + CONVERT(VARCHAR(8), term_start, 112),
 				@column_label = COALESCE(@column_label + ',', '') + dbo.FNADateFormat(term_start),
 				@column_type = COALESCE(@column_type + ',', '') + 'ed_no',
 				@column_width = COALESCE(@column_width + ',', '') + '150',
 				@column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
 		FROM #temp_meter_data_terms		
 		WHERE term_start <= @term_end
 
 		SET @column_list = 'meter,meter_id,channel,' + @column_list
 		SET @column_label = 'Meter,ID,Channel,' + @column_label
 		SET @column_type = 'ro,ro,ro,' + @column_type
 		SET @column_width = '150,10,80,' + @column_width
 		SET @column_visibility = 'false,true,false,' + @column_visibility
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
		UPDATE t SET t.process_clm_name =  'ISNULL([' + nd.process_clm_name + '],0)' + '-' + 'ISNULL(['+ d.process_clm_name + '],0)'
		FROM #temp_hour_breakdown t
		INNER JOIN 
		(
		SELECT * FROM 
		#temp_hour_breakdown
		WHERE is_dst = 0) nd
		ON t.clm_name = nd.clm_name
		INNER JOIN 
		(
		SELECT * FROM 
		#temp_hour_breakdown
		WHERE is_dst = 1) d

		ON nd.clm_name = d.clm_name
		WHERE t.is_dst = 0


			
	
		SELECT @column_list = COALESCE(@column_list + ',', '') + CASE WHEN LEN(process_clm_name)>5 THEN 'NULLIF(ABS(' + process_clm_name + '),0)' ELSE '[' + process_clm_name + ']' 
		END  + CASE WHEN LEN(process_clm_name)> 7 THEN LEFT(REPLACE(process_clm_name,'ISNULL(',''), 7) ELSE  '[' + process_clm_name + ']'  END     
 		FROM  #temp_hour_breakdown

		
 		SET @column_list = 'meter,meter_id,channel,prod_date,' + @column_list
	END
	ELSE
	BEGIN
 		SELECT @column_list = COALESCE(@column_list + ',', '') + 'MAX([' + CONVERT(VARCHAR(8), term_start, 112) + ']) [' + CONVERT(VARCHAR(8), term_start, 112) + ']'
 		FROM #temp_meter_data_terms
 		WHERE term_start <= @term_end
 		SET @column_list = 'MAX(meter) meter, MAX(meter_id) meter_id, MAX(channel) channel,' + @column_list
	END
 
	
	SET @sql = 'SELECT ' + @column_list + ' FROM ' + @process_table + ' a '
	
	IF @channel IS NOT NULL
		SET @sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @channel + ''') scsv ON scsv.item = a.channel '
		
	SET @sql += ' WHERE 1 = 1'
	
	SET @sql += ' AND a.meter_id = ' + CAST(@meter_id AS VARCHAR(20))
	
	IF @granularity IN (982, 989, 987, 994, 995)
		SET @sql += ' AND a.prod_date >= ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''' AND a.prod_date <= ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''''
	
	IF @granularity IN (982, 989, 987, 994, 995)
		SET @sql += ' ORDER BY a.prod_date'
	

	EXEC(@sql)
	RETURN
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
		--BEGIN TRAN
		
 		IF @xml IS NOT NULL
		BEGIN
			DECLARE @xml_process_table VARCHAR(200)
			SET @xml_process_table = dbo.FNAProcessTableName('xml_table', @user_name, dbo.FNAGetNewID())
		  
			EXEC spa_parse_xml_file 'b', NULL, @xml, @xml_process_table
			DECLARE @dst_hr VARCHAR(10)
			SELECT TOP 1 @dst_hr=CAST(CAST(LEFT(clm_name,2) AS INT) +1  AS VARCHAR) FROM #temp_hour_breakdown WHERE is_dst = 1
		
			IF OBJECT_ID('tempdb..#temp_xml_table_columns') IS NOT NULL
				DROP TABLE #temp_xml_table_columns
		
			CREATE TABLE #temp_xml_table_columns(column_name VARCHAR(100) COLLATE DATABASE_DEFAULT )
		
			SET @table_name = REPLACE(@xml_process_table, 'adiha_process.dbo.', '')
		
			INSERT INTO #temp_xml_table_columns(column_name)
			SELECT COLUMN_NAME
 			FROM adiha_process.INFORMATION_SCHEMA.COLUMNS
 			WHERE TABLE_NAME = @table_name
						
 			IF OBJECT_ID('tempdb..#temp_changed_meter_data') IS NOT NULL
 				DROP TABLE #temp_changed_meter_data
			IF OBJECT_ID('tempdb..#temp_meter_data1') IS NOT NULL
 				DROP TABLE #temp_meter_data1
 
 			CREATE TABLE #temp_changed_meter_data(
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
 				
 				SET @select_statement = 'SELECT col_meter_id, col_channel, col_prod_date, NULLIF(volume, ''0'') [volume], REPLACE(hrs, ''_'', '':'') hr, 0'
 				SET @select_statement2 = 'SELECT col_meter_id, col_channel, col_prod_date, ' + @select_list
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
 					SET @hidden_select_statement2 = 'SELECT meter_id, channel, prod_date, ' + @hidden_select_list
 					SET @for_statement = 'hrs'
 				
 					SET @sql = '
 						INSERT INTO #temp_changed_meter_data(meter_id, channel, prod_date, volume, [hr], is_dst)
 						SELECT meter_id, channel, prod_date, NULLIF(volume, 0) [volume], REPLACE(hrs, ''_'', '':'') hr, 0
 						FROM ( ' + 
 							@hidden_select_statement2 + ' 
 							FROM (SELECT MIN(col_prod_date) term_start, MAX(col_prod_date) term_end FROM ' + @xml_process_table + ') term
 							OUTER APPLY (
 								SELECT * FROM ' + @process_table + ' 
 								WHERE prod_date >= term.term_start AND prod_date <= term.term_end
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
 						@select_list = COALESCE(@select_list + ',', '') + 'ISNULL(CAST([col_' + CONVERT(VARCHAR(8), term_start, 112) + '] AS FLOAT), 0) [' + CONVERT(VARCHAR(8), term_start, 112) + ']'
 				FROM #temp_meter_data_terms tat
 
 				SET @select_statement = 'SELECT col_meter_id, col_channel, CONVERT(DATETIME, term_date2, 120) prod_date, NULLIF(volume, 0) [volume], NULL hr, 0'
 				SET @select_statement2 = 'SELECT col_meter_id, col_channel, ' + @select_list
 				SET @for_statement = 'term_date2'
 			END
			
			SET @sql = '
 					INSERT INTO #temp_changed_meter_data(meter_id, channel, prod_date, volume, [hr], is_dst)
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
 			--PRINT(@sql)
 			EXEC(@sql)

 			IF OBJECT_ID('tempdb..#temp_meter_data_hour') IS NOT NULL
 				DROP TABLE #temp_meter_data_hour
 				
 			CREATE TABLE #temp_meter_data_hour (
 				meter_id INT,
 				channel INT,
 				prod_date DATETIME, period INT, meter_data_id INT,
 				Hr1 FLOAT, Hr2 FLOAT, Hr3 FLOAT, Hr4 FLOAT, Hr5 FLOAT, Hr6 FLOAT, Hr7 FLOAT, Hr8 FLOAT, Hr9 FLOAT, Hr10 FLOAT,
 				Hr11 FLOAT, Hr12 FLOAT, Hr13 FLOAT, Hr14 FLOAT, Hr15 FLOAT, Hr16 FLOAT, Hr17 FLOAT, Hr18 FLOAT, Hr19 FLOAT, Hr20 FLOAT,
 				Hr21 FLOAT, Hr22 FLOAT, Hr23 FLOAT, Hr24 FLOAT, Hr25 FLOAT		
 			)
 			
 			IF @granularity IN (982, 989, 987, 994, 995)
 			BEGIN 			
 				INSERT INTO #temp_meter_data_hour(
 					meter_id, channel, prod_date, period,
 					Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25
 				)	
 				SELECT meter_id, channel, prod_date, period, [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25]
				FROM
				(
					SELECT t1.meter_id, t1.channel, t1.prod_date, t1.volume, CAST(LEFT(t1.hr, 2) AS INT) [hour], t2.period
 					FROM #temp_changed_meter_data t1
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
				

				UPDATE #temp_meter_data_hour SET Hr25 = NULL WHERE prod_date NOT IN (SELECT dst_date FROM #temp_dst_date WHERE insert_delete = 'i')
				--select * from #temp_meter_data_hour
				
				
				 DECLARE @update_column VARCHAR(30 )
				 SELECT @update_column = COALESCE(@update_column + ',', '') + 'Hr'+CAST(tdd.dst_hour AS VARCHAR(20)) + '= NULL' FROM #temp_dst_date tdd WHERE 
				 tdd.insert_delete = 'd'

				 
				 IF(@update_column IS NOT NULL)
				 EXEC('
					update tmdh 
					set ' + @update_column + ' 
					from #temp_meter_data_hour tmdh 
					inner join #temp_dst_date tdd 
						on tmdh.prod_date = tdd.dst_date
					where tdd.insert_delete = ''d''
				')

 					
 			END
 			ELSE
 			BEGIN
 				INSERT INTO #temp_meter_data_hour(
 					meter_id, channel, prod_date, period, Hr1
 				)	
 				SELECT t1.meter_id, t1.channel, t1.prod_date, NULL, t1.volume
 				FROM #temp_changed_meter_data t1
 				--WHERE t1.volume IS NOT NULL
 			END

 			IF OBJECT_ID('tempdb..#temp_inserted_updated_deal_meter') IS NOT NULL
 				DROP TABLE #temp_inserted_updated_deal_meter
 			CREATE TABLE #temp_inserted_updated_deal_meter(meter_data_id INT, meter_id INT, channel INT, from_date DATETIME)
 			
 			IF EXISTS(SELECT 1 FROM #temp_meter_data_hour)
 			BEGIN
 				IF OBJECT_ID('tempdb..#temp_meter_data') IS NOT NULL
 					DROP TABLE #temp_meter_data
 				
 				CREATE TABLE #temp_meter_data (meter_data_id INT, meter_id INT, channel INT, from_date DATETIME, to_date DATETIME)
 				
 				INSERT INTO #temp_meter_data (meter_id, channel, from_date, to_date)
 				SELECT meter_id, channel, MIN(prod_date) from_date, dbo.FNAGetTermEndDate(@frequency, MAX(prod_date), 0) to_date
 				FROM #temp_meter_data_hour
 				GROUP BY meter_id, channel
 				
 				IF EXISTS(
 					SELECT 1
 					FROM #temp_meter_data t1
 					INNER JOIN mv90_data md
 						ON md.meter_id = t1.meter_id
 						AND md.channel = t1.channel
 						AND ISNULL(md.granularity, @granularity) <> @granularity
 				) 
 				BEGIN
 					DELETE mdh
 					FROM mv90_data_hour mdh
 					INNER JOIN mv90_data md ON md.meter_data_id = mdh.meter_data_id
 					INNER JOIN #temp_meter_data_hour t1
 						ON md.meter_id = t1.meter_id
 						AND md.channel = t1.channel
						AND mdh.[prod_date] = t1.[prod_date]
 						AND ISNULL(md.granularity, @granularity) <> @granularity
 					
 					DELETE md
 					FROM #temp_meter_data t1
 					INNER JOIN mv90_data md
 						ON md.meter_id = t1.meter_id
 						AND md.channel = t1.channel
 						AND ISNULL(md.granularity, @granularity) <> @granularity
						AND [dbo].[FNAgetcontractmonth](md.[from_date]) = [dbo].[FNAgetcontractmonth](t1.[from_date])
 				END

				SELECT MAX(md.meter_data_id) meter_data_id INTO
				#temp_meter_data1
				FROM #temp_meter_data_hour t1
 				INNER JOIN mv90_data md 
 					ON md.meter_id = t1.meter_id
 					AND md.channel = t1.channel
 					AND md.granularity = @granularity
					AND md.[from_date] = CONVERT(VARCHAR(7),t1.[prod_date],120)+'-01'
				GROUP BY t1.meter_id,t1.channel,CONVERT(VARCHAR(7),t1.[prod_date],120)+'-01',DATEADD(MONTH,1,CONVERT(VARCHAR(7),t1.[prod_date],120)+'-01')-1

				UPDATE md
 				SET granularity = @granularity
 				OUTPUT INSERTED.meter_data_id, INSERTED.meter_id, INSERTED.channel, INSERTED.from_date INTO #temp_inserted_updated_deal_meter(meter_data_id, meter_id, channel, from_date)
				FROM #temp_meter_data1 t1
 				INNER JOIN mv90_data md 
 					ON md.meter_data_id = t1.meter_data_id
 				
 				--UPDATE md
 				--SET gen_date = CASE WHEN md.gen_date <= t1.from_date THEN md.gen_date ELSE t1.from_date END,
 				--	from_date = CASE WHEN md.from_date <= t1.from_date THEN md.from_date ELSE t1.from_date END,
 				--	to_date = CASE WHEN md.to_date >= t1.to_date THEN md.to_date ELSE t1.to_date END,
 				--	granularity = @granularity
 				--OUTPUT INSERTED.meter_data_id, INSERTED.meter_id, INSERTED.channel, INSERTED.from_date INTO #temp_inserted_updated_deal_meter(meter_data_id, meter_id, channel, from_date)
 				--FROM #temp_meter_data t1
 				--INNER JOIN mv90_data md
 				--	ON md.meter_id = t1.meter_id
 				--	AND md.channel = t1.channel
 				--	AND md.granularity = @granularity
 				
 				INSERT INTO mv90_data (meter_id, gen_date, from_date, to_date, channel, granularity)
 				OUTPUT INSERTED.meter_data_id, INSERTED.meter_id, INSERTED.channel, INSERTED.from_date INTO #temp_inserted_updated_deal_meter(meter_data_id, meter_id, channel, from_date)
 				SELECT t1.meter_id, 
					   CONVERT(VARCHAR(7),t1.[prod_date],120)+'-01',
 					   CONVERT(VARCHAR(7),t1.[prod_date],120)+'-01',
 					   DATEADD(MONTH,1,CONVERT(VARCHAR(7),t1.[prod_date],120)+'-01')-1,
					   t1.channel, 
					   @granularity
 				FROM #temp_meter_data_hour t1
 				LEFT JOIN mv90_data md 
 					ON md.meter_id = t1.meter_id
 					AND md.channel = t1.channel
 					AND md.granularity = @granularity
					AND md.[from_date] = CONVERT(VARCHAR(7),t1.[prod_date],120)+'-01'
 				WHERE md.meter_data_id IS NULL
				GROUP BY t1.meter_id,t1.channel,CONVERT(VARCHAR(7),t1.[prod_date],120)+'-01',DATEADD(MONTH,1,CONVERT(VARCHAR(7),t1.[prod_date],120)+'-01')-1	
 								
 				UPDATE t1
 				SET meter_data_id = t2.meter_data_id
 				FROM #temp_meter_data_hour t1
 				INNER JOIN #temp_inserted_updated_deal_meter t2 
				ON t2.meter_id = t1.meter_id 
					AND t2.[from_date] = CONVERT(VARCHAR(7),t1.[prod_date],120)+'-01' 
					AND t2.channel = t1.channel 
 				
				IF @dst_hr IS NOT NULL
					EXEC('update  #temp_meter_data_hour set Hr' +@dst_hr+ '= ISNULL(Hr'+@dst_hr + ',0)+' +'ISNULL(Hr25,0)')
 				
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
 				INNER JOIN #temp_meter_data_hour t1 
 					ON t1.meter_data_id = mvd.meter_data_id
 					AND t1.prod_date = mvd.prod_date
 					AND ISNULL(t1.period, 0) = ISNULL(mvd.period, 0)
				INNER JOIN [mv90_data] md ON md.[meter_id] = t1.[meter_id] AND md.[from_date] = CONVERT(VARCHAR(7),t1.[prod_date],120)+'-01'
 	
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
 				FROM #temp_meter_data_hour t1
 				LEFT JOIN mv90_data_hour mvd
 					ON t1.meter_data_id = mvd.meter_data_id
 					AND t1.prod_date = mvd.prod_date
 					AND ISNULL(t1.period, 0) = ISNULL(mvd.period, 0)
 				WHERE mvd.recid IS NULL

				IF OBJECT_ID('tempdb..#temp_deleted_mvdh') IS NOT NULL
					DROP TABLE #temp_deleted_mvdh
				CREATE TABLE #temp_deleted_mvdh (
					meter_data_id INT
				)

				DELETE mvdh
				OUTPUT DELETED.meter_data_id INTO #temp_deleted_mvdh(meter_data_id)
				FROM   mv90_data_hour mvdh
				INNER JOIN #temp_meter_data_hour t1
					ON  t1.meter_data_id = mvdh.meter_data_id
					AND t1.prod_date = mvdh.prod_date
					AND ISNULL(t1.period, 0) = ISNULL(mvdh.period, 0)
				WHERE mvdh.Hr1 IS NULL AND mvdh.Hr2 IS NULL AND mvdh.Hr3 IS NULL AND mvdh.Hr4 IS NULL AND mvdh.Hr5 IS NULL
				AND mvdh.Hr6 IS NULL AND mvdh.Hr7 IS NULL AND mvdh.Hr8 IS NULL AND mvdh.Hr9 IS NULL AND mvdh.Hr10 IS NULL
				AND mvdh.Hr11 IS NULL AND mvdh.Hr12 IS NULL AND mvdh.Hr13 IS NULL AND mvdh.Hr14 IS NULL AND mvdh.Hr15 IS NULL 
				AND mvdh.Hr16 IS NULL AND mvdh.Hr17 IS NULL AND mvdh.Hr18 IS NULL AND mvdh.Hr19 IS NULL AND mvdh.Hr20 IS NULL 
				AND mvdh.Hr21 IS NULL AND mvdh.Hr22 IS NULL AND mvdh.Hr23 IS NULL AND mvdh.Hr24 IS NULL AND mvdh.Hr25 IS NULL

				DELETE md
				FROM mv90_data md
				INNER JOIN #temp_deleted_mvdh t1 ON t1.meter_data_id = md.meter_data_id
				LEFT JOIN mv90_data_hour mdh ON mdh.meter_data_id = md.meter_data_id
				WHERE mdh.recid IS NULL

				EXEC('UPDATE mv SET mv.volume = mdv.vol_sum  
 					  FROM
 						(
 							SELECT SUM(ISNULL(mdh.Hr1,0) + ISNULL(mdh.Hr2,0) + ISNULL(mdh.Hr3,0) + ISNULL(mdh.Hr4,0) + ISNULL(mdh.Hr5,0) + ISNULL(mdh.Hr6,0) + 
 								ISNULL(mdh.Hr7,0) + ISNULL(mdh.Hr8,0) + ISNULL(mdh.Hr9,0) + ISNULL(mdh.Hr10,0) + ISNULL(mdh.Hr11,0) + ISNULL(mdh.Hr12,0) + ISNULL(mdh.Hr13,0) + ISNULL(mdh.Hr14,0) + ISNULL(mdh.Hr15,0) + 
 								ISNULL(mdh.Hr16,0) + ISNULL(mdh.Hr17,0) + ISNULL(mdh.Hr18,0) + ISNULL(mdh.Hr19,0) + ISNULL(mdh.Hr20,0) + ISNULL(mdh.Hr21,0) + ISNULL(mdh.Hr22,0) + 
 								ISNULL(mdh.Hr23,0) + ISNULL(mdh.Hr24,0) ) vol_sum, meter_data_id
 							FROM mv90_data_hour mdh GROUP BY mdh.meter_data_id
 						) mdv
 						INNER JOIN mv90_data mv ON mv.meter_data_id = mdv.meter_data_id
 						INNER JOIN #temp_inserted_updated_deal_meter t ON t.meter_id = mv.meter_id
 			   ')

 			END
		END
		--COMMIT
 		EXEC spa_ErrorHandler 0
 			, 'mv90_data_hour'
 			, 'spa_update_meter_data'
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
 			, 'spa_update_meter_data'
 			, 'Error'
 			, @DESC
 			, ''
	END CATCH
 	
END
